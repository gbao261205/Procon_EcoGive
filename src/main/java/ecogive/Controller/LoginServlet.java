//package ecogive.Controller;
//
//import ecogive.Model.User;
//import ecogive.dao.UserDAO;
//import jakarta.servlet.ServletException;
//import jakarta.servlet.annotation.WebServlet;
//import jakarta.servlet.http.HttpServlet;
//import jakarta.servlet.http.HttpServletRequest;
//import jakarta.servlet.http.HttpServletResponse;
//import jakarta.servlet.http.HttpSession;
//import org.mindrot.jbcrypt.BCrypt;
//
//import java.io.IOException;
//import java.sql.SQLException;
//
//@WebServlet("/login")
//public class LoginServlet extends HttpServlet{
//    private UserDAO userDAO;
//
//    @Override
//    public void init() throws ServletException {
//        userDAO = new UserDAO(); // hoặc inject tùy cách bạn dùng
//    }
//
//    @Override
//    protected void doGet(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//        // Nếu đã đăng nhập thì chuyển qua trang khác (home, dashboard,...)
//        HttpSession session = request.getSession(false);
//        if (session != null && session.getAttribute("currentUser") != null) {
//            response.sendRedirect(request.getContextPath() + "/"); // chỉnh lại đường dẫn nếu cần
//            return;
//        }
//
//        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
//    }
//
//    @Override
//    protected void doPost(HttpServletRequest request, HttpServletResponse response)
//            throws ServletException, IOException {
//
//        // Lấy param từ form
//        String username = request.getParameter("username");
//        String password = request.getParameter("password");
//
//        // Trim để tránh space thừa
//        if (username != null) username = username.trim();
//
//        // Validate đơn giản phía server
//        if (username == null || username.isEmpty() ||
//                password == null || password.isEmpty()) {
//            request.setAttribute("error", "Vui lòng nhập đầy đủ tên đăng nhập và mật khẩu.");
//            request.setAttribute("username", username);
//            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
//            return;
//        }
//
//        try {
//            User user = userDAO.findByUsername(username);
//
//            if (user == null) {
//                // Không tìm thấy user
//                request.setAttribute("error", "Tài khoản không tồn tại.");
//                request.setAttribute("username", username);
//                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
//                return;
//            }
//
//            String hashed = user.getPasswordHash(); // cột password_hash trong DB
//            boolean match = hashed != null && BCrypt.checkpw(password, hashed);
//
//            if (!match) {
//                // Sai mật khẩu
//                request.setAttribute("error", "Mật khẩu không chính xác.");
//                request.setAttribute("username", username);
//                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
//                return;
//            }
//
//            // Đăng nhập thành công
//            HttpSession session = request.getSession(true);
//            session.setAttribute("currentUser", user);
//
//            // Có thể set thời gian timeout session (vd: 30 phút)
//            session.setMaxInactiveInterval(30 * 60);
//
//            // Chuyển sang trang chính sau khi login
//            response.sendRedirect(request.getContextPath() + "/"); // chỉnh lại cho phù hợp project
//
//        } catch (SQLException e) {
//            e.printStackTrace();
//            request.setAttribute("error", "Có lỗi xảy ra. Vui lòng thử lại sau.");
//            request.setAttribute("username", username);
//            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
//        }
//    }
//}
package ecogive.Controller;

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
                handleError(request, response, "Tài khoản không tồn tại.", username);
                return;
            }

            // === SỬA LỖI 500 Ở ĐÂY ===
            String storedHash = user.getPasswordHash();
            boolean match = false;

            if (storedHash == null) {
                match = false;
            }
            // Kiểm tra xem có phải định dạng BCrypt không ($2a$, $2y$, $2b$)
            else if (storedHash.startsWith("$2a$") || storedHash.startsWith("$2y$") || storedHash.startsWith("$2b$")) {
                try {
                    match = BCrypt.checkpw(password, storedHash);
                } catch (IllegalArgumentException e) {
                    // Nếu hash bị lỗi format dù có tiền tố -> coi như sai pass
                    match = false;
                }
            }
            // Nếu không phải BCrypt, so sánh chuỗi thường (cho dữ liệu cũ/test)
            else {
                match = storedHash.equals(password);
            }

            if (!match) {
                handleError(request, response, "Mật khẩu không chính xác.", username);
                return;
            }

            // Đăng nhập thành công
            HttpSession session = request.getSession(true);
            session.setAttribute("currentUser", user);
            session.setMaxInactiveInterval(30 * 60); // 30 phút
            //PHÂN QUYỀN
            redirectBasedOnRole(request, response, user);

        } catch (SQLException e) {
            e.printStackTrace();
            handleError(request, response, "Lỗi hệ thống. Vui lòng thử lại.", username);
        }
    }
    private void redirectBasedOnRole(HttpServletRequest request, HttpServletResponse response, User user) throws IOException {
        if ("ADMIN".equals(user.getRole())) {
            // Nếu là Admin -> Vào Dashboard
            response.sendRedirect(request.getContextPath() + "/admin?action=dashboard");
        } else {
            // Nếu là User -> Vào trang chủ (Nếu chưa có file home thì tạm để /)
            response.sendRedirect(request.getContextPath() + "/");
        }
    }

    // Hàm phụ trợ xử lý lỗi hiển thị lại trang login
    private void handleError(HttpServletRequest req, HttpServletResponse resp, String msg, String username) throws ServletException, IOException {
        req.setAttribute("error", msg);
        req.setAttribute("username", username);
        req.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(req, resp);
    }
}