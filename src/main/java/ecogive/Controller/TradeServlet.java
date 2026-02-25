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
            } else if ("admin_approve".equals(action)) { // MỚI: Admin duyệt
                handleAdminApprove(req, currentUser, response);
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
        long targetItemId = Long.parseLong(req.getParameter("targetItemId"));
        long offerItemId;
        String offerType = req.getParameter("offerType");
        
        if ("new".equals(offerType)) {
            Item newItem = new Item();
            newItem.setGiverId(user.getUserId());
            newItem.setTitle(req.getParameter("offerTitle"));
            newItem.setDescription(req.getParameter("offerDesc"));
            newItem.setCategoryId(1);
            newItem.setStatus(ItemStatus.PENDING);
            
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
            
            Item targetItem = itemDAO.findById(targetItemId);
            if (targetItem != null) {
                newItem.setLocation(targetItem.getLocation());
                newItem.setAddress(targetItem.getAddress());
            }
            
            itemDAO.insert(newItem);
            offerItemId = newItem.getItemId();
        } else {
            offerItemId = Long.parseLong(req.getParameter("offerItemId"));
        }

        Transaction trans = new Transaction();
        trans.setItemId(targetItemId);
        trans.setReceiverId(user.getUserId());
        trans.setOfferItemId(offerItemId);
        trans.setTransactionType("TRADE");
        trans.setStatus(TransactionStatus.PENDING_TRADE);
        trans.setExchangeDate(LocalDateTime.now());

        if (transactionDAO.insert(trans)) {
            Item targetItem = itemDAO.findById(targetItemId);
            String sysMsg = "SYSTEM_TRADE_PROPOSAL:" + trans.getTransactionId();
            saveSystemMessage(user.getUserId(), targetItem.getGiverId(), sysMsg, null);

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

        // SỬA ĐỔI: Chuyển sang WAITING_ADMIN_APPROVAL
        if (transactionDAO.updateStatus(transactionId, TransactionStatus.WAITING_ADMIN_APPROVAL)) {
            // Gửi tin nhắn thông báo
            String sysMsg = "SYSTEM_GIFT:Đã chấp nhận! Đang chờ Admin duyệt...";
            saveSystemMessage(user.getUserId(), trans.getReceiverId(), sysMsg, null);

            response.addProperty("status", "success");
            response.addProperty("message", "Đã chấp nhận. Vui lòng chờ Admin duyệt.");
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

            response.addProperty("status", "success");
            response.addProperty("message", "Đã từ chối trao đổi.");
        } else {
            throw new Exception("Lỗi cập nhật.");
        }
    }
    
    // --- MỚI: ADMIN DUYỆT ---
    private void handleAdminApprove(HttpServletRequest req, User user, JsonObject response) throws Exception {
        // Kiểm tra quyền Admin
        if (!"ADMIN".equals(user.getRole().name())) {
            throw new Exception("Bạn không có quyền Admin.");
        }
        
        long transactionId = Long.parseLong(req.getParameter("transactionId"));
        String decision = req.getParameter("decision"); // "approve" or "reject"
        
        Transaction trans = transactionDAO.findById(transactionId);
        if (trans == null) throw new Exception("Giao dịch không tồn tại.");
        
        TransactionStatus newStatus = "approve".equals(decision) ? TransactionStatus.TRADE_APPROVED : TransactionStatus.TRADE_REJECTED;
        
        if (transactionDAO.updateStatus(transactionId, newStatus)) {
            // Gửi thông báo cho cả 2 bên (A và B)
            String msgContent = "approve".equals(decision) 
                ? "SYSTEM_GIFT:Admin đã duyệt! Hai bạn có thể tiến hành trao đổi." 
                : "SYSTEM_GIFT:Admin đã từ chối yêu cầu trao đổi này.";
                
            // Gửi cho người nhận (A)
            saveSystemMessage(user.getUserId(), trans.getReceiverId(), msgContent, null);
            
            // Gửi cho người cho (B) - Cần lấy ID của B
            Item itemB = itemDAO.findById(trans.getItemId());
            saveSystemMessage(user.getUserId(), itemB.getGiverId(), msgContent, null);
            
            response.addProperty("status", "success");
            response.addProperty("message", "Đã xử lý duyệt.");
        } else {
            throw new Exception("Lỗi cập nhật.");
        }
    }

    private void handleConfirmReady(HttpServletRequest req, User user, JsonObject response) throws Exception {
        long transactionId = Long.parseLong(req.getParameter("transactionId"));
        Transaction trans = transactionDAO.findById(transactionId);
        
        Item itemB = itemDAO.findById(trans.getItemId());
        
        TransactionStatus newStatus = trans.getStatus();
        boolean isComplete = false;

        if (user.getUserId() == trans.getReceiverId()) {
            if (trans.getStatus() == TransactionStatus.TRADE_APPROVED) { // SỬA: Check TRADE_APPROVED
                newStatus = TransactionStatus.CONFIRMED_BY_A;
            } else if (trans.getStatus() == TransactionStatus.CONFIRMED_BY_B) {
                newStatus = TransactionStatus.COMPLETED;
                isComplete = true;
            }
        } else if (user.getUserId() == itemB.getGiverId()) {
            if (trans.getStatus() == TransactionStatus.TRADE_APPROVED) { // SỬA: Check TRADE_APPROVED
                newStatus = TransactionStatus.CONFIRMED_BY_B;
            } else if (trans.getStatus() == TransactionStatus.CONFIRMED_BY_A) {
                newStatus = TransactionStatus.COMPLETED;
                isComplete = true;
            }
        }

        if (transactionDAO.updateStatus(transactionId, newStatus)) {
            response.addProperty("status", "success");
            response.addProperty("newStatus", newStatus.name());
            if (isComplete) {
                response.addProperty("message", "Trao đổi thành công!");
            } else {
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
