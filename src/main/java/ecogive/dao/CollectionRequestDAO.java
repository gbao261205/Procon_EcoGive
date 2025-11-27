package ecogive.dao;

import ecogive.Model.CollectionRequest;
import ecogive.Model.CollectionRequestStatus;
import ecogive.Model.GeoPoint;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.time.LocalDateTime;
import java.util.ArrayList;
import java.util.List;

public class CollectionRequestDAO {
    private String toWKT(GeoPoint p) {
        if (p == null) return null;
        return "POINT(" + p.getLongitude() + " " + p.getLatitude() + ")";
    }

    private GeoPoint fromResultSet(ResultSet rs) throws SQLException {
        double lon = rs.getDouble("longitude");
        double lat = rs.getDouble("latitude");
        return new GeoPoint(lon, lat);
    }

    public CollectionRequest findById(long id) throws SQLException {
        String sql = "SELECT request_id, user_id, item_type, status, pickup_date, address, " +
                "ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                "FROM collection_requests WHERE request_id = ?";

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

    public List<CollectionRequest> findByUserId(long userId) throws SQLException {
        String sql = "SELECT request_id, user_id, item_type, status, pickup_date, address, " +
                "ST_X(location) AS longitude, ST_Y(location) AS latitude " +
                "FROM collection_requests WHERE user_id = ?";

        List<CollectionRequest> list = new ArrayList<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setLong(1, userId);
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

    public boolean insert(CollectionRequest cr) throws SQLException {
        String sql = "INSERT INTO collection_requests (user_id, item_type, status, pickup_date, address, location) " +
                "VALUES (?, ?, ?, ?, ?, ST_GeomFromText(?))";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setLong(1, cr.getUserId());
            stmt.setString(2, cr.getItemType());
            stmt.setString(3, cr.getStatus().name());

            LocalDateTime pickupDate = cr.getPickupDate();
            stmt.setTimestamp(4, Timestamp.valueOf(pickupDate));

            stmt.setString(5, cr.getAddress());
            stmt.setString(6, toWKT(cr.getLocation()));

            int affected = stmt.executeUpdate();
            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        cr.setRequestId(keys.getLong(1));
                    }
                }
                return true;
            }
        } catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    public boolean updateStatus(long requestId, CollectionRequestStatus status) throws SQLException {
        String sql = "UPDATE collection_requests SET status = ? WHERE request_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, status.name());
            stmt.setLong(2, requestId);
            int affected = stmt.executeUpdate();
            return affected > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private CollectionRequest mapRow(ResultSet rs) throws SQLException {
        CollectionRequest cr = new CollectionRequest();
        cr.setRequestId(rs.getLong("request_id"));
        cr.setUserId(rs.getLong("user_id"));
        cr.setItemType(rs.getString("item_type"));

        String statusStr = rs.getString("status");
        if (statusStr != null) {
            cr.setStatus(CollectionRequestStatus.valueOf(statusStr));
        }

        Timestamp ts = rs.getTimestamp("pickup_date");
        if (ts != null) {
            cr.setPickupDate(ts.toLocalDateTime());
        }

        cr.setAddress(rs.getString("address"));
        cr.setLocation(fromResultSet(rs));

        return cr;
    }
}
