package ecogive.Controller;

import ecogive.Model.CollectionPoint;
import ecogive.Model.Role;
import ecogive.Model.User;
import ecogive.dao.CollectionPointDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/dashboard/company")
public class CompanyDashboardServlet extends HttpServlet {

    private final CollectionPointDAO collectionPointDAO = new CollectionPointDAO();

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        HttpSession session = request.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRole() != Role.COLLECTOR_COMPANY) {
            response.sendRedirect(request.getContextPath() + "/login");
            return;
        }

        try {
            // Fetch collection points owned by this company
            List<CollectionPoint> collectionPoints = collectionPointDAO.findByOwnerId(currentUser.getUserId());
            request.setAttribute("collectionPoints", collectionPoints);
        } catch (SQLException e) {
            e.printStackTrace();
            // Optionally, set an error message for the view
            request.setAttribute("errorMessage", "Không thể tải danh sách điểm thu gom.");
        }

        request.getRequestDispatcher("/WEB-INF/views/company-dashboard.jsp").forward(request, response);
    }
}
