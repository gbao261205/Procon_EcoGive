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
import java.math.BigDecimal;
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

    private String getProjectUploadDirectory() {
        String currentDir = System.getProperty("user.dir");
        File currentDirFile = new File(currentDir);
        String projectRoot = null;
        if (new File(currentDirFile, "src").exists()) {
            projectRoot = currentDirFile.getAbsolutePath();
        } else {
            File parent = currentDirFile;
            int maxLevels = 10;
            for (int i = 0; i < maxLevels; i++) {
                parent = parent.getParentFile();
                if (parent == null) break;
                if (new File(parent, "src").exists()) {
                    projectRoot = parent.getAbsolutePath();
                    break;
                }
            }
        }
        if (projectRoot == null) {
            projectRoot = currentDir;
        }
        return projectRoot + File.separator + "src" + File.separator +
                "main" + File.separator + "webapp" + File.separator + "img_items";
    }

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
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;
            String uploadPath = getProjectUploadDirectory();
            File uploadDir = new File(uploadPath);
            if (!uploadDir.exists()) {
                uploadDir.mkdirs();
            }
            String filePath = uploadPath + File.separator + uniqueFileName;
            filePart.write(filePath);
            String imageUrlForDB = filePath.replace("\\", "/");

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
