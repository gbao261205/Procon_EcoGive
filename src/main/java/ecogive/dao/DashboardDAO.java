package ecogive.dao;

import ecogive.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

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
        String sql = "SELECT SUM(season_points) FROM users";
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

    // --- MỚI: Lấy dữ liệu biểu đồ Time Series ---
    public Map<String, List<Object[]>> getTransactionTimeSeries() throws SQLException {
        Map<String, List<Object[]>> result = new HashMap<>();
        List<Object[]> giveData = new ArrayList<>();
        List<Object[]> tradeData = new ArrayList<>();

        // Query thống kê theo ngày và loại giao dịch
        // Chỉ lấy các giao dịch đã hoàn thành (COMPLETED)
        String sql = "SELECT DATE(exchange_date) as date, transaction_type, COUNT(*) as cnt " +
                     "FROM transactions " +
                     "WHERE status = 'COMPLETED' " +
                     "GROUP BY DATE(exchange_date), transaction_type " +
                     "ORDER BY date ASC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql);
             ResultSet rs = stmt.executeQuery()) {

            while (rs.next()) {
                String date = rs.getString("date");
                String type = rs.getString("transaction_type");
                int count = rs.getInt("cnt");

                Object[] point = new Object[]{date, count};

                if ("GIVE".equalsIgnoreCase(type)) {
                    giveData.add(point);
                } else if ("TRADE".equalsIgnoreCase(type)) {
                    tradeData.add(point);
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            throw new SQLException(e);
        }

        result.put("GIVE", giveData);
        result.put("TRADE", tradeData);
        return result;
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
