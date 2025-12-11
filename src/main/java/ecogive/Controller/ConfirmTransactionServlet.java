package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
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
    private final UserDAO userDAO = new UserDAO(); // Để lấy tên người nhận

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
            long currentGiverId = currentUser.getUserId();

            Item item = itemDAO.findById(itemId);

            if (item == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.addProperty("status", "error");
                response.addProperty("message", "Không tìm thấy vật phẩm.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 1. CHECK QUYỀN: Người thực hiện phải là chủ món đồ
            if (item.getGiverId() != currentGiverId) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.addProperty("status", "error");
                response.addProperty("message", "Bạn không phải chủ món đồ này!");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 2. CHECK TRẠNG THÁI: Món đồ phải đang sẵn sàng
            if (item.getStatus() != ItemStatus.AVAILABLE && item.getStatus() != ItemStatus.PENDING) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Món đồ này đã không còn sẵn sàng (Status: " + item.getStatus() + ")");
                resp.getWriter().write(gson.toJson(response));
                return;
            }
            
            // Lấy tên người nhận để trả về
            User receiver = userDAO.findById(receiverId);
            if (receiver == null) {
                throw new SQLException("Không tìm thấy người nhận.");
            }

            // 3. THỰC HIỆN GIAO DỊCH (sử dụng DAO)
            boolean success = transactionDAO.createInitialTransaction(itemId, receiverId);

            if (success) {
                response.addProperty("status", "success");
                response.addProperty("message", "Xác nhận tặng thành công! Vật phẩm đang chờ được giao.");
                response.addProperty("itemName", item.getTitle());
                response.addProperty("receiverName", receiver.getUsername());
            } else {
                throw new SQLException("Không thể khởi tạo giao dịch. Có thể vật phẩm đã được tặng cho người khác.");
            }

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("status", "error");
            response.addProperty("message", "ID không hợp lệ.");
        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi cơ sở dữ liệu: " + e.getMessage());
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}
