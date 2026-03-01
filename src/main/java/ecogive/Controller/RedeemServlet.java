package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Reward;
import ecogive.Model.User;
import ecogive.dao.RewardDAO;
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
import java.sql.SQLException;
import java.util.List;

@WebServlet("/redeem")
public class RedeemServlet extends HttpServlet {

    private final RewardDAO rewardDAO = new RewardDAO();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // Refresh user data to get latest points
            User updatedUser = userDAO.findById(currentUser.getUserId());
            if (updatedUser != null) {
                session.setAttribute("currentUser", updatedUser);
                req.setAttribute("user", updatedUser);
            }

            List<Reward> rewards = rewardDAO.findAllActive();
            req.setAttribute("rewards", rewards);
            
            req.getRequestDispatcher("/WEB-INF/views/redeem.jsp").forward(req, resp);
        } catch (SQLException e) {
            throw new ServletException("Error retrieving rewards", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.addProperty("status", "error");
            response.addProperty("message", "Bạn cần đăng nhập để đổi quà.");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        try {
            long rewardId = Long.parseLong(req.getParameter("rewardId"));
            Reward reward = rewardDAO.findById(rewardId);

            if (reward == null || !"APPROVED".equals(reward.getStatus()) || reward.getStock() <= 0) {
                throw new Exception("Quà tặng không tồn tại hoặc đã hết hàng.");
            }

            // Tính toán giá sau khi giảm (nếu có logic giảm giá theo Tier)
            BigDecimal discountRate = currentUser.getTier().getDiscountRate();
            BigDecimal originalCost = reward.getPointCost();
            BigDecimal discountAmount = originalCost.multiply(discountRate);
            BigDecimal finalCost = originalCost.subtract(discountAmount);

            // Kiểm tra điểm
            if (currentUser.getCurrentPoints().compareTo(finalCost) < 0) {
                throw new Exception("Bạn không đủ điểm hiện tại để đổi món quà này.");
            }

            // Thực hiện đổi quà
            boolean success = rewardDAO.redeemReward(currentUser.getUserId(), rewardId, finalCost);

            if (success) {
                // Cập nhật lại session
                User updatedUser = userDAO.findById(currentUser.getUserId());
                session.setAttribute("currentUser", updatedUser);

                // --- MỚI: Gửi email xác nhận ---
                sendRedemptionEmail(updatedUser, reward, finalCost);
                // -------------------------------

                response.addProperty("status", "success");
                response.addProperty("message", "Đổi quà thành công! Hãy kiểm tra email để nhận hướng dẫn nhận quà.");
                response.addProperty("newPoints", updatedUser.getCurrentPoints());
            } else {
                throw new Exception("Đổi quà thất bại. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
        }

        resp.getWriter().write(gson.toJson(response));
    }

    private void sendRedemptionEmail(User user, Reward reward, BigDecimal cost) {
        String subject = "🎁 Xác nhận đổi quà thành công - EcoGive";
        String content = "<h3>Xin chào " + user.getDisplayName() + ",</h3>"
                + "<p>Bạn đã đổi thành công món quà: <b>" + reward.getName() + "</b></p>"
                + "<p>Số điểm đã trừ: <b>" + cost + " EcoPoints</b></p>"
                + "<p>Số điểm còn lại: <b>" + user.getCurrentPoints() + " EcoPoints</b></p>"
                + "<hr>"
                + "<h4>Hướng dẫn nhận quà:</h4>"
                + "<p>Vui lòng mang email này đến trạm EcoGive gần nhất hoặc liên hệ bộ phận CSKH để nhận quà.</p>"
                + "<p>Mã đổi quà: <b>REDEEM-" + System.currentTimeMillis() + "</b></p>"
                + "<br><p>Cảm ơn bạn đã đồng hành cùng EcoGive!</p>";

        try {
            EmailUtility.sendEmail(user.getEmail(), subject, content);
        } catch (Exception e) {
            System.err.println("Lỗi gửi mail đổi quà cho user " + user.getUserId() + ": " + e.getMessage());
        }
    }
}
