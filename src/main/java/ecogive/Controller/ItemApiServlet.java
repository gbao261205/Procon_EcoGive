package ecogive.Controller; // Lưu ý: Bạn kiểm tra lại tên package là Controller hay controller nhé (chữ hoa/thường)

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

    // --- SỬA Ở ĐÂY: Cấu hình Gson để xử lý LocalDateTime ---
    private final Gson gson = new GsonBuilder()
            .registerTypeAdapter(LocalDateTime.class, new JsonSerializer<LocalDateTime>() {
                @Override
                public JsonElement serialize(LocalDateTime src, Type typeOfSrc, JsonSerializationContext context) {
                    // Chuyển ngày tháng thành chuỗi String (VD: "2023-11-29T21:00:00")
                    return new JsonPrimitive(src.toString());
                }
            })
            .create();
    // -------------------------------------------------------

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            // 2. Lấy danh sách vật phẩm "AVAILABLE" từ DB
            List<Item> items = itemDAO.findAllAvailable();

            // 3. Chuyển List<Item> thành chuỗi JSON (Giờ đã hoạt động tốt với ngày tháng)
            String json = gson.toJson(items);

            // 4. Gửi về cho Client
            resp.getWriter().write(json);

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Lỗi kết nối cơ sở dữ liệu\"}");
        }
    }
}