package ecogive.dao;

import ecogive.Model.Role;
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

    public User findByEmail(String email) throws SQLException {
        String sql = "SELECT * FROM users WHERE email = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, email);
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

    public User findByResetToken(String token) throws SQLException {
        String sql = "SELECT * FROM users WHERE reset_token = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, token);
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

    public User findByVerificationToken(String token) throws SQLException {
        String sql = "SELECT * FROM users WHERE verification_token = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, token);
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

    public List<User> getTopUsers(int limit) throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'USER' ORDER BY eco_points DESC LIMIT ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setInt(1, limit);
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

    public boolean insert(User user) throws SQLException {
        String sql = "INSERT INTO users (username, email, password_hash, role, eco_points, reputation_score, join_date, phone_number, address, is_verified, verification_token) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole().name());
            stmt.setBigDecimal(5, user.getEcoPoints() != null ? user.getEcoPoints() : BigDecimal.ZERO);
            stmt.setBigDecimal(6, user.getReputationScore() != null ? user.getReputationScore() : BigDecimal.valueOf(1.00));
            if (user.getJoinDate() != null) {
                stmt.setTimestamp(7, Timestamp.valueOf(user.getJoinDate()));
            } else {
                stmt.setTimestamp(7, new Timestamp(System.currentTimeMillis()));
            }
            stmt.setString(8, user.getPhoneNumber());
            stmt.setString(9, user.getAddress());
            stmt.setBoolean(10, user.isVerified());
            stmt.setString(11, user.getVerificationToken());

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

    public boolean update(User user) throws SQLException {
        String sql = "UPDATE users SET username = ?, email = ?, password_hash = ?, role = ?, phone_number = ?, address = ?, reset_token = ?, reset_token_expiry = ?, is_verified = ?, verification_token = ? WHERE user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getEmail());
            stmt.setString(3, user.getPasswordHash());
            stmt.setString(4, user.getRole().name());
            stmt.setString(5, user.getPhoneNumber());
            stmt.setString(6, user.getAddress());
            stmt.setString(7, user.getResetToken());
            if (user.getResetTokenExpiry() != null) {
                stmt.setTimestamp(8, Timestamp.valueOf(user.getResetTokenExpiry()));
            } else {
                stmt.setTimestamp(8, null);
            }
            stmt.setBoolean(9, user.isVerified());
            stmt.setString(10, user.getVerificationToken());
            stmt.setLong(11, user.getUserId());

            int affected = stmt.executeUpdate();
            return affected > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean verifyUser(long userId) throws SQLException {
        String sql = "UPDATE users SET is_verified = TRUE, verification_token = NULL WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean addEcoPoints(long userId, BigDecimal pointsToAdd) throws SQLException {
        String sql = "UPDATE users SET eco_points = eco_points + ? WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBigDecimal(1, pointsToAdd);
            stmt.setLong(2, userId);
            return stmt.executeUpdate() > 0;
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
        u.setPhoneNumber(rs.getString("phone_number"));
        u.setAddress(rs.getString("address"));
        u.setResetToken(rs.getString("reset_token"));
        u.setVerified(rs.getBoolean("is_verified"));
        u.setVerificationToken(rs.getString("verification_token"));
        
        Timestamp expiry = rs.getTimestamp("reset_token_expiry");
        if (expiry != null) {
            u.setResetTokenExpiry(expiry.toLocalDateTime());
        }
        
        String roleStr = rs.getString("role");
        if (roleStr != null && !roleStr.isEmpty()) {
            try {
                u.setRole(Role.valueOf(roleStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
                System.err.println("Invalid role value in database: " + roleStr);
                u.setRole(Role.USER);
            }
        } else {
            u.setRole(Role.USER);
        }

        Timestamp ts = rs.getTimestamp("join_date");
        if (ts != null) {
            u.setJoinDate(ts.toLocalDateTime());
        }
        return u;
    }
}
