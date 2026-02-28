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
import java.util.regex.Pattern;

@WebServlet("/register-collector")
public class RegisterCollectorServlet extends HttpServlet {
    private UserDAO userDAO;
    private static final String EMAIL_REGEX = "^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$";
    private static final String PHONE_REGEX = "^0[0-9]{9}$"; // Bắt đầu bằng 0, theo sau là 9 chữ số

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {

        String username = request.getParameter("username"); // Tên đăng nhập (ID)
        String displayName = request.getParameter("displayName"); // Tên Doanh nghiệp
        String email = request.getParameter("email");
        String phoneNumber = request.getParameter("phoneNumber");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Keep user input in case of error
        request.setAttribute("username", username);
        request.setAttribute("displayName", displayName);
        request.setAttribute("email", email);
        request.setAttribute("phoneNumber", phoneNumber);
        request.setAttribute("address", address);

        // --- Validation ---
        if (username == null || username.trim().isEmpty() ||
            displayName == null || displayName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phoneNumber == null || phoneNumber.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            password == null || password.isEmpty()) {
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin.");
            request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
            return;
        }

        if (!Pattern.matches(EMAIL_REGEX, email)) {
            request.setAttribute("error", "Địa chỉ email không hợp lệ.");
            request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
            return;
        }

        if (!Pattern.matches(PHONE_REGEX, phoneNumber)) {
            request.setAttribute("error", "Số điện thoại không hợp lệ (phải bắt đầu bằng 0 và có 10 chữ số).");
            request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
            return;
        }

        if (password.length() < 6) {
            request.setAttribute("error", "Mật khẩu phải có ít nhất 6 ký tự.");
            request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
            return;
        }

        try {
            // Check if username already exists
            if (userDAO.findByUsername(username) != null) {
                request.setAttribute("error", "Tên đăng nhập đã tồn tại.");
                request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
                return;
            }
            
            // Check if email already exists
            if (userDAO.findByEmail(email) != null) {
                request.setAttribute("error", "Email đã được sử dụng.");
                request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
                return;
            }
            
            // --- Create New Collector User ---
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
            String verificationToken = UUID.randomUUID().toString(); // Generate Token

            User newUser = new User();
            newUser.setUsername(username);
            newUser.setDisplayName(displayName); // Lưu tên doanh nghiệp vào display_name
            newUser.setEmail(email);
            newUser.setPhoneNumber(phoneNumber);
            newUser.setAddress(address);
            newUser.setPasswordHash(hashedPassword);
            newUser.setRole(Role.COLLECTOR_COMPANY); // Set role
            newUser.setEcoPoints(BigDecimal.ZERO);
            newUser.setReputationScore(BigDecimal.valueOf(1.00));
            newUser.setJoinDate(LocalDateTime.now());
            newUser.setVerified(false); // Chưa xác thực
            newUser.setVerificationToken(verificationToken); // Lưu token

            if (userDAO.insert(newUser)) {
                // --- Gửi email xác thực ---
                String verifyLink = request.getScheme() + "://" + request.getServerName() + ":" + request.getServerPort()
                        + request.getContextPath() + "/verify?token=" + verificationToken;

                String subject = "Xác thực tài khoản Doanh nghiệp EcoGive";
                String content = "<p>Xin chào " + displayName + ",</p>"
                        + "<p>Cảm ơn bạn đã đăng ký tài khoản Đối tác Thu gom tại EcoGive.</p>"
                        + "<p>Vui lòng nhấp vào liên kết bên dưới để kích hoạt tài khoản doanh nghiệp của bạn:</p>"
                        + "<p><a href=\"" + verifyLink + "\">Xác thực tài khoản ngay</a></p>"
                        + "<p>Trân trọng,<br>Đội ngũ EcoGive</p>";

                try {
                    EmailUtility.sendEmail(email, subject, content);
                    request.setAttribute("message", "Đăng ký thành công! Vui lòng kiểm tra email để xác thực tài khoản doanh nghiệp.");
                    request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
                } catch (Exception e) {
                    e.printStackTrace();
                    // User đã được tạo nhưng gửi mail lỗi
                    request.setAttribute("error", "Đăng ký thành công nhưng không thể gửi email xác thực. Vui lòng liên hệ Admin.");
                    request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
                }
            } else {
                request.setAttribute("error", "Không thể tạo tài khoản. Vui lòng thử lại.");
                request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
            }

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi với cơ sở dữ liệu. Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/register-collector.jsp").forward(request, response);
        }
    }
}
