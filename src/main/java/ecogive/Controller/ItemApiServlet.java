package ecogive.controller;

import com.google.gson.Gson;
import ecogive.Model.Item;
import ecogive.dao.ItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.sql.SQLException;
import java.util.List;

// Đường dẫn này dành cho code JS gọi, không phải để người dùng vào trực tiếp
@WebServlet("/api/items")
public class ItemApiServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();
    private final Gson gson = new Gson();

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        // 1. Cấu hình phản hồi là JSON (UTF-8 để không lỗi font tiếng Việt)
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            // 2. Lấy danh sách vật phẩm "AVAILABLE" từ DB
            // (Chỉ hiện đồ còn hàng, không hiện đồ chờ duyệt hoặc đã xong)
            List<Item> items = itemDAO.findAllAvailable();

            // 3. Chuyển List<Item> thành chuỗi JSON
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