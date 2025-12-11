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
            // --- Validation ---
            String name = req.getParameter("name");
            String address = req.getParameter("address");
            String typeStr = req.getParameter("type");
            String latStr = req.getParameter("latitude");
            String lngStr = req.getParameter("longitude");

            if (name == null || name.trim().isEmpty() ||
                address == null || address.trim().isEmpty() ||
                typeStr == null || typeStr.trim().isEmpty() ||
                latStr == null || latStr.trim().isEmpty() ||
                lngStr == null || lngStr.trim().isEmpty()) {
                
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Vui lòng điền đầy đủ thông tin bắt buộc.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // --- Create Model Object ---
            CollectionPoint cp = new CollectionPoint();
            cp.setName(name);
            cp.setAddress(address);
            cp.setCompanyId(currentUser.getUserId()); // Assign company ID

            // Parse and validate type
            try {
                cp.setType(CollectionPointType.valueOf(typeStr));
            } catch (IllegalArgumentException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Loại rác không hợp lệ.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // Parse and validate coordinates
            try {
                double lat = Double.parseDouble(latStr);
                double lng = Double.parseDouble(lngStr);
                cp.setLocation(new GeoPoint(lng, lat));
            } catch (NumberFormatException e) {
                resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
                response.addProperty("status", "error");
                response.addProperty("message", "Tọa độ không hợp lệ.");
                resp.getWriter().write(gson.toJson(response));
                return;
            }

            // --- Call DAO ---
            if (collectionPointDAO.insert(cp)) {
                resp.setStatus(HttpServletResponse.SC_OK);
                response.addProperty("status", "success");
                response.addProperty("message", "Thêm điểm thu gom thành công!");
            } else {
                resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
                response.addProperty("status", "error");
                response.addProperty("message", "Lỗi khi lưu vào cơ sở dữ liệu.");
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
