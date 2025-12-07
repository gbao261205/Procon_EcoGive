package ecogive.Controller;

import ecogive.Model.Item;
import ecogive.Model.User;
import ecogive.Model.Review; // Import Model chuẩn
import ecogive.dao.ItemDAO;
import ecogive.dao.ReviewDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/profile")
public class ProfileServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final ReviewDAO reviewDAO = new ReviewDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        long userId = currentUser.getUserId();

        // 1. Lấy danh sách đồ đã tặng (Đã sửa DAO ở bước 1)
        List<Item> givenItems = itemDAO.findItemsByGiverId(userId);

        // 2. Lấy danh sách đồ đã nhận (Đã sửa DAO ở bước 1)
        List<Item> receivedItems = itemDAO.findItemsByReceiverId(userId);

        // 3. Lấy danh sách đánh giá (Đã sửa DAO ở bước 2)
        List<Review> reviews = reviewDAO.findReviewsByTargetUser(userId);

        req.setAttribute("givenItems", givenItems);
        req.setAttribute("receivedItems", receivedItems);
        req.setAttribute("reviews", reviews);

        // Forward ra file profile.jsp (Ngang hàng home.jsp)
        req.getRequestDispatcher("/WEB-INF/views/profile.jsp").forward(req, resp);
    }
}