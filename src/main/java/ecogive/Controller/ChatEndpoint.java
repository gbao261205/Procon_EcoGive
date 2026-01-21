package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.util.DatabaseConnection; // Import DatabaseConnection
import jakarta.websocket.*;
import jakarta.websocket.server.PathParam;
import jakarta.websocket.server.ServerEndpoint;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.sql.SQLException;
import java.util.Map;
import java.util.concurrent.ConcurrentHashMap;

@ServerEndpoint("/chat/{userId}")
public class ChatEndpoint {
    private static final Map<String, Session> userSessions = new ConcurrentHashMap<>();
    private static final Gson gson = new Gson();

    @OnOpen
    public void onOpen(Session session, @PathParam("userId") String userId) {
        userSessions.put(userId, session);
        System.out.println("User connected: " + userId);
    }

    @OnMessage
    public void onMessage(String message, Session senderSession) {
        try {
            // 1. Parse tin nhắn từ Client
            JsonObject jsonMsg = gson.fromJson(message, JsonObject.class);
            String receiverIdStr = jsonMsg.get("receiverId").getAsString();
            String content = jsonMsg.get("content").getAsString();

            // Lấy senderId từ URL kết nối websocket
            String senderIdStr = senderSession.getPathParameters().get("userId");

            // 2. LƯU VÀO DATABASE (QUAN TRỌNG: Lưu bất kể người nhận on hay off)
            saveMessageToDB(Long.parseLong(senderIdStr), Long.parseLong(receiverIdStr), content);

            // 3. Gửi Real-time nếu người nhận đang Online
            Session receiverSession = userSessions.get(receiverIdStr);
            if (receiverSession != null && receiverSession.isOpen()) {
                JsonObject response = new JsonObject();
                response.addProperty("senderId", senderIdStr);
                response.addProperty("content", content);
                receiverSession.getBasicRemote().sendText(gson.toJson(response));
            }
        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    @OnClose
    public void onClose(Session session, @PathParam("userId") String userId) {
        userSessions.remove(userId);
    }

    @OnError
    public void onError(Session session, Throwable throwable) {
        System.err.println("Chat Error: " + throwable.getMessage());
    }

    // --- HÀM LƯU DB ĐÃ SỬA ---
    private void saveMessageToDB(long senderId, long receiverId, String content) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content) VALUES (?, ?, ?)";

        // Sử dụng DatabaseConnection thay vì hardcode
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, senderId);
            ps.setLong(2, receiverId);
            ps.setString(3, content);
            ps.executeUpdate();

            System.out.println("Saved message from " + senderId + " to " + receiverId);
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Lỗi lưu tin nhắn vào DB: " + e.getMessage());
        }
    }
}