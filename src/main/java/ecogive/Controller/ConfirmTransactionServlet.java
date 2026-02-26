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

            Transaction trans;
            
            // --- SỬA ĐỔI: Logic tìm kiếm giao dịch ---
            if ("complete_trade".equals(action)) {
                // Nếu là TRADE, tìm giao dịch giữa 2 bên bất kể vai trò
                trans = transactionDAO.findActiveTradeTransactionByParties(itemId, currentUser.getUserId(), receiverId);
            } else {
                // Nếu là GIVE hoặc CANCEL, dùng logic cũ (tìm theo receiver cụ thể)
                trans = transactionDAO.findActiveTransaction(itemId, receiverId);
            }
            
            if (trans == null) {
                // Thử tìm ngược lại nếu là CANCEL (để hỗ trợ hủy linh hoạt hơn)
                if ("cancel".equals(action)) {
                     trans = transactionDAO.findActiveTransaction(itemId, currentUser.getUserId());
                }
                
                if (trans == null) {
                    throw new Exception("Không tìm thấy giao dịch hợp lệ.");
                }
            }

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
                    
                    // Gửi thông báo hủy cho đối tác
                    String partnerId = (currentUser.getUserId() == item.getGiverId()) 
                        ? String.valueOf(trans.getReceiverId()) 
                        : String.valueOf(item.getGiverId());
                    ChatEndpoint.sendSystemMessage(partnerId, "SYSTEM_GIFT:Giao dịch đã bị hủy bởi đối tác.");

                    response.addProperty("status", "success");
                    response.addProperty("message", "Đã hủy giao dịch.");
                    response.addProperty("newStatus", "CANCELED");
                } else {
                    throw new Exception("Lỗi khi hủy giao dịch.");
                }

            } else if ("TRADE".equals(type)) {
                // --- XỬ LÝ LUỒNG TRAO ĐỔI (TRADE) ---
                if (!"complete_trade".equals(action)) {
                     throw new Exception("Hành động không hợp lệ cho giao dịch Trao đổi.");
                }

                // Kiểm tra xem user hiện tại là bên nào
                boolean isProposer = (currentUser.getUserId() == trans.getReceiverId()); // Người đề nghị đổi
                boolean isOwner = (currentUser.getUserId() == item.getGiverId());       // Chủ item gốc

                if (!isProposer && !isOwner) {
                     throw new Exception("Bạn không tham gia cuộc trao đổi này.");
                }

                TransactionStatus currentStatus = trans.getStatus();
                TransactionStatus nextStatus = currentStatus;
                boolean isFullyCompleted = false;
                
                if (currentStatus == TransactionStatus.TRADE_ACCEPTED) {
                    // Chưa ai xác nhận -> Chuyển sang trạng thái xác nhận 1 phần
                    nextStatus = isProposer ? TransactionStatus.CONFIRMED_BY_A : TransactionStatus.CONFIRMED_BY_B;
                    transactionDAO.updateStatus(trans.getTransactionId(), nextStatus);
                    
                    // Thông báo cho đối tác
                    String partnerId = isProposer ? String.valueOf(item.getGiverId()) : String.valueOf(trans.getReceiverId());
                    String sysMsg = "SYSTEM_TRADE:Đối tác đã xác nhận hoàn tất trao đổi. Đang chờ bạn xác nhận!";
                    ChatEndpoint.sendSystemMessage(partnerId, sysMsg);
                    
                    response.addProperty("message", "Đã xác nhận. Đang chờ đối tác xác nhận.");
                } else if ((currentStatus == TransactionStatus.CONFIRMED_BY_A && isOwner) ||
                           (currentStatus == TransactionStatus.CONFIRMED_BY_B && isProposer)) {
                    // Một bên đã xong, giờ bên còn lại xác nhận nốt -> TRADE_COMPLETED
                    nextStatus = TransactionStatus.COMPLETED;
                    boolean success = transactionDAO.updateStatus(trans.getTransactionId(), TransactionStatus.COMPLETED);
                    if (success) {
                        // Hoàn tất cả 2 item
                        itemDAO.updateStatus(itemId, ItemStatus.TRADE_COMPLETED); // Item gốc
                        if (trans.getOfferItemId() != null) {
                            itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.TRADE_COMPLETED); // Item đổi
                        }
                        
                        // Thông báo hoàn tất cho cả 2
                        String msgComplete = "SYSTEM_TRADE:Chúc mừng! Giao dịch trao đổi đã thành công tốt đẹp.";
                        ChatEndpoint.sendSystemMessage(String.valueOf(trans.getReceiverId()), msgComplete);
                        ChatEndpoint.sendSystemMessage(String.valueOf(item.getGiverId()), msgComplete);

                        isFullyCompleted = true;
                        response.addProperty("message", "Trao đổi thành công tốt đẹp!");
                    }
                } else if (currentStatus == TransactionStatus.COMPLETED || currentStatus == TransactionStatus.COMPLETED) {
                    response.addProperty("message", "Giao dịch đã hoàn tất rồi.");
                    isFullyCompleted = true;
                } else {
                    // Trường hợp người dùng bấm lại nút xác nhận khi đã xác nhận rồi (nhưng đối tác chưa)
                    response.addProperty("message", "Bạn đã xác nhận rồi. Đang chờ đối tác.");
                }
                
                response.addProperty("status", "success");
                response.addProperty("newStatus", nextStatus.toString());
                response.addProperty("isCompleted", isFullyCompleted);

            } else {
                // --- XỬ LÝ LUỒNG TẶNG (GIVE) ---
                if ("giver_confirm".equals(action)) {
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
