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

    // Helper method để đỡ viết lặp code
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