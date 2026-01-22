package ecogive.Controller;

import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.User;
import ecogive.Model.Review;
import ecogive.dao.ItemDAO;
import ecogive.dao.ReviewDAO;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // --- MỚI: Refresh User Session ---
        try {
            User updatedUser = userDAO.findById(currentUser.getUserId());
            if (updatedUser != null) {
                session.setAttribute("currentUser", updatedUser);
                currentUser = updatedUser; // Cập nhật biến local để dùng bên dưới
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // ---------------------------------

        long userId = currentUser.getUserId();

        // 1. Lấy danh sách đồ đã tặng
        List<Item> givenItems = itemDAO.findItemsByGiverId(userId);

        // 2. Lấy danh sách đồ đã nhận
        List<Item> receivedItems = itemDAO.findItemsByReceiverId(userId);

        // 3. Lấy danh sách đánh giá
        List<Review> reviews = reviewDAO.findReviewsByTargetUser(userId);

        req.setAttribute("givenItems", givenItems);
        req.setAttribute("receivedItems", receivedItems);
        req.setAttribute("reviews", reviews);

        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        String action = req.getParameter("action");
        String itemIdStr = req.getParameter("itemId");

        if (itemIdStr != null && !itemIdStr.isEmpty()) {
            try {
                long itemId = Long.parseLong(itemIdStr);
                Item item = itemDAO.findById(itemId);

                // Kiểm tra quyền sở hữu
                if (item != null && item.getGiverId() == currentUser.getUserId()) {
                    if ("cancel-item".equals(action) && item.getStatus() == ItemStatus.PENDING) {
                        itemDAO.updateStatus(itemId, ItemStatus.CANCELLED);
                    } else if ("remove-item".equals(action) && item.getStatus() == ItemStatus.AVAILABLE) {
                        itemDAO.updateStatus(itemId, ItemStatus.CANCELLED);
                    }
                }
            } catch (SQLException | NumberFormatException e) {
                e.printStackTrace();
            }
        }

        resp.sendRedirect(req.getContextPath() + "/profile");
    }
}
