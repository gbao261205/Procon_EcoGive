package ecogive.Controller;

import ecogive.Model.Item;
import ecogive.dao.ItemDAO;
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

    @Override
    public void init() {
        itemDAO = new ItemDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);

        // Check if the user is logged in
        if (session == null || session.getAttribute("currentUser") == null) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

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
