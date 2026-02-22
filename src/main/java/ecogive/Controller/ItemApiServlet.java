package ecogive.Controller;

import com.google.gson.*;
import ecogive.Model.Item;
import ecogive.dao.ItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.lang.reflect.Type;
import java.sql.SQLException;
import java.time.LocalDateTime;
import java.util.List;

@WebServlet("/api/items")
public class ItemApiServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    private final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
                @Override
                public JsonElement serialize(LocalDateTime src, Type typeOfSrc, JsonSerializationContext context) {
                    return new JsonPrimitive(src.toString());
                }
            })
            .create();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            List<Item> items;
            
            // Kiểm tra xem có tham số bounds không
            String minLatStr = req.getParameter("minLat");
            String maxLatStr = req.getParameter("maxLat");
            String minLngStr = req.getParameter("minLng");
            String maxLngStr = req.getParameter("maxLng");
            String categoryIdStr = req.getParameter("categoryId");
            
            // --- MỚI: Tham số cho phân trang và sắp xếp theo khoảng cách ---
            String latStr = req.getParameter("lat");
            String lngStr = req.getParameter("lng");
            String pageStr = req.getParameter("page");
            String limitStr = req.getParameter("limit");
            // ---------------------------------------------------------------

            if (minLatStr != null && maxLatStr != null && minLngStr != null && maxLngStr != null) {
                // Case 1: Lấy theo Viewport (Bản đồ)
                double minLat = Double.parseDouble(minLatStr);
                double maxLat = Double.parseDouble(maxLatStr);
                double minLng = Double.parseDouble(minLngStr);
                double maxLng = Double.parseDouble(maxLngStr);
                
                Integer categoryId = null;
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        categoryId = Integer.parseInt(categoryIdStr);
                    } catch (NumberFormatException e) {}
                }

                items = itemDAO.findAvailableInBounds(minLat, minLng, maxLat, maxLng, categoryId);
            } else if (latStr != null && lngStr != null) {
                // Case 2: Lấy theo khoảng cách và phân trang (Danh sách cuộn)
                double lat = Double.parseDouble(latStr);
                double lng = Double.parseDouble(lngStr);
                int page = (pageStr != null) ? Integer.parseInt(pageStr) : 1;
                int limit = (limitStr != null) ? Integer.parseInt(limitStr) : 10;
                int offset = (page - 1) * limit;
                
                Integer categoryId = null;
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        categoryId = Integer.parseInt(categoryIdStr);
                    } catch (NumberFormatException e) {}
                }
                
                items = itemDAO.findAvailableSortedByDistance(lat, lng, limit, offset, categoryId);
            } else {
                // Case 3: Fallback (Lấy tất cả - không khuyến khích nếu dữ liệu lớn)
                items = itemDAO.findAllAvailable();
            }

            String json = gson.toJson(items);
            resp.getWriter().write(json);

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Lỗi kết nối cơ sở dữ liệu\"}");
        } catch (NumberFormatException e) {
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"Tham số không hợp lệ\"}");
        }
    }
}