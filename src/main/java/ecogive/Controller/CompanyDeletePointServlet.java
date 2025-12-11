package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.CollectionPoint;
import ecogive.Model.User;
import ecogive.dao.CollectionPointDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;
import java.sql.SQLException;

@WebServlet("/company/collect-point/delete")
public class CompanyDeletePointServlet extends HttpServlet {

    private final CollectionPointDAO collectionPointDAO = new CollectionPointDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();

        HttpSession session = req.getSession(false);
        User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

        // Middleware: Check if user is a logged-in company
        if (currentUser == null || !"ENTERPRISE_COLLECTOR".equals(currentUser.getRole())) {
            resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
            response.addProperty("status", "error");
            response.addProperty("message", "Không có quyền truy cập!");
            resp.getWriter().write(gson.toJson(response));
            return;
        }

        try {
            String pointIdStr = req.getParameter("pointId");
            if (pointIdStr == null || pointIdStr.trim().isEmpty()) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "ID điểm thu gom là bắt buộc.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            long pointId = Long.parseLong(pointIdStr);

            // --- Middleware: Ownership Check ---
            CollectionPoint pointToDelete = collectionPointDAO.findById(pointId);

            if (pointToDelete == null) {
                resp.setStatus(HttpServletResponse.SC_NOT_FOUND);
                response.addProperty("status", "error");
                response.addProperty("message", "Điểm thu gom không tồn tại.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            if (pointToDelete.getCompanyId() != currentUser.getUserId()) {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.addProperty("status", "error");
                response.addProperty("message", "Bạn không có quyền xóa điểm thu gom này.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }
            // --- End of Ownership Check ---

            // --- Call DAO to Delete ---
            if (collectionPointDAO.delete(pointId)) {
                resp.setStatus(HttpServletResponse.SC_OK);
                response.addProperty("status", "success");
                response.addProperty("message", "Xóa điểm thu gom thành công!");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.addProperty("status", "error");
                response.addProperty("message", "Lỗi khi xóa khỏi cơ sở dữ liệu.");
            }

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("status", "error");
            response.addProperty("message", "ID điểm thu gom không hợp lệ.");
            resp.getWriter().write(gson.toJson(response));
        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
            resp.getWriter().write(gson.toJson(response));
        }
    }
}
