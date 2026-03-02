package ecogive.dao;

import ecogive.Model.Role;
import ecogive.Model.Tier;
import ecogive.Model.User;
import ecogive.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.List;

public class UserDAO {
    
    private static final BigDecimal DAILY_CAP = new BigDecimal("500.00");

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

    public List<User> findByRole(String role) throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, role);
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

    public List<User> getTopUsers(int limit) throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE role = 'USER' AND is_verified = TRUE ORDER BY season_points DESC LIMIT ?";
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
        String sql = "INSERT INTO users (username, display_name, email, password_hash, role, current_points, lifetime_points, season_points, tier, reputation_score, join_date, phone_number, address, is_verified, verification_token) " +
                "VALUES (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getDisplayName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPasswordHash());
            stmt.setString(5, user.getRole().name());
            
            BigDecimal zero = BigDecimal.ZERO;
            stmt.setBigDecimal(6, user.getCurrentPoints() != null ? user.getCurrentPoints() : zero);
            stmt.setBigDecimal(7, user.getLifetimePoints() != null ? user.getLifetimePoints() : zero);
            stmt.setBigDecimal(8, user.getSeasonPoints() != null ? user.getSeasonPoints() : zero);
            stmt.setString(9, user.getTier() != null ? user.getTier().name() : "STANDARD");
            
            stmt.setBigDecimal(10, user.getReputationScore() != null ? user.getReputationScore() : BigDecimal.valueOf(1.00));
            if (user.getJoinDate() != null) {
                stmt.setTimestamp(11, Timestamp.valueOf(user.getJoinDate()));
            } else {
                stmt.setTimestamp(11, new Timestamp(System.currentTimeMillis()));
            }
            stmt.setString(12, user.getPhoneNumber());
            stmt.setString(13, user.getAddress());
            stmt.setBoolean(14, user.isVerified());
            stmt.setString(15, user.getVerificationToken());

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
        String sql = "UPDATE users SET username = ?, display_name = ?, email = ?, password_hash = ?, role = ?, phone_number = ?, address = ?, reset_token = ?, reset_token_expiry = ?, is_verified = ?, verification_token = ? WHERE user_id = ?";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, user.getUsername());
            stmt.setString(2, user.getDisplayName());
            stmt.setString(3, user.getEmail());
            stmt.setString(4, user.getPasswordHash());
            stmt.setString(5, user.getRole().name());
            stmt.setString(6, user.getPhoneNumber());
            stmt.setString(7, user.getAddress());
            stmt.setString(8, user.getResetToken());
            if (user.getResetTokenExpiry() != null) {
                stmt.setTimestamp(9, Timestamp.valueOf(user.getResetTokenExpiry()));
            } else {
                stmt.setTimestamp(9, null);
            }
            stmt.setBoolean(10, user.isVerified());
            stmt.setString(11, user.getVerificationToken());
            stmt.setLong(12, user.getUserId());

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
    
    // --- CẬP NHẬT: Hàm cộng điểm thông minh (Cộng cả 3 quỹ & Check Tier & Daily Cap) ---
    public boolean addEcoPoints(long userId, BigDecimal pointsToAdd) throws SQLException {
        if (pointsToAdd.compareTo(BigDecimal.ZERO) <= 0) return false;

        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Kiểm tra Daily Cap
            LocalDate today = LocalDate.now();
            BigDecimal currentDailyPoints = BigDecimal.ZERO;
            
            String checkDailySql = "SELECT points_earned FROM daily_points WHERE user_id = ? AND date = ?";
            try (PreparedStatement ps = conn.prepareStatement(checkDailySql)) {
                ps.setLong(1, userId);
                ps.setDate(2, Date.valueOf(today));
                try (ResultSet rs = ps.executeQuery()) {
                    if (rs.next()) {
                        currentDailyPoints = rs.getBigDecimal("points_earned");
                    }
                }
            }

            BigDecimal remainingCap = DAILY_CAP.subtract(currentDailyPoints);
            if (remainingCap.compareTo(BigDecimal.ZERO) <= 0) {
                // Đã đạt giới hạn ngày, không cộng thêm
                conn.rollback();
                return true; // Trả về true để không báo lỗi, nhưng thực tế không cộng
            }

            BigDecimal actualPointsToAdd = pointsToAdd.min(remainingCap);

            // 2. Cập nhật Daily Points
            String updateDailySql = "INSERT INTO daily_points (user_id, date, points_earned) VALUES (?, ?, ?) " +
                                    "ON DUPLICATE KEY UPDATE points_earned = points_earned + ?";
            try (PreparedStatement ps = conn.prepareStatement(updateDailySql)) {
                ps.setLong(1, userId);
                ps.setDate(2, Date.valueOf(today));
                ps.setBigDecimal(3, actualPointsToAdd);
                ps.setBigDecimal(4, actualPointsToAdd);
                ps.executeUpdate();
            }

            // 3. Cộng điểm vào User
            String updatePointsSql = "UPDATE users SET " +
                    "current_points = current_points + ?, " +
                    "lifetime_points = lifetime_points + ?, " +
                    "season_points = season_points + ? " +
                    "WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updatePointsSql)) {
                stmt.setBigDecimal(1, actualPointsToAdd);
                stmt.setBigDecimal(2, actualPointsToAdd);
                stmt.setBigDecimal(3, actualPointsToAdd);
                stmt.setLong(4, userId);
                stmt.executeUpdate();
            }

            // 4. Cập nhật Tier
            String updateTierSql = "UPDATE users SET tier = CASE " +
                    "WHEN lifetime_points >= 2500 THEN 'DIAMOND' " +
                    "WHEN lifetime_points >= 800 THEN 'GOLD' " +
                    "WHEN lifetime_points >= 200 THEN 'SILVER' " +
                    "ELSE 'STANDARD' END " +
                    "WHERE user_id = ?";
            try (PreparedStatement stmt = conn.prepareStatement(updateTierSql)) {
                stmt.setLong(1, userId);
                stmt.executeUpdate();
            }

            conn.commit();
            return true;
        } catch (Exception e) {
            if (conn != null) {
                try { conn.rollback(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
            throw new SQLException(e);
        } finally {
            if (conn != null) {
                try { conn.setAutoCommit(true); conn.close(); } catch (SQLException ex) { ex.printStackTrace(); }
            }
        }
    }
    
    public boolean deductPoints(long userId, BigDecimal pointsToDeduct) throws SQLException {
        String sql = "UPDATE users SET current_points = current_points - ? WHERE user_id = ? AND current_points >= ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setBigDecimal(1, pointsToDeduct);
            stmt.setLong(2, userId);
            stmt.setBigDecimal(3, pointsToDeduct);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean resetSeasonPoints() throws SQLException {
        String sql = "UPDATE users SET season_points = 0";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
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

    public boolean updateCompanyVerificationRequest(long userId, String documentUrl) throws SQLException {
        String sql = "UPDATE users SET company_verification_status = 'PENDING', verification_document = ? WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, documentUrl);
            stmt.setLong(2, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean approveCompany(long userId) throws SQLException {
        String sql = "UPDATE users SET is_company_verified = TRUE, company_verification_status = 'VERIFIED' WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean rejectCompany(long userId) throws SQLException {
        String sql = "UPDATE users SET is_company_verified = FALSE, company_verification_status = 'REJECTED' WHERE user_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, userId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public List<User> getPendingCompanyVerifications() throws SQLException {
        List<User> list = new ArrayList<>();
        String sql = "SELECT * FROM users WHERE company_verification_status = 'PENDING'";
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

    private User mapRow(ResultSet rs) throws SQLException {
        User u = new User();
        u.setUserId(rs.getLong("user_id"));
        u.setUsername(rs.getString("username"));
        
        try {
            u.setDisplayName(rs.getString("display_name"));
        } catch (SQLException e) {
            u.setDisplayName(u.getUsername());
        }

        u.setEmail(rs.getString("email"));
        u.setPasswordHash(rs.getString("password_hash"));
        
        try {
            u.setCurrentPoints(rs.getBigDecimal("current_points"));
            u.setLifetimePoints(rs.getBigDecimal("lifetime_points"));
            u.setSeasonPoints(rs.getBigDecimal("season_points"));
            
            String tierStr = rs.getString("tier");
            if (tierStr != null) {
                u.setTier(Tier.valueOf(tierStr));
            } else {
                u.setTier(Tier.STANDARD);
            }
        } catch (SQLException e) {
            u.setCurrentPoints(BigDecimal.ZERO);
            u.setLifetimePoints(BigDecimal.ZERO);
            u.setSeasonPoints(BigDecimal.ZERO);
            u.setTier(Tier.STANDARD);
        }
        
        u.setReputationScore(rs.getBigDecimal("reputation_score"));
        u.setPhoneNumber(rs.getString("phone_number"));
        u.setAddress(rs.getString("address"));
        u.setResetToken(rs.getString("reset_token"));
        u.setVerified(rs.getBoolean("is_verified"));
        u.setVerificationToken(rs.getString("verification_token"));
        
        try {
            u.setCompanyVerified(rs.getBoolean("is_company_verified"));
            u.setCompanyVerificationStatus(rs.getString("company_verification_status"));
            u.setVerificationDocument(rs.getString("verification_document"));
        } catch (SQLException e) {
            u.setCompanyVerified(false);
            u.setCompanyVerificationStatus("NONE");
        }
        
        Timestamp expiry = rs.getTimestamp("reset_token_expiry");
        if (expiry != null) {
            u.setResetTokenExpiry(expiry.toLocalDateTime());
        }
        
        String roleStr = rs.getString("role");
        if (roleStr != null && !roleStr.isEmpty()) {
            try {
                u.setRole(Role.valueOf(roleStr.toUpperCase()));
            } catch (IllegalArgumentException e) {
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
