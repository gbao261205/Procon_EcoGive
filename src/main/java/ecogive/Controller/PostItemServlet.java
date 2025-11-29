package ecogive.controller;

import ecogive.Model.GeoPoint;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.HttpSession;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.time.LocalDateTime;
import java.util.UUID;

@WebServlet("/post-item")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class PostItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        req.setCharacterEncoding("UTF-8");

        // 1. Kiểm tra đăng nhập
        HttpSession session = req.getSession(false);
        if (session == null || session.getAttribute("currentUser") == null) {
            resp.sendError(HttpServletResponse.SC_UNAUTHORIZED, "Bạn cần đăng nhập để đăng tin.");
            return;
        }
        User currentUser = (User) session.getAttribute("currentUser");

        try {
            // 2. Lấy dữ liệu từ Form
            String title = req.getParameter("title");
            String description = req.getParameter("description");
            String categoryIdStr = req.getParameter("category"); // Nhận ID danh mục
            // Trong demo HTML bạn dùng text category, nhưng DB cần ID.
            // Để đơn giản cho demo này, ta hardcode category_id = 1 hoặc parse từ form nếu bạn làm dropdown.
            // Tạm thời fix cứng là 1 (Nội thất) để test, sau này bạn sửa form thành <select>
            int categoryId = 1;

            double lat = Double.parseDouble(req.getParameter("latitude"));
            double lng = Double.parseDouble(req.getParameter("longitude"));

            // 3. Xử lý Upload ảnh
            Part filePart = req.getPart("itemPhoto");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = UUID.randomUUID().toString() + "_" + fileName;

            // Lưu ảnh vào thư mục "uploads" trong server (hoặc thư mục project nếu cấu hình)
            // LƯU Ý: Để đơn giản, ta lưu vào thư mục images của Webapp
            String uploadPath = getServletContext().getRealPath("") + File.separator + "images";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            filePart.write(uploadPath + File.separator + uniqueFileName);

            // Đường dẫn để lưu vào DB (Relative path)
            String dbImageUrl = "images/" + uniqueFileName;

            // 4. Tạo đối tượng Item
            Item item = new Item();
            item.setGiverId(currentUser.getUserId());
            item.setTitle(title);
            item.setDescription(description);
            item.setCategoryId(categoryId);
            item.setImageUrl(dbImageUrl);
            item.setStatus(ItemStatus.PENDING); // Mặc định là chờ duyệt
            item.setPostDate(LocalDateTime.now());
            item.setLocation(new GeoPoint(lng, lat)); // Lưu ý: GeoPoint(lng, lat)

            // 5. Lưu vào DB
            boolean success = itemDAO.insert(item);

            if (success) {
                // Trả về JSON thành công
                resp.setContentType("application/json");
                resp.getWriter().write("{\"status\":\"success\", \"message\":\"Đăng tin thành công! Chờ Admin duyệt.\"}");
            } else {
                resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi khi lưu vào Database");
            }

        } catch (Exception e) {
            e.printStackTrace();
            resp.sendError(HttpServletResponse.SC_INTERNAL_SERVER_ERROR, "Lỗi xử lý: " + e.getMessage());
        }
    }
}