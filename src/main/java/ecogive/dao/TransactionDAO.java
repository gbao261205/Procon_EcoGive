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
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return null;
    }

    public List<Transaction> findByReceiverId(long receiverId) throws SQLException {
        String sql = "SELECT * FROM transactions WHERE receiver_id = ?";
        List<Transaction> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, receiverId);
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }

    public boolean insert(Transaction t) throws SQLException {
        String sql = "INSERT INTO transactions (item_id, receiver_id, exchange_date, status) " +
                "VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, t.getItemId());
            stmt.setLong(2, t.getReceiverId());

            LocalDateTime exchangeDate = t.getExchangeDate() != null ? t.getExchangeDate() : LocalDateTime.now();
            stmt.setTimestamp(3, Timestamp.valueOf(exchangeDate));

            stmt.setString(4, t.getStatus().name());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        t.setTransactionId(keys.getLong(1));
                    }
                }
                return true;
            }
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    public boolean updateStatus(long transactionId, TransactionStatus status) throws SQLException {
        String sql = "UPDATE transactions SET status = ? WHERE transaction_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status.name());
            stmt.setLong(2, transactionId);
            int affected = stmt.executeUpdate();
            return affected > 0;
        }catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private Transaction mapRow(ResultSet rs) throws SQLException {
        Transaction t = new Transaction();
        t.setTransactionId(rs.getLong("transaction_id"));
        t.setItemId(rs.getLong("item_id"));
        t.setReceiverId(rs.getLong("receiver_id"));

        Timestamp ts = rs.getTimestamp("exchange_date");
        if (ts != null) {
            t.setExchangeDate(ts.toLocalDateTime());
        }

        String statusStr = rs.getString("status");
        if (statusStr != null) {
            t.setStatus(TransactionStatus.valueOf(statusStr));
        }

        return t;
    }

}
