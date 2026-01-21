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
import java.sql.SQLException;

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

            Transaction trans = transactionDAO.findActiveTransaction(itemId, receiverId);
            if (trans == null) {
                System.out.println("Transaction not found for itemId=" + itemId + ", receiverId=" + receiverId);
                throw new Exception("Không tìm thấy giao dịch cho item " + itemId);
            }
            
            System.out.println("Found Transaction: ID=" + trans.getTransactionId() + ", Status=" + trans.getStatus() + ", ItemID=" + trans.getItemId());

            if ("giver_confirm".equals(action)) {
                // 1. NGƯỜI CHO XÁC NHẬN
                if (item.getGiverId() != currentUser.getUserId()) {
                    throw new Exception("Bạn không phải chủ món đồ.");
                }
                
                if (trans.getStatus() == TransactionStatus.CONFIRMED) {
                    response.addProperty("status", "success");
                    response.addProperty("message", "Bạn đã xác nhận giao dịch này rồi.");
                    response.addProperty("newStatus", "CONFIRMED");
                } else if (trans.getStatus() == TransactionStatus.PENDING) {
                    boolean success = transactionDAO.confirmByGiver(trans.getTransactionId());
                    if (success) {
                        itemDAO.updateStatus(itemId, ItemStatus.PENDING);
                        response.addProperty("status", "success");
                        response.addProperty("message", "Đã xác nhận cho! Chờ người nhận xác nhận.");
                        response.addProperty("newStatus", "CONFIRMED");
                    } else {
                        throw new Exception("Lỗi cập nhật giao dịch.");
                    }
                } else {
                    throw new Exception("Trạng thái giao dịch không hợp lệ (" + trans.getStatus() + "). ItemID=" + itemId);
                }

            } else if ("receiver_confirm".equals(action)) {
                // 2. NGƯỜI NHẬN XÁC NHẬN
                if (trans.getReceiverId() != currentUser.getUserId()) {
                    throw new Exception("Bạn không phải người nhận trong giao dịch này.");
                }

                if (trans.getStatus() == TransactionStatus.COMPLETED) {
                     response.addProperty("status", "success");
                     response.addProperty("message", "Giao dịch đã hoàn tất trước đó.");
                     response.addProperty("newStatus", "COMPLETED");
                } else if (trans.getStatus() == TransactionStatus.CONFIRMED) {
                    boolean success = transactionDAO.confirmByReceiver(trans.getTransactionId());
                    if (success) {
                        itemDAO.updateStatus(itemId, ItemStatus.COMPLETED);
                        response.addProperty("status", "success");
                        response.addProperty("message", "Giao dịch hoàn tất! Cảm ơn bạn.");
                        response.addProperty("newStatus", "COMPLETED");
                    } else {
                        throw new Exception("Lỗi cập nhật giao dịch.");
                    }
                } else {
                    throw new Exception("Người cho chưa xác nhận hoặc trạng thái không hợp lệ (" + trans.getStatus() + ").");
                }
            } else {
                // Fallback
                if (item.getGiverId() == currentUser.getUserId()) {
                     boolean success = transactionDAO.confirmByGiver(trans.getTransactionId());
                     if(success) {
                         itemDAO.updateStatus(itemId, ItemStatus.PENDING);
                         response.addProperty("status", "success");
                         response.addProperty("message", "Đã xác nhận cho.");
                     }
                } else {
                    throw new Exception("Hành động không hợp lệ.");
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
