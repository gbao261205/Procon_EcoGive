package ecogive.Controller;

import ecogive.Model.Role;
import ecogive.Model.User;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/admin/users")
public class AdminUserServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("delete-user".equals(action)) {
                deleteUser(request, response);
            } else {
                // Default action is to list users
                listUsers(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error in doGet", e);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String action = request.getParameter("action");

        try {
            if ("add-user".equals(action)) {
                addUser(request, response);
            } else if ("update-user".equals(action)) {
                updateUser(request, response);
            }
        } catch (SQLException e) {
            throw new ServletException("Database error in doPost", e);
        }
    }

    private void listUsers(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, ServletException, IOException {
        List<User> users = userDAO.findAll();
        request.setAttribute("users", users);
        request.getRequestDispatcher("/WEB-INF/views/admin/users.jsp").forward(request, response);
    }

    private void addUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String plainPassword = request.getParameter("password");
        String roleStr = request.getParameter("role");

        String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());

        User newUser = new User();
        newUser.setUsername(username);
        newUser.setEmail(email);
        newUser.setPasswordHash(hashedPassword);
        
        // SỬA LỖI: Chuyển đổi String thành Enum Role
        try {
            newUser.setRole(Role.valueOf(roleStr.toUpperCase()));
        } catch (IllegalArgumentException | NullPointerException e) {
            // Nếu role không hợp lệ hoặc null, gán vai trò mặc định
            newUser.setRole(Role.USER);
        }
        
        newUser.setEcoPoints(BigDecimal.ZERO);
        newUser.setReputationScore(BigDecimal.valueOf(1.00));
        newUser.setJoinDate(LocalDateTime.now());

        userDAO.insert(newUser);

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void updateUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        long id = Long.parseLong(request.getParameter("user_id"));
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String plainPassword = request.getParameter("password");
        String roleStr = request.getParameter("role");

        User user = userDAO.findById(id);
        if (user == null) {
            response.sendRedirect(request.getContextPath() + "/admin/users");
            return;
        }

        user.setUsername(username);
        user.setEmail(email);

        // SỬA LỖI: Chuyển đổi String thành Enum Role
        try {
            user.setRole(Role.valueOf(roleStr.toUpperCase()));
        } catch (IllegalArgumentException | NullPointerException e) {
            // Giữ nguyên vai trò cũ nếu giá trị mới không hợp lệ
            // Hoặc có thể log lỗi
        }

        if (plainPassword != null && !plainPassword.isEmpty()) {
            String hashedPassword = BCrypt.hashpw(plainPassword, BCrypt.gensalt());
            user.setPasswordHash(hashedPassword);
        }

        userDAO.update(user);

        response.sendRedirect(request.getContextPath() + "/admin/users");
    }

    private void deleteUser(HttpServletRequest request, HttpServletResponse response)
            throws SQLException, IOException {
        long id = Long.parseLong(request.getParameter("id"));
        userDAO.delete(id);
        response.sendRedirect(request.getContextPath() + "/admin/users");
    }
}
