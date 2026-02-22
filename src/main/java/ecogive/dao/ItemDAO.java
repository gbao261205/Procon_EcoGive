package ecogive.dao;

import ecogive.Model.GeoPoint;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.util.DatabaseConnection;

import java.math.BigDecimal;
import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class ItemDAO {
    private String toWKT(GeoPoint p) {
        if (p == null) return null;
        return "POINT(" + p.getLongitude() + " " + p.getLatitude() + ")";
    }

    private GeoPoint fromResultSet(ResultSet rs) throws SQLException {
        double lon = rs.getDouble("longitude");
        double lat = rs.getDouble("latitude");
        return new GeoPoint(lon, lat);
    }

    public Item findById(long id) throws SQLException {
        String sql = "SELECT *, ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                     "FROM items WHERE item_id = ?";

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

    public List<Item> findAllAvailable() throws SQLException {
        String sql = "SELECT i.*, ST_X(i.location) AS longitude, ST_Y(i.location) AS latitude, u.username " +
                "FROM items i " +
                "JOIN users u ON i.giver_id = u.user_id " +
                "WHERE i.status = 'AVAILABLE'";

        List<Item> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                Item item = mapRow(rs);
                item.setGiverName(rs.getString("username"));
                list.add(item);
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }

    // --- MỚI: Tìm kiếm theo vùng hiển thị (Viewport) và Category ---
    public List<Item> findAvailableInBounds(double minLat, double minLng, double maxLat, double maxLng, Integer categoryId) throws SQLException {
        String polygonWKT = String.format("POLYGON((%f %f, %f %f, %f %f, %f %f, %f %f))",
                minLng, minLat,
                maxLng, minLat,
                maxLng, maxLat,
                minLng, maxLat,
                minLng, minLat);

        StringBuilder sql = new StringBuilder(
                "SELECT i.*, ST_X(i.location) AS longitude, ST_Y(i.location) AS latitude, u.username " +
                "FROM items i " +
                "JOIN users u ON i.giver_id = u.user_id " +
                "WHERE i.status = 'AVAILABLE' " +
                "AND MBRContains(ST_GeomFromText(?), i.location)"
        );

        if (categoryId != null) {
            sql.append(" AND i.category_id = ?");
        }

        List<Item> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            stmt.setString(1, polygonWKT);
            if (categoryId != null) {
                stmt.setInt(2, categoryId);
            }

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Item item = mapRow(rs);
                    item.setGiverName(rs.getString("username"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }

    // Giữ lại phương thức cũ để tương thích ngược (nếu cần)
    public List<Item> findAvailableInBounds(double minLat, double minLng, double maxLat, double maxLng) throws SQLException {
        return findAvailableInBounds(minLat, minLng, maxLat, maxLng, null);
    }
    // --------------------------------------------------
    
    // --- MỚI: Tìm kiếm theo khoảng cách và phân trang ---
    public List<Item> findAvailableSortedByDistance(double lat, double lng, int limit, int offset, Integer categoryId) throws SQLException {
        // Sử dụng ST_Distance_Sphere để tính khoảng cách (đơn vị mét)
        // Sắp xếp tăng dần theo khoảng cách
        StringBuilder sql = new StringBuilder(
            "SELECT i.*, ST_X(i.location) AS longitude, ST_Y(i.location) AS latitude, u.username, " +
            "ST_Distance_Sphere(i.location, ST_GeomFromText(?)) AS distance " +
            "FROM items i " +
            "JOIN users u ON i.giver_id = u.user_id " +
            "WHERE i.status = 'AVAILABLE' "
        );
        
        if (categoryId != null) {
            sql.append(" AND i.category_id = ? ");
        }
        
        sql.append("ORDER BY distance ASC LIMIT ? OFFSET ?");

        String pointWKT = "POINT(" + lng + " " + lat + ")";
        List<Item> list = new ArrayList<>();

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {

            int paramIndex = 1;
            stmt.setString(paramIndex++, pointWKT);
            
            if (categoryId != null) {
                stmt.setInt(paramIndex++, categoryId);
            }
            
            stmt.setInt(paramIndex++, limit);
            stmt.setInt(paramIndex++, offset);

            try (ResultSet rs = stmt.executeQuery()) {
                while (rs.next()) {
                    Item item = mapRow(rs);
                    item.setGiverName(rs.getString("username"));
                    list.add(item);
                }
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }
    
    // Overload cho tương thích cũ
    public List<Item> findAvailableSortedByDistance(double lat, double lng, int limit, int offset) throws SQLException {
        return findAvailableSortedByDistance(lat, lng, limit, offset, null);
    }
    // ----------------------------------------------------

    public List<Item> findAll() throws SQLException {
        return findAll(1000, 0, null); // Default fallback
    }

    public List<Item> findAll(int limit, int offset, String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder(
            "SELECT *, ST_X(location) AS longitude, ST_Y(location) AS latitude FROM items "
        );
        
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append(" WHERE status = ? ");
        }
        
        sql.append(" ORDER BY post_date DESC LIMIT ? OFFSET ?");

        List<Item> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            int paramIndex = 1;
            if (statusFilter != null && !statusFilter.isEmpty()) {
                stmt.setString(paramIndex++, statusFilter);
            }
            stmt.setInt(paramIndex++, limit);
            stmt.setInt(paramIndex++, offset);

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

    public int countAll(String statusFilter) throws SQLException {
        StringBuilder sql = new StringBuilder("SELECT COUNT(*) FROM items");
        if (statusFilter != null && !statusFilter.isEmpty()) {
            sql.append(" WHERE status = ?");
        }

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            if (statusFilter != null && !statusFilter.isEmpty()) {
                stmt.setString(1, statusFilter);
            }

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

    // --- SỬA ĐỔI: Lấy thêm tên danh mục ---
    public List<Item> findItemsByGiverId(long giverId) {
        List<Item> list = new ArrayList<>();
        String sql = "SELECT i.*, ST_X(i.location) AS longitude, ST_Y(i.location) AS latitude, c.name AS category_name " +
                     "FROM items i " +
                     "LEFT JOIN categories c ON i.category_id = c.category_id " +
                     "WHERE i.giver_id = ? ORDER BY i.post_date DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, giverId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                Item item = mapRow(rs);
                item.setCategoryName(rs.getString("category_name"));
                list.add(item);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
    // --------------------------------------

    public List<Item> findItemsByReceiverId(long receiverId) {
        List<Item> list = new ArrayList<>();
        String sql = "SELECT i.*, ST_X(i.location) AS longitude, ST_Y(i.location) AS latitude " +
                "FROM items i " +
                "JOIN transactions t ON i.item_id = t.item_id " +
                "WHERE t.receiver_id = ? ORDER BY t.exchange_date DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, receiverId);
            ResultSet rs = ps.executeQuery();
            while (rs.next()) {
                list.add(mapRow(rs));
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }

    public boolean insert(Item item) throws SQLException {
        String sql = "INSERT INTO items (giver_id, title, description, category_id, image_url, status, post_date, location, eco_points, address) " +
                     "VALUES (?, ?, ?, ?, ?, ?, ?, ST_GeomFromText(?), ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, item.getGiverId());
            stmt.setString(2, item.getTitle());
            stmt.setString(3, item.getDescription());
            stmt.setInt(4, item.getCategoryId());
            stmt.setString(5, item.getImageUrl());
            stmt.setString(6, item.getStatus() != null ? item.getStatus().name() : ItemStatus.AVAILABLE.name());
            LocalDateTime postDate = item.getPostDate() != null ? item.getPostDate() : LocalDateTime.now();
            stmt.setTimestamp(7, Timestamp.valueOf(postDate));
            stmt.setString(8, toWKT(item.getLocation()));
            stmt.setBigDecimal(9, item.getEcoPoints());
            stmt.setString(10, item.getAddress());

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        item.setItemId(keys.getLong(1));
                    }
                }
                return true;
            }
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    public boolean updateStatus(long itemId, ItemStatus status) throws SQLException {
        String sql = "UPDATE items SET status = ? WHERE item_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, status.name());
            stmt.setLong(2, itemId);
            return stmt.executeUpdate() > 0;
        }catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean updateItemDetails(long itemId, int categoryId, BigDecimal ecoPoints) throws SQLException {
        String sql = "UPDATE items SET category_id = ?, eco_points = ? WHERE item_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            stmt.setInt(1, categoryId);
            stmt.setBigDecimal(2, ecoPoints);
            stmt.setLong(3, itemId);
            
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    // --- MỚI: Tìm kiếm theo tên (Fuzzy Search - Tách từ) ---
    public List<Item> searchByTitle(String keyword) throws SQLException {
        // Tách từ khóa thành mảng các từ
        String[] words = keyword.trim().split("\\s+");
        
        StringBuilder sql = new StringBuilder(
            "SELECT *, ST_X(location) AS longitude, ST_Y(location) AS latitude " +
            "FROM items WHERE status = 'AVAILABLE'"
        );
        
        // Thêm điều kiện LIKE cho mỗi từ
        for (int i = 0; i < words.length; i++) {
            sql.append(" AND title LIKE ?");
        }
        
        sql.append(" ORDER BY post_date DESC LIMIT 5");

        List<Item> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            // Gán tham số cho từng từ
            for (int i = 0; i < words.length; i++) {
                stmt.setString(i + 1, "%" + words[i] + "%");
            }
            
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

    // --- MỚI: Tìm kiếm theo tên danh mục (Fuzzy Search) ---
    public List<Item> searchByCategoryName(String categoryName) throws SQLException {
        String[] words = categoryName.trim().split("\\s+");
        
        StringBuilder sql = new StringBuilder(
            "SELECT i.*, ST_X(i.location) AS longitude, ST_Y(i.location) AS latitude " +
            "FROM items i " +
            "JOIN categories c ON i.category_id = c.category_id " +
            "WHERE i.status = 'AVAILABLE'"
        );
        
        for (int i = 0; i < words.length; i++) {
            sql.append(" AND c.name LIKE ?");
        }
        
        sql.append(" ORDER BY i.post_date DESC LIMIT 5");

        List<Item> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql.toString())) {
            
            for (int i = 0; i < words.length; i++) {
                stmt.setString(i + 1, "%" + words[i] + "%");
            }

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
    // ----------------------------------------

    public boolean delete(long itemId) throws SQLException {
        String sql = "DELETE FROM items WHERE item_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, itemId);
            return stmt.executeUpdate() > 0;
        }catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private Item mapRow(ResultSet rs) throws SQLException {
        Item item = new Item();
        item.setItemId(rs.getLong("item_id"));
        item.setGiverId(rs.getLong("giver_id"));
        item.setTitle(rs.getString("title"));
        item.setDescription(rs.getString("description"));
        item.setCategoryId(rs.getInt("category_id"));
        item.setImageUrl(rs.getString("image_url"));
        item.setEcoPoints(rs.getBigDecimal("eco_points"));
        item.setAddress(rs.getString("address"));

        String statusStr = rs.getString("status");
        if (statusStr != null) {
            item.setStatus(ItemStatus.valueOf(statusStr));
        }

        Timestamp ts = rs.getTimestamp("post_date");
        if (ts != null) {
            item.setPostDate(ts.toLocalDateTime());
        }

        item.setLocation(fromResultSet(rs));

        return item;
    }
}
