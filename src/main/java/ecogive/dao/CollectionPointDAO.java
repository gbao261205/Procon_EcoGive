package ecogive.dao;

import ecogive.Model.CollectionPoint;
import ecogive.Model.CollectionPointType;
import ecogive.Model.GeoPoint;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static ecogive.util.DatabaseConnection.getConnection;

public class CollectionPointDAO {

    private String toWKT(GeoPoint p) {
        if (p == null) return null;
        return "POINT(" + p.getLongitude() + " " + p.getLatitude() + ")";
    }

    private GeoPoint fromResultSet(ResultSet rs) throws SQLException {
        double lon = rs.getDouble("longitude");
        double lat = rs.getDouble("latitude");
        return new GeoPoint(lon, lat);
    }

    public List<CollectionPoint> findAll() throws SQLException {
        // Sửa SQL: LEFT JOIN với bảng users để lấy owner_name và owner_role
        String sql = "SELECT cp.*, ST_X(cp.location) AS longitude, ST_Y(cp.location) AS latitude, u.username AS owner_name, u.role AS owner_role " +
                     "FROM collection_points cp " +
                     "LEFT JOIN users u ON cp.owner_id = u.user_id " +
                     "ORDER BY cp.point_id DESC";
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

    public List<CollectionPoint> findByOwnerId(long ownerId) throws SQLException {
        String sql = "SELECT *, ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                     "FROM collection_points WHERE owner_id = ? ORDER BY point_id DESC";
        List<CollectionPoint> list = new ArrayList<>();
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, ownerId);
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

    public boolean insert(CollectionPoint p) throws SQLException {
        String sql = "INSERT INTO collection_points (name, type, address, location, owner_id) " +
                     "VALUES (?, ?, ?, ST_GeomFromText(?), ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {
            stmt.setString(1, p.getName());
            stmt.setString(2, p.getType().name());
            stmt.setString(3, p.getAddress());
            stmt.setString(4, toWKT(p.getLocation()));
            if (p.getOwnerId() == 0) {
                stmt.setNull(5, Types.BIGINT);
            } else {
                stmt.setLong(5, p.getOwnerId());
            }

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

    public boolean update(CollectionPoint p) throws SQLException {
        String sql = "UPDATE collection_points SET name=?, type=?, address=?, location=ST_GeomFromText(?) WHERE point_id=?";
        try (Connection conn = getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setString(1, p.getName());
            ps.setString(2, p.getType().name());
            ps.setString(3, p.getAddress());
            ps.setString(4, toWKT(p.getLocation()));
            ps.setLong(5, p.getPointId());
            return ps.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean delete(long pointId) throws SQLException {
        String sql = "DELETE FROM collection_points WHERE point_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, pointId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public boolean delete(long pointId, long ownerId) throws SQLException {
        String sql = "DELETE FROM collection_points WHERE point_id = ? AND owner_id = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, pointId);
            stmt.setLong(2, ownerId);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    
    public List<CollectionPoint> findByType(CollectionPointType type) throws SQLException {
        String sql = "SELECT cp.*, ST_X(cp.location) AS longitude, ST_Y(cp.location) AS latitude, u.username AS owner_name, u.role AS owner_role " +
                     "FROM collection_points cp " +
                     "LEFT JOIN users u ON cp.owner_id = u.user_id " +
                     "WHERE cp.type = ? ORDER BY cp.point_id DESC";
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

    private CollectionPoint mapRow(ResultSet rs) throws SQLException {
        CollectionPoint cp = new CollectionPoint();
        cp.setPointId(rs.getLong("point_id"));
        cp.setName(rs.getString("name"));
        cp.setOwnerId(rs.getLong("owner_id"));
        
        ResultSetMetaData metaData = rs.getMetaData();
        int columnCount = metaData.getColumnCount();
        
        for (int i = 1; i <= columnCount; i++) {
            String columnLabel = metaData.getColumnLabel(i);
            if ("owner_name".equalsIgnoreCase(columnLabel)) {
                cp.setOwnerName(rs.getString("owner_name"));
            }
            if ("owner_role".equalsIgnoreCase(columnLabel)) {
                cp.setOwnerRole(rs.getString("owner_role"));
            }
        }

        String typeStr = rs.getString("type");
        if (typeStr != null) {
            try {
                cp.setType(CollectionPointType.valueOf(typeStr));
            } catch (IllegalArgumentException e) {
                System.err.println("Unknown type in DB: " + typeStr);
            }
        }
        cp.setAddress(rs.getString("address"));
        cp.setLocation(fromResultSet(rs));
        return cp;
    }
}
