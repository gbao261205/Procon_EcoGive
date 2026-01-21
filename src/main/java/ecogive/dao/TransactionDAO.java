package ecogive.dao;

import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;

public class TransactionDAO {

    public Transaction findById(int id) throws SQLException {
        String sql = "SELECT * FROM transactions WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, id);
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
    
    // Tìm transaction đang active (chưa hoàn thành/hủy) giữa item và receiver
    public Transaction findActiveTransaction(long itemId, long receiverId) throws SQLException {
        // Ưu tiên tìm cái đang PENDING hoặc CONFIRMED
        String sql = "SELECT * FROM transactions WHERE item_id = ? AND receiver_id = ? " +
                     "AND status IN ('PENDING', 'CONFIRMED') " +
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
        
        // Fallback
        String sqlFallback = "SELECT * FROM transactions WHERE item_id = ? AND receiver_id = ? ORDER BY transaction_id DESC LIMIT 1";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sqlFallback)) {
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
    
    // Người cho xác nhận -> CONFIRMED
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
    
    // Người nhận xác nhận -> COMPLETED
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

    // Kiểm tra tồn tại
    public boolean checkExists(long itemId, long receiverId) throws SQLException {
        String sql = "SELECT 1 FROM transactions WHERE item_id = ? AND receiver_id = ? AND status IN ('PENDING', 'CONFIRMED')";
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
        String sql = "INSERT INTO transactions (item_id, receiver_id, status, exchange_date) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, transaction.getItemId());
            stmt.setLong(2, transaction.getReceiverId());
            
            String statusName = transaction.getStatus().name();
            System.out.println("Inserting Transaction: Item=" + transaction.getItemId() + ", Receiver=" + transaction.getReceiverId() + ", Status=" + statusName);
            
            stmt.setString(3, statusName);
            stmt.setTimestamp(4, Timestamp.valueOf(transaction.getExchangeDate()));

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
}
