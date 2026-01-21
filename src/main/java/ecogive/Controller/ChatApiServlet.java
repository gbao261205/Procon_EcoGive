package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import ecogive.Model.User;
import ecogive.util.DatabaseConnection;
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
        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1. INBOX LIST
            if ("inbox".equals(action)) {
                // SỬA ĐỔI: Dùng separator "|||" để tránh lỗi khi tên item chứa ":"
                String sql = "SELECT u.user_id, u.username, " +
                        "(SELECT content FROM messages m WHERE (m.sender_id = u.user_id AND m.receiver_id = ?) " +
                        "OR (m.sender_id = ? AND m.receiver_id = u.user_id) ORDER BY m.created_at DESC LIMIT 1) as last_msg, " +

                        // Subquery lấy item info
                        "(SELECT CONCAT(t.item_id, '|||', i.title, '|||', i.giver_id) " +
                        " FROM transactions t JOIN items i ON t.item_id = i.item_id " +
                        " WHERE (t.receiver_id = ? AND i.giver_id = u.user_id) " +
                        "    OR (t.receiver_id = u.user_id AND i.giver_id = ?) " +
                        " ORDER BY t.transaction_id DESC LIMIT 1) as item_info " +

                        "FROM users u " +
                        "WHERE u.user_id IN (" +
                        "   SELECT sender_id FROM messages WHERE receiver_id = ? " +
                        "   UNION " +
                        "   SELECT receiver_id FROM messages WHERE sender_id = ? " +
                        "   UNION " +
                        "   SELECT i.giver_id FROM transactions t JOIN items i ON t.item_id = i.item_id WHERE t.receiver_id = ? " +
                        "   UNION " +
                        "   SELECT t.receiver_id FROM transactions t JOIN items i ON t.item_id = i.item_id WHERE i.giver_id = ? " +
                        ")";

                PreparedStatement ps = conn.prepareStatement(sql);
                long uid = currentUser.getUserId();
                
                ps.setLong(1, uid);
                ps.setLong(2, uid);
                ps.setLong(3, uid);
                ps.setLong(4, uid);
                ps.setLong(5, uid);
                ps.setLong(6, uid);
                ps.setLong(7, uid);
                ps.setLong(8, uid);

                ResultSet rs = ps.executeQuery();
                JsonArray inboxList = new JsonArray();
                while(rs.next()) {
                    JsonObject obj = new JsonObject();
                    obj.addProperty("userId", rs.getLong("user_id"));
                    obj.addProperty("username", rs.getString("username"));
                    
                    String lastMsg = rs.getString("last_msg");
                    if (lastMsg == null) lastMsg = "Bắt đầu cuộc trò chuyện...";
                    obj.addProperty("lastMsg", lastMsg);

                    // Parse item info với separator mới
                    String itemInfo = rs.getString("item_info");
                    if (itemInfo != null) {
                        // Escape pipe | vì split dùng regex
                        String[] parts = itemInfo.split("\\|\\|\\|");
                        if (parts.length >= 3) {
                            try {
                                obj.addProperty("itemId", Long.parseLong(parts[0]));
                                obj.addProperty("itemName", parts[1]);
                                obj.addProperty("giverId", Long.parseLong(parts[2]));
                            } catch (NumberFormatException e) {
                                // Ignore parse error
                            }
                        }
                    }

                    inboxList.add(obj);
                }
                resp.getWriter().write(new Gson().toJson(inboxList));
            }

            // 2. CHAT HISTORY
            else if ("history".equals(action)) {
                long partnerId = Long.parseLong(req.getParameter("partnerId"));
                long myId = currentUser.getUserId();

                String sql = "SELECT * FROM messages WHERE (sender_id = ? AND receiver_id = ?) " +
                        "OR (sender_id = ? AND receiver_id = ?) ORDER BY created_at ASC";

                PreparedStatement ps = conn.prepareStatement(sql);
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