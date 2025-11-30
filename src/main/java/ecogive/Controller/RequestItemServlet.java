package ecogive.Controller;

import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import ecogive.dao.TransactionDAO;
import com.google.gson.Gson; // Đảm bảo bạn đã có Gson

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.time.LocalDateTime;
import java.util.HashMap;
import java.util.Map;

@WebServlet("/request-item")
public class RequestItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        Map<String, Object> result = new HashMap<>();

        try {
            // 1. Kiểm tra đăng nhập
            HttpSession session = req.getSession(false);
            if (session == null || session.getAttribute("currentUser") == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                result.put("status", "error");
                result.put("message", "Bạn cần đăng nhập để nhận đồ.");
                resp.getWriter().write(gson.toJson(result));
                return;
            }
            User currentUser = (User) session.getAttribute("currentUser");

            // 2. Lấy Item ID từ request
            long itemId = Long.parseLong(req.getParameter("itemId"));
            Item item = itemDAO.findById(itemId);

            // 3. Kiểm tra tính hợp lệ
            if (item == null) {
                result.put("status", "error");
                result.put("message", "Vật phẩm không tồn tại.");
            } else if (item.getGiverId() == currentUser.getUserId()) {
                result.put("status", "error");
                result.put("message", "Bạn không thể nhận đồ của chính mình.");
            } else if (item.getStatus() != ItemStatus.AVAILABLE) {
                result.put("status", "error");
                result.put("message", "Vật phẩm này đã có người nhận hoặc đang chờ xử lý.");
            } else {
                // 4. Hợp lệ -> Tạo Transaction
                Transaction trans = new Transaction();
                trans.setItemId(itemId);
                trans.setReceiverId(currentUser.getUserId());
                trans.setExchangeDate(LocalDateTime.now()); // Thời gian tạo yêu cầu
                trans.setStatus(TransactionStatus.CONFIRMED); // CONFIRMED: Đã xác nhận yêu cầu

                boolean transSuccess = transactionDAO.insert(trans);

                if (transSuccess) {
                    // 5. Cập nhật trạng thái vật phẩm -> PENDING (Để ẩn khỏi bản đồ/không cho ai khác nhận)
                    itemDAO.updateStatus(itemId, ItemStatus.PENDING);

                    result.put("status", "success");
                    result.put("message", "Yêu cầu nhận đồ thành công! Hãy liên hệ người tặng.");
                } else {
                    result.put("status", "error");
                    result.put("message", "Lỗi khi tạo giao dịch.");
                }
            }
        } catch (Exception e) {
            e.printStackTrace();
            result.put("status", "error");
            result.put("message", "Lỗi server: " + e.getMessage());
        }

        resp.getWriter().write(gson.toJson(result));
    }
}