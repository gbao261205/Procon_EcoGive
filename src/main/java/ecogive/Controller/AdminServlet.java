package ecogive.Controller;

import ecogive.Model.*;
import ecogive.dao.*;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

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

    private boolean checkAdmin(HttpServletRequest req, HttpServletResponse resp) throws IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRole() != Role.ADMIN) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Bạn không có quyền truy cập trang này.");
            return false;
        }
        return true;
    }

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        if (!checkAdmin(req, resp)) return;

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
                case "delete-user":
                    deleteUser(req, resp);
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
        if (!checkAdmin(req, resp)) return;

        String action = req.getParameter("action");
        try {
            if ("add-category".equals(action)) {
                addCategory(req, resp);
            }
            else if ("update-category".equals(action)) {
                updateCategory(req, resp);
            }
            else if ("add-user".equals(action)) {
                addUser(req, resp);
            }
            else if ("update-user".equals(action)) {
                updateUser(req, resp);
            }
            else if ("delete-station".equals(action)) {
                deleteStation(req, resp);
            }
            else if ("add-station".equals(action)) {
                addStation(req, resp);
            }
            else if ("update-station".equals(action)) {
                updateStation(req, resp);
            }
        } catch (SQLException e) {
            throw new ServletException(e);
        } catch (Exception e) {
            throw new RuntimeException(e);
        }
    }

    private void addUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String roleStr = req.getParameter("role");

        User u = new User();
        u.setUsername(username);
        u.setEmail(email);
        u.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));

        try {
            u.setRole(Role.valueOf(roleStr.toUpperCase()));
        } catch (IllegalArgumentException | NullPointerException e) {
            u.setRole(Role.USER); // Default to USER if role is invalid
        }

        userDAO.insert(u);
        resp.sendRedirect(req.getContextPath() + "/admin?action=users");
    }

    private void updateUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        long id = Long.parseLong(req.getParameter("user_id"));
        String username = req.getParameter("username");
        String email = req.getParameter("email");
        String password = req.getParameter("password");
        String roleStr = req.getParameter("role");

        User oldUser = userDAO.findById(id);
        if (oldUser != null) {
            oldUser.setUsername(username);
            oldUser.setEmail(email);

            try {
                oldUser.setRole(Role.valueOf(roleStr.toUpperCase()));
            } catch (IllegalArgumentException | NullPointerException e) {
                // Keep the old role if the new one is invalid
            }

            if (password != null && !password.trim().isEmpty()) {
                oldUser.setPasswordHash(BCrypt.hashpw(password, BCrypt.gensalt()));
            }

            userDAO.update(oldUser);
        }
        resp.sendRedirect(req.getContextPath() + "/admin?action=users");
    }

    private void deleteUser(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        long id = Long.parseLong(req.getParameter("id"));
        userDAO.delete(id);
        resp.sendRedirect(req.getContextPath() + "/admin?action=users");
    }
    
    private void addStation(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        String name = req.getParameter("name");
        String typeStr = req.getParameter("type");
        String address = req.getParameter("address");
        double lat = Double.parseDouble(req.getParameter("latitude"));
        double lng = Double.parseDouble(req.getParameter("longitude"));

        CollectionPointType type = CollectionPointType.valueOf(typeStr);
        CollectionPoint p = new CollectionPoint();
        p.setName(name);
        p.setType(type);
        p.setAddress(address);
        p.setLocation(new GeoPoint(lng, lat));
        // Note: owner_id is not set here, so it will be NULL (or default), indicating an admin-created point.

        stationDAO.insert(p);
        resp.sendRedirect(req.getContextPath() + "/admin?action=stations");
    }

    private void updateStation(HttpServletRequest req, HttpServletResponse resp) throws IOException, SQLException {
        long id = Long.parseLong(req.getParameter("id"));
        String name = req.getParameter("name");
        String typeStr = req.getParameter("type");
        String address = req.getParameter("address");
        double lat = Double.parseDouble(req.getParameter("latitude"));
        double lng = Double.parseDouble(req.getParameter("longitude"));

        CollectionPointType type = CollectionPointType.valueOf(typeStr);
        CollectionPoint p = new CollectionPoint();
        p.setPointId(id);
        p.setName(name);
        p.setType(type);
        p.setAddress(address);
        p.setLocation(new GeoPoint(lng, lat));

        stationDAO.update(p);
        resp.sendRedirect(req.getContextPath() + "/admin?action=stations");
    }

    private void showDashboard(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException, SQLException {
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
        resp.sendRedirect(req.getContextPath() + "/admin?action=categories");
    }
    
    private void updateCategory(HttpServletRequest req, HttpServletResponse resp) throws Exception {
        int id = Integer.parseInt(req.getParameter("id"));
        String name = req.getParameter("name");
        String pointsStr = req.getParameter("fixed_points");

        Category c = new Category();
        c.setCategoryId(id);
        c.setName(name);
        c.setFixedPoints(new BigDecimal(pointsStr));

        categoryDAO.update(c);
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
        String statusStr = req.getParameter("status");
        List<Item> items;

        if (statusStr != null && !statusStr.isEmpty()) {
            items = itemDAO.findAll().stream()
                    .filter(i -> i.getStatus().name().equals(statusStr))
                    .toList();
        } else {
            items = itemDAO.findAll();
        }

        req.setAttribute("items", items);
        req.getRequestDispatcher("/WEB-INF/views/admin/items.jsp").forward(req, resp);
    }

    private void updateItemStatus(HttpServletRequest req, HttpServletResponse resp, ItemStatus status) throws SQLException, IOException {
        long id = Long.parseLong(req.getParameter("id"));
        itemDAO.updateStatus(id, status);
        resp.sendRedirect(req.getContextPath() + "/admin?action=items");
    }
}
