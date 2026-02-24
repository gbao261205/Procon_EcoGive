package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.util.DatabaseConnection;
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
            String receiverIdStr = jsonMsg.has("receiverId") ? jsonMsg.get("receiverId").getAsString() : null;
            String content = jsonMsg.has("content") ? jsonMsg.get("content").getAsString() : "";
            String imageUrl = jsonMsg.has("imageUrl") ? jsonMsg.get("imageUrl").getAsString() : null;

            if (receiverIdStr == null) return;

            // Lấy senderId từ URL kết nối websocket
            String senderIdStr = senderSession.getPathParameters().get("userId");

            // 2. LƯU VÀO DATABASE
            saveMessageToDB(Long.parseLong(senderIdStr), Long.parseLong(receiverIdStr), content, imageUrl);

            // 3. Gửi Real-time nếu người nhận đang Online
            Session receiverSession = userSessions.get(receiverIdStr);
            if (receiverSession != null && receiverSession.isOpen()) {
                JsonObject response = new JsonObject();
                response.addProperty("senderId", senderIdStr);
                response.addProperty("content", content);
                if (imageUrl != null) response.addProperty("imageUrl", imageUrl);
                
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

    // --- HÀM LƯU DB ĐÃ CẬP NHẬT ---
    private void saveMessageToDB(long senderId, long receiverId, String content, String imageUrl) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content, image_url) VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, senderId);
            ps.setLong(2, receiverId);
            ps.setString(3, content);
            ps.setString(4, imageUrl); // Có thể là null
            ps.executeUpdate();

            System.out.println("Saved message from " + senderId + " to " + receiverId + (imageUrl != null ? " with image" : ""));
        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Lỗi lưu tin nhắn vào DB: " + e.getMessage());
        }
    }
}
