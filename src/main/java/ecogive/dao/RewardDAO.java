package ecogive.dao;

import ecogive.Model.Reward;
import ecogive.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class RewardDAO {

    public List<Reward> findAllActive() throws SQLException {
        List<Reward> list = new ArrayList<>();
        String sql = "SELECT * FROM rewards WHERE status = 'APPROVED' AND stock > 0 ORDER BY point_cost ASC";
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

    // --- MỚI: Lấy tất cả quà (cho Admin) ---
    public List<Reward> findAll() throws SQLException {
        List<Reward> list = new ArrayList<>();
        String sql = "SELECT * FROM rewards ORDER BY created_at DESC";
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

    public Reward findById(long id) throws SQLException {
        String sql = "SELECT * FROM rewards WHERE reward_id = ?";
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

    public boolean insert(Reward r) throws SQLException {
        String sql = "INSERT INTO rewards (name, description, point_cost, image_url, stock, type, sponsor_name, status) VALUES (?, ?, ?, ?, ?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            
            stmt.setString(1, r.getName());
            stmt.setString(2, r.getDescription());
            stmt.setBigDecimal(3, r.getPointCost());
            stmt.setString(4, r.getImageUrl());
            stmt.setInt(5, r.getStock());
            stmt.setString(6, r.getType());
            stmt.setString(7, r.getSponsorName());
            stmt.setString(8, r.getStatus());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        r.setRewardId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    // --- MỚI: Cập nhật quà ---
    public boolean update(Reward r) throws SQLException {
        String sql = "UPDATE rewards SET name = ?, description = ?, point_cost = ?, image_url = ?, stock = ?, type = ?, sponsor_name = ?, status = ? WHERE reward_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setString(1, r.getName());
            stmt.setString(2, r.getDescription());
            stmt.setBigDecimal(3, r.getPointCost());
            stmt.setString(4, r.getImageUrl());
            stmt.setInt(5, r.getStock());
            stmt.setString(6, r.getType());
            stmt.setString(7, r.getSponsorName());
            stmt.setString(8, r.getStatus());
            stmt.setLong(9, r.getRewardId());

            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    // --- MỚI: Xóa quà ---
    public boolean delete(long id) throws SQLException {
        String sql = "DELETE FROM rewards WHERE reward_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean redeemReward(long userId, long rewardId, BigDecimal cost) throws SQLException {
        Connection conn = null;
        try {
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Trừ điểm User (chỉ trừ current_points)
            String deductSql = "UPDATE users SET current_points = current_points - ? WHERE user_id = ? AND current_points >= ?";
            try (PreparedStatement ps = conn.prepareStatement(deductSql)) {
                ps.setBigDecimal(1, cost);
                ps.setLong(2, userId);
                ps.setBigDecimal(3, cost);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    throw new SQLException("Không đủ điểm hoặc lỗi user.");
                }
            }

            // 2. Trừ kho Reward
            String stockSql = "UPDATE rewards SET stock = stock - 1 WHERE reward_id = ? AND stock > 0";
            try (PreparedStatement ps = conn.prepareStatement(stockSql)) {
                ps.setLong(1, rewardId);
                int rows = ps.executeUpdate();
                if (rows == 0) {
                    throw new SQLException("Hết hàng.");
                }
            }

            // 3. Lưu lịch sử
            String historySql = "INSERT INTO reward_redemptions (user_id, reward_id, points_spent, status) VALUES (?, ?, ?, 'COMPLETED')";
            try (PreparedStatement ps = conn.prepareStatement(historySql)) {
                ps.setLong(1, userId);
                ps.setLong(2, rewardId);
                ps.setBigDecimal(3, cost);
                ps.executeUpdate();
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

    private Reward mapRow(ResultSet rs) throws SQLException {
        Reward r = new Reward();
        r.setRewardId(rs.getLong("reward_id"));
        r.setName(rs.getString("name"));
        r.setDescription(rs.getString("description"));
        r.setPointCost(rs.getBigDecimal("point_cost"));
        r.setImageUrl(rs.getString("image_url"));
        r.setStock(rs.getInt("stock"));
        r.setType(rs.getString("type"));
        r.setSponsorName(rs.getString("sponsor_name"));
        r.setStatus(rs.getString("status"));
        r.setCreatedAt(rs.getTimestamp("created_at").toLocalDateTime());
        return r;
    }
}
