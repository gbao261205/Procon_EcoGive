package ecogive.Controller;

import ecogive.Model.User;
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/chat")
public class ChatPageServlet extends HttpServlet {
    
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendRedirect(req.getContextPath() + "/login");
            return;
        }
        
        // Nếu có partnerId, lấy thông tin partner để hiển thị display_name ngay khi load trang
        String partnerIdStr = req.getParameter("partnerId");
        if (partnerIdStr != null && !partnerIdStr.isEmpty()) {
            try {
                long partnerId = Long.parseLong(partnerIdStr);
                User partner = userDAO.findById(partnerId);
                if (partner != null) {
                    String displayName = partner.getDisplayName();
                    if (displayName == null || displayName.isEmpty()) {
                        displayName = partner.getUsername();
                    }
                    req.setAttribute("partnerDisplayName", displayName);
                }
            } catch (NumberFormatException | SQLException e) {
                e.printStackTrace();
            }
        }

        // Forward to chat.jsp
        req.getRequestDispatcher("/WEB-INF/views/chat.jsp").forward(req, resp);
    }
}
