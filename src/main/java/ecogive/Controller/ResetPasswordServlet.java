package ecogive.Controller;

import ecogive.Model.User;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import org.mindrot.jbcrypt.BCrypt;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;

@WebServlet("/reset-password")
public class ResetPasswordServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");

        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Mã xác thực không hợp lệ.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.findByResetToken(token);
            if (user == null || user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {
                request.setAttribute("error", "Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                return;
            }

            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
        }
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String token = request.getParameter("token");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        if (token == null || token.isEmpty()) {
            request.setAttribute("error", "Mã xác thực bị thiếu.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            return;
        }

        if (password == null || password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.findByResetToken(token);
            if (user == null || user.getResetTokenExpiry().isBefore(LocalDateTime.now())) {
                request.setAttribute("error", "Liên kết đặt lại mật khẩu không hợp lệ hoặc đã hết hạn.");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                return;
            }

            // Cập nhật mật khẩu
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            user.setPasswordHash(hashedPassword);
            user.setResetToken(null);
            user.setResetTokenExpiry(null);

            userDAO.update(user);

            request.setAttribute("success", "true"); // Để login.jsp hiển thị thông báo thành công nếu cần
            request.setAttribute("message", "Đặt lại mật khẩu thành công. Vui lòng đăng nhập.");
            request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống khi cập nhật mật khẩu.");
            request.setAttribute("token", token);
            request.getRequestDispatcher("/WEB-INF/views/reset-password.jsp").forward(request, response);
        }
    }
}
