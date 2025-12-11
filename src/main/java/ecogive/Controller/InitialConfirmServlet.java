package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.TransactionStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import ecogive.dao.TransactionDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/api/transaction/initial-confirm")
public class InitialConfirmServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();

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
            if (item.getStatus() != ItemStatus.AVAILABLE) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Món đồ này đã không còn sẵn sàng (Status: " + item.getStatus() + ")");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 3. THỰC HIỆN GIAO DỊCH
            // Sử dụng một phương thức trong DAO để đảm bảo tính toàn vẹn (atomic)
            boolean success = transactionDAO.createInitialTransaction(itemId, receiverId);

            if (success) {
                response.addProperty("status", "success");
                response.addProperty("message", "Xác nhận tặng thành công! Vật phẩm đang chờ được giao.");
            } else {
                throw new SQLException("Không thể khởi tạo giao dịch.");
            }

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("status", "error");
            response.addProperty("message", "ID không hợp lệ.");
            resp.getWriter().write(gson.toJson(response));
        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi cơ sở dữ liệu: " + e.getMessage());
            resp.getWriter().write(gson.toJson(response));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
            resp.getWriter().write(gson.toJson(response));
        }
        resp.getWriter().write(gson.toJson(response));
    }
}
