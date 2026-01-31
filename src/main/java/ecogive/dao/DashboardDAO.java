package ecogive.dao;

import ecogive.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;

public class DashboardDAO {

    public int countTotalUsers() throws SQLException {
        return  executeCount("SELECT COUNT(*) FROM users");
    }

    public int countTotalItems() throws SQLException {
        return executeCount("SELECT COUNT(*) FROM items");
    }

    public int countPendingItems() throws SQLException {
        return executeCount("SELECT COUNT(*) FROM items WHERE status = 'PENDING'");
    }
    public int countCollectionPoints() throws SQLException {
        return executeCount("SELECT COUNT(*) FROM collection_points");
    }

    public double sumTotalEcoPoints() throws SQLException {
        String sql = "SELECT SUM(eco_points) FROM users";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            if (rs.next()) {
                return rs.getDouble(1);
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
        return 0.0;
    }

    // Lấy thống kê số lượng item theo từng danh mục (tên danh mục -> count)
    public java.util.LinkedHashMap<String, Integer> getCategoryCounts() throws SQLException {
        String sql = "SELECT c.name AS category_name, COUNT(i.item_id) AS cnt " +
                     "FROM categories c LEFT JOIN items i ON c.category_id = i.category_id " +
                     "GROUP BY c.category_id, c.name ORDER BY cnt DESC";
        java.util.LinkedHashMap<String, Integer> map = new java.util.LinkedHashMap<>();
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {
            while (rs.next()) {
                String name = rs.getString("category_name");
                int cnt = rs.getInt("cnt");
                map.put(name, cnt);
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new SQLException(e);
        }
        return map;
    }

     private int executeCount(String sql) {
         try (Connection conn = DatabaseConnection.getConnection();
              PreparedStatement stmt = conn.prepareStatement(sql);
              ResultSet rs = stmt.executeQuery()) {
             if (rs.next()) {
                 return rs.getInt(1);
             }
         } catch (Exception e) {
             e.printStackTrace();
         }
         return 0;
     }
 }
