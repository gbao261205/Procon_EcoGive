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
import java.math.BigDecimal;
import java.sql.SQLException;
import java.time.LocalDateTime;

@WebServlet("/register/collector-company")
public class RegisterCollectorServlet extends HttpServlet {
    private UserDAO userDAO;

    @Override
    public void init() {
        userDAO = new UserDAO();
    }

    @Override
    protected void doGet(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        request.getRequestDispatcher("/WEB-INF/views/register_collector.jsp").forward(request, response);
    }

    @Override
    protected void doPost(HttpServletRequest request, HttpServletResponse response)
            throws ServletException, IOException {
        
        String companyName = request.getParameter("companyName");
        String email = request.getParameter("email");
        String phone = request.getParameter("phone");
        String address = request.getParameter("address");
        String password = request.getParameter("password");
        String confirmPassword = request.getParameter("confirmPassword");

        // Keep user input in case of error
        request.setAttribute("companyName", companyName);
        request.setAttribute("email", email);
        request.setAttribute("phone", phone);
        request.setAttribute("address", address);

        // --- Validation ---
        if (companyName == null || companyName.trim().isEmpty() ||
            email == null || email.trim().isEmpty() ||
            phone == null || phone.trim().isEmpty() ||
            address == null || address.trim().isEmpty() ||
            password == null || password.isEmpty()) {
            
            request.setAttribute("error", "Vui lòng điền đầy đủ thông tin.");
            request.getRequestDispatcher("/WEB-INF/views/register_collector.jsp").forward(request, response);
            return;
        }

        if (!password.equals(confirmPassword)) {
            request.setAttribute("error", "Mật khẩu xác nhận không khớp.");
            request.getRequestDispatcher("/WEB-INF/views/register_collector.jsp").forward(request, response);
            return;
        }

        try {
            // Check if username (company name) already exists
            if (userDAO.findByUsername(companyName) != null) {
                request.setAttribute("error", "Tên doanh nghiệp đã tồn tại.");
                request.getRequestDispatcher("/WEB-INF/views/register_collector.jsp").forward(request, response);
                return;
            }
            
            // --- Create New Collector Company User ---
            String hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());

            User newUser = new User();
            newUser.setUsername(companyName);
            newUser.setEmail(email);
            newUser.setPasswordHash(hashedPassword);
            newUser.setPhone(phone);
            newUser.setAddress(address);
            newUser.setRole("ENTERPRISE_COLLECTOR"); // Set role
            newUser.setEcoPoints(BigDecimal.ZERO);
            newUser.setReputationScore(BigDecimal.valueOf(3.00)); // Default reputation for collectors
            newUser.setJoinDate(LocalDateTime.now());

            userDAO.insertCollectorCompany(newUser);

            // Redirect to login page with a success message
            response.sendRedirect(request.getContextPath() + "/login?success=true");

        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Đã xảy ra lỗi với cơ sở dữ liệu. Vui lòng thử lại.");
            request.getRequestDispatcher("/WEB-INF/views/register_collector.jsp").forward(request, response);
        }
    }
}
