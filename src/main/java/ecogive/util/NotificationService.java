package ecogive.util;

import com.google.gson.JsonObject;
import ecogive.Controller.ChatEndpoint;
import ecogive.Model.Notification;
import ecogive.Model.User;
import ecogive.dao.NotificationDAO;
import ecogive.dao.UserDAO;

import java.util.concurrent.ExecutorService;
import java.util.concurrent.Executors;

public class NotificationService {

    private static final NotificationDAO notificationDAO = new NotificationDAO();
    private static final UserDAO userDAO = new UserDAO();
    private static final ExecutorService emailExecutor = Executors.newFixedThreadPool(5); // Thread pool cho email

    public static void sendNotification(long receiverId, String content, String type, Long referenceId, String emailSubject) {
        try {
            // 1. Lưu vào Database
            Notification noti = new Notification(receiverId, content, type, referenceId);
            notificationDAO.insert(noti);

            // 2. Gửi WebSocket (Real-time)
            JsonObject wsMsg = new JsonObject();
            wsMsg.addProperty("type", "NOTIFICATION");
            wsMsg.addProperty("content", content);
            wsMsg.addProperty("notiType", type);
            if (referenceId != null) wsMsg.addProperty("referenceId", referenceId);
            
            // Gửi qua ChatEndpoint (cần thêm method hỗ trợ gửi JSON thuần túy nếu chưa có, hoặc dùng sendJsonMessage)
            ChatEndpoint.sendJsonMessage(String.valueOf(receiverId), wsMsg);

            // 3. Gửi Email (Async)
            if (emailSubject != null) {
                emailExecutor.submit(() -> {
                    try {
                        User receiver = userDAO.findById(receiverId);
                        if (receiver != null && receiver.getEmail() != null) {
                            String emailBody = buildEmailBody(receiver.getUsername(), content);
                            EmailUtility.sendEmail(receiver.getEmail(), emailSubject, emailBody);
                            System.out.println("Email sent to " + receiver.getEmail());
                        }
                    } catch (Exception e) {
                        System.err.println("Failed to send email notification: " + e.getMessage());
                    }
                });
            }

        } catch (Exception e) {
            e.printStackTrace();
        }
    }

    private static String buildEmailBody(String username, String content) {
        return "<div style='font-family: Arial, sans-serif; padding: 20px; color: #333;'>"
             + "<h2 style='color: #05976a;'>EcoGive Thông báo</h2>"
             + "<p>Xin chào <b>" + username + "</b>,</p>"
             + "<p>" + content + "</p>"
             + "<p>Vui lòng truy cập <a href='http://localhost:8080/Procon_EcoGive/home'>EcoGive</a> để xem chi tiết.</p>"
             + "<hr>"
             + "<p style='font-size: 12px; color: #777;'>Đây là email tự động, vui lòng không trả lời.</p>"
             + "</div>";
    }
}
