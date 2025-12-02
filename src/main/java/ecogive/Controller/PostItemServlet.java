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

    /**
     * Helper: Lấy đường dẫn tuyệt đối đến thư mục source code (src/main/webapp/img_items)
     * Để tránh việc mất ảnh khi redeploy server.
     */
    private String getProjectUploadDirectory() {
        System.out.println("=== UPLOAD DIRECTORY DEBUG ===");

        // Lấy đường dẫn thư mục hiện tại (nơi JVM đang chạy)
        String currentDir = System.getProperty("user.dir");
        System.out.println("Current working directory (user.dir): " + currentDir);

        File currentDirFile = new File(currentDir);
        String projectRoot = null;

        // 1. Kiểm tra thư mục hiện tại có chứa src không
        if (new File(currentDirFile, "src").exists()) {
            projectRoot = currentDirFile.getAbsolutePath();
        }
        // 2. Nếu không, tìm ngược lên các thư mục cha (thường gặp khi chạy trong Tomcat/bin)
        else {
            File parent = currentDirFile;
            int maxLevels = 10;

            for (int i = 0; i < maxLevels; i++) {
                parent = parent.getParentFile();
                if (parent == null) break;

                // Tìm thư mục tên "ecogive" (tên project) có chứa src
                File[] subdirs = parent.listFiles(File::isDirectory);
                if (subdirs != null) {
                    for (File subdir : subdirs) {
                        if (subdir.getName().equals("ecogive") && new File(subdir, "src").exists()) {
                            projectRoot = subdir.getAbsolutePath();
                            break;
                        }
                    }
                }
                if (projectRoot != null) break;

                // Hoặc kiểm tra trực tiếp parent
                if (new File(parent, "src").exists()) {
                    projectRoot = parent.getAbsolutePath();
                    break;
                }
            }
        }

        // Fallback: Nếu không tìm thấy, dùng thư mục hiện tại
        if (projectRoot == null) {
            System.out.println("WARNING: Could not find project root automatically, using current dir.");
            projectRoot = currentDir;
        }

        // Tạo đường dẫn đến folder img_items trong webapp
        String uploadPath = projectRoot + File.separator + "src" + File.separator +
                "main" + File.separator + "webapp" + File.separator + "img_items";

        System.out.println("Final upload path: " + uploadPath);
        return uploadPath;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            // 1. Kiểm tra đăng nhập
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

            // 3. Xử lý file ảnh (Logic mới kết hợp)
            Part filePart = req.getPart("itemPhoto");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();

            // Tạo tên file unique
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;

            // Sử dụng hàm helper để lấy đường dẫn lưu file an toàn
            String uploadPath = getProjectUploadDirectory();
            File uploadDir = new File(uploadPath);

            if (!uploadDir.exists()) {
                uploadDir.mkdirs(); // Tạo thư mục nếu chưa có
            }

            String filePath = uploadPath + File.separator + uniqueFileName;

            // Ghi file ra ổ cứng
            filePart.write(filePath);
            System.out.println("File saved at: " + filePath);

            // Chuẩn hóa đường dẫn cho DB (thay thế dấu \ bằng /)
            // Đây là bước quan trọng để JSP đọc được ảnh qua Servlet
            String imageUrlForDB = filePath.replace("\\", "/");

            // 4. Tạo đối tượng Item
            Item item = new Item();
            item.setTitle(title);
            item.setDescription(description);
            item.setGiverId(currentUser.getUserId());
            item.setCategoryId(categoryId);

            // LƯU Ý: Lưu đường dẫn tuyệt đối vào DB
            item.setImageUrl(imageUrlForDB);

            item.setStatus(ItemStatus.PENDING);
            item.setPostDate(LocalDateTime.now());
            item.setLocation(new GeoPoint(longitude, latitude));

            // 5. Lưu vào database
            boolean success = itemDAO.insert(item);
            if (!success) {
                throw new SQLException("Không thể lưu item vào database");
            }

            // 6. Trả về thành công (Giữ format JSON chi tiết của bạn)
            resp.setStatus(HttpServletResponse.SC_OK);

            // Escape đường dẫn ảnh cho chuỗi JSON (tránh lỗi cú pháp JSON)
            String escapedImageUrl = item.getImageUrl().replace("\"", "\\\"");

            String jsonResponse = String.format(
                    "{\"success\": true, \"itemId\": %d, \"imageUrl\": \"%s\", \"ecoPointsAwarded\": 5, \"message\": \"Đăng tin thành công!\"}",
                    item.getItemId(),
                    escapedImageUrl
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