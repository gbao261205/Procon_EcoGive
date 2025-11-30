package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import ecogive.Model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.*;

@WebServlet("/api/chat")
public class ChatApiServlet extends HttpServlet {

    private Connection getConnection() throws SQLException, ClassNotFoundException {
        Class.forName("com.mysql.cj.jdbc.Driver");
        // <--- NHỚ KIỂM TRA PASSWORD
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/ecogive", "root", "123456");
    }

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

        String action = req.getParameter("action");
        try (Connection conn = getConnection()) {

            // 1. INBOX LIST
            if ("inbox".equals(action)) {
                // SỬA: Bỏ "u.avatar" vì bảng users của bạn không có cột này
                String sql = "SELECT u.user_id, u.username, " +
                        "(SELECT content FROM messages m WHERE (m.sender_id = u.user_id AND m.receiver_id = ?) " +
                        "OR (m.sender_id = ? AND m.receiver_id = u.user_id) ORDER BY m.created_at DESC LIMIT 1) as last_msg " +
                        "FROM users u " +
                        "WHERE u.user_id IN (SELECT DISTINCT CASE WHEN sender_id = ? THEN receiver_id ELSE sender_id END " +
                        "FROM messages WHERE sender_id = ? OR receiver_id = ?)";

                PreparedStatement ps = conn.prepareStatement(sql);
                // SỬA: Dùng setLong thay vì setInt (vì DB là BIGINT)
                long uid = currentUser.getUserId();
                for(int i=1; i<=5; i++) ps.setLong(i, uid);

                ResultSet rs = ps.executeQuery();
                JsonArray inboxList = new JsonArray();
                while(rs.next()) {
                    JsonObject obj = new JsonObject();
                    obj.addProperty("userId", rs.getLong("user_id")); // getLong
                    obj.addProperty("username", rs.getString("username"));
                    // Tạm thời không lấy avatar nữa
                    obj.addProperty("lastMsg", rs.getString("last_msg"));
                    inboxList.add(obj);
                }
                resp.getWriter().write(new Gson().toJson(inboxList));
            }

            // 2. CHAT HISTORY
            else if ("history".equals(action)) {
                long partnerId = Long.parseLong(req.getParameter("partnerId")); // parseLong
                long myId = currentUser.getUserId();

                String sql = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) " +
                        "OR (sender_id = ? AND receiver_id = ?) ORDER BY created_at ASC";

                PreparedStatement ps = conn.prepareStatement(sql);
                // SỬA: Dùng setLong
                ps.setLong(1, myId);
                ps.setLong(2, partnerId);
                ps.setLong(3, partnerId);
                ps.setLong(4, myId);

                ResultSet rs = ps.executeQuery();
                JsonArray history = new JsonArray();
                while(rs.next()) {
                    JsonObject msg = new JsonObject();
                    msg.addProperty("senderId", rs.getLong("sender_id"));
                    msg.addProperty("content", rs.getString("content"));
                    msg.addProperty("createdAt", rs.getString("created_at"));
                    history.add(msg);
                }
                resp.getWriter().write(new Gson().toJson(history));
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
        }
    }
}