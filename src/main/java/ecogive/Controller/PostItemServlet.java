package ecogive.Controller;

import ecogive.Model.GeoPoint;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.File;
import java.io.IOException;
import java.nio.file.Paths;
import java.sql.SQLException;
import java.time.LocalDateTime;

@WebServlet("/post-item")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2,  // 2MB
        maxFileSize = 1024 * 1024 * 10,       // 10MB
        maxRequestSize = 1024 * 1024 * 50     // 50MB
)
public class PostItemServlet extends HttpServlet {

    private final ItemDAO itemDAO = new ItemDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            // 1. Kiểm tra user đã login chưa
            HttpSession session = req.getSession(false);
            User currentUser = (session != null)
                    ? (User) session.getAttribute("currentUser")
                    : null;

            if (currentUser == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.getWriter().write("{\"error\": \"Vui lòng đăng nhập\"}");
                return;
            }

            // 2. Lấy dữ liệu từ form
            String title = req.getParameter("title");
            String description = req.getParameter("description");
            double latitude = Double.parseDouble(req.getParameter("latitude"));
            double longitude = Double.parseDouble(req.getParameter("longitude"));
            int categoryId = Integer.parseInt(req.getParameter("category"));

            // 3. Xử lý upload file ảnh
            Part filePart = req.getPart("itemPhoto");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            // Tạo tên file unique để tránh trùng
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;

            // Đường dẫn lưu file (bạn cần tạo thư mục "uploads" trong webapp)
            String uploadPath = getServletContext().getRealPath("") + File.separator + "uploads";
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) uploadDir.mkdir();

            String filePath = uploadPath + File.separator + uniqueFileName;
            filePart.write(filePath);

            // 4. Tạo đối tượng Item
            Item item = new Item();
            item.setTitle(title);
            item.setDescription(description);
            item.setGiverId(currentUser.getUserId());
            item.setCategoryId(categoryId);
            item.setImageUrl("uploads/" + uniqueFileName);
            item.setStatus(ItemStatus.PENDING); // Chờ admin duyệt
            item.setPostDate(LocalDateTime.now());

            GeoPoint location = new GeoPoint(longitude, latitude);
            item.setLocation(location);

            // 5. Lưu vào database
            boolean success = itemDAO.insert(item);
            if (!success) {
                throw new SQLException("Không thể lưu item vào database");
            }

            // 6. Trả về thành công
            resp.setStatus(HttpServletResponse.SC_OK);

            String jsonResponse = String.format(
                    "{\"success\": true, \"itemId\": %d, \"imageUrl\": \"%s\", \"ecoPointsAwarded\": 5, \"message\": \"Đăng tin thành công!\"}",
                    item.getItemId(),
                    item.getImageUrl()
            );
            resp.getWriter().write(jsonResponse);

        } catch (SQLException e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_INTERNAL_SERVER_ERROR);
            resp.getWriter().write("{\"error\": \"Lỗi database: " + e.getMessage() + "\"}");
        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"Lỗi xử lý: " + e.getMessage() + "\"}");
        }
    }
}