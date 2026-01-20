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

            if (minLatStr != null && maxLatStr != null && minLngStr != null && maxLngStr != null) {
                double minLat = Double.parseDouble(minLatStr);
                double maxLat = Double.parseDouble(maxLatStr);
                double minLng = Double.parseDouble(minLngStr);
                double maxLng = Double.parseDouble(maxLngStr);
                
                Integer categoryId = null;
                if (categoryIdStr != null && !categoryIdStr.isEmpty()) {
                    try {
                        categoryId = Integer.parseInt(categoryIdStr);
                    } catch (NumberFormatException e) {
                        // Ignore invalid categoryId
                    }
                }

                items = itemDAO.findAvailableInBounds(minLat, minLng, maxLat, maxLng, categoryId);
            } else {
                // Fallback: Lấy tất cả (hoặc giới hạn số lượng nếu cần)
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
            resp.getWriter().write("{\"error\": \"Tham số toạ độ không hợp lệ\"}");
        }
    }
}