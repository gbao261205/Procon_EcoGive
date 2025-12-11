package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Category;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.Transaction;
import ecogive.Model.TransactionStatus;
import ecogive.Model.User;
import ecogive.dao.CategoryDAO;
import ecogive.dao.ItemDAO;
import ecogive.dao.TransactionDAO;
import ecogive.dao.UserDAO;
import ecogive.util.DatabaseConnection;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.math.BigDecimal;
import java.sql.Connection;
import java.sql.SQLException;

@WebServlet("/transaction/confirm")
public class CompleteTransactionServlet extends HttpServlet {

    private final TransactionDAO transactionDAO = new TransactionDAO();
    private final ItemDAO itemDAO = new ItemDAO();
    private final CategoryDAO categoryDAO = new CategoryDAO();
    private final UserDAO userDAO = new UserDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        if (currentUser == null) {
            resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
            response.addProperty("message", "Bạn cần đăng nhập để thực hiện hành động này.");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        String transactionIdStr = req.getParameter("transactionId");
        if (transactionIdStr == null) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("message", "Thiếu ID giao dịch.");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        Connection conn = null;
        try {
            long transactionId = Long.parseLong(transactionIdStr);
            conn = DatabaseConnection.getConnection();
            conn.setAutoCommit(false);

            // 1. Fetch and Validate Transaction
            Transaction transaction = transactionDAO.findById(transactionId);
            if (transaction == null) {
                throw new ServletException("Giao dịch không tồn tại.");
            }

            // 2. Authorization Check
            if (transaction.getReceiverId() != currentUser.getUserId()) {
                throw new SecurityException("Bạn không phải là người nhận trong giao dịch này.");
            }

            // 3. Status Check
            if (transaction.getStatus() != TransactionStatus.CONFIRMED) {
                throw new IllegalStateException("Giao dịch không ở trạng thái chờ xác nhận. Trạng thái hiện tại: " + transaction.getStatus());
            }

            // 4. Get Item and Giver Info
            Item item = itemDAO.findById(transaction.getItemId());
            if (item == null) {
                throw new ServletException("Vật phẩm liên quan đến giao dịch không tồn tại.");
            }
            long giverId = item.getGiverId();

            // 5. Get Points from Category
            Category category = categoryDAO.findById(item.getCategoryId());
            if (category == null) {
                throw new ServletException("Danh mục của vật phẩm không tồn tại.");
            }
            BigDecimal pointsToAdd = category.getFixedPoints();

            // --- Perform DB Updates ---
            transactionDAO.updateStatus(transactionId, TransactionStatus.COMPLETED);
            itemDAO.updateStatus(item.getItemId(), ItemStatus.COMPLETED);
            userDAO.addEcoPoints(giverId, pointsToAdd);

            conn.commit(); // Commit the transaction

            response.addProperty("status", "success");
            response.addProperty("message", "Xác nhận giao dịch thành công! " + pointsToAdd + " điểm đã được cộng cho người cho.");
            resp.setStatus(HttpServletResponse.SC_OK);

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("message", "ID giao dịch không hợp lệ.");
        } catch (SecurityException e) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.addProperty("message", e.getMessage());
        } catch (IllegalStateException e) {
            resp.setStatus(HttpServletResponse.SC_CONFLICT);
            response.addProperty("message", e.getMessage());
        } catch (Exception e) {
            if (conn != null) {
                try {
                    conn.rollback();
                } catch (SQLException ex) {
                    ex.printStackTrace();
                }
            }
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("message", "Đã xảy ra lỗi hệ thống: " + e.getMessage());
        } finally {
            if (conn != null) {
                try {
                    conn.setAutoCommit(true);
                    conn.close();
                } catch (SQLException e) {
                    e.printStackTrace();
                }
            }
            resp.getWriter().write(gson.toJson(response));
        }
    }
}
