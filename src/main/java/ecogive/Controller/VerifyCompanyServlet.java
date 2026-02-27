package ecogive.Controller;

import ecogive.Model.Role;
import ecogive.Model.User;
import ecogive.dao.UserDAO;
import ecogive.util.CloudinaryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;

@WebServlet("/verify-company")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class VerifyCompanyServlet extends HttpServlet {

    private final UserDAO userDAO = new UserDAO();
    private final CloudinaryService cloudinaryService = new CloudinaryService();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        // Chỉ cho phép tài khoản COLLECTOR_COMPANY truy cập
        if (currentUser.getRole() != Role.COLLECTOR_COMPANY) {
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Chức năng chỉ dành cho tài khoản doanh nghiệp.");
            return;
        }

        req.getRequestDispatcher("/WEB-INF/views/verify-company.jsp").forward(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null || currentUser.getRole() != Role.COLLECTOR_COMPANY) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }

        try {
            Part filePart = req.getPart("documentImage");
            if (filePart == null || filePart.getSize() == 0) {
                req.setAttribute("error", "Vui lòng chọn ảnh giấy phép kinh doanh.");
                req.getRequestDispatcher("/WEB-INF/views/verify-company.jsp").forward(req, resp);
                return;
            }

            String imageUrl = cloudinaryService.uploadImage(filePart);
            
            if (userDAO.updateCompanyVerificationRequest(currentUser.getUserId(), imageUrl)) {
                // Cập nhật session
                currentUser.setCompanyVerificationStatus("PENDING");
                currentUser.setVerificationDocument(imageUrl);
                session.setAttribute("currentUser", currentUser);
                
                req.setAttribute("message", "Đã gửi yêu cầu xác thực thành công! Vui lòng chờ Admin duyệt.");
            } else {
                req.setAttribute("error", "Lỗi khi cập nhật thông tin. Vui lòng thử lại.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            req.setAttribute("error", "Lỗi hệ thống: " + e.getMessage());
        }
        
        req.getRequestDispatcher("/WEB-INF/views/verify-company.jsp").forward(req, resp);
    }
}
