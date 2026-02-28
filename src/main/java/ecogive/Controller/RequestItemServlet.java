package ecogive.Controller;

import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import ecogive.dao.TransactionDAO;
import ecogive.util.DatabaseConnection;
import ecogive.util.NotificationService;
import com.google.gson.Gson;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/request-item")
public class RequestItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Map<String, Object> result = new HashMap<>();

        try {
            // 1. Kiểm tra đăng nhập
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("currentUser") == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                result.put("status", "error");
                result.put("message", "Bạn cần đăng nhập để nhận đồ.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }
            User currentUser = (User) session.getAttribute("currentUser");

            // 2. Lấy Item ID từ request
            long itemId = Long.parseLong(req.getParameter("itemId"));
            Item item = itemDAO.findById(itemId);
            
            System.out.println("RequestItem: User=" + currentUser.getUserId() + ", Item=" + itemId);

            // 3. Kiểm tra tính hợp lệ
            if (item == null) {
                result.put("status", "error");
                result.put("message", "Vật phẩm không tồn tại.");
            } else if (item.getGiverId() == currentUser.getUserId()) {
                result.put("status", "error");
                result.put("message", "Bạn không thể nhận đồ của chính mình.");
            } else if (item.getStatus() != ItemStatus.AVAILABLE) {
                System.out.println("Item status invalid: " + item.getStatus());
                result.put("status", "error");
                result.put("message", "Vật phẩm này đã có người nhận hoặc đang chờ xử lý (Status: " + item.getStatus() + ")");
            } else {
                // 4. Hợp lệ -> Tạo Transaction PENDING
                boolean exists = transactionDAO.checkExists(itemId, currentUser.getUserId());
                System.out.println("Transaction exists? " + exists);
                
                boolean transSuccess = true;
                Transaction trans = null;

                if (!exists) {
                    trans = new Transaction();
                    trans.setItemId(itemId);
                    trans.setReceiverId(currentUser.getUserId());
                    trans.setExchangeDate(LocalDateTime.now());
                    trans.setStatus(TransactionStatus.PENDING); 
                    transSuccess = transactionDAO.insert(trans);
                    System.out.println("Created new transaction: " + transSuccess);
                } else {
                    System.out.println("Transaction already exists (PENDING/CONFIRMED), skipping insert.");
                    // Nếu đã tồn tại thì coi như thành công, không tạo mới nhưng vẫn báo thành công
                }

                if (transSuccess) {
                    // --- CẬP NHẬT: Gửi thông báo và email ---
                    if (!exists && trans != null) {
                        // Ưu tiên dùng displayName
                        String senderName = currentUser.getDisplayName() != null && !currentUser.getDisplayName().isEmpty() 
                                            ? currentUser.getDisplayName() 
                                            : currentUser.getUsername();
                        
                        String content = "Người dùng " + senderName + " muốn xin vật phẩm '" + item.getTitle() + "' của bạn.";
                        String sysMsg = "SYSTEM_GIFT:" + content;
                        
                        // 1. Lưu tin nhắn chat (để hiện trong khung chat)
                        saveSystemMessage(currentUser.getUserId(), item.getGiverId(), sysMsg, null);
                        ChatEndpoint.sendSystemMessage(String.valueOf(item.getGiverId()), sysMsg);

                        // 2. Gửi Notification + Email
                        NotificationService.sendNotification(
                            item.getGiverId(), 
                            content, 
                            "GIFT_REQUEST", 
                            (long) trans.getTransactionId(), 
                            "Yêu cầu xin vật phẩm mới: " + item.getTitle()
                        );
                    }
                    // --------------------------------------------------

                    result.put("status", "success");
                    result.put("message", "Đã gửi yêu cầu! Hãy chat với người tặng.");
                    result.put("itemName", item.getTitle()); // Trả về tên vật phẩm
                } else {
                    result.put("status", "error");
                    result.put("message", "Lỗi khi tạo giao dịch.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", "Lỗi server: " + e.getMessage());
        }

        resp.getWriter().write(gson.toJson(result));
    }

    private void saveSystemMessage(long senderId, long receiverId, String content, String imageUrl) {
        String sql = "INSERT INTO messages (sender_id, receiver_id, content, image_url) VALUES (?, ?, ?, ?)";
        try (Connection conn = DatabaseConnection.getConnection();
             PreparedStatement ps = conn.prepareStatement(sql)) {
            ps.setLong(1, senderId);
            ps.setLong(2, receiverId);
            ps.setString(3, content);
            ps.setString(4, imageUrl);
            ps.executeUpdate();
        } catch (Exception e) {
            e.printStackTrace();
        }
    }
}
