package ecogive.Controller;

import ecogive.Model.User;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/verify")
public class VerifyAccountServlet extends HttpServlet {
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
            User user = userDAO.findByVerificationToken(token);
            if (user != null) {
                if (user.isVerified()) {
                    request.setAttribute("message", "Tài khoản đã được xác thực trước đó. Vui lòng đăng nhập.");
                } else {
                    userDAO.verifyUser(user.getUserId());
                    request.setAttribute("message", "Xác thực tài khoản thành công! Bạn có thể đăng nhập ngay bây giờ.");
                }
            } else {
                request.setAttribute("error", "Mã xác thực không hợp lệ hoặc không tồn tại.");
            }
        } catch (SQLException e) {
            e.printStackTrace();
            request.setAttribute("error", "Lỗi hệ thống khi xác thực tài khoản.");
        }

        request.getRequestDispatcher("/WEB-INF/views/login.jsp").forward(request, response);
    }
}
