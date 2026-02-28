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
        handleRequest(req, resp);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        handleRequest(req, resp);
    }

    private void handleRequest(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(401);
            JsonObject err = new JsonObject();
            err.addProperty("error", "Unauthorized");
            resp.getWriter().write(new Gson().toJson(err));
            return;
        }

        String action = req.getParameter("action");
        try (Connection conn = DatabaseConnection.getConnection()) {

            // 1. INBOX LIST
            if ("inbox".equals(action)) {
                String sql = "SELECT u.user_id, u.username, u.display_name, " + // Thêm display_name
                        "(SELECT content FROM messages m WHERE (m.sender_id = u.user_id AND m.receiver_id = ?) " +
                        "OR (m.sender_id = ? AND m.receiver_id = u.user_id) ORDER BY m.created_at DESC LIMIT 1) as last_msg, " +
                        
                        // --- MỚI: Lấy thời gian tin nhắn cuối cùng để sắp xếp ---
                        "(SELECT created_at FROM messages m WHERE (m.sender_id = u.user_id AND m.receiver_id = ?) " +
                        "OR (m.sender_id = ? AND m.receiver_id = u.user_id) ORDER BY m.created_at DESC LIMIT 1) as last_msg_time, " +
                        // --------------------------------------------------------

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
                        ") " +
                        "ORDER BY last_msg_time DESC"; // Sắp xếp theo thời gian

                PreparedStatement ps = conn.prepareStatement(sql);
                long uid = currentUser.getUserId();
                
                // Set tham số (tổng cộng 10 tham số uid)
                for(int i=1; i<=10; i++) ps.setLong(i, uid);

                ResultSet rs = ps.executeQuery();
                JsonArray inboxList = new JsonArray();
                while(rs.next()) {
                    JsonObject obj = new JsonObject();
                    obj.addProperty("userId", rs.getLong("user_id"));
                    obj.addProperty("username", rs.getString("username"));
                    
                    // Lấy display_name, nếu null thì fallback về username
                    String displayName = rs.getString("display_name");
                    if (displayName == null || displayName.isEmpty()) {
                        displayName = rs.getString("username");
                    }
                    obj.addProperty("displayName", displayName);
                    
                    String lastMsg = rs.getString("last_msg");
                    if (lastMsg == null) lastMsg = "Bắt đầu cuộc trò chuyện...";
                    obj.addProperty("lastMsg", lastMsg);
                    
                    // Có thể trả về lastMsgTime nếu cần hiển thị thời gian
                    Timestamp ts = rs.getTimestamp("last_msg_time");
                    if (ts != null) {
                        obj.addProperty("lastMsgTime", ts.toString());
                    }

                    String itemInfo = rs.getString("item_info");
                    if (itemInfo != null) {
                        String[] parts = itemInfo.split("\\|\\|\\|");
                        if (parts.length >= 3) {
                            try {
                                obj.addProperty("itemId", Long.parseLong(parts[0]));
                                obj.addProperty("itemName", parts[1]);
                                obj.addProperty("giverId", Long.parseLong(parts[2]));
                            } catch (NumberFormatException e) {}
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
                
                boolean hasImageColumn = false;
                try {
                    rs.findColumn("image_url");
                    hasImageColumn = true;
                } catch (SQLException e) {}

                JsonArray history = new JsonArray();
                while(rs.next()) {
                    JsonObject msg = new JsonObject();
                    msg.addProperty("senderId", rs.getLong("sender_id"));
                    String content = rs.getString("content");
                    msg.addProperty("content", content);
                    
                    if (hasImageColumn) {
                        msg.addProperty("imageUrl", rs.getString("image_url"));
                    }
                    msg.addProperty("createdAt", rs.getString("created_at"));

                    // --- LOGIC MỚI: Kiểm tra trạng thái Trade nếu là tin nhắn đề nghị ---
                    if (content != null && content.startsWith("SYSTEM_TRADE_PROPOSAL:")) {
                        try {
                            long transId = Long.parseLong(content.split(":")[1]);
                            String statusSql = "SELECT status FROM transactions WHERE transaction_id = ?";
                            try (PreparedStatement psStatus = conn.prepareStatement(statusSql)) {
                                psStatus.setLong(1, transId);
                                try (ResultSet rsStatus = psStatus.executeQuery()) {
                                    if (rsStatus.next()) {
                                        msg.addProperty("tradeStatus", rsStatus.getString("status"));
                                    }
                                }
                            }
                        } catch (Exception e) {
                            // Ignore error parsing
                        }
                    }

                    history.add(msg);
                }
                resp.getWriter().write(new Gson().toJson(history));
            }

            // 3. ACTIVE DEALS
            else if ("active_deals".equals(action)) {
                long partnerId = Long.parseLong(req.getParameter("partnerId"));
                long myId = currentUser.getUserId();

                String sql = "SELECT t.transaction_id, t.item_id, i.title, i.giver_id, t.status, t.transaction_type " +
                             "FROM transactions t " +
                             "JOIN items i ON t.item_id = i.item_id " +
                             "WHERE ((t.receiver_id = ? AND i.giver_id = ?) OR (t.receiver_id = ? AND i.giver_id = ?)) " +
                             "AND t.status IN ('PENDING', 'CONFIRMED', 'PENDING_TRADE', 'TRADE_ACCEPTED', 'CONFIRMED_BY_A', 'CONFIRMED_BY_B') " +
                             "ORDER BY t.transaction_id DESC";

                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, myId);
                ps.setLong(2, partnerId);
                ps.setLong(3, partnerId);
                ps.setLong(4, myId);

                ResultSet rs = ps.executeQuery();
                JsonArray deals = new JsonArray();
                while(rs.next()) {
                    JsonObject deal = new JsonObject();
                    deal.addProperty("transactionId", rs.getLong("transaction_id"));
                    deal.addProperty("itemId", rs.getLong("item_id"));
                    deal.addProperty("itemName", rs.getString("title"));
                    deal.addProperty("giverId", rs.getLong("giver_id"));
                    deal.addProperty("status", rs.getString("status"));
                    deal.addProperty("type", rs.getString("transaction_type"));
                    deals.add(deal);
                }
                resp.getWriter().write(new Gson().toJson(deals));
            }

            // 4. ITEM DETAIL
            else if ("item_detail".equals(action)) {
                long itemId = Long.parseLong(req.getParameter("itemId"));
                String sql = "SELECT i.*, u.username as giver_name, u.display_name as giver_display_name, c.name as category_name " +
                             "FROM items i " +
                             "JOIN users u ON i.giver_id = u.user_id " +
                             "LEFT JOIN categories c ON i.category_id = c.category_id " +
                             "WHERE i.item_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, itemId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    JsonObject item = new JsonObject();
                    item.addProperty("itemId", rs.getLong("item_id"));
                    item.addProperty("title", rs.getString("title"));
                    item.addProperty("description", rs.getString("description"));
                    item.addProperty("imageUrl", rs.getString("image_url"));
                    item.addProperty("address", rs.getString("address"));
                    item.addProperty("ecoPoints", rs.getBigDecimal("eco_points"));
                    
                    String giverName = rs.getString("giver_name");
                    String giverDisplayName = rs.getString("giver_display_name");
                    item.addProperty("giverName", giverDisplayName != null ? giverDisplayName : giverName);
                    
                    item.addProperty("categoryName", rs.getString("category_name"));
                    item.addProperty("status", rs.getString("status"));
                    resp.getWriter().write(new Gson().toJson(item));
                } else {
                    resp.setStatus(404);
                }
            }

            // 5. USER INFO
            else if ("user_info".equals(action)) {
                long userId = Long.parseLong(req.getParameter("userId"));
                String sql = "SELECT user_id, username, display_name, email, eco_points, reputation_score, join_date, role, address " +
                             "FROM users WHERE user_id = ?";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, userId);
                ResultSet rs = ps.executeQuery();
                if (rs.next()) {
                    JsonObject user = new JsonObject();
                    user.addProperty("userId", rs.getLong("user_id"));
                    user.addProperty("username", rs.getString("username"));
                    
                    String displayName = rs.getString("display_name");
                    if (displayName == null || displayName.isEmpty()) {
                        displayName = rs.getString("username");
                    }
                    user.addProperty("displayName", displayName);

                    user.addProperty("email", rs.getString("email"));
                    user.addProperty("ecoPoints", rs.getBigDecimal("eco_points"));
                    user.addProperty("reputationScore", rs.getBigDecimal("reputation_score"));
                    user.addProperty("joinDate", rs.getTimestamp("join_date").toString());
                    user.addProperty("role", rs.getString("role"));
                    user.addProperty("address", rs.getString("address"));
                    
                    String countSql = "SELECT COUNT(*) FROM transactions t JOIN items i ON t.item_id = i.item_id " +
                                      "WHERE i.giver_id = ? AND t.status = 'COMPLETED'";
                    PreparedStatement psCount = conn.prepareStatement(countSql);
                    psCount.setLong(1, userId);
                    ResultSet rsCount = psCount.executeQuery();
                    if (rsCount.next()) user.addProperty("givenCount", rsCount.getInt(1));
                    
                    resp.getWriter().write(new Gson().toJson(user));
                } else {
                    resp.setStatus(404);
                }
            }
            
            // 6. DELETE CONVERSATION
            else if ("delete_conversation".equals(action)) {
                long partnerId = Long.parseLong(req.getParameter("partnerId"));
                long myId = currentUser.getUserId();

                String sql = "DELETE FROM messages WHERE (sender_id = ? AND receiver_id = ?) OR (sender_id = ? AND receiver_id = ?)";
                PreparedStatement ps = conn.prepareStatement(sql);
                ps.setLong(1, myId);
                ps.setLong(2, partnerId);
                ps.setLong(3, partnerId);
                ps.setLong(4, myId);
                
                int rows = ps.executeUpdate();
                
                JsonObject respObj = new JsonObject();
                respObj.addProperty("status", "success");
                respObj.addProperty("message", "Đã xóa " + rows + " tin nhắn.");
                resp.getWriter().write(new Gson().toJson(respObj));
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(500);
        }
    }
}
