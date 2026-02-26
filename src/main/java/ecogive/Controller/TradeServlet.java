package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import ecogive.dao.TransactionDAO;
import ecogive.util.CloudinaryService;
import ecogive.util.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.IOException;
import java.sql.Connection;
import java.sql.PreparedStatement;
import java.time.LocalDateTime;

@WebServlet("/api/trade")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class TradeServlet extends HttpServlet {

    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final ItemDAO itemDAO = new ItemDAO();
    private final CloudinaryService cloudinaryService = new CloudinaryService();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();

        try {
            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

            if (currentUser == null) {
                resp.setStatus(401);
                throw new Exception("Bạn cần đăng nhập.");
            }

            String action = req.getParameter("action");

            if ("propose".equals(action)) {
                handleProposeTrade(req, currentUser, response);
            } else if ("accept".equals(action)) {
                handleAcceptTrade(req, currentUser, response);
            } else if ("reject".equals(action)) {
                handleRejectTrade(req, currentUser, response);
            } else if ("confirm_ready".equals(action)) {
                handleConfirmReady(req, currentUser, response);
            } else {
                throw new Exception("Hành động không hợp lệ.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }

    private void handleProposeTrade(HttpServletRequest req, User user, JsonObject response) throws Exception {
        long targetItemId = Long.parseLong(req.getParameter("targetItemId")); // Item B (của người khác)
        long offerItemId;
        String offerType = req.getParameter("offerType");
        
        // Kiểm tra Item B có tồn tại và AVAILABLE không
        Item targetItem = itemDAO.findById(targetItemId);
        if (targetItem == null || targetItem.getStatus() != ItemStatus.AVAILABLE) {
            throw new Exception("Vật phẩm bạn muốn đổi không còn khả dụng.");
        }
        if (targetItem.getGiverId() == user.getUserId()) {
            throw new Exception("Không thể tự đổi đồ của chính mình.");
        }
        
        if ("new".equals(offerType)) {
            // Tạo Item mới với trạng thái TRADE_PENDING (chỉ dùng để đổi)
            Item newItem = new Item();
            newItem.setGiverId(user.getUserId());
            newItem.setTitle(req.getParameter("offerTitle"));
            newItem.setDescription(req.getParameter("offerDesc"));
            newItem.setCategoryId(1); // Mặc định category chung
            newItem.setStatus(ItemStatus.TRADE_PENDING);
            
            Part filePart = req.getPart("offerImage");
            String imgUrl = "https://placehold.co/300x300?text=No+Image";
            
            if (filePart != null && filePart.getSize() > 0) {
                try {
                    imgUrl = cloudinaryService.uploadImage(filePart);
                } catch (Exception e) {
                    System.err.println("Lỗi upload ảnh trade: " + e.getMessage());
                }
            }
            newItem.setImageUrl(imgUrl);
            newItem.setLocation(targetItem.getLocation()); // Tạm lấy location của target
            newItem.setAddress(targetItem.getAddress());
            
            itemDAO.insert(newItem);
            offerItemId = newItem.getItemId();
        } else {
            // Dùng Item có sẵn
            offerItemId = Long.parseLong(req.getParameter("offerItemId"));
            Item offerItem = itemDAO.findById(offerItemId);
            if (offerItem == null || offerItem.getGiverId() != user.getUserId()) {
                throw new Exception("Vật phẩm bạn chọn không hợp lệ.");
            }
            if (offerItem.getStatus() != ItemStatus.AVAILABLE) {
                throw new Exception("Vật phẩm của bạn đang bận trong giao dịch khác.");
            }
        }

        Transaction trans = new Transaction();
        trans.setItemId(targetItemId);
        trans.setReceiverId(user.getUserId()); // Người đề nghị là Receiver trong ngữ cảnh này (muốn nhận Item B)
        trans.setOfferItemId(offerItemId);
        trans.setTransactionType("TRADE");
        trans.setStatus(TransactionStatus.PENDING_TRADE);
        trans.setExchangeDate(LocalDateTime.now());

        if (transactionDAO.insert(trans)) {
            // Gửi thông báo Real-time cho chủ sở hữu Item B
            String sysMsg = "SYSTEM_TRADE_PROPOSAL:" + trans.getTransactionId();
            saveSystemMessage(user.getUserId(), targetItem.getGiverId(), sysMsg, null);
            
            // Gọi WebSocket để báo ngay lập tức
            ChatEndpoint.sendSystemMessage(String.valueOf(targetItem.getGiverId()), sysMsg);

            response.addProperty("status", "success");
            response.addProperty("message", "Đã gửi đề nghị trao đổi!");
            response.addProperty("transactionId", trans.getTransactionId());
        } else {
            throw new Exception("Lỗi tạo giao dịch.");
        }
    }

    private void handleAcceptTrade(HttpServletRequest req, User user, JsonObject response) throws Exception {
        long transactionId = Long.parseLong(req.getParameter("transactionId"));
        Transaction trans = transactionDAO.findById(transactionId);
        
        if (trans == null) throw new Exception("Giao dịch không tồn tại.");
        
        Item itemB = itemDAO.findById(trans.getItemId());
        if (itemB.getGiverId() != user.getUserId()) {
            throw new Exception("Bạn không có quyền chấp nhận.");
        }
        
        // Kiểm tra lại trạng thái Item A và B trước khi chốt
        if (itemB.getStatus() != ItemStatus.AVAILABLE) {
            throw new Exception("Vật phẩm của bạn không còn khả dụng.");
        }
        if (trans.getOfferItemId() != null) {
            Item itemA = itemDAO.findById(trans.getOfferItemId());
            if (itemA.getStatus() != ItemStatus.AVAILABLE && itemA.getStatus() != ItemStatus.TRADE_PENDING) {
                throw new Exception("Vật phẩm đối phương không còn khả dụng.");
            }
        }

        // --- SỬA ĐỔI: Dùng TRADE_ACCEPTED thay vì TRADE_APPROVED ---
        if (transactionDAO.updateStatus(transactionId, TransactionStatus.TRADE_ACCEPTED)) {
            // KHÓA ITEM (Set PENDING) để không ai khác lấy được
            itemDAO.updateStatus(trans.getItemId(), ItemStatus.PENDING); // Item B
            if (trans.getOfferItemId() != null) {
                Item itemA = itemDAO.findById(trans.getOfferItemId());
                if (itemA.getStatus() == ItemStatus.AVAILABLE) {
                    itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.PENDING); // Item A
                }
            }

            String sysMsg = "SYSTEM_GIFT:Đã chấp nhận! Hai bên hãy tiến hành trao đổi.";
            saveSystemMessage(user.getUserId(), trans.getReceiverId(), sysMsg, null);
            
            // Gửi WebSocket thông báo
            ChatEndpoint.sendSystemMessage(String.valueOf(trans.getReceiverId()), sysMsg);

            response.addProperty("status", "success");
            response.addProperty("message", "Đã chấp nhận trao đổi.");
        } else {
            throw new Exception("Lỗi cập nhật.");
        }
    }

    private void handleRejectTrade(HttpServletRequest req, User user, JsonObject response) throws Exception {
        long transactionId = Long.parseLong(req.getParameter("transactionId"));
        Transaction trans = transactionDAO.findById(transactionId);

        if (transactionDAO.updateStatus(transactionId, TransactionStatus.CANCELED)) {
            String sysMsg = "SYSTEM_GIFT:Đề nghị trao đổi đã bị từ chối.";
            saveSystemMessage(user.getUserId(), trans.getReceiverId(), sysMsg, null);
            
            // Gửi WebSocket
            ChatEndpoint.sendSystemMessage(String.valueOf(trans.getReceiverId()), sysMsg);

            response.addProperty("status", "success");
            response.addProperty("message", "Đã từ chối trao đổi.");
        } else {
            throw new Exception("Lỗi cập nhật.");
        }
    }

    private void handleConfirmReady(HttpServletRequest req, User user, JsonObject response) throws Exception {
        long transactionId = Long.parseLong(req.getParameter("transactionId"));
        Transaction trans = transactionDAO.findById(transactionId);
        
        Item itemB = itemDAO.findById(trans.getItemId());
        long partnerId = (user.getUserId() == trans.getReceiverId()) ? itemB.getGiverId() : trans.getReceiverId();
        
        TransactionStatus currentStatus = trans.getStatus();
        TransactionStatus newStatus = currentStatus;
        boolean isComplete = false;

        // Logic xác định trạng thái tiếp theo
        // --- SỬA ĐỔI: Dùng TRADE_ACCEPTED thay vì TRADE_APPROVED ---
        if (user.getUserId() == trans.getReceiverId()) {
            // User là A (Người đề nghị)
            if (currentStatus == TransactionStatus.TRADE_ACCEPTED) {
                newStatus = TransactionStatus.CONFIRMED_BY_A;
            } else if (currentStatus == TransactionStatus.CONFIRMED_BY_B) {
                newStatus = TransactionStatus.COMPLETED;
                isComplete = true;
            }
        } else if (user.getUserId() == itemB.getGiverId()) {
            // User là B (Chủ item)
            if (currentStatus == TransactionStatus.TRADE_ACCEPTED) {
                newStatus = TransactionStatus.CONFIRMED_BY_B;
            } else if (currentStatus == TransactionStatus.CONFIRMED_BY_A) {
                newStatus = TransactionStatus.COMPLETED;
                isComplete = true;
            }
        }

        if (transactionDAO.updateStatus(transactionId, newStatus)) {
            response.addProperty("status", "success");
            response.addProperty("newStatus", newStatus.name());
            
            // Gửi sự kiện TRADE_READY qua WebSocket
            JsonObject readyEvent = new JsonObject();
            readyEvent.addProperty("type", "TRADE_READY");
            readyEvent.addProperty("userId", user.getUserId());
            readyEvent.addProperty("transactionId", transactionId);
            ChatEndpoint.sendJsonMessage(String.valueOf(partnerId), readyEvent);
            
            if (isComplete) {
                // Cập nhật trạng thái Item -> COMPLETED (để đồng bộ với logic Giving)
                // Hoặc giữ TRADE_COMPLETED nếu muốn phân biệt
                itemDAO.updateStatus(trans.getItemId(), ItemStatus.COMPLETED);
                if (trans.getOfferItemId() != null) {
                    itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.COMPLETED);
                }
                
                // --- SỬ DỤNG SYSTEM_TRADE (MÀU TÍM) ---
                String sysMsg = "SYSTEM_TRADE:Trao đổi thành công! Giao dịch hoàn tất.";
                
                // Lưu vào DB (sender là SYSTEM hoặc User? Ở đây đang lưu sender = User)
                // Lưu ý: hàm saveSystemMessage của class này dòng 290 đang insert vào bảng messages
                saveSystemMessage(user.getUserId(), partnerId, sysMsg, null);
                
                // Gửi Socket
                ChatEndpoint.sendSystemMessage(String.valueOf(partnerId), sysMsg);
                ChatEndpoint.sendSystemMessage(String.valueOf(user.getUserId()), sysMsg); // Gửi cho cả chính mình để hiện lên chat

                // Gửi sự kiện TRADE_EXECUTE để chạy animation
                JsonObject execEvent = new JsonObject();
                execEvent.addProperty("type", "TRADE_EXECUTE");
                execEvent.addProperty("transactionId", transactionId);
                ChatEndpoint.sendJsonMessage(String.valueOf(user.getUserId()), execEvent);
                ChatEndpoint.sendJsonMessage(String.valueOf(partnerId), execEvent);

                response.addProperty("message", "Trao đổi thành công!");
            } else {
                // --- THÊM: Gửi thông báo cho đối phương biết mình đã sẵn sàng ---
                String readyMsg = "SYSTEM_TRADE:Đối tác đã xác nhận sẵn sàng. Chờ bạn xác nhận!";
                ChatEndpoint.sendSystemMessage(String.valueOf(partnerId), readyMsg);
                
                response.addProperty("message", "Đã xác nhận. Chờ đối phương...");
            }
        } else {
            throw new Exception("Lỗi cập nhật trạng thái.");
        }
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
