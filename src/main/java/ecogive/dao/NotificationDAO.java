package ecogive.dao;

import ecogive.Model.Notification;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class NotificationDAO {

    public boolean insert(Notification noti) throws SQLException {
        String sql = "INSERT INTO notifications (user_id, content, type, reference_id, is_read, created_at) VALUES (?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setLong(1, noti.getUserId());
            stmt.setString(2, noti.getContent());
            stmt.setString(3, noti.getType());
            if (noti.getReferenceId() != null) {
                stmt.setLong(4, noti.getReferenceId());
            } else {
                stmt.setNull(4, Types.BIGINT);
            }
            stmt.setBoolean(5, noti.isRead());
            stmt.setTimestamp(6, Timestamp.valueOf(noti.getCreatedAt() != null ? noti.getCreatedAt() : LocalDateTime.now()));

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        noti.setNotificationId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    public List<Notification> findByUserId(long userId, int limit) throws SQLException {
        List<Notification> list = new ArrayList<>();
        String sql = "SELECT * FROM notifications WHERE user_id = ? ORDER BY created_at DESC LIMIT ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setLong(1, userId);
            stmt.setInt(2, limit);
            
            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    list.add(mapRow(rs));
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }

    public int countUnread(long userId) throws SQLException {
        String sql = "SELECT COUNT(*) FROM notifications WHERE user_id = ? AND is_read = FALSE";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            try (ResultSet rs = stmt.executeQuery()) {
                if (rs.next()) {
                    return rs.getInt(1);
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return 0;
    }

    public boolean markAsRead(long notificationId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE notification_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, notificationId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean markAllAsRead(long userId) throws SQLException {
        String sql = "UPDATE notifications SET is_read = TRUE WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean delete(long notificationId) throws SQLException {
        String sql = "DELETE FROM notifications WHERE notification_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, notificationId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private Notification mapRow(ResultSet rs) throws SQLException {
        Notification n = new Notification();
        n.setNotificationId(rs.getLong("notification_id"));
        n.setUserId(rs.getLong("user_id"));
        n.setContent(rs.getString("content"));
        n.setType(rs.getString("type"));
        long refId = rs.getLong("reference_id");
        if (!rs.wasNull()) n.setReferenceId(refId);
        n.setRead(rs.getBoolean("is_read"));
        n.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return n;
    }
}
