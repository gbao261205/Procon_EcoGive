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
                // Nếu chưa có transaction (trường hợp hiếm hoi hoặc lỗi), có thể tạo mới nếu action là giver_confirm?
                // Nhưng theo logic mới, request đã tạo transaction PENDING rồi.
                throw new Exception("Không tìm thấy giao dịch hợp lệ.");
            }

            if ("cancel".equals(action)) {
                // --- HỦY GIAO DỊCH ---
                // Chỉ cho phép hủy nếu là người trong cuộc
                if (currentUser.getUserId() != item.getGiverId() && currentUser.getUserId() != trans.getReceiverId()) {
                    throw new Exception("Bạn không có quyền hủy giao dịch này.");
                }

                boolean success = transactionDAO.cancelTransaction(trans.getTransactionId());
                if (success) {
                    // Nếu item đang PENDING (do đã confirm trước đó), trả về AVAILABLE
                    if (item.getStatus() == ItemStatus.PENDING) {
                        itemDAO.updateStatus(itemId, ItemStatus.AVAILABLE);
                    }
                    response.addProperty("status", "success");
                    response.addProperty("message", "Đã hủy giao dịch.");
                    response.addProperty("newStatus", "CANCELED");
                } else {
                    throw new Exception("Lỗi khi hủy giao dịch.");
                }

            } else if ("giver_confirm".equals(action)) {
                // --- NGƯỜI CHO XÁC NHẬN ---
                if (item.getGiverId() != currentUser.getUserId()) {
                    throw new Exception("Bạn không phải chủ món đồ.");
                }
                
                // Kiểm tra xem item có đang bị khóa bởi giao dịch khác không
                if (item.getStatus() != ItemStatus.AVAILABLE && trans.getStatus() == TransactionStatus.PENDING) {
                     // Nếu item không AVAILABLE (ví dụ PENDING do giao dịch khác), không cho confirm cái mới
                     throw new Exception("Vật phẩm đang trong quá trình giao dịch với người khác.");
                }

                if (trans.getStatus() == TransactionStatus.CONFIRMED) {
                    response.addProperty("status", "success");
                    response.addProperty("message", "Bạn đã xác nhận giao dịch này rồi.");
                } else if (trans.getStatus() == TransactionStatus.PENDING) {
                    boolean success = transactionDAO.confirmByGiver(trans.getTransactionId());
                    if (success) {
                        // Khóa item lại
                        itemDAO.updateStatus(itemId, ItemStatus.PENDING);
                        response.addProperty("status", "success");
                        response.addProperty("message", "Đã xác nhận cho! Chờ người nhận xác nhận.");
                        response.addProperty("newStatus", "CONFIRMED");
                    } else {
                        throw new Exception("Lỗi cập nhật giao dịch.");
                    }
                } else {
                    throw new Exception("Trạng thái giao dịch không hợp lệ (" + trans.getStatus() + ").");
                }

            } else if ("receiver_confirm".equals(action)) {
                // --- NGƯỜI NHẬN XÁC NHẬN ---
                if (trans.getReceiverId() != currentUser.getUserId()) {
                    throw new Exception("Bạn không phải người nhận trong giao dịch này.");
                }

                if (trans.getStatus() == TransactionStatus.COMPLETED) {
                     response.addProperty("status", "success");
                     response.addProperty("message", "Giao dịch đã hoàn tất trước đó.");
                } else if (trans.getStatus() == TransactionStatus.CONFIRMED) {
                    boolean success = transactionDAO.confirmByReceiver(trans.getTransactionId());
                    if (success) {
                        itemDAO.updateStatus(itemId, ItemStatus.COMPLETED);

                        // Cộng điểm
                        BigDecimal points = item.getEcoPoints();
                        if (points != null && points.compareTo(BigDecimal.ZERO) > 0) {
                            userDAO.addEcoPoints(item.getGiverId(), points);
                        }

                        response.addProperty("status", "success");
                        response.addProperty("message", "Giao dịch hoàn tất! Cảm ơn bạn.");
                        response.addProperty("newStatus", "COMPLETED");
                    } else {
                        throw new Exception("Lỗi cập nhật giao dịch.");
                    }
                } else {
                    throw new Exception("Người cho chưa xác nhận hoặc trạng thái không hợp lệ.");
                }
            } else {
                throw new Exception("Hành động không hợp lệ.");
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
