package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import ecogive.Model.Notification;
import ecogive.Model.User;
import ecogive.dao.NotificationDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/notifications")
public class NotificationApiServlet extends HttpServlet {

    private final NotificationDAO notificationDAO = new NotificationDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(401);
            return;
        }

        try {
            // Lấy 10 thông báo mới nhất
            List<Notification> list = notificationDAO.findByUserId(currentUser.getUserId(), 10);
            int unreadCount = notificationDAO.countUnread(currentUser.getUserId());

            JsonObject result = new JsonObject();
            result.addProperty("unreadCount", unreadCount);
            
            JsonArray jsonList = new JsonArray();
            for (Notification n : list) {
                JsonObject obj = new JsonObject();
                obj.addProperty("id", n.getNotificationId());
                obj.addProperty("content", n.getContent());
                obj.addProperty("type", n.getType());
                obj.addProperty("isRead", n.isRead());
                obj.addProperty("createdAt", n.getCreatedAt().toString());
                if (n.getReferenceId() != null) {
                    obj.addProperty("referenceId", n.getReferenceId());
                }
                jsonList.add(obj);
            }
            result.add("notifications", jsonList);

            resp.getWriter().write(gson.toJson(result));

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(401);
            return;
        }

        String action = req.getParameter("action");
        try {
            if ("read".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                notificationDAO.markAsRead(id);
                response.addProperty("status", "success");
            } else if ("read_all".equals(action)) {
                notificationDAO.markAllAsRead(currentUser.getUserId());
                response.addProperty("status", "success");
            } else if ("delete".equals(action)) {
                long id = Long.parseLong(req.getParameter("id"));
                notificationDAO.delete(id);
                response.addProperty("status", "success");
            } else {
                response.addProperty("status", "error");
                response.addProperty("message", "Invalid action");
            }
        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}
