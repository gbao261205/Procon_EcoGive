package ecogive.util;

import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import com.google.gson.JsonParser;
import io.github.cdimascio.dotenv.Dotenv;

import java.io.ByteArrayOutputStream;
import java.io.IOException;
import java.io.InputStream;
import java.net.URI;
import java.net.URL;
import java.net.http.HttpClient;
import java.net.http.HttpRequest;
import java.net.http.HttpResponse;
import java.nio.charset.StandardCharsets;
import java.util.Base64;

public class GeminiService {

    private static final String API_URL = "https://generativelanguage.googleapis.com/v1beta/models/gemini-2.5-flash:generateContent";
    
    private final String apiKey;
    private final HttpClient httpClient;

    public GeminiService() {
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
        this.apiKey = dotenv.get("GEMINI_API_KEY");
        this.httpClient = HttpClient.newHttpClient();
    }

    public boolean checkImageCategory(String imageUrl, String categoryName) {
        if (apiKey == null || apiKey.isEmpty()) {
            System.err.println("GEMINI_API_KEY not found!");
            return false;
        }

        try {
            // 1. Tải ảnh từ URL và chuyển sang Base64
            String base64Image = downloadImageAsBase64(imageUrl);
            if (base64Image == null) return false;

            // 2. Tạo JSON Payload
            JsonObject payload = new JsonObject();
            JsonArray contents = new JsonArray();
            JsonObject contentObj = new JsonObject();
            JsonArray parts = new JsonArray();

            // Part 1: Text Prompt
            // Đảm bảo categoryName không bị null
            if (categoryName == null) categoryName = "Unknown";
            
            JsonObject textPart = new JsonObject();
            // Thêm hướng dẫn rõ ràng hơn cho Gemini
            textPart.addProperty("text", 
                "Look at this image. Does it contain an item that belongs to the category: '" + categoryName + "'? " +
                "Please answer with exactly one word: YES or NO.");
            parts.add(textPart);

            // Part 2: Image Data
            JsonObject imagePart = new JsonObject();
            JsonObject inlineData = new JsonObject();
            inlineData.addProperty("mime_type", "image/jpeg");
            inlineData.addProperty("data", base64Image);
            imagePart.add("inline_data", inlineData);
            parts.add(imagePart);

            contentObj.add("parts", parts);
            contents.add(contentObj);
            payload.add("contents", contents);

            // 3. Gửi Request (UTF-8)
            HttpRequest request = HttpRequest.newBuilder()
                    .uri(URI.create(API_URL + "?key=" + apiKey))
                    .header("Content-Type", "application/json; charset=utf-8")
                    .POST(HttpRequest.BodyPublishers.ofString(payload.toString(), StandardCharsets.UTF_8))
                    .build();

            HttpResponse<String> response = httpClient.send(request, HttpResponse.BodyHandlers.ofString(StandardCharsets.UTF_8));

            // 4. Xử lý Response
            if (response.statusCode() == 200) {
                JsonObject jsonResponse = JsonParser.parseString(response.body()).getAsJsonObject();
                try {
                    String answer = jsonResponse.getAsJsonArray("candidates")
                            .get(0).getAsJsonObject()
                            .getAsJsonObject("content")
                            .getAsJsonArray("parts")
                            .get(0).getAsJsonObject()
                            .get("text").getAsString().trim().toUpperCase();
                    
                    // --- LOG DEBUG CHI TIẾT ---
                    System.out.println("--------------------------------------------------");
                    System.out.println("Gemini Request Category: " + categoryName);
                    System.out.println("Gemini Response Answer: [" + answer + "]");
                    System.out.println("--------------------------------------------------");
                    // --------------------------

                    return answer.contains("YES");
                } catch (Exception e) {
                    System.err.println("Error parsing Gemini response: " + response.body());
                    return false;
                }
            } else {
                System.err.println("Gemini API Error: " + response.statusCode() + " - " + response.body());
                return false;
            }

        } catch (Exception e) {
            e.printStackTrace();
            return false;
        }
    }

    private String downloadImageAsBase64(String imageUrl) {
        try (InputStream in = new URL(imageUrl).openStream();
             ByteArrayOutputStream out = new ByteArrayOutputStream()) {
            
            byte[] buffer = new byte[1024];
            int n;
            while ((n = in.read(buffer)) != -1) {
                out.write(buffer, 0, n);
            }
            return Base64.getEncoder().encodeToString(out.toByteArray());
        } catch (IOException e) {
            System.err.println("Failed to download image: " + imageUrl);
            return null;
        }
    }
}
