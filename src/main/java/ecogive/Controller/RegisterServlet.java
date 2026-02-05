package ecogive.Controller;

import ecogive.Model.Role;
import ecogive.Model.User;
import ecogive.dao.UserDAO;
import ecogive.util.EmailUtility;
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
import java.util.UUID;

@WebServlet("/register")
public class RegisterServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String username = request.getParameter("username");
        String email = request.getParameter("email");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        request.setAttribute("username", username);
        request.setAttribute("email", email);

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            return;
        }

        try {
            if (userDAO.findByUsername(username) != null) {
                request.setAttribute("error", "Tên đăng nhập đã tồn tại.");
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                return;
            }
            
            if (userDAO.findByEmail(email) != null) {
                request.setAttribute("error", "Email đã được sử dụng.");
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
                return;
            }
            
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            String verificationToken = UUID.randomUUID().toString();

            User newUser = new User();
            newUser.setUsername(username);
            newUser.setEmail(email);
            newUser.setPasswordHash(hashedPassword);
            newUser.setRole(Role.USER);
            newUser.setEcoPoints(BigDecimal.ZERO);
            newUser.setReputationScore(BigDecimal.valueOf(1.00));
            newUser.setJoinDate(LocalDateTime.now());
            newUser.setVerified(false); // Chưa xác thực
            newUser.setVerificationToken(verificationToken);

            userDAO.insert(newUser);

            // Gửi email xác thực
            String verifyLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                    + request.getContextPath() + "/verify?token=" + verificationToken;
            
            String subject = "Xác thực tài khoản EcoGive";
            String content = "<p>Xin chào " + username + ",</p>"
                    + "<p>Cảm ơn bạn đã đăng ký tài khoản EcoGive. Vui lòng nhấp vào liên kết bên dưới để kích hoạt tài khoản của bạn:</p>"
                    + "<p><a href=\"" + verifyLink + "\">Xác thực tài khoản</a></p>";

            try {
                EmailUtility.sendEmail(email, subject, content);
                request.setAttribute("message", "Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản.");
                request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
            } catch (Exception e) {
                e.printStackTrace();
                request.setAttribute("error", "Đăng ký thành công nhưng không thể gửi email xác thực. Vui lòng liên hệ admin.");
                request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi với cơ sở dữ liệu. Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/register.jsp").forward(request, response);
        }
    }
}
