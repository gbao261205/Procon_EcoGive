package ecogive.Controller;

import ecogive.Model.CollectionPoint;
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
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // 1. Authorization Check
        if (currentUser == null || !"ENTERPRISE_COLLECTOR".equals(currentUser.getRole())) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            // 2. Fetch Data
            List<CollectionPoint> collectionPoints = collectionPointDAO.findByCompanyId(currentUser.getUserId());
            req.setAttribute("collectionPoints", collectionPoints);
            req.setAttribute("totalPoints", collectionPoints.size());

        } catch (SQLException e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi khi tải dữ liệu điểm thu gom.");
        }

        // 3. Forward to JSP
        req.getRequestDispatcher("/WEB-INF/views/company/dashboard.jsp").forward(req, resp);
    }
}
