package ecogive.dao;

import ecogive.Model.Category;
import ecogive.util.DatabaseConnection;

import java.sql.*;
import java.util.ArrayList;
import java.util.List;

public class CategoryDAO {
    public Category findById(int id) throws SQLException {
        String sql = "SELECT * FROM categories WHERE category_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
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

    public List<Category> findAll() throws SQLException {
        String sql = "SELECT * FROM categories";
        List<Category> list = new ArrayList<>();
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

    public boolean insert(Category c) throws SQLException {
        String sql = "INSERT INTO categories (name, fixed_points) VALUES (?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql, Statement.RETURN_GENERATED_KEYS)) {

            stmt.setString(1, c.getName());
            stmt.setBigDecimal(2, c.getFixedPoints());
            int affected = stmt.executeUpdate();

            if (affected > 0) {
                try (ResultSet keys = stmt.getGeneratedKeys()) {
                    if (keys.next()) {
                        c.setCategoryId(keys.getInt(1));
                    }
                }
                return true;
            }
        }catch (Exception e) {
            throw new SQLException(e);
        }
        return false;
    }

    public boolean update(Category c) throws SQLException {
        String sql = "UPDATE categories SET name = ?, fixed_points = ? WHERE category_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setString(1, c.getName());
            stmt.setBigDecimal(2, c.getFixedPoints());
            stmt.setInt(3, c.getCategoryId());
            int affected = stmt.executeUpdate();
            return affected > 0;
        }catch (Exception e) {
            throw new SQLException(e);
        }
    }

    public boolean delete(int id) throws SQLException {
        String sql = "DELETE FROM categories WHERE category_id = ?";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {

            stmt.setInt(1, id);
            int affected = stmt.executeUpdate();
            return affected > 0;
        }catch (Exception e) {
            throw new SQLException(e);
        }
    }

    private Category mapRow(ResultSet rs) throws SQLException {
        Category c = new Category();
        c.setCategoryId(rs.getInt("category_id"));
        c.setName(rs.getString("name"));
        c.setFixedPoints(rs.getBigDecimal("fixed_points"));
        return c;
    }
}
