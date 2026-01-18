package ecogive.Controller;

import ecogive.Model.GeoPoint;
import ecogive.Model.Item;
import ecogive.Model.ItemStatus;
import ecogive.Model.User;
import ecogive.dao.ItemDAO;
import ecogive.util.CloudinaryService;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.*;

import java.io.IOException;
import java.math.BigDecimal;
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
    private final CloudinaryService cloudinaryService = new CloudinaryService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = req.getSession(false);
            User currentUser = (session != null)
                    ? (User) session.getAttribute("currentUser")
                    : null;

            if (currentUser == null) {
                resp.setStatus(HttpServletResponse.SC_UNAUTHORIZED);
                resp.getWriter().write("{\"error\": \"Vui lòng đăng nhập\"}");
                return;
            }

            String title = req.getParameter("title");
            String description = req.getParameter("description");
            double latitude = Double.parseDouble(req.getParameter("latitude"));
            double longitude = Double.parseDouble(req.getParameter("longitude"));
            int categoryId = Integer.parseInt(req.getParameter("category"));
            
            // Xử lý ecoPoints an toàn
            String ecoPointsStr = req.getParameter("ecoPoints");
            BigDecimal ecoPoints;
            if (ecoPointsStr != null && !ecoPointsStr.trim().isEmpty()) {
                try {
                    ecoPoints = new BigDecimal(ecoPointsStr);
                } catch (NumberFormatException e) {
                    ecoPoints = BigDecimal.ZERO; 
                }
            } else {
                ecoPoints = BigDecimal.ZERO; 
            }

            Part filePart = req.getPart("itemPhoto");
            String imageUrlForDB;

            // Upload ảnh lên Cloudinary
            if (filePart != null && filePart.getSize() > 0) {
                try {
                    imageUrlForDB = cloudinaryService.uploadImage(filePart);
                } catch (Exception e) {
                    e.printStackTrace();
                    throw new IOException("Lỗi upload ảnh lên Cloudinary: " + e.getMessage());
                }
            } else {
                // Nếu không có ảnh, dùng ảnh mặc định (hoặc xử lý lỗi tùy ý)
                imageUrlForDB = "https://via.placeholder.com/300?text=No+Image";
            }

            Item item = new Item();
            item.setTitle(title);
            item.setDescription(description);
            item.setGiverId(currentUser.getUserId());
            item.setCategoryId(categoryId);
            item.setImageUrl(imageUrlForDB);
            
            // KHÔI PHỤC LOGIC CŨ: Trạng thái mặc định là PENDING (chờ duyệt)
            item.setStatus(ItemStatus.PENDING);
            
            item.setPostDate(LocalDateTime.now());
            item.setLocation(new GeoPoint(longitude, latitude));
            item.setEcoPoints(ecoPoints);

            boolean success = itemDAO.insert(item);
            if (!success) {
                throw new SQLException("Không thể lưu item vào database");
            }

            resp.setStatus(HttpServletResponse.SC_OK);
            // Escape URL để an toàn trong JSON
            String escapedImageUrl = item.getImageUrl().replace("\"", "\\\"");
            String jsonResponse = String.format(
                    "{\"success\": true, \"itemId\": %d, \"imageUrl\": \"%s\", \"ecoPointsAwarded\": %s, \"message\": \"Đăng tin thành công! Vui lòng chờ Admin duyệt.\"}",
                    item.getItemId(),
                    escapedImageUrl,
                    item.getEcoPoints().toPlainString()
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
