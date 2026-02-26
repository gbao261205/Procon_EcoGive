package ecogive.dao;

import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class TransactionDAO {

    public Transaction findById(long id) throws SQLException {
        String sql = "SELECT * FROM transactions WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return null;
    }
    
    public Transaction findActiveTransaction(long itemId, long receiverId) throws SQLException {
        String sql = "SELECT * FROM transactions WHERE item_id = ? AND receiver_id = ? " +
                     "AND status IN ('PENDING', 'CONFIRMED', 'PENDING_TRADE', 'TRADE_ACCEPTED', 'CONFIRMED_BY_A', 'CONFIRMED_BY_B') " +
                     "ORDER BY transaction_id DESC LIMIT 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, itemId);
            stmt.setLong(2, receiverId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return null;
    }

    public Transaction findActiveTradeTransactionByParties(long itemId, long user1Id, long user2Id) throws SQLException {
        String sql = "SELECT * FROM transactions WHERE item_id = ? " +
                     "AND (receiver_id = ? OR receiver_id = ?) " +
                     "AND transaction_type = 'TRADE' " +
                     "AND status IN ('PENDING_TRADE', 'TRADE_ACCEPTED', 'CONFIRMED_BY_A', 'CONFIRMED_BY_B') " +
                     "ORDER BY transaction_id DESC LIMIT 1";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, itemId);
            stmt.setLong(2, user1Id);
            stmt.setLong(3, user2Id);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return mapRow(rs);
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return null;
    }

    public boolean updateStatus(long transactionId, TransactionStatus status) throws SQLException {
        String sql = "UPDATE transactions SET status = ? WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setLong(2, transactionId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean confirmByGiver(long transactionId) throws SQLException {
        String sql = "UPDATE transactions SET status = 'CONFIRMED', giver_confirmed_date = NOW() WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, transactionId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean confirmByReceiver(long transactionId) throws SQLException {
        String sql = "UPDATE transactions SET status = 'COMPLETED' WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, transactionId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean cancelTransaction(long transactionId) throws SQLException {
        String sql = "UPDATE transactions SET status = 'CANCELED' WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, transactionId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean checkExists(long itemId, long receiverId) throws SQLException {
        String sql = "SELECT 1 FROM transactions WHERE item_id = ? AND receiver_id = ? AND status NOT IN ('COMPLETED', 'CANCELED')";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, itemId);
            stmt.setLong(2, receiverId);
            try (ResultSet rs = stmt.executeQuery()) {
                return rs.next();
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private Transaction mapRow(ResultSet rs) throws SQLException {
        Transaction t = new Transaction();
        t.setTransactionId(rs.getInt("transaction_id"));
        t.setItemId(rs.getLong("item_id"));
        t.setReceiverId(rs.getLong("receiver_id"));
        t.setExchangeDate(rs.getTimestamp("exchange_date").toLocalDateTime());
        t.setStatus(TransactionStatus.valueOf(rs.getString("status")));
        
        t.setTransactionType(rs.getString("transaction_type"));
        long offerId = rs.getLong("offer_item_id");
        if (!rs.wasNull()) {
            t.setOfferItemId(offerId);
        }
        
        try {
            Timestamp ts = rs.getTimestamp("giver_confirmed_date");
            if (ts != null) {
                t.setGiverConfirmedDate(ts.toLocalDateTime());
            }
        } catch (SQLException e) {
            // Ignore
        }
        return t;
    }

    public boolean insert(Transaction transaction) throws SQLException {
        String sql = "INSERT INTO transactions (item_id, receiver_id, status, exchange_date, transaction_type, offer_item_id) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, transaction.getItemId());
            stmt.setLong(2, transaction.getReceiverId());
            stmt.setString(3, transaction.getStatus().name());
            stmt.setTimestamp(4, Timestamp.valueOf(transaction.getExchangeDate()));
            
            stmt.setString(5, transaction.getTransactionType() != null ? transaction.getTransactionType() : "GIVE");
            if (transaction.getOfferItemId() != null) {
                stmt.setLong(6, transaction.getOfferItemId());
            } else {
                stmt.setNull(6, Types.BIGINT);
            }

            int affectedRows = stmt.executeUpdate();
            if (affectedRows > 0) {
                try (ResultSet generatedKeys = stmt.getGeneratedKeys()) {
                    if (generatedKeys.next()) {
                        transaction.setTransactionId(generatedKeys.getInt(1));
                    }
                }
                return true;
            }
            return false;
        } catch (Exception e) {
            throw new SQLException("Lỗi khi chèn giao dịch mới: " + e.getMessage(), e);
        }
    }

    public boolean createInitialTransaction(long itemId, long receiverId) throws SQLException {
        Transaction trans = findActiveTransaction(itemId, receiverId);
        if (trans != null) {
            return confirmByGiver(trans.getTransactionId());
        }
        return false;
    }

    public List<Transaction> findOtherPendingRequests(long itemId, long acceptedReceiverId) throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        String sql = "SELECT * FROM transactions WHERE item_id = ? AND receiver_id != ? AND status IN ('PENDING', 'PENDING_TRADE')";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, itemId);
            stmt.setLong(2, acceptedReceiverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            throw new SQLException("Error finding other pending requests: " + e.getMessage(), e);
        }
        return transactions;
    }

    public void cancelOtherTransactions(long itemId, long acceptedTransactionId) throws SQLException {
        String sql = "UPDATE transactions SET status = 'CANCELED' WHERE item_id = ? AND transaction_id != ? AND status IN ('PENDING', 'PENDING_TRADE')";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, itemId);
            stmt.setLong(2, acceptedTransactionId);
            stmt.executeUpdate();
        } catch (Exception e) {
            throw new SQLException("Error canceling other transactions: " + e.getMessage(), e);
        }
    }
    
    public List<Transaction> findOverdueConfirmedTransactions(int days) throws SQLException {
        List<Transaction> transactions = new ArrayList<>();
        // Find 'GIVE' transactions that were confirmed by the giver more than 'days' ago but are not yet completed.
        String sql = "SELECT * FROM transactions " +
                     "WHERE status = 'CONFIRMED' " +
                     "AND transaction_type = 'GIVE' " +
                     "AND giver_confirmed_date < NOW() - INTERVAL ? DAY";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, days);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    transactions.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            throw new SQLException("Error finding overdue confirmed transactions: " + e.getMessage(), e);
        }
        return transactions;
    }
}
