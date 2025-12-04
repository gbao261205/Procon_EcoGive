package ecogive.Controller;

import ecogive.Model.Category;
import ecogive.Model.CollectionPoint;
import ecogive.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.util.List;

@WebServlet("/admin")
public class AdminServlet extends HttpServlet {

    private final DashboardDAO dashboardDAO = new DashboardDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final UserDAO userDAO = new UserDAO();
    private final ItemDAO itemDAO = new ItemDAO();
    private final CollectionPointDAO stationDAO = new CollectionPointDAO();
    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        if (action == null) action = "dashboard";

        try {
            switch (action) {
                case "dashboard":
                    showDashboard(req, resp);
                    break;
                case "categories":
                    listCategories(req, resp);
                    break;
                case "users":
                    listUsers(req, resp);
                    break;
                case "delete-category":
                    deleteCategory(req, resp);
                    break;
                case "items":
                    listItems(req, resp);
                    break;
                case "approve-item":
                    updateItemStatus(req, resp, ItemStatus.AVAILABLE);
                    break;
                case "reject-item":
                    updateItemStatus(req, resp, ItemStatus.CANCELLED);
                    break;
                case "stations":
                    listStations(req, resp);
                    break;
                default:
                    showDashboard(req, resp);
                    break;
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        String action = req.getParameter("action");
        try {
            if ("add-category".equals(action)) {
                addCategory(req, resp);
            }
            else if ("delete-station".equals(action)) {
                deleteStation(req, resp);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        }
    }
    private void showDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        // Lấy số liệu từ DB thật
        req.setAttribute("totalUsers", dashboardDAO.countTotalUsers());
        req.setAttribute("totalItems", dashboardDAO.countTotalItems());
        req.setAttribute("pendingItems", dashboardDAO.countPendingItems());
        req.setAttribute("totalEcoPoints", dashboardDAO.sumTotalEcoPoints());
        req.setAttribute("totalStations", dashboardDAO.countCollectionPoints());
        req.getRequestDispatcher("/WEB-INF/views/admin/dashboard.jsp").forward(req, resp);
    }

    private void listCategories(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        req.setAttribute("categories", categoryDAO.findAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/categories.jsp").forward(req, resp);
    }

    private void listUsers(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        req.setAttribute("users", userDAO.findAll());
        req.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(req, resp);
    }
    private void addCategory(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        String name = req.getParameter("name");
        String pointsStr = req.getParameter("fixed_points");

        Category c = new Category();
        c.setName(name);
        c.setFixedPoints(new BigDecimal(pointsStr));

        categoryDAO.insert(c);

        // Reload lại trang danh mục
        resp.sendRedirect(req.getContextPath() + "/admin?action=categories");
    }

    private void listStations(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        List<CollectionPoint> list = stationDAO.findAll();
        req.setAttribute("stations", list);
        req.getRequestDispatcher("/WEB-INF/views/admin/station.jsp").forward(req, resp);
    }

    private void deleteStation(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        long id = Long.parseLong(req.getParameter("id"));
        stationDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/admin?action=stations");
    }
    private void deleteCategory(HttpServletRequest req, HttpServletResponse resp) throws SQLException, IOException {
        int id = Integer.parseInt(req.getParameter("id"));
        categoryDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/admin?action=categories");
    }
    private void listItems(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
        // Bạn có thể viết thêm hàm findAll() trong ItemDAO để lấy cả item PENDING và AVAILABLE
        // Tạm thời dùng findAllAvailable() hoặc viết hàm mới lấy tất cả để Admin soi
        List<Item> items = itemDAO.findAll(); // Cần đảm bảo ItemDAO có hàm này trả về tất cả item
        req.setAttribute("items", items);
        req.getRequestDispatcher("/WEB-INF/views/admin/items.jsp").forward(req, resp);
    }

    private void updateItemStatus(HttpServletRequest req, HttpServletResponse resp, ItemStatus status) throws SQLException, IOException {
        long id = Long.parseLong(req.getParameter("id"));
        itemDAO.updateStatus(id, status);
        resp.sendRedirect(req.getContextPath() + "/admin?action=items");
    }
}