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
     * Lấy đường dẫn tuyệt đối đến thư mục project
     * Tự động tìm từ thư mục đang chạy
     */
    private String getProjectUploadDirectory() {
        System.out.println("=== UPLOAD DIRECTORY DEBUG ===");

        // Lấy đường dẫn thư mục hiện tại (nơi JVM đang chạy)
        String currentDir = System.getProperty("user.dir");
        System.out.println("Current working directory (user.dir): " + currentDir);

        File currentDirFile = new File(currentDir);
        String projectRoot = null;

        // Tìm thư mục project bằng cách tìm thư mục có chứa "src"
        // Kiểm tra thư mục hiện tại trước
        if (new File(currentDirFile, "src").exists()) {
            projectRoot = currentDirFile.getAbsolutePath();
            System.out.println("Found 'src' in current directory");
        }
        // Nếu đang chạy từ thư mục con (như webapps), tìm lên trên
        else {
            File parent = currentDirFile;
            int maxLevels = 10; // Tìm tối đa 10 cấp

            for (int i = 0; i < maxLevels; i++) {
                parent = parent.getParentFile();
                if (parent == null) break;

                System.out.println("Checking parent level " + (i+1) + ": " + parent.getAbsolutePath());

                // Tìm thư mục ecogive có chứa src
                File[] subdirs = parent.listFiles(File::isDirectory);
                if (subdirs != null) {
                    for (File subdir : subdirs) {
                        if (subdir.getName().equals("ecogive") && new File(subdir, "src").exists()) {
                            projectRoot = subdir.getAbsolutePath();
                            System.out.println("Found project 'ecogive' with 'src' folder at: " + projectRoot);
                            break;
                        }
                    }
                }

                if (projectRoot != null) break;

                // Hoặc kiểm tra xem thư mục parent có chứa src không
                if (new File(parent, "src").exists()) {
                    projectRoot = parent.getAbsolutePath();
                    System.out.println("Found 'src' in parent directory: " + projectRoot);
                    break;
                }
            }
        }

        // Nếu không tìm thấy, dùng đường dẫn mặc định
        if (projectRoot == null) {
            System.out.println("WARNING: Could not find project root automatically");
            System.out.println("Using current directory as fallback");
            projectRoot = currentDir;
        }

        String uploadPath = projectRoot + File.separator + "src" + File.separator +
                "main" + File.separator + "webapp" + File.separator + "img_items";

        System.out.println("Final project root: " + projectRoot);
        System.out.println("Final upload path: " + uploadPath);
        System.out.println("==============================");

        return uploadPath;
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        try {
            HttpSession session = req.getSession(false);
            User currentUser = (session != null) ? (User) session.getAttribute("currentUser") : null;
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

            Part filePart = req.getPart("itemPhoto");
            String fileName = Paths.get(filePart.getSubmittedFileName()).getFileName().toString();
            String uniqueFileName = System.currentTimeMillis() + "_" + fileName;

            // --- LƯU VÀO THƯ MỤC PROJECT (tự động phát hiện) ---
            String uploadPath = getProjectUploadDirectory();
            File uploadDir = new File(uploadPath);

            System.out.println("\n>>> SAVING FILE <<<");
            System.out.println("Upload directory exists: " + uploadDir.exists());

            if (!uploadDir.exists()) {
                boolean created = uploadDir.mkdirs();
                System.out.println("Created directory: " + created);
                System.out.println("Directory path: " + uploadDir.getAbsolutePath());
            }

            String filePath = uploadPath + File.separator + uniqueFileName;
            System.out.println("Full file path: " + filePath);

            filePart.write(filePath);

            File savedFile = new File(filePath);
            System.out.println("File saved successfully: " + savedFile.exists());
            System.out.println("File size: " + savedFile.length() + " bytes");
            System.out.println(">>>>>>>>>>>>>>>>>>>\n");

            // --- Lưu đường dẫn ĐẦY ĐỦ với dấu / vào database ---
            String imageUrl = filePath.replace("\\", "/"); // Chuyển tất cả \ thành /
            System.out.println("Image URL saved to database: " + imageUrl);

            Item item = new Item();
            item.setTitle(title);
            item.setDescription(description);
            item.setGiverId(currentUser.getUserId());
            item.setCategoryId(categoryId);
            item.setImageUrl(imageUrl);
            item.setStatus(ItemStatus.PENDING);
            item.setPostDate(LocalDateTime.now());
            item.setLocation(new GeoPoint(longitude, latitude));

            boolean success = itemDAO.insert(item);
            if (!success) {
                throw new SQLException("Could not save item to the database");
            }

            resp.setStatus(HttpServletResponse.SC_OK);
            resp.getWriter().write("{\"success\": true, \"imageUrl\": \"" + imageUrl + "\"}");

        } catch (Exception e) {
            e.printStackTrace();
            resp.setStatus(HttpServletResponse.SC_BAD_REQUEST);
            resp.getWriter().write("{\"error\": \"Lỗi xử lý: " + e.getMessage() + "\"}");
        }
    }
}