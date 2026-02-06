package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.CollectionPoint;
import ecogive.Model.GeoPoint;
import ecogive.Model.User;
import ecogive.Model.Role;
import ecogive.dao.CollectionPointDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;

import java.io.IOException;

@WebServlet("/api/create-collection-point")
public class CreateCollectionPointServlet extends HttpServlet {

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

            // 1. Check Authorization (Admin or Collector Company)
            if (currentUser == null || (currentUser.getRole() != Role.ADMIN && currentUser.getRole() != Role.COLLECTOR_COMPANY)) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                response.addProperty("status", "error");
                response.addProperty("message", "Không có quyền truy cập!");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 2. Get data
            String name = req.getParameter("name");
            String typeStr = req.getParameter("type");
            String address = req.getParameter("address");
            double lat = Double.parseDouble(req.getParameter("latitude"));
            double lng = Double.parseDouble(req.getParameter("longitude"));

            // 3. Create Model Object
            CollectionPoint cp = new CollectionPoint();
            cp.setName(name);
            cp.setAddress(address);
            cp.setOwnerId(currentUser.getUserId()); // Set owner
            
            // Đã sửa: Gán trực tiếp typeStr vào typeCode, nếu null thì gán mặc định
            if (typeStr == null || typeStr.isEmpty()) {
                cp.setTypeCode("E_WASTE"); // Default
            } else {
                cp.setTypeCode(typeStr);
            }

            cp.setLocation(new GeoPoint(lng, lat));

            // 4. Call DAO
            if (collectionPointDAO.insert(cp)) {
                response.addProperty("status", "success");
                response.addProperty("message", "Thêm điểm thu gom thành công!");
            } else {
                response.addProperty("status", "error");
                response.addProperty("message", "Lỗi khi lưu vào Database.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}
