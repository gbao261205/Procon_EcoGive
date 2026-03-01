package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Reward;
import ecogive.Model.User;
import ecogive.dao.RewardDAO;
import ecogive.util.CloudinaryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin/rewards")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class AdminRewardServlet extends HttpServlet {

    private final RewardDAO rewardDAO = new RewardDAO();
    private final CloudinaryService cloudinaryService = new CloudinaryService();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || !"ADMIN".equals(currentUser.getRole().name())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            List<Reward> rewards = rewardDAO.findAll();
            req.setAttribute("rewards", rewards);
            // Set active tab for sidebar
            req.setAttribute("activeTab", "rewards");
            req.getRequestDispatcher("/WEB-INF/views/admin/manage-rewards.jsp").forward(req, resp);
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

        if (currentUser == null || !"ADMIN".equals(currentUser.getRole().name())) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.addProperty("status", "error");
            response.addProperty("message", "Unauthorized");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        String action = req.getParameter("action");

        try {
            if ("add".equals(action)) {
                handleAddReward(req, response);
            } else if ("update".equals(action)) {
                handleUpdateReward(req, response);
            } else if ("delete".equals(action)) {
                handleDeleteReward(req, response);
            } else {
                throw new Exception("Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
        }

        resp.getWriter().write(gson.toJson(response));
    }

    private void handleAddReward(HttpServletRequest req, JsonObject response) throws Exception {
        String name = req.getParameter("name");
        String description = req.getParameter("description");
        BigDecimal pointCost = new BigDecimal(req.getParameter("pointCost"));
        int stock = Integer.parseInt(req.getParameter("stock"));
        String type = req.getParameter("type"); // ADMIN or SPONSOR
        String sponsorName = req.getParameter("sponsorName");
        String status = req.getParameter("status");

        Part filePart = req.getPart("image");
        String imageUrl = "https://placehold.co/400x300?text=No+Image";
        if (filePart != null && filePart.getSize() > 0) {
            imageUrl = cloudinaryService.uploadImage(filePart);
        }

        Reward r = new Reward();
        r.setName(name);
        r.setDescription(description);
        r.setPointCost(pointCost);
        r.setStock(stock);
        r.setType(type);
        r.setSponsorName(sponsorName);
        r.setStatus(status);
        r.setImageUrl(imageUrl);

        if (rewardDAO.insert(r)) {
            response.addProperty("status", "success");
            response.addProperty("message", "Thêm quà tặng thành công!");
        } else {
            throw new Exception("Lỗi khi thêm quà tặng.");
        }
    }

    private void handleUpdateReward(HttpServletRequest req, JsonObject response) throws Exception {
        long id = Long.parseLong(req.getParameter("id"));
        Reward r = rewardDAO.findById(id);
        if (r == null) throw new Exception("Không tìm thấy quà tặng.");

        r.setName(req.getParameter("name"));
        r.setDescription(req.getParameter("description"));
        r.setPointCost(new BigDecimal(req.getParameter("pointCost")));
        r.setStock(Integer.parseInt(req.getParameter("stock")));
        r.setType(req.getParameter("type"));
        r.setSponsorName(req.getParameter("sponsorName"));
        r.setStatus(req.getParameter("status"));

        Part filePart = req.getPart("image");
        if (filePart != null && filePart.getSize() > 0) {
            String newUrl = cloudinaryService.uploadImage(filePart);
            r.setImageUrl(newUrl);
        }

        if (rewardDAO.update(r)) {
            response.addProperty("status", "success");
            response.addProperty("message", "Cập nhật thành công!");
        } else {
            throw new Exception("Lỗi khi cập nhật.");
        }
    }

    private void handleDeleteReward(HttpServletRequest req, JsonObject response) throws Exception {
        long id = Long.parseLong(req.getParameter("id"));
        if (rewardDAO.delete(id)) {
            response.addProperty("status", "success");
            response.addProperty("message", "Xóa thành công!");
        } else {
            throw new Exception("Lỗi khi xóa.");
        }
    }
}
