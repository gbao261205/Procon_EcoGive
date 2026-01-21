package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.User;
import ecogive.util.DatabaseConnection; // Import DatabaseConnection
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/api/rate-transaction")
public class RateTransactionServlet extends HttpServlet {

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();
        Gson gson = new Gson();

        // Sử dụng DatabaseConnection để lấy kết nối chuẩn
        try (Connection conn = DatabaseConnection.getConnection()) {
            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

            if (currentUser == null) {
                response.addProperty("status", "error");
                response.addProperty("message", "Chưa đăng nhập!");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            long itemId = Long.parseLong(req.getParameter("itemId"));
            int rating = Integer.parseInt(req.getParameter("rating"));
            String comment = req.getParameter("comment");
            long reviewerId = currentUser.getUserId();

            // 1. Tìm transaction liên quan (đã COMPLETED vì người dùng đã xác nhận nhận hàng trước đó)
            String findTransSql = "SELECT t.transaction_id, t.item_id, i.giver_id " +
                    "FROM transactions t " +
                    "JOIN items i ON t.item_id = i.item_id " +
                    "WHERE t.item_id = ? AND t.receiver_id = ? AND t.status = 'COMPLETED'";

            PreparedStatement psFind = conn.prepareStatement(findTransSql);
            psFind.setLong(1, itemId);
            psFind.setLong(2, reviewerId);
            ResultSet rs = psFind.executeQuery();

            if (rs.next()) {
                long transactionId = rs.getLong("transaction_id");
                long giverId = rs.getLong("giver_id");

                conn.setAutoCommit(false);
                try {
                    // 2. Insert Review
                    String insertReview = "INSERT INTO reviews (transaction_id, reviewer_id, rated_user_id, rating, comment) VALUES (?, ?, ?, ?, ?)";
                    PreparedStatement psReview = conn.prepareStatement(insertReview);
                    psReview.setLong(1, transactionId);
                    psReview.setLong(2, reviewerId);
                    psReview.setLong(3, giverId);
                    psReview.setInt(4, rating);
                    psReview.setString(5, comment);
                    psReview.executeUpdate();

                    // 3. Update Reputation Score cho Giver (Tính trung bình cộng)
                    String updateScore = "UPDATE users u SET reputation_score = " +
                            "(SELECT AVG(rating) FROM reviews r WHERE r.rated_user_id = ?) " +
                            "WHERE u.user_id = ?";
                    PreparedStatement psScore = conn.prepareStatement(updateScore);
                    psScore.setLong(1, giverId);
                    psScore.setLong(2, giverId);
                    psScore.executeUpdate();

                    conn.commit();
                    response.addProperty("status", "success");
                    response.addProperty("message", "Đánh giá thành công! Cảm ơn bạn.");
                } catch (Exception e) {
                    conn.rollback();
                    throw e;
                }
            } else {
                response.addProperty("status", "error");
                response.addProperty("message", "Không tìm thấy giao dịch đã hoàn tất để đánh giá.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi: " + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}