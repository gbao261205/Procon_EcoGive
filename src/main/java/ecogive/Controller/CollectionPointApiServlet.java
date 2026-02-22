package ecogive.Controller;

import com.google.gson.Gson;
import ecogive.Model.CollectionPoint;
import ecogive.dao.CollectionPointDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.ArrayList;
import java.util.List;

@WebServlet("/api/collection-points")
public class CollectionPointApiServlet extends HttpServlet {

    private final CollectionPointDAO stationDAO = new CollectionPointDAO();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            // --- MỚI: Tham số cho phân trang và sắp xếp theo khoảng cách ---
            String latStr = req.getParameter("lat");
            String lngStr = req.getParameter("lng");
            String pageStr = req.getParameter("page");
            String limitStr = req.getParameter("limit");
            
            // --- MỚI: Tham số lọc ---
            String typeCode = req.getParameter("type");
            String ownerRole = req.getParameter("ownerRole");
            // ---------------------------------------------------------------

            List<CollectionPoint> points;

            if (latStr != null && lngStr != null) {
                double lat = Double.parseDouble(latStr);
                double lng = Double.parseDouble(lngStr);
                int page = (pageStr != null) ? Integer.parseInt(pageStr) : 1;
                int limit = (limitStr != null) ? Integer.parseInt(limitStr) : 10;
                int offset = (page - 1) * limit;

                points = stationDAO.findAllSortedByDistance(lat, lng, limit, offset, typeCode, ownerRole);
            } else {
                // Fallback: Lấy tất cả (có thể thêm lọc ở đây nếu cần, nhưng hiện tại ưu tiên geo-search)
                if (typeCode != null) {
                    points = stationDAO.findByType(typeCode);
                } else {
                    points = stationDAO.findAll();
                }
            }

            List<StationDTO> dtos = new ArrayList<>();
            for (CollectionPoint p : points) {
                dtos.add(new StationDTO(p));
            }

            resp.getWriter().write(new Gson().toJson(dtos));
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
        }
    }

    // Sửa DTO để thêm ownerRole
    private static class StationDTO {
        long pointId;
        String name;
        String type;
        String address;
        double latitude;
        double longitude;
        String ownerRole; // Thêm trường này

        public StationDTO(CollectionPoint p) {
            this.pointId = p.getPointId();
            this.name = p.getName();
            this.type = p.getTypeCode(); // Đã sửa: dùng getTypeCode() thay vì getType().name()
            this.address = p.getAddress();
            this.ownerRole = p.getOwnerRole(); // Lấy dữ liệu từ model
            if (p.getLocation() != null) {
                this.latitude = p.getLocation().getLatitude();
                this.longitude = p.getLocation().getLongitude();
            }
        }
    }
}
