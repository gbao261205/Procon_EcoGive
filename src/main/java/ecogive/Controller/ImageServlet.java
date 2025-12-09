package ecogive.Controller;

import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.File;
import java.io.FileInputStream;
import java.io.IOException;
import java.io.OutputStream;
import java.nio.file.Files;

/**
 * Servlet để serve ảnh từ thư mục project
 * URL format: /images?path=C:/Users/POW/workspace/ecogive/src/main/webapp/img_items/123.png
 */
@WebServlet("/images")
public class ImageServlet extends HttpServlet {

    @Override
    protected void doGet(HttpServletRequest req, HttpServletResponse resp)
            throws ServletException, IOException {

        String imagePath = req.getParameter("path");

        System.out.println("=== IMAGE SERVLET DEBUG ===");
        System.out.println("Requested image path: " + imagePath);

        if (imagePath == null || imagePath.trim().isEmpty()) {
            resp.sendError(HttpServletResponse.SC_BAD_REQUEST, "Missing 'path' parameter");
            return;
        }

        File imageFile = new File(imagePath);

        System.out.println("File exists: " + imageFile.exists());
        System.out.println("File absolute path: " + imageFile.getAbsolutePath());
        System.out.println("File size: " + imageFile.length() + " bytes");

        // Kiểm tra file có tồn tại không
        if (!imageFile.exists() || !imageFile.isFile()) {
            System.out.println("ERROR: File not found!");
            resp.sendError(HttpServletResponse.SC_NOT_FOUND, "Image not found");
            return;
        }

        // Kiểm tra security: chỉ cho phép file trong thư mục img_items
        if (!imagePath.contains("img_items")) {
            System.out.println("ERROR: Security violation - path doesn't contain img_items");
            resp.sendError(HttpServletResponse.SC_FORBIDDEN, "Access denied");
            return;
        }

        // Xác định content type dựa trên extension
        String mimeType = Files.probeContentType(imageFile.toPath());
        if (mimeType == null) {
            // Fallback nếu không detect được
            String fileName = imageFile.getName().toLowerCase();
            if (fileName.endsWith(".png")) mimeType = "image/png";
            else if (fileName.endsWith(".jpg") || fileName.endsWith(".jpeg")) mimeType = "image/jpeg";
            else if (fileName.endsWith(".gif")) mimeType = "image/gif";
            else if (fileName.endsWith(".webp")) mimeType = "image/webp";
            else mimeType = "application/octet-stream";
        }

        System.out.println("Content type: " + mimeType);
        System.out.println("=========================\n");

        // Set response headers
        resp.setContentType(mimeType);
        resp.setContentLengthLong(imageFile.length());
        resp.setHeader("Cache-Control", "public, max-age=31536000"); // Cache 1 năm

        // Đọc và gửi file
        try (FileInputStream fis = new FileInputStream(imageFile);
             OutputStream os = resp.getOutputStream()) {

            byte[] buffer = new byte[8192];
            int bytesRead;
            while ((bytesRead = fis.read(buffer)) != -1) {
                os.write(buffer, 0, bytesRead);
            }
            os.flush();
        }
    }
}