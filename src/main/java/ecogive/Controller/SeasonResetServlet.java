package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.User;
import ecogive.dao.LeaderboardHistoryDAO;
import ecogive.dao.UserDAO;
import ecogive.util.EmailUtility;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.time.LocalDate;
import java.time.format.DateTimeFormatter;
import java.util.List;

@WebServlet("/admin/season-reset")
public class SeasonResetServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final LeaderboardHistoryDAO historyDAO = new LeaderboardHistoryDAO();
    private final Gson gson = new Gson();

    // Cấu hình phần thưởng cho Top 5 (nhưng chỉ gửi mail Top 3)
    private static final BigDecimal[] REWARDS = {
        new BigDecimal("500"), // Top 1
        new BigDecimal("300"), // Top 2
        new BigDecimal("200"), // Top 3
        new BigDecimal("100"),  // Top 4
        new BigDecimal("100")   // Top 5
    };

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();

        // 1. Kiểm tra quyền Admin
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
        
        // Cho phép gọi bằng secret key (cho Cron Job) hoặc Admin login
        String secretKey = req.getParameter("secret");
        boolean isAuthorized = (currentUser != null && "ADMIN".equals(currentUser.getRole().name())) 
                               || "MY_SUPER_SECRET_CRON_KEY".equals(secretKey);

        if (!isAuthorized) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.addProperty("status", "error");
            response.addProperty("message", "Unauthorized");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        try {
            // 2. Lấy Top 5 User
            List<User> topUsers = userDAO.getTopUsers(5);
            if (topUsers.isEmpty()) {
                response.addProperty("status", "success");
                response.addProperty("message", "Không có user nào để reset.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 3. Tạo tên mùa giải (VD: Season 2023-Q4)
            LocalDate now = LocalDate.now();
            int quarter = (now.getMonthValue() - 1) / 3 + 1;
            String seasonName = "Season " + now.getYear() + "-Q" + quarter;

            // 4. Lưu Snapshot
            historyDAO.saveSnapshot(topUsers, seasonName);

            // 5. Cộng thưởng và Gửi Email
            for (int i = 0; i < topUsers.size(); i++) {
                User winner = topUsers.get(i);
                BigDecimal reward = (i < REWARDS.length) ? REWARDS[i] : BigDecimal.ZERO;
                
                // Cộng điểm thưởng
                userDAO.addEcoPoints(winner.getUserId(), reward);

                // Chỉ gửi email cho Top 3
                if (i < 3) {
                    String subject = "🎉 Chúc mừng! Bạn lọt Top " + (i + 1) + " Mùa giải " + seasonName;
                    String content = "<h3>Xin chào " + winner.getDisplayName() + ",</h3>"
                            + "<p>Chúc mừng bạn đã đạt thứ hạng <b>#" + (i + 1) + "</b> trong mùa giải vừa qua trên EcoGive!</p>"
                            + "<p>Phần thưởng của bạn: <b>" + reward + " EcoPoints</b>.</p>"
                            + "<p>Điểm thưởng đã được cộng vào tài khoản của bạn để đổi quà.</p>"
                            + "<p>Mùa giải mới đã bắt đầu, hãy tiếp tục tái chế nhé!</p>"
                            + "<br><p>Trân trọng,<br>Đội ngũ EcoGive</p>";
                    
                    try {
                        EmailUtility.sendEmail(winner.getEmail(), subject, content);
                    } catch (Exception e) {
                        System.err.println("Lỗi gửi mail cho user " + winner.getUserId() + ": " + e.getMessage());
                    }
                }
            }

            // 6. Reset Season Points toàn bộ user
            userDAO.resetSeasonPoints();

            response.addProperty("status", "success");
            response.addProperty("message", "Đã reset mùa giải thành công! Top 5 đã được thưởng.");

        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
        }

        resp.getWriter().write(gson.toJson(response));
    }
}
