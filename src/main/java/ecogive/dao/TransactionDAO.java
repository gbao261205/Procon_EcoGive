package ecogive.dao;

import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

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

    public boolean updateStatus(int transactionId, TransactionStatus status) throws SQLException {
        String sql = "UPDATE transactions SET status = ? WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setInt(2, transactionId);
            return stmt.executeUpdate() > 0;
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
        return t;
    }

    public boolean insert(Transaction transaction) throws SQLException {
        String sql = "INSERT INTO transactions (item_id, receiver_id, status, exchange_date) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, transaction.getItemId());
            stmt.setLong(2, transaction.getReceiverId());
            stmt.setString(3, transaction.getStatus().name());
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
            throw new SQLException("Lỗi khi chèn giao dịch mới", e);
        }
    }

    public boolean createInitialTransaction(long itemId, long receiverId) throws SQLException {
        // SỬA LỖI: Cho phép tặng cả vật phẩm đang PENDING
        String updateItemSql = "UPDATE items SET status = 'CONFIRMED' WHERE item_id = ? AND (status = 'AVAILABLE' OR status = 'PENDING')";
        
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false); // Bắt đầu transaction

            // 1. Cập nhật trạng thái vật phẩm
            try (PreparedStatement psUpdate = conn.prepareStatement(updateItemSql)) {
                psUpdate.setLong(1, itemId);
                int affectedRows = psUpdate.executeUpdate();
                if (affectedRows == 0) {
                    conn.rollback();
                    return false;
                }
            }

            // 2. Tạo và chèn giao dịch mới
            Transaction newTransaction = new Transaction();
            newTransaction.setItemId(itemId);
            newTransaction.setReceiverId(receiverId);
            newTransaction.setStatus(TransactionStatus.CONFIRMED);
            newTransaction.setExchangeDate(LocalDateTime.now());
            
            String insertTransactionSql = "INSERT INTO transactions (item_id, receiver_id, status, exchange_date) VALUES (?, ?, ?, ?)";
            try (PreparedStatement psInsert = conn.prepareStatement(insertTransactionSql)) {
                psInsert.setLong(1, newTransaction.getItemId());
                psInsert.setLong(2, newTransaction.getReceiverId());
                psInsert.setString(3, newTransaction.getStatus().name());
                psInsert.setTimestamp(4, Timestamp.valueOf(newTransaction.getExchangeDate()));
                psInsert.executeUpdate();
            }

            conn.commit(); // Hoàn tất transaction
            return true;

        } catch (Exception e) {
            if (conn != null) {
                conn.rollback(); // Hoàn tác nếu có lỗi
            }
            throw new SQLException("Lỗi khi tạo giao dịch ban đầu", e);
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
        }
    }
}
