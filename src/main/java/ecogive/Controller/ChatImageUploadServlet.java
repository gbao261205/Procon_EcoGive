package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonObject;
import ecogive.util.CloudinaryService; // Import CloudinaryService
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.MultipartConfig;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import jakarta.servlet.http.Part;

import java.io.IOException;

@WebServlet("/api/chat/upload-image")
@MultipartConfig(
        fileSizeThreshold = 1024 * 1024 * 2, // 2MB
        maxFileSize = 1024 * 1024 * 10,      // 10MB
        maxRequestSize = 1024 * 1024 * 50    // 50MB
)
public class ChatImageUploadServlet extends HttpServlet {

    private final CloudinaryService cloudinaryService = new CloudinaryService();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");
        JsonObject jsonResponse = new JsonObject();
        Gson gson = new Gson();

        try {
            Part filePart = req.getPart("image");
            if (filePart == null || filePart.getSize() == 0) {
                jsonResponse.addProperty("status", "error");
                jsonResponse.addProperty("message", "Chưa chọn ảnh");
                resp.getWriter().write(gson.toJson(jsonResponse));
                return;
            }

            // --- SỬ DỤNG CLOUDINARY SERVICE ---
            String imageUrl = cloudinaryService.uploadImage(filePart);
            
            if (imageUrl != null) {
                jsonResponse.addProperty("status", "success");
                jsonResponse.addProperty("imageUrl", imageUrl);
            } else {
                throw new IOException("Không nhận được URL từ Cloudinary");
            }
            
        } catch (Exception e) {
            e.printStackTrace();
            jsonResponse.addProperty("status", "error");
            jsonResponse.addProperty("message", "Lỗi upload: " + e.getMessage());
        }

        resp.getWriter().write(gson.toJson(jsonResponse));
    }
}
