package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.Role;
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

@WebServlet("/api/delete-collection-point")
public class DeleteCollectionPointServlet extends HttpServlet {

    private final CollectionPointDAO collectionPointDAO = new CollectionPointDAO();

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
                response.addProperty("message", "Vui lòng đăng nhập.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            long pointId = Long.parseLong(req.getParameter("pointId"));
            boolean success = false;

            if (currentUser.getRole() == Role.ADMIN) {
                // Admin can delete any point
                success = collectionPointDAO.delete(pointId);
            } else if (currentUser.getRole() == Role.COLLECTOR_COMPANY) {
                // Collector can only delete their own points
                success = collectionPointDAO.delete(pointId, currentUser.getUserId());
            }

            if (success) {
                response.addProperty("status", "success");
                response.addProperty("message", "Xóa điểm thu gom thành công!");
            } else {
                resp.setStatus(HttpServletResponse.SC_FORBIDDEN);
                response.addProperty("status", "error");
                response.addProperty("message", "Không thể xóa điểm thu gom hoặc không có quyền.");
            }

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("status", "error");
            response.addProperty("message", "ID điểm thu gom không hợp lệ.");
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
