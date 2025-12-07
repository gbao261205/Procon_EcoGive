package ecogive.dao;

import ecogive.Model.User;
import ecogive.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    public User findById(long id) throws SQLException {
        String sql = "SELECT * FROM users WHERE user_id = ?";
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

    public User findByUsername(String username) throws SQLException {
        String sql = "SELECT * FROM users WHERE username = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, username);
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

    public List<User> findAll() throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }

    public boolean insert(User user) throws SQLException {
        String sql = "INSERT INTO users (username, email, password_hash, role, eco_points, reputation_score, join_date) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole());
            stmt.setBigDecimal(5, user.getEcoPoints() != null ? user.getEcoPoints() : BigDecimal.ZERO);
            stmt.setBigDecimal(6, user.getReputationScore() != null ? user.getReputationScore() : BigDecimal.valueOf(1.00));
            if (user.getJoinDate() != null) {
                stmt.setTimestamp(7, Timestamp.valueOf(user.getJoinDate()));
            } else {
                stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            }

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        user.setUserId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    // Trong file UserDAO.java

    public boolean update(User user) throws SQLException {
        // CHỈ CẬP NHẬT THÔNG TIN CƠ BẢN (Bỏ eco_points và reputation_score ra khỏi SQL update)
        String sql = "UPDATE users SET username = ?, email = ?, password_hash = ?, role = ? WHERE user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole());
            stmt.setLong(5, user.getUserId());

            int affected = stmt.executeUpdate();
            return affected > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean delete(long id) throws SQLException {
        String sql = "DELETE FROM users WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            int affected = stmt.executeUpdate();
            return affected > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getLong("user_id"));
        u.setUsername(rs.getString("username"));
        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        u.setEcoPoints(rs.getBigDecimal("eco_points"));
        u.setReputationScore(rs.getBigDecimal("reputation_score"));
        u.setRole(rs.getString("role"));
        Timestamp ts = rs.getTimestamp("join_date");
        if (ts != null) {
            u.setJoinDate(ts.toLocalDateTime());
        }
        return u;
    }
}
