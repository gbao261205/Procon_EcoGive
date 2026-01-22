package ecogive.Controller;

import ecogive.Model.Item;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
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

@WebServlet("/")
public class HomeServlet extends HttpServlet {
    private ItemDAO itemDAO;
    private UserDAO userDAO;

    @Override
    public void init() {
        itemDAO = new ItemDAO();
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if the user is logged in
        if (session == null || session.getAttribute("currentUser") == null) {
            // Nếu chưa đăng nhập, vẫn cho xem trang chủ nhưng không có thông tin user
            // Hoặc chuyển hướng login tùy logic. Ở đây logic cũ là redirect login.
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        // --- MỚI: Refresh User Session ---
        User sessionUser = (User) session.getAttribute("currentUser");
        try {
            User updatedUser = userDAO.findById(sessionUser.getUserId());
            if (updatedUser != null) {
                session.setAttribute("currentUser", updatedUser);
            }
        } catch (SQLException e) {
            e.printStackTrace();
        }
        // ---------------------------------

        try {
            // Fetch all items from the database
            List<Item> items = itemDAO.findAll();
            // Set the items as a request attribute
            request.setAttribute("items", items);
        } catch (SQLException e) {
            // Handle database errors
            e.printStackTrace();
            throw new ServletException("Error retrieving items from the database", e);
        }

        // Forward to the home page view
        request.getRequestDispatcher("/WEB-INF/views/home.jsp").forward(request, response);
    }
}