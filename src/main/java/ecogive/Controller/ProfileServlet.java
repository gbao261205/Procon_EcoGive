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
import java.util.Collections;
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

        String userIdParam = req.getParameter("userId");
        long profileUserId;
        boolean isMyProfile = true;

        User profileUser = null;

        try {
            if (userIdParam != null && !userIdParam.isEmpty()) {
                profileUserId = Long.parseLong(userIdParam);
                if (profileUserId != currentUser.getUserId()) {
                    isMyProfile = false;
                    profileUser = userDAO.findById(profileUserId);
                } else {
                    profileUser = currentUser;
                }
            } else {
                profileUserId = currentUser.getUserId();
                profileUser = currentUser;
            }

            if (profileUser == null) {
                // User không tồn tại hoặc có lỗi, chuyển hướng về trang chủ hoặc trang lỗi
                resp.sendRedirect(req.getContextPath() + "/home");
                return;
            }

            // Refresh thông tin người dùng hiện tại nếu xem profile của chính mình
            if (isMyProfile) {
                User updatedUser = userDAO.findById(currentUser.getUserId());
                if (updatedUser != null) {
                    session.setAttribute("currentUser", updatedUser);
                    profileUser = updatedUser; // Dùng thông tin mới nhất
                }
            }

        } catch (NumberFormatException | SQLException e) {
            e.printStackTrace();
            resp.sendRedirect(req.getContextPath() + "/home"); // Lỗi thì về home
            return;
        }

        // Lấy dữ liệu dựa trên profileUser
        List<Item> givenItems = itemDAO.findItemsByGiverId(profileUser.getUserId());
        List<Review> reviews = reviewDAO.findReviewsByTargetUser(profileUser.getUserId());
        List<Item> receivedItems = isMyProfile ? itemDAO.findItemsByReceiverId(profileUser.getUserId()) : Collections.emptyList();


        req.setAttribute("profileUser", profileUser);
        req.setAttribute("isMyProfile", isMyProfile);
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
