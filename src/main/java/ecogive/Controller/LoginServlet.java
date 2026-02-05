package ecogive.Controller;

import ecogive.Model.Role;
import ecogive.Model.User;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/login")
public class LoginServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        HttpSession session = request.getSession(false);
        if (session != null && session.getAttribute("currentUser") != null) {
            User user = (User) session.getAttribute("currentUser");
            redirectBasedOnRole(request, response, user);
            return;
        }
        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username");
        String password = request.getParameter("password");

        if (username != null) username = username.trim();

        if (username == null || username.isEmpty() || password == null || password.isEmpty()) {
            handleError(request, response, "Vui lòng nhập đầy đủ thông tin.", username);
            return;
        }

        try {
            User user = userDAO.findByUsername(username);

            if (user == null) {
                handleError(request, response, "Tài khoản hoặc mật khẩu không chính xác.", username);
                return;
            }

            String storedHash = user.getPasswordHash();
            boolean match = false;

            if (storedHash == null) {
                match = false;
            }
            else if (storedHash.startsWith("$2a$") || storedHash.startsWith("$2y$") || storedHash.startsWith("$2b$")) {
                try {
                    match = BCrypt.checkpw(password, storedHash);
                } catch (IllegalArgumentException e) {
                    match = false;
                }
            }
            else {
                match = storedHash.equals(password);
            }

            if (!match) {
                handleError(request, response, "Tài khoản hoặc mật khẩu không chính xác.", username);
                return;
            }
            
            // Kiểm tra xác thực email
            if (!user.isVerified()) {
                handleError(request, response, "Tài khoản chưa được xác thực. Vui lòng kiểm tra email của bạn.", username);
                return;
            }

            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setMaxInactiveInterval(30 * 60); 
            
            redirectBasedOnRole(request, response, user);

        } catch (SQLException e) {
            e.printStackTrace();
            handleError(request, response, "Lỗi hệ thống. Vui lòng thử lại.", username);
        }
    }
    
    private void redirectBasedOnRole(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        Role userRole = user.getRole();

        if (userRole == Role.ADMIN) {
            // Admin -> /admin?action=dashboard
            response.sendRedirect(request.getContextPath() + "/admin?action=dashboard");
        } else if (userRole == Role.COLLECTOR_COMPANY) {
            // Collector Company -> /dashboard/company
            response.sendRedirect(request.getContextPath() + "/dashboard/company");
        } else {
            // User -> /
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    private void handleError(HttpServletRequest req, HttpServletResponse resp, String msg, String username) throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
}
