package ecogive.dao;

import ecogive.Model.Review;
import ecogive.util.DatabaseConnection;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.util.ArrayList;
import java.util.List;

public class ReviewDAO {

    public List<Review> findReviewsByTargetUser(long targetUserId) {
        List<Review> list = new ArrayList<>();

        // SQL JOIN để lấy username của người đánh giá
        String sql = "SELECT r.*, u.username AS reviewer_name " +
                "FROM reviews r " +
                "JOIN users u ON r.reviewer_id = u.user_id " +
                "WHERE r.rated_user_id = ? " +
                "ORDER BY r.created_at DESC";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, targetUserId);
            ResultSet rs = ps.executeQuery();

            while (rs.next()) {
                Review rev = new Review();
                rev.setReviewId(rs.getLong("review_id"));
                rev.setRating(rs.getInt("rating"));
                rev.setComment(rs.getString("comment"));
                rev.setCreatedAt(rs.getTimestamp("created_at"));

                // Set tên người đánh giá vào Model
                rev.setReviewerName(rs.getString("reviewer_name"));

                list.add(rev);
            }
        } catch (Exception e) { e.printStackTrace(); }
        return list;
    }
}