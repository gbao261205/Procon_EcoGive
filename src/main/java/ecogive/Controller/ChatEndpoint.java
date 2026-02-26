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
    // Map lưu session của người dùng đang online: Key = userId (String), Value = Session
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
            
            String receiverIdStr = null;
            if (jsonMsg.has("receiverId") && !jsonMsg.get("receiverId").isJsonNull()) {
                receiverIdStr = jsonMsg.get("receiverId").getAsString();
            }

            String content = "";
            if (jsonMsg.has("content") && !jsonMsg.get("content").isJsonNull()) {
                content = jsonMsg.get("content").getAsString();
            }

            String imageUrl = null;
            if (jsonMsg.has("imageUrl") && !jsonMsg.get("imageUrl").isJsonNull()) {
                imageUrl = jsonMsg.get("imageUrl").getAsString();
            }

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

    // --- PUBLIC STATIC METHODS CHO SERVLET GỌI ---

    /**
     * Gửi tin nhắn hệ thống (Text) tới một user cụ thể
     */
    public static void sendSystemMessage(String receiverId, String message) {
        Session session = userSessions.get(receiverId);
        if (session != null && session.isOpen()) {
            try {
                JsonObject response = new JsonObject();
                response.addProperty("senderId", "SYSTEM"); // Đánh dấu là hệ thống
                response.addProperty("content", message);
                session.getBasicRemote().sendText(gson.toJson(response));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    /**
     * Gửi tin nhắn JSON tùy chỉnh (Dùng cho sự kiện Trade: TRADE_READY, TRADE_EXECUTE...)
     */
    public static void sendJsonMessage(String receiverId, JsonObject jsonMessage) {
        Session session = userSessions.get(receiverId);
        if (session != null && session.isOpen()) {
            try {
                session.getBasicRemote().sendText(gson.toJson(jsonMessage));
            } catch (IOException e) {
                e.printStackTrace();
            }
        }
    }

    // --- DATABASE HELPER ---
    private void saveMessageToDB(long senderId, long receiverId, String content, String imageUrl) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content, image_url) VALUES (?, ?, ?, ?)";

        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {

            ps.setLong(1, senderId);
            ps.setLong(2, receiverId);
            ps.setString(3, content);
            ps.setString(4, imageUrl);
            ps.executeUpdate();

        } catch (SQLException e) {
            e.printStackTrace();
            System.err.println("Lỗi lưu tin nhắn vào DB: " + e.getMessage());
        }
    }
}
