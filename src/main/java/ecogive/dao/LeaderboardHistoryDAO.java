package ecogive.dao;

import ecogive.Model.User;
import ecogive.util.DatabaseConnection;

import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.List;

public class LeaderboardHistoryDAO {

    public void saveSnapshot(List<User> topUsers, String seasonName) throws SQLException {
        String sql = "INSERT INTO leaderboard_history (season_name, user_id, total_season_points, final_rank) VALUES (?, ?, ?, ?)";
        
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement stmt = conn.prepareStatement(sql)) {
            
            int rank = 1;
            for (User user : topUsers) {
                stmt.setString(1, seasonName);
                stmt.setLong(2, user.getUserId());
                stmt.setBigDecimal(3, user.getSeasonPoints());
                stmt.setInt(4, rank++);
                stmt.addBatch();
            }
            
            stmt.executeBatch();
        } catch (Exception e) {
            throw new SQLException(e);
        }
    }
}
