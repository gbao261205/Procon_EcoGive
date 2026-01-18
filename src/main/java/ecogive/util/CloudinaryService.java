package ecogive.util;

import com.cloudinary.Cloudinary;
import com.cloudinary.utils.ObjectUtils;
import io.github.cdimascio.dotenv.Dotenv;
import jakarta.servlet.http.Part;

import java.io.File;
import java.io.FileOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.util.Map;

public class CloudinaryService {

    private static Cloudinary cloudinary;

    static {
        // Thử tải từ .env trước
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
        
        String cloudName = dotenv.get("CLOUDINARY_CLOUD_NAME");
        String apiKey = dotenv.get("CLOUDINARY_API_KEY");
        String apiSecret = dotenv.get("CLOUDINARY_API_SECRET");

        // Nếu không có trong .env, thử lấy từ biến môi trường hệ thống
        if (cloudName == null) cloudName = System.getenv("CLOUDINARY_CLOUD_NAME");
        if (apiKey == null) apiKey = System.getenv("CLOUDINARY_API_KEY");
        if (apiSecret == null) apiSecret = System.getenv("CLOUDINARY_API_SECRET");

        if (cloudName != null && apiKey != null && apiSecret != null) {
            cloudinary = new Cloudinary(ObjectUtils.asMap(
                    "cloud_name", cloudName,
                    "api_key", apiKey,
                    "api_secret", apiSecret,
                    "secure", true
            ));
        } else {
            System.err.println("WARNING: Cloudinary credentials not found in .env or environment variables.");
        }
    }

    public String uploadImage(Part filePart) throws IOException {
        if (cloudinary == null) {
            throw new IOException("Cloudinary not configured. Please check .env file.");
        }

        // Cloudinary SDK yêu cầu File hoặc byte array. 
        // Chuyển Part thành File tạm để upload
        File tempFile = File.createTempFile("upload_", "_" + getFileName(filePart));
        
        try (InputStream input = filePart.getInputStream();
             FileOutputStream output = new FileOutputStream(tempFile)) {
            byte[] buffer = new byte[1024];
            int length;
            while ((length = input.read(buffer)) > 0) {
                output.write(buffer, 0, length);
            }
        }

        try {
            // Upload lên Cloudinary
            Map uploadResult = cloudinary.uploader().upload(tempFile, ObjectUtils.asMap(
                    "folder", "ecogive_items", // Thư mục trên Cloudinary
                    "resource_type", "image"
            ));
            
            // Trả về URL bảo mật (https)
            return (String) uploadResult.get("secure_url");
        } finally {
            // Xóa file tạm sau khi upload xong
            if (tempFile.exists()) {
                tempFile.delete();
            }
        }
    }

    private String getFileName(Part part) {
        String contentDisp = part.getHeader("content-disposition");
        String[] tokens = contentDisp.split(";");
        for (String token : tokens) {
            if (token.trim().startsWith("filename")) {
                return token.substring(token.indexOf("=") + 2, token.length() - 1);
            }
        }
        return "unknown.jpg";
    }
}
