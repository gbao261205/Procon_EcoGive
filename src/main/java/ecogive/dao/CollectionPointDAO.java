package ecogive.dao;

import ecogive.Model.CollectionPoint;
import ecogive.Model.CollectionPointType;
import ecogive.Model.GeoPoint;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

// Import static để code ngắn gọn hơn
import static ecogive.util.DatabaseConnection.getConnection;

public class CollectionPointDAO {

    // Helper: Chuyển GeoPoint thành chuỗi WKT cho MySQL (POINT(Lng Lat))
    private String toWKT(GeoPoint p) {
        if (p == null) return null;
        return "POINT(" + p.getLongitude() + " " + p.getLatitude() + ")";
    }

    private GeoPoint fromResultSet(ResultSet rs) throws SQLException {
        double lon = rs.getDouble("longitude");
        double lat = rs.getDouble("latitude");
        return new GeoPoint(lon, lat);
    }

    // 1. LẤY TẤT CẢ
    public List<CollectionPoint> findAll() throws SQLException {
        String sql = "SELECT point_id, name, type, address, " +
                "ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                "FROM collection_points ORDER BY point_id ASC"; // Thêm ORDER BY để trạm mới lên đầu

        List<CollectionPoint> list = new ArrayList<>();
        try (Connection conn = getConnection();
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

    // 2. LẤY THEO LOẠI
    public List<CollectionPoint> findByType(CollectionPointType type) throws SQLException {
        String sql = "SELECT point_id, name, type, address, " +
                "ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                "FROM collection_points WHERE type = ?";

        List<CollectionPoint> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, type.name());
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

    // 3. THÊM MỚI
    public boolean insert(CollectionPoint p) throws SQLException {
        String sql = "INSERT INTO collection_points (name, type, address, location) " +
                "VALUES (?, ?, ?, ST_GeomFromText(?))";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, p.getName());
            stmt.setString(2, p.getType().name());
            stmt.setString(3, p.getAddress());
            // Sử dụng helper toWKT để đảm bảo định dạng đúng
            stmt.setString(4, toWKT(p.getLocation()));

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        p.setPointId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    // 4. CẬP NHẬT (ĐÃ SỬA LỖI)
    public boolean update(CollectionPoint p) throws SQLException {
        String sql = "UPDATE collection_points SET name=?, type=?, address=?, location=ST_GeomFromText(?) WHERE point_id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setString(1, p.getName());

            // SỬA LỖI: Phải dùng .name() để lấy chuỗi từ Enum
            ps.setString(2, p.getType().name());

            ps.setString(3, p.getAddress());

            // SỬA LỖI: Dùng lại hàm toWKT để nhất quán và tránh lỗi null
            ps.setString(4, toWKT(p.getLocation()));

            ps.setLong(5, p.getPointId());

            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    // 5. XÓA
    public boolean delete(long id) throws SQLException {
        String sql = "DELETE FROM collection_points WHERE point_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    // Helper: Map dữ liệu từ ResultSet vào Object
    private CollectionPoint mapRow(ResultSet rs) throws SQLException {
        CollectionPoint cp = new CollectionPoint();
        cp.setPointId(rs.getLong("point_id"));
        cp.setName(rs.getString("name"));

        String typeStr = rs.getString("type");
        if (typeStr != null) {
            try {
                cp.setType(CollectionPointType.valueOf(typeStr));
            } catch (IllegalArgumentException e) {
                // Xử lý nếu DB có giá trị không khớp Enum (tránh crash)
                System.err.println("Unknown type in DB: " + typeStr);
            }
        }

        cp.setAddress(rs.getString("address"));
        cp.setLocation(fromResultSet(rs));
        return cp;
    }
}