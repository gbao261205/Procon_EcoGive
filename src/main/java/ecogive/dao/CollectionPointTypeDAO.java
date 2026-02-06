package ecogive.dao;

import ecogive.Model.CollectionPointType;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

import static ecogive.util.DatabaseConnection.getConnection;

public class CollectionPointTypeDAO {

    public List<CollectionPointType> findAll() throws SQLException {
        String sql = "SELECT * FROM collection_point_types ORDER BY display_name";
        List<CollectionPointType> list = new ArrayList<>();
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

    public CollectionPointType findByCode(String code) throws SQLException {
        String sql = "SELECT * FROM collection_point_types WHERE type_code = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, code);
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

    public boolean insert(CollectionPointType type) throws SQLException {
        String sql = "INSERT INTO collection_point_types (type_code, display_name, description, icon) VALUES (?, ?, ?, ?)";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, type.getTypeCode());
            stmt.setString(2, type.getDisplayName());
            stmt.setString(3, type.getDescription());
            stmt.setString(4, type.getIcon());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean update(CollectionPointType type) throws SQLException {
        String sql = "UPDATE collection_point_types SET display_name=?, description=?, icon=? WHERE type_code=?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, type.getDisplayName());
            stmt.setString(2, type.getDescription());
            stmt.setString(3, type.getIcon());
            stmt.setString(4, type.getTypeCode());
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean delete(String typeCode) throws SQLException {
        String sql = "DELETE FROM collection_point_types WHERE type_code = ?";
        try (Connection conn = getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            stmt.setString(1, typeCode);
            return stmt.executeUpdate() > 0;
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private CollectionPointType mapRow(ResultSet rs) throws SQLException {
        CollectionPointType type = new CollectionPointType();
        type.setTypeCode(rs.getString("type_code"));
        type.setDisplayName(rs.getString("display_name"));
        type.setDescription(rs.getString("description"));
        type.setIcon(rs.getString("icon"));
        return type;
    }
}
