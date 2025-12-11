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

@WebServlet("/company/collect-point/add")
public class CompanyAddPointServlet extends HttpServlet {

    private final CollectionPointDAO collectionPointDAO = new CollectionPointDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject response = new JsonObject();
        Gson gson = new Gson();

        try {
            HttpSession session = req.getSession(false);
            // Middleware đã kiểm tra, nhưng để an toàn, kiểm tra lại
            User currentUser = (User) session.getAttribute("currentUser");

            // 1. Validate dữ liệu đầu vào
            String name = req.getParameter("name");
            String address = req.getParameter("address");
            String typeStr = req.getParameter("type");
            String latStr = req.getParameter("latitude");
            String lngStr = req.getParameter("longitude");

            if (name == null || name.trim().isEmpty() ||
                address == null || address.trim().isEmpty() ||
                latStr == null || latStr.trim().isEmpty() ||
                lngStr == null || lngStr.trim().isEmpty() ||
                typeStr == null || typeStr.trim().isEmpty()) {
                
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Vui lòng điền đầy đủ các trường bắt buộc.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            double lat = Double.parseDouble(latStr);
            double lng = Double.parseDouble(lngStr);

            // 2. Tạo Model Object
            CollectionPoint cp = new CollectionPoint();
            cp.setName(name);
            cp.setAddress(address);
            cp.setOwnerId(currentUser.getUserId()); // Gán ID của doanh nghiệp đang đăng nhập
            
            try {
                cp.setType(CollectionPointType.valueOf(typeStr));
            } catch (IllegalArgumentException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Loại rác thải không hợp lệ.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            cp.setLocation(new GeoPoint(lng, lat));

            // 3. Gọi DAO để lưu
            if (collectionPointDAO.insert(cp)) {
                response.addProperty("status", "success");
                response.addProperty("message", "Thêm điểm thu gom thành công!");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.addProperty("status", "error");
                response.addProperty("message", "Lỗi khi lưu vào cơ sở dữ liệu.");
            }

        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            response.addProperty("status", "error");
            response.addProperty("message", "Tọa độ không hợp lệ.");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            response.addProperty("status", "error");
            response.addProperty("message", "Lỗi server: " + e.getMessage());
        }
        resp.getWriter().write(gson.toJson(response));
    }
}
