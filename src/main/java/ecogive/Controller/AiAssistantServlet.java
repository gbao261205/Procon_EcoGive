package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import ecogive.Model.CollectionPoint;
import ecogive.Model.CollectionPointType;
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
        quickReplies.add("🔍 Tìm sản phẩm theo tên...");
        quickReplies.add("📂 Tìm sản phẩm theo danh mục...");
        quickReplies.add("📍 Tìm điểm thu gom gần đây");
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
        CollectionPointType typeToSearch = null;

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
            // --- 3. HƯỚNG DẪN TÍCH ĐIỂM ---
            else if (lowerQuestion.contains("cách tích điểm") || lowerQuestion.contains("ecopoints")) {
                answer = "Bạn có thể tích điểm EcoPoints bằng cách:\n" +
                         "1. Đăng tin tặng đồ cũ (được duyệt).\n" +
                         "2. Mang rác tái chế đến các điểm thu gom.\n" +
                         "3. Tham gia các sự kiện xanh của EcoGive.\n" +
                         "Điểm này có thể dùng để đổi quà hoặc vinh danh trên bảng xếp hạng!";
            }
            // --- 4. HƯỚNG DẪN TÁI CHẾ (GỌI GROQ API) ---
            else if (lowerQuestion.startsWith("hướng dẫn cách tái chế:")) {
                String itemToRecycle = question.substring("hướng dẫn cách tái chế:".length()).trim();
                if (itemToRecycle.isEmpty()) {
                    answer = "Vui lòng nhập tên vật phẩm bạn muốn tái chế.";
                } else {
                    answer = callGroqApi(itemToRecycle);
                }
            }
            // --- 5. TÌM ĐIỂM THU GOM (LOGIC CŨ) ---
            else {
                if (lowerQuestion.contains("pin") || lowerQuestion.contains("ắc quy")) {
                    answer = "Pin cũ chứa kim loại nặng độc hại, tuyệt đối không bỏ thùng rác thường. Bạn có thể mang đến các điểm thu gom Pin dưới đây:";
                    typeToSearch = CollectionPointType.BATTERY;
                }
                else if (lowerQuestion.contains("thuốc") || lowerQuestion.contains("y tế") || lowerQuestion.contains("kim tiêm")) {
                    answer = "Rác thải y tế cần xử lý chuyên biệt để tránh lây nhiễm. Hãy liên hệ các trạm y tế hoặc điểm thu gom sau:";
                    typeToSearch = CollectionPointType.MEDICAL;
                }
                else if (lowerQuestion.contains("hóa chất") || lowerQuestion.contains("tẩy rửa") || lowerQuestion.contains("sơn")) {
                    answer = "Hóa chất thừa cần được xử lý tại các cơ sở chuyên dụng. Dưới đây là gợi ý cho bạn:";
                    typeToSearch = CollectionPointType.CHEMICAL;
                }
                else if (lowerQuestion.contains("điện tử") || lowerQuestion.contains("máy tính") || lowerQuestion.contains("điện thoại") || lowerQuestion.contains("tivi")) {
                    answer = "Đồ điện tử cũ (E-Waste) có thể tái chế được các linh kiện quý. Bạn có thể mang đến các điểm này:";
                    typeToSearch = CollectionPointType.E_WASTE;
                }
                else if (lowerQuestion.contains("quần áo") || lowerQuestion.contains("vải")) {
                    answer = "Quần áo cũ có thể quyên góp từ thiện hoặc tái chế. Xem các điểm nhận đồ vải tại đây:";
                    typeToSearch = CollectionPointType.TEXTILE;
                }
                else if (lowerQuestion.contains("bán") || lowerQuestion.contains("ve chai") || lowerQuestion.contains("đồng nát")) {
                    answer = "Nếu bạn muốn bán phế liệu, hãy liên hệ các đại lý hoặc cá nhân thu mua uy tín gần đây:";
                    typeToSearch = CollectionPointType.DEALER;
                }
                else if (lowerQuestion.contains("điểm thu gom") || lowerQuestion.contains("trạm")) {
                     answer = "Dưới đây là một số điểm thu gom gần đây:";
                     typeToSearch = CollectionPointType.BATTERY; 
                }
                else {
                    answer = "Xin lỗi, tôi chưa hiểu rõ yêu cầu. Bạn có thể hỏi về: 'tìm sản phẩm', 'điểm thu gom pin', 'cách tích điểm', hoặc 'hướng dẫn cách tái chế: [tên vật phẩm]'...";
                }

                if (typeToSearch != null) {
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
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            answer = "Đã xảy ra lỗi khi xử lý yêu cầu của bạn.";
        }

        response.addProperty("answer", answer);
        response.add("suggestions", suggestions);
        response.add("quickReplies", quickReplies);

        resp.getWriter().write(new Gson().toJson(response));
    }

    private String callGroqApi(String item) {
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
        systemMsg.addProperty("content", "Bạn là một trợ lý AI chuyên về tái chế và bảo vệ môi trường. Hãy hướng dẫn người dùng cách tái chế hoặc xử lý loại rác thải họ hỏi một cách ngắn gọn, súc tích và an toàn. Nếu vật phẩm không thể tái chế, hãy hướng dẫn cách vứt bỏ đúng quy định. Chỉ trả lời bằng tiếng Việt.");
        messages.add(systemMsg);

        JsonObject userMsg = new JsonObject();
        userMsg.addProperty("role", "user");
        userMsg.addProperty("content", "Hướng dẫn tôi cách tái chế hoặc xử lý: " + item);
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
