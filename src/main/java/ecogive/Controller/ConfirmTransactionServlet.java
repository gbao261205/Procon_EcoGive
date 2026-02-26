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
import ecogive.dao.UserDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;

@WebServlet("/api/confirm-transaction")
public class ConfirmTransactionServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final UserDAO userDAO = new UserDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();
        Gson gson = new Gson();

        try {
            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

            if (currentUser == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.addProperty("status", "error");
                response.addProperty("message", "Hết phiên đăng nhập.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            long itemId = Long.parseLong(req.getParameter("itemId"));
            long receiverId = Long.parseLong(req.getParameter("receiverId"));
            String action = req.getParameter("action");
            
            System.out.println("ConfirmTransaction: itemId=" + itemId + ", receiverId=" + receiverId + ", action=" + action + ", user=" + currentUser.getUserId());

            Item item = itemDAO.findById(itemId);
            if (item == null) throw new Exception("Không tìm thấy vật phẩm ID=" + itemId);

            // Tìm transaction cụ thể giữa item và receiver này
            Transaction trans = transactionDAO.findActiveTransaction(itemId, receiverId);
            
            if (trans == null) {
                throw new Exception("Không tìm thấy giao dịch hợp lệ.");
            }

            // --- LOGIC MỚI: TÁCH BIỆT GIVE VÀ TRADE ---
            String type = trans.getTransactionType(); // "GIVE" hoặc "TRADE"

            if ("cancel".equals(action)) {
                // --- HỦY GIAO DỊCH (Chung cho cả 2) ---
                if (currentUser.getUserId() != item.getGiverId() && currentUser.getUserId() != trans.getReceiverId()) {
                    throw new Exception("Bạn không có quyền hủy giao dịch này.");
                }
                
                // Logic hủy giống nhau
                boolean success = transactionDAO.cancelTransaction(trans.getTransactionId());
                if (success) {
                    itemDAO.updateStatus(itemId, ItemStatus.AVAILABLE);
                    // Nếu là Trade thì phải nhả cả item đối ứng ra
                    if ("TRADE".equals(type) && trans.getOfferItemId() != null) {
                        itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.AVAILABLE);
                    }
                    response.addProperty("status", "success");
                    response.addProperty("message", "Đã hủy giao dịch.");
                    response.addProperty("newStatus", "CANCELED");
                } else {
                    throw new Exception("Lỗi khi hủy giao dịch.");
                }

            } else if ("TRADE".equals(type)) {
                // --- XỬ LÝ LUỒNG TRAO ĐỔI (TRADE) ---
                // Quy tắc: Cả 2 bên (Người đề nghị và Chủ món đồ) đều phải bấm xác nhận "Đã hoàn tất"
                // Ở đây ta dùng 2 trạng thái phụ: CONFIRMED_BY_A (người tạo trans), CONFIRMED_BY_B (người nhận trans)
                // Hoặc đơn giản hóa: Ai bấm cũng được tính là hoàn tất 1 phần? 
                // Để đơn giản và chặt chẽ: Ta dùng action "complete_trade"
                
                if (!"complete_trade".equals(action)) {
                     throw new Exception("Hành động không hợp lệ cho giao dịch Trao đổi.");
                }

                // Kiểm tra xem user hiện tại là bên nào
                boolean isProposer = (currentUser.getUserId() == trans.getReceiverId()); // Người đề nghị đổi (Receiver trong bảng trans)
                boolean isOwner = (currentUser.getUserId() == item.getGiverId());       // Chủ item gốc

                if (!isProposer && !isOwner) {
                     throw new Exception("Bạn không tham gia cuộc trao đổi này.");
                }


                // Cập nhật trạng thái xác nhận của từng bên
                // Giả sử ta dùng status CONFIRMED_BY_A (Proposer) và CONFIRMED_BY_B (Owner)
                TransactionStatus currentStatus = trans.getStatus();
                TransactionStatus nextStatus = currentStatus;
                
                if (currentStatus == TransactionStatus.TRADE_ACCEPTED) {
                    // Chưa ai xác nhận
                    nextStatus = isProposer ? TransactionStatus.CONFIRMED_BY_A : TransactionStatus.CONFIRMED_BY_B;
                    transactionDAO.updateStatus(trans.getTransactionId(), nextStatus);
                    
                    // --- THÊM NOTIFICATION ---
                    String partnerId = isProposer 
                        ? String.valueOf(item.getGiverId()) 
                        : String.valueOf(trans.getReceiverId());
                    
                    String sysMsg = "SYSTEM_TRADE:Đối tác đã xác nhận hoàn tất. Đang chờ bạn xác nhận!";
                    ChatEndpoint.sendSystemMessage(partnerId, sysMsg);
                    
                    response.addProperty("message", "Đã xác nhận hoàn tất. Chờ phía bên kia xác nhận.");
                } else if ((currentStatus == TransactionStatus.CONFIRMED_BY_A && isOwner) ||
                           (currentStatus == TransactionStatus.CONFIRMED_BY_B && isProposer)) {
                    // Một bên đã xong, giờ bên còn lại xác nhận nốt -> COMPLETE
                    nextStatus = TransactionStatus.COMPLETED;
                    boolean success = transactionDAO.updateStatus(trans.getTransactionId(), TransactionStatus.COMPLETED);
                    if (success) {
                        // Hoàn tất cả 2 item
                        itemDAO.updateStatus(itemId, ItemStatus.COMPLETED); // Item gốc
                        if (trans.getOfferItemId() != null) {
                            itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.COMPLETED); // Item đổi
                        }
                        
                        // --- THÊM NOTIFICATION CHO CẢ 2 BÊN ---
                        String msgComplete = "SYSTEM_TRADE:Giao dịch trao đổi thành công! Cảm ơn hai bạn.";
                        ChatEndpoint.sendSystemMessage(String.valueOf(trans.getReceiverId()), msgComplete);
                        ChatEndpoint.sendSystemMessage(String.valueOf(item.getGiverId()), msgComplete);

                        // Cộng điểm (nếu có logic point cho trade)
                         response.addProperty("message", "Trao đổi thành công tốt đẹp!");
                    }
                } else if (currentStatus == TransactionStatus.COMPLETED) {
                    response.addProperty("message", "Giao dịch đã hoàn tất rồi.");
                } else {
                    response.addProperty("message", "Đã xác nhận. Đang chờ đối tác.");
                }
                
                response.addProperty("status", "success");
                response.addProperty("newStatus", nextStatus.toString());

            } else {
                // --- XỬ LÝ LUỒNG TẶNG (GIVE) - GIỮ NGUYÊN LOGIC CŨ ---
                if ("giver_confirm".equals(action)) {
                    // ... (Người cho xác nhận)
                    if (item.getGiverId() != currentUser.getUserId()) {
                        throw new Exception("Bạn không phải chủ món đồ.");
                    }
                    if (trans.getStatus() == TransactionStatus.CONFIRMED) {
                         response.addProperty("status", "success");
                         response.addProperty("message", "Bạn đã xác nhận rồi.");
                    } else {
                        boolean success = transactionDAO.confirmByGiver(trans.getTransactionId());
                        if (success) {
                            itemDAO.updateStatus(itemId, ItemStatus.PENDING);
                            response.addProperty("status", "success");
                            response.addProperty("message", "Đã xác nhận cho! Chờ người nhận xác nhận.");
                            response.addProperty("newStatus", "CONFIRMED");
                        }
                    }

                } else if ("receiver_confirm".equals(action)) {
                    // ... (Người nhận xác nhận lấy)
                    if (trans.getReceiverId() != currentUser.getUserId()) {
                        throw new Exception("Bạn không phải người nhận.");
                    }
                    if (trans.getStatus() == TransactionStatus.CONFIRMED) {
                        boolean success = transactionDAO.confirmByReceiver(trans.getTransactionId());
                        if (success) {
                            itemDAO.updateStatus(itemId, ItemStatus.COMPLETED);
                            // Cộng điểm
                            if (item.getEcoPoints() != null && item.getEcoPoints().compareTo(BigDecimal.ZERO) > 0) {
                                userDAO.addEcoPoints(item.getGiverId(), item.getEcoPoints());
                            }
                            response.addProperty("status", "success");
                            response.addProperty("message", "Giao dịch hoàn tất! Cảm ơn bạn.");
                            response.addProperty("newStatus", "COMPLETED");
                        }
                    } else {
                        throw new Exception("Người cho chưa xác nhận.");
                    }
                } else {
                    throw new Exception("Hành động không hợp lệ cho giao dịch Tặng.");
                }
            }
            
            response.addProperty("itemName", item.getTitle());

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}
