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
import java.util.List;

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
            
            // Lấy tên hiển thị của người dùng hiện tại
            String currentDisplayName = currentUser.getDisplayName() != null && !currentUser.getDisplayName().isEmpty() 
                                        ? currentUser.getDisplayName() 
                                        : currentUser.getUsername();

            long itemId = Long.parseLong(req.getParameter("itemId"));
            long receiverId = Long.parseLong(req.getParameter("receiverId"));
            String action = req.getParameter("action");
            
            System.out.println("ConfirmTransaction: itemId=" + itemId + ", receiverId=" + receiverId + ", action=" + action + ", user=" + currentUser.getUserId());

            Item item = itemDAO.findById(itemId);
            if (item == null) throw new Exception("Không tìm thấy vật phẩm ID=" + itemId);

            Transaction trans;
            
            if ("complete_trade".equals(action)) {
                trans = transactionDAO.findActiveTradeTransactionByParties(itemId, currentUser.getUserId(), receiverId);
            } else {
                trans = transactionDAO.findActiveTransaction(itemId, receiverId);
            }
            
            if (trans == null) {
                if ("cancel".equals(action)) {
                     trans = transactionDAO.findActiveTransaction(itemId, currentUser.getUserId());
                }
                
                if (trans == null) {
                    throw new Exception("Không tìm thấy giao dịch hợp lệ.");
                }
            }

            String type = trans.getTransactionType();

            if ("cancel".equals(action)) {
                if (currentUser.getUserId() != item.getGiverId() && currentUser.getUserId() != trans.getReceiverId()) {
                    throw new Exception("Bạn không có quyền hủy giao dịch này.");
                }
                
                boolean success = transactionDAO.cancelTransaction(trans.getTransactionId());
                if (success) {
                    itemDAO.updateStatus(itemId, ItemStatus.AVAILABLE);
                    if ("TRADE".equals(type) && trans.getOfferItemId() != null) {
                        itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.AVAILABLE);
                    }
                    
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
                if (!"complete_trade".equals(action)) {
                     throw new Exception("Hành động không hợp lệ cho giao dịch Trao đổi.");
                }

                boolean isProposer = (currentUser.getUserId() == trans.getReceiverId());
                boolean isOwner = (currentUser.getUserId() == item.getGiverId());

                if (!isProposer && !isOwner) {
                     throw new Exception("Bạn không tham gia cuộc trao đổi này.");
                }

                TransactionStatus currentStatus = trans.getStatus();
                TransactionStatus nextStatus = currentStatus;
                boolean isFullyCompleted = false;
                
                if (currentStatus == TransactionStatus.TRADE_ACCEPTED) {
                    nextStatus = isProposer ? TransactionStatus.CONFIRMED_BY_A : TransactionStatus.CONFIRMED_BY_B;
                    transactionDAO.updateStatus(trans.getTransactionId(), nextStatus);
                    
                    String partnerId = isProposer ? String.valueOf(item.getGiverId()) : String.valueOf(trans.getReceiverId());
                    String sysMsg = "SYSTEM_TRADE:Đối tác đã xác nhận hoàn tất trao đổi. Đang chờ bạn xác nhận!";
                    ChatEndpoint.sendSystemMessage(partnerId, sysMsg);
                    
                    response.addProperty("message", "Đã xác nhận. Đang chờ đối tác xác nhận.");
                } else if ((currentStatus == TransactionStatus.CONFIRMED_BY_A && isOwner) ||
                           (currentStatus == TransactionStatus.CONFIRMED_BY_B && isProposer)) {
                    nextStatus = TransactionStatus.COMPLETED;
                    boolean success = transactionDAO.updateStatus(trans.getTransactionId(), TransactionStatus.COMPLETED);
                    if (success) {
                        itemDAO.updateStatus(itemId, ItemStatus.TRADE_COMPLETED);
                        if (trans.getOfferItemId() != null) {
                            itemDAO.updateStatus(trans.getOfferItemId(), ItemStatus.TRADE_COMPLETED);
                        }
                        
                        // --- MỚI: Logic cộng điểm cho Trade (50% giá trị) ---
                        BigDecimal itemPoints = item.getEcoPoints() != null ? item.getEcoPoints() : BigDecimal.ZERO;
                        BigDecimal offerPoints = BigDecimal.ZERO;
                        
                        if (trans.getOfferItemId() != null) {
                            Item offerItem = itemDAO.findById(trans.getOfferItemId());
                            if (offerItem != null && offerItem.getEcoPoints() != null) {
                                offerPoints = offerItem.getEcoPoints();
                            }
                        }
                        
                        // Tính 50% điểm
                        BigDecimal half = new BigDecimal("0.5");
                        BigDecimal pointsForOwner = itemPoints.multiply(half); // Chủ item nhận 50% điểm item của mình
                        BigDecimal pointsForProposer = offerPoints.multiply(half); // Người đề nghị nhận 50% điểm item của họ
                        
                        if (pointsForOwner.compareTo(BigDecimal.ZERO) > 0) {
                            userDAO.addEcoPoints(item.getGiverId(), pointsForOwner);
                        }
                        if (pointsForProposer.compareTo(BigDecimal.ZERO) > 0) {
                            userDAO.addEcoPoints(trans.getReceiverId(), pointsForProposer);
                        }
                        // ----------------------------------------------------
                        
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
                    response.addProperty("message", "Bạn đã xác nhận rồi. Đang chờ đối tác.");
                }
                
                response.addProperty("status", "success");
                response.addProperty("newStatus", nextStatus.toString());
                response.addProperty("isCompleted", isFullyCompleted);

            } else {
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

                            // --- MỚI: Hủy các yêu cầu khác và thông báo ---
                            List<Transaction> otherRequests = transactionDAO.findOtherPendingRequests(itemId, receiverId);
                            transactionDAO.cancelOtherTransactions(itemId, trans.getTransactionId());

                            for (Transaction t : otherRequests) {
                                String cancelMsg = "SYSTEM_GIFT:Vật phẩm bạn quan tâm đã được chủ sở hữu tặng cho người khác.";
                                ChatEndpoint.sendSystemMessage(String.valueOf(t.getReceiverId()), cancelMsg);
                            }
                            // ---------------------------------------------

                            // Sử dụng display_name trong thông báo
                            String sysMsg = "SYSTEM_GIFT:" + currentDisplayName + " đã xác nhận giao đồ. Bạn hãy xác nhận khi nhận được nhé!";
                            ChatEndpoint.sendSystemMessage(String.valueOf(receiverId), sysMsg);

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
                            if (item.getEcoPoints() != null && item.getEcoPoints().compareTo(BigDecimal.ZERO) > 0) {
                                userDAO.addEcoPoints(item.getGiverId(), item.getEcoPoints());
                            }
                            
                            // Thông báo cho người tặng
                            String sysMsg = "SYSTEM_GIFT:Người nhận đã xác nhận nhận đồ. Giao dịch hoàn tất!";
                            ChatEndpoint.sendSystemMessage(String.valueOf(item.getGiverId()), sysMsg);

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
