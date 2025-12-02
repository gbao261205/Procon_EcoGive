package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.User;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.Connection;
import java.sql.DriverManager;
import java.sql.PreparedStatement;
import java.sql.ResultSet;

@WebServlet("/api/confirm-transaction")
public class ConfirmTransactionServlet extends HttpServlet {

    private Connection getConnection() throws Exception {
        Class.forName("com.mysql.cj.jdbc.Driver");
        return DriverManager.getConnection("jdbc:mysql://localhost:3306/ecogive", "root", "123456"); // Kiểm tra pass
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();
        Gson gson = new Gson();

        try (Connection conn = getConnection()) {
            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

            if (currentUser == null) {
                response.addProperty("status", "error");
                response.addProperty("message", "Hết phiên đăng nhập.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // Lấy tham số an toàn
            String itemIdRaw = req.getParameter("itemId");
            String receiverIdRaw = req.getParameter("receiverId");

            // Xử lý ID
            long currentGiverId = ((Number) currentUser.getUserId()).longValue();
            long itemId = Long.parseLong(itemIdRaw);
            long receiverId = Long.parseLong(receiverIdRaw);

            // 1. CHECK QUYỀN
            String checkSql = "SELECT giver_id, status, title, u.username as receiver_name FROM items i JOIN users u ON u.user_id = ? WHERE i.item_id = ?";
            PreparedStatement checkPs = conn.prepareStatement(checkSql);
            checkPs.setLong(1, receiverId);
            checkPs.setLong(2, itemId);
            ResultSet rs = checkPs.executeQuery();

            String itemName = "";
            String receiverName = "";

            if (rs.next()) {
                long dbGiverId = rs.getLong("giver_id");
                String status = rs.getString("status");
                itemName = rs.getString("title");
                receiverName = rs.getString("receiver_name");

                if (dbGiverId != currentGiverId) {
                    response.addProperty("status", "error");
                    response.addProperty("message", "Bạn không phải chủ món đồ này!");
                    resp.getWriter().write(gson.toJson(response));
                    return;
                }

                // Chỉ cho phép chốt nếu đang AVAILABLE
                if (!"AVAILABLE".equals(status) && !"PENDING".equals(status)) {
                    response.addProperty("status", "error");
                    response.addProperty("message", "Món đồ này đã không còn sẵn sàng (Status: " + status + ")");
                    resp.getWriter().write(gson.toJson(response));
                    return;
                }
            } else {
                response.addProperty("status", "error");
                response.addProperty("message", "Không tìm thấy dữ liệu.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 2. TRANSACTION (SỬA LỖI Ở ĐÂY: DÙNG CONFIRMED)
            conn.setAutoCommit(false);
            try {
                // A. Update Item -> CONFIRMED (Ẩn khỏi map, chờ giao)
                String updateSql = "UPDATE items SET status = 'CONFIRMED' WHERE item_id = ?";
                PreparedStatement psUpdate = conn.prepareStatement(updateSql);
                psUpdate.setLong(1, itemId);
                psUpdate.executeUpdate();

                // B. Insert Transaction -> CONFIRMED
                String transSql = "INSERT INTO transactions (item_id, receiver_id, status) VALUES (?, ?, 'CONFIRMED')";
                PreparedStatement psTrans = conn.prepareStatement(transSql);
                psTrans.setLong(1, itemId);
                psTrans.setLong(2, receiverId);
                psTrans.executeUpdate();

                conn.commit();

                // Trả về data
                response.addProperty("status", "success");
                response.addProperty("itemName", itemName);
                response.addProperty("receiverName", receiverName);

            } catch (Exception e) {
                conn.rollback();
                throw e;
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}