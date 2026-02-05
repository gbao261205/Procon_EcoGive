package ecogive.Controller;

import ecogive.Model.User;
import ecogive.dao.UserDAO;
import ecogive.util.EmailUtility;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.UUID;

@WebServlet("/forgot-password")
public class ForgotPasswordServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() throws ServletException {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        String email = request.getParameter("email");

        if (email == null || email.trim().isEmpty()) {
            request.setAttribute("error", "Vui lòng nhập email.");
            request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
            return;
        }

        try {
            User user = userDAO.findByEmail(email);
            if (user != null) {
                // Tạo token
                String token = UUID.randomUUID().toString();
                user.setResetToken(token);
                user.setResetTokenExpiry(LocalDateTime.now().plusHours(1)); // Hết hạn sau 1 giờ

                userDAO.update(user);

                // Gửi email
                String resetLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                        + request.getContextPath() + "/reset-password?token=" + token;
                
                String subject = "Đặt lại mật khẩu EcoGive";
                String content = "<p>Xin chào,</p>"
                        + "<p>Bạn đã yêu cầu đặt lại mật khẩu. Vui lòng nhấp vào liên kết bên dưới để đặt lại mật khẩu của bạn:</p>"
                        + "<p><a href=\"" + resetLink + "\">Đặt lại mật khẩu</a></p>"
                        + "<p>Liên kết này sẽ hết hạn sau 1 giờ.</p>";

                try {
                    EmailUtility.sendEmail(email, subject, content);
                    request.setAttribute("message", "Một email hướng dẫn đặt lại mật khẩu đã được gửi đến địa chỉ của bạn.");
                } catch (Exception e) {
                    e.printStackTrace();
                    request.setAttribute("error", "Lỗi khi gửi email: " + e.getMessage());
                }
            } else {
                // Để bảo mật, chúng ta vẫn hiển thị thông báo thành công ngay cả khi email không tồn tại
                request.setAttribute("message", "Nếu email tồn tại trong hệ thống, bạn sẽ nhận được hướng dẫn đặt lại mật khẩu.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        }

        request.getRequestDispatcher("/WEB-INF/views/forgot-password.jsp").forward(request, response);
    }
}
