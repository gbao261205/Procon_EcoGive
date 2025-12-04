package ecogive.dao;

import ecogive.Model.CollectionPoint;
import ecogive.Model.CollectionPointType;
import ecogive.Model.GeoPoint;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

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
        String sql = "SELECT point_id, name, type, address, " +
                "ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                "FROM collection_points";

        List<CollectionPoint> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                list.add(mapRow(rs));
            }
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return list;
    }

    public List<CollectionPoint> findByType(CollectionPointType type) throws SQLException {
        String sql = "SELECT point_id, name, type, address, " +
                "ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                "FROM collection_points WHERE type = ?";

        List<CollectionPoint> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, type.name());
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

    public boolean insert(CollectionPoint p) throws SQLException {
        String sql = "INSERT INTO collection_points (name, type, address, location) " +
                "VALUES (?, ?, ?, ST_GeomFromText(?))";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, p.getName());
            stmt.setString(2, p.getType().name());
            stmt.setString(3, p.getAddress());
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
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }
    public boolean delete(long id) throws SQLException {
        String sql = "DELETE FROM collection_points WHERE point_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setLong(1, id);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
    private CollectionPoint mapRow(ResultSet rs) throws SQLException {
        CollectionPoint cp = new CollectionPoint();
        cp.setPointId(rs.getLong("point_id"));
        cp.setName(rs.getString("name"));

        String typeStr = rs.getString("type");
        if (typeStr != null) {
            cp.setType(CollectionPointType.valueOf(typeStr));
        }

        cp.setAddress(rs.getString("address"));
        cp.setLocation(fromResultSet(rs));
        return cp;
    }
}
