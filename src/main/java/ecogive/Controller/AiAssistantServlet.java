package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import ecogive.Model.CollectionPoint;
import ecogive.Model.Item;
import ecogive.dao.CollectionPointDAO;
import ecogive.dao.ItemDAO;
import io.github.cdimascio.dotenv.Dotenv;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;
import okhttp3.*;

import java.io.IOException;
import java.util.List;
import java.util.concurrent.TimeUnit;

@WebServlet("/api/ai-assistant")
public class AiAssistantServlet extends HttpServlet {

    private final CollectionPointDAO pointDAO = new CollectionPointDAO();
    private final ItemDAO itemDAO = new ItemDAO();
    private String groqApiKey;
    private static final String GROQ_API_URL = "https://api.groq.com/openai/v1/chat/completions";

    @Override
    public void init() throws ServletException {
        super.init();
        // Load API key từ file .env khi servlet được khởi tạo
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
        this.groqApiKey = dotenv.get("GROQ_API_KEY");
        if (this.groqApiKey == null || this.groqApiKey.isEmpty()) {
            System.err.println("FATAL ERROR: GROQ_API_KEY not found in .env file!");
        } else {
            System.out.println("GROQ_API_KEY loaded: " + this.groqApiKey.substring(0, 5) + "...");
        }
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String question = req.getParameter("question");
        JsonObject response = new JsonObject();
        JsonArray suggestions = new JsonArray();
        JsonArray quickReplies = new JsonArray();

        // Luôn thêm các câu hỏi nhanh vào response
        // quickReplies.add("🔍 Tìm sản phẩm theo tên...");
        // quickReplies.add("📂 Tìm sản phẩm theo danh mục...");
        // quickReplies.add("📍 Tìm điểm thu gom gần đây");
        quickReplies.add("❓ Cách tích điểm EcoPoints?");
        quickReplies.add("♻️ Hướng dẫn cách tái chế: ..."); // Thêm nút mới

        if (question == null || question.trim().isEmpty()) {
            response.addProperty("answer", "Bạn cần giúp gì về việc phân loại rác hoặc tìm điểm thu gom?");
            response.add("suggestions", suggestions);
            response.add("quickReplies", quickReplies);
            resp.getWriter().write(new Gson().toJson(response));
            return;
        }

        String lowerQuestion = question.toLowerCase().trim();
        String answer = "";
        String typeToSearch = null;

        try {
            // --- 1. TÌM SẢN PHẨM THEO TÊN ---
            if (lowerQuestion.startsWith("tìm sản phẩm tên:")) {
                String keyword = question.substring("tìm sản phẩm tên:".length()).trim();
                List<Item> items = itemDAO.searchByTitle(keyword);
                
                if (items.isEmpty()) {
                    answer = "Không tìm thấy sản phẩm nào có tên chứa '" + keyword + "'.";
                } else {
                    answer = "Tìm thấy " + items.size() + " sản phẩm phù hợp:";
                    for (Item item : items) {
                        JsonObject iJson = new JsonObject();
                        iJson.addProperty("name", "📦 " + item.getTitle());
                        iJson.addProperty("address", item.getDescription());
                        if (item.getLocation() != null) {
                            iJson.addProperty("lat", item.getLocation().getLatitude());
                            iJson.addProperty("lng", item.getLocation().getLongitude());
                        }
                        suggestions.add(iJson);
                    }
                }
            }
            // --- 2. TÌM SẢN PHẨM THEO DANH MỤC ---
            else if (lowerQuestion.startsWith("tìm sản phẩm thuộc danh mục:")) {
                String catName = question.substring("tìm sản phẩm thuộc danh mục:".length()).trim();
                List<Item> items = itemDAO.searchByCategoryName(catName);
                
                if (items.isEmpty()) {
                    answer = "Không tìm thấy sản phẩm nào thuộc danh mục '" + catName + "'.";
                } else {
                    answer = "Dưới đây là các sản phẩm thuộc danh mục '" + catName + "':";
                    for (Item item : items) {
                        JsonObject iJson = new JsonObject();
                        iJson.addProperty("name", "📦 " + item.getTitle());
                        iJson.addProperty("address", item.getDescription());
                        if (item.getLocation() != null) {
                            iJson.addProperty("lat", item.getLocation().getLatitude());
                            iJson.addProperty("lng", item.getLocation().getLongitude());
                        }
                        suggestions.add(iJson);
                    }
                }
            }
            // --- 3. TÌM SẢN PHẨM TỰ NHIÊN (MỚI) ---
            else if (lowerQuestion.contains("muốn tìm") || lowerQuestion.startsWith("tìm ") || lowerQuestion.startsWith("có "))  {
                // Trích xuất keyword
                String keyword = lowerQuestion.replace("tôi muốn tìm", "")
                                              .replace("tìm giúp tôi", "")
                                              .replace("tìm", "")
                                              .replace("có", "")
                                              .replace("không", "")
                                              .replace("?", "")
                                              .trim();
                
                if (keyword.isEmpty()) {
                    answer = "Bạn muốn tìm sản phẩm gì? Hãy nhập tên cụ thể nhé.";
                } else {
                    List<Item> items = itemDAO.searchByTitle(keyword);
                    if (items.isEmpty()) {
                        answer = "Rất tiếc, hiện tại không có sản phẩm '" + keyword + "' nào trên hệ thống. Vui lòng quay lại sau!";
                    } else {
                        answer = "Tìm thấy " + items.size() + " sản phẩm '" + keyword + "' phù hợp:";
                        for (Item item : items) {
                            JsonObject iJson = new JsonObject();
                            iJson.addProperty("name", "📦 " + item.getTitle());
                            iJson.addProperty("address", item.getDescription());
                            if (item.getLocation() != null) {
                                iJson.addProperty("lat", item.getLocation().getLatitude());
                                iJson.addProperty("lng", item.getLocation().getLongitude());
                            }
                            suggestions.add(iJson);
                        }
                    }
                }
            }
            // --- 4. HƯỚNG DẪN TÍCH ĐIỂM ---
            else if (lowerQuestion.contains("cách tích điểm") || lowerQuestion.contains("ecopoints")) {
                answer = "Bạn có thể tích điểm EcoPoints bằng cách:\n" +
                         "1. Đăng tin tặng đồ cũ (được duyệt).\n" +
                         "2. Mang rác tái chế đến các điểm thu gom.\n" +
                         "3. Tham gia các sự kiện xanh của EcoGive.\n" +
                         "Điểm này có thể dùng để đổi quà hoặc vinh danh trên bảng xếp hạng!";
            }
            // --- 5. HƯỚNG DẪN TÁI CHẾ (GỌI GROQ API) ---
            else if (lowerQuestion.startsWith("hướng dẫn cách tái chế:") || lowerQuestion.contains("tái chế")) {
                String itemToRecycle = "";
                if (lowerQuestion.startsWith("hướng dẫn cách tái chế:")) {
                    itemToRecycle = question.substring("hướng dẫn cách tái chế:".length()).trim();
                } else {
                    itemToRecycle = question;
                }

                if (itemToRecycle.isEmpty()) {
                    answer = "Vui lòng nhập tên vật phẩm bạn muốn tái chế.";
                } else {
                    // 5.1. Kiểm tra xem có điểm thu gom nào trên web phù hợp không
                    String localSuggestion = "";
                    String type = detectWasteType(itemToRecycle);
                    
                    if (type != null) {
                        try {
                            List<CollectionPoint> points = pointDAO.findByType(type);
                            if (!points.isEmpty()) {
                                localSuggestion = "💡 **Gợi ý từ EcoGive:** Chúng tôi tìm thấy " + points.size() + " điểm thu gom phù hợp trên hệ thống:\n";
                                int count = 0;
                                for (CollectionPoint p : points) {
                                    if (count >= 3) break;
                                    JsonObject pJson = new JsonObject();
                                    pJson.addProperty("name", "📍 " + p.getName());
                                    pJson.addProperty("address", p.getAddress());
                                    pJson.addProperty("lat", p.getLatitude());
                                    pJson.addProperty("lng", p.getLongitude());
                                    suggestions.add(pJson);
                                    count++;
                                }
                            }
                        } catch (Exception e) {
                            System.err.println("Database error when finding points: " + e.getMessage());
                            // Ignore DB error and proceed to AI
                        }
                    }

                    // 5.2. Gọi AI để lấy hướng dẫn chi tiết
                    String aiAdvice = callGroqApi(itemToRecycle);
                    
                    if (!localSuggestion.isEmpty()) {
                        answer = localSuggestion + "\n\n" + aiAdvice;
                    } else {
                        answer = aiAdvice;
                    }
                }
            }
            // --- 6. TÌM ĐIỂM THU GOM (LOGIC CŨ) ---
            else {
                typeToSearch = detectWasteType(lowerQuestion);
                
                if (typeToSearch != null) {
                    answer = "Dưới đây là các điểm thu gom phù hợp với yêu cầu của bạn:";
                } else if (lowerQuestion.contains("điểm thu gom") || lowerQuestion.contains("trạm")) {
                     answer = "Dưới đây là một số điểm thu gom gần đây:";
                     typeToSearch = "BATTERY"; // Mặc định
                } else {
                    // Nếu không khớp các lệnh trên, coi như là câu hỏi chung và gửi cho AI xử lý
                    // Nhưng AI sẽ có rule chặn các câu hỏi không liên quan
                    answer = callGroqApi(question);
                }

                if (typeToSearch != null) {
                    try {
                        List<CollectionPoint> points = pointDAO.findByType(typeToSearch);
                        int count = 0;
                        for (CollectionPoint p : points) {
                            if (count >= 3) break;
                            JsonObject pJson = new JsonObject();
                            pJson.addProperty("name", "📍 " + p.getName());
                            pJson.addProperty("address", p.getAddress());
                            pJson.addProperty("lat", p.getLatitude());
                            pJson.addProperty("lng", p.getLongitude());
                            suggestions.add(pJson);
                            count++;
                        }
                    } catch (Exception e) {
                        System.err.println("Database error when finding points: " + e.getMessage());
                        answer += "\n(Hiện tại không thể tải danh sách điểm thu gom do lỗi kết nối)";
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            answer = "Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.";
        }

        response.addProperty("answer", answer);
        response.add("suggestions", suggestions);
        response.add("quickReplies", quickReplies);

        resp.getWriter().write(new Gson().toJson(response));
    }

    private String detectWasteType(String text) {
        String lower = text.toLowerCase();
        if (lower.contains("pin") || lower.contains("ắc quy")) return "BATTERY";
        if (lower.contains("thuốc") || lower.contains("y tế") || lower.contains("kim tiêm")) return "MEDICAL";
        if (lower.contains("hóa chất") || lower.contains("tẩy rửa") || lower.contains("sơn")) return "CHEMICAL";
        if (lower.contains("điện tử") || lower.contains("máy tính") || lower.contains("điện thoại") || lower.contains("tivi")) return "E_WASTE";
        if (lower.contains("quần áo") || lower.contains("vải")) return "TEXTILE";
        if (lower.contains("bán") || lower.contains("ve chai") || lower.contains("đồng nát")) return "DEALER";
        return null;
    }

    private String callGroqApi(String userQuestion) {
        if (groqApiKey == null || groqApiKey.isEmpty()) {
            return "Lỗi cấu hình: Không tìm thấy Groq API Key.";
        }

        OkHttpClient client = new OkHttpClient.Builder()
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .writeTimeout(30, TimeUnit.SECONDS)
            .build();

        JsonObject jsonBody = new JsonObject();
        jsonBody.addProperty("model", "llama-3.3-70b-versatile");
        
        JsonArray messages = new JsonArray();
        JsonObject systemMsg = new JsonObject();
        systemMsg.addProperty("role", "system");
        
        // --- BILINGUAL SYSTEM PROMPT ---
        systemMsg.addProperty("content", "You are an AI assistant for EcoGive, specializing in recycling and environmental protection.\n" +
                "IMPORTANT RULES:\n" +
                "1. You must ONLY answer questions related to recycling, waste sorting, and environmental protection.\n" +
                "2. If the user asks about other topics, politely refuse.\n" +
                "3. Provide concise, clear, and safe instructions.\n" +
                "4. LANGUAGE REQUIREMENT: Always match the language of the user's question. If they ask in Vietnamese, answer in Vietnamese. If they ask in English, answer in English.");
        messages.add(systemMsg);

        JsonObject userMsg = new JsonObject();
        userMsg.addProperty("role", "user");
        userMsg.addProperty("content", userQuestion);
        messages.add(userMsg);

        jsonBody.add("messages", messages);

        RequestBody body = RequestBody.create(jsonBody.toString(), MediaType.parse("application/json; charset=utf-8"));
        Request request = new Request.Builder()
                .url(GROQ_API_URL)
                .addHeader("Authorization", "Bearer " + groqApiKey)
                .addHeader("Content-Type", "application/json")
                .post(body)
                .build();

        try (Response response = client.newCall(request).execute()) {
            if (!response.isSuccessful()) {
                // --- DEBUG LOGGING ---
                String errorBody = response.body() != null ? response.body().string() : "No body";
                System.err.println("Groq API Error: Code=" + response.code() + ", Body=" + errorBody);
                // ---------------------
                return "Xin lỗi, hiện tại tôi không thể kết nối với máy chủ AI. Vui lòng thử lại sau.";
            }
            
            String responseBody = response.body().string();
            JsonObject jsonResponse = new Gson().fromJson(responseBody, JsonObject.class);
            return jsonResponse.getAsJsonArray("choices")
                    .get(0).getAsJsonObject()
                    .getAsJsonObject("message")
                    .get("content").getAsString();
        } catch (IOException e) {
            e.printStackTrace();
            return "Đã xảy ra lỗi khi gọi AI: " + e.getMessage();
        }
    }
}
