package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.Model.CollectionPoint;
import ecogive.Model.CollectionPointType;
import ecogive.Model.GeoPoint;
import ecogive.Model.User;
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

    private final CollectionPointDAO stationDAO = new CollectionPointDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();
        Gson gson = new Gson();

        try {
            // 1. Check Admin
            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;

            if (currentUser == null || !"ADMIN".equals(currentUser.getRole())) { // Sửa lại logic check Role tùy theo Enum của bạn
                response.addProperty("status", "error");
                response.addProperty("message", "Không có quyền truy cập!");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // 2. Lấy dữ liệu
            String name = req.getParameter("name");
            String typeStr = req.getParameter("type");
            String address = req.getParameter("address");
            double lat = Double.parseDouble(req.getParameter("latitude"));
            double lng = Double.parseDouble(req.getParameter("longitude"));

            // 3. Tạo Object Model
            CollectionPoint cp = new CollectionPoint();
            cp.setName(name);
            cp.setAddress(address);

            // Xử lý Enum Type
            try {
                cp.setType(CollectionPointType.valueOf(typeStr));
            } catch (IllegalArgumentException e) {
                cp.setType(CollectionPointType.E_WASTE); // Default nếu lỗi
            }

            // Xử lý GeoPoint
            cp.setLocation(new GeoPoint(lng, lat)); // Lưu ý constructor GeoPoint(lng, lat) hay (lat, lng) tùy bạn định nghĩa

            // 4. Gọi DAO
            if (stationDAO.insert(cp)) {
                response.addProperty("status", "success");
                response.addProperty("message", "Thêm trạm thành công!");
            } else {
                response.addProperty("status", "error");
                response.addProperty("message", "Lỗi khi lưu vào Database.");
            }

        } catch (Exception e) {
            e.printStackTrace();
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}