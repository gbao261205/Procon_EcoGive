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
import jakarta.servlet.http.HttpSession;
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
        Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();
        this.groqApiKey = dotenv.get("GROQ_API_KEY");
        if (this.groqApiKey == null || this.groqApiKey.isEmpty()) {
            System.err.println("FATAL ERROR: GROQ_API_KEY not found in .env file!");
        } else {
            System.out.println("GROQ_API_KEY loaded: " + this.groqApiKey.substring(0, 5) + "...");
        }
    }

    // Helper để thêm quick reply dạng Object {text, code, payload}
    // payload: Câu lệnh thực tế sẽ được điền vào ô chat (đã bản địa hóa)
    private void addQuickReply(JsonArray array, String text, String code, String payload) {
        JsonObject obj = new JsonObject();
        obj.addProperty("text", text);      // Hiển thị trên nút
        obj.addProperty("code", code);      // Mã logic (để focus input nếu cần)
        obj.addProperty("payload", payload);// Nội dung sẽ điền vào ô input
        array.add(obj);
    }

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String question = req.getParameter("question");
        
        HttpSession session = req.getSession(false);
        String lang = (session != null && session.getAttribute("lang") != null) 
                      ? (String) session.getAttribute("lang") 
                      : "vi";
        if (req.getParameter("lang") != null) {
            lang = req.getParameter("lang");
        }
        boolean isEnglish = "en".equals(lang);

        JsonObject response = new JsonObject();
        JsonArray suggestions = new JsonArray();
        JsonArray quickReplies = new JsonArray();

        // Quick Replies đa ngôn ngữ - Gửi kèm PAYLOAD đúng ngôn ngữ
        if (isEnglish) {
//            addQuickReply(quickReplies, "🔍 Search item by name...", "name", "search item name:");
//            addQuickReply(quickReplies, "📂 Search item by category...", "category", "search item category:");
//            addQuickReply(quickReplies, "📍 Find nearby collection points", "point", "find nearby collection points");
            addQuickReply(quickReplies, "❓ How to earn EcoPoints?", "guide", "how to earn ecopoints");
            addQuickReply(quickReplies, "♻️ Recycling guide: ...", "recycle", "recycling guide:");
        } else {
//            addQuickReply(quickReplies, "🔍 Tìm sản phẩm theo tên...", "name", "tìm sản phẩm tên:");
//            addQuickReply(quickReplies, "📂 Tìm sản phẩm theo danh mục...", "category", "tìm sản phẩm thuộc danh mục:");
//            addQuickReply(quickReplies, "📍 Tìm điểm thu gom gần đây", "point", "tìm điểm thu gom gần đây");
            addQuickReply(quickReplies, "❓ Cách tích điểm EcoPoints?", "guide", "cách tích điểm ecopoints");
            addQuickReply(quickReplies, "♻️ Hướng dẫn cách tái chế: ...", "recycle", "hướng dẫn cách tái chế:");
        }

        if (question == null || question.trim().isEmpty()) {
            String welcomeMsg = isEnglish 
                ? "How can I help you with waste sorting or finding collection points?" 
                : "Bạn cần giúp gì về việc phân loại rác hoặc tìm điểm thu gom?";
            response.addProperty("answer", welcomeMsg);
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
            boolean isSearchName = lowerQuestion.startsWith("tìm sản phẩm tên:") || lowerQuestion.startsWith("search item name:");
            String searchPrefix = lowerQuestion.startsWith("tìm sản phẩm tên:") ? "tìm sản phẩm tên:" : "search item name:";
            
            if (isSearchName) {
                String keyword = question.substring(searchPrefix.length()).trim();
                List<Item> items = itemDAO.searchByTitle(keyword);
                
                if (items.isEmpty()) {
                    answer = isEnglish 
                        ? "No items found with name containing '" + keyword + "'."
                        : "Không tìm thấy sản phẩm nào có tên chứa '" + keyword + "'.";
                } else {
                    answer = isEnglish 
                        ? "Found " + items.size() + " matching items:"
                        : "Tìm thấy " + items.size() + " sản phẩm phù hợp:";
                        
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
            else if (lowerQuestion.startsWith("tìm sản phẩm thuộc danh mục:") || lowerQuestion.startsWith("search item category:")) {
                String prefix = lowerQuestion.startsWith("tìm sản phẩm thuộc danh mục:") ? "tìm sản phẩm thuộc danh mục:" : "search item category:";
                String catName = question.substring(prefix.length()).trim();
                List<Item> items = itemDAO.searchByCategoryName(catName);
                
                if (items.isEmpty()) {
                    answer = isEnglish
                        ? "No items found in category '" + catName + "'."
                        : "Không tìm thấy sản phẩm nào thuộc danh mục '" + catName + "'.";
                } else {
                    answer = isEnglish
                        ? "Here are items in category '" + catName + "':"
                        : "Dưới đây là các sản phẩm thuộc danh mục '" + catName + "':";
                        
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
            // --- 3. TÌM SẢN PHẨM TỰ NHIÊN ---
            else if (lowerQuestion.contains("muốn tìm") || lowerQuestion.startsWith("tìm ") || lowerQuestion.startsWith("có ") ||
                     lowerQuestion.contains("want to find") || lowerQuestion.startsWith("find ") || lowerQuestion.startsWith("is there "))  {
                
                String keyword = lowerQuestion
                        .replace("tôi muốn tìm", "").replace("i want to find", "")
                        .replace("tìm giúp tôi", "").replace("find for me", "")
                        .replace("tìm", "").replace("find", "")
                        .replace("có", "").replace("is there", "")
                        .replace("không", "")
                        .replace("?", "")
                        .trim();
                
                if (keyword.isEmpty()) {
                    answer = isEnglish 
                        ? "What are you looking for? Please enter a specific name."
                        : "Bạn muốn tìm sản phẩm gì? Hãy nhập tên cụ thể nhé.";
                } else {
                    List<Item> items = itemDAO.searchByTitle(keyword);
                    if (items.isEmpty()) {
                        answer = isEnglish
                            ? "Sorry, no items named '" + keyword + "' found. Please check back later!"
                            : "Rất tiếc, hiện tại không có sản phẩm '" + keyword + "' nào trên hệ thống. Vui lòng quay lại sau!";
                    } else {
                        answer = isEnglish
                            ? "Found " + items.size() + " items matching '" + keyword + "':"
                            : "Tìm thấy " + items.size() + " sản phẩm '" + keyword + "' phù hợp:";
                            
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
            else if (lowerQuestion.contains("cách tích điểm") || lowerQuestion.contains("ecopoints") || lowerQuestion.contains("earn points")) {
                if (isEnglish) {
                    answer = "You can earn EcoPoints by:\n" +
                             "1. Posting donation items (approved).\n" +
                             "2. Bringing recyclables to collection points.\n" +
                             "3. Joining EcoGive green events.\n" +
                             "Points can be used to redeem rewards or rank up on the leaderboard!";
                } else {
                    answer = "Bạn có thể tích điểm EcoPoints bằng cách:\n" +
                             "1. Đăng tin tặng đồ cũ (được duyệt).\n" +
                             "2. Mang rác tái chế đến các điểm thu gom.\n" +
                             "3. Tham gia các sự kiện xanh của EcoGive.\n" +
                             "Điểm này có thể dùng để đổi quà hoặc vinh danh trên bảng xếp hạng!";
                }
            }
            // --- 5. HƯỚNG DẪN TÁI CHẾ (GỌI GROQ API) ---
            else if (lowerQuestion.startsWith("hướng dẫn cách tái chế:") || lowerQuestion.startsWith("recycling guide:") || lowerQuestion.contains("tái chế") || lowerQuestion.contains("recycle")) {
                String itemToRecycle = "";
                if (lowerQuestion.startsWith("hướng dẫn cách tái chế:")) {
                    itemToRecycle = question.substring("hướng dẫn cách tái chế:".length()).trim();
                } else if (lowerQuestion.startsWith("recycling guide:")) {
                    itemToRecycle = question.substring("recycling guide:".length()).trim();
                } else {
                    itemToRecycle = question;
                }

                if (itemToRecycle.isEmpty()) {
                    answer = isEnglish ? "Please enter the item name you want to recycle." : "Vui lòng nhập tên vật phẩm bạn muốn tái chế.";
                } else {
                    String localSuggestion = "";
                    String type = detectWasteType(itemToRecycle);
                    
                    if (type != null) {
                        try {
                            List<CollectionPoint> points = pointDAO.findByType(type);
                            if (!points.isEmpty()) {
                                localSuggestion = isEnglish 
                                    ? "💡 **EcoGive Suggestion:** We found " + points.size() + " suitable collection points:\n"
                                    : "💡 **Gợi ý từ EcoGive:** Chúng tôi tìm thấy " + points.size() + " điểm thu gom phù hợp trên hệ thống:\n";
                                    
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
                            System.err.println("Database error: " + e.getMessage());
                        }
                    }

                    // Gọi AI
                    String aiAdvice = callGroqApi(itemToRecycle, isEnglish);
                    
                    if (!localSuggestion.isEmpty()) {
                        answer = localSuggestion + "\n\n" + aiAdvice;
                    } else {
                        answer = aiAdvice;
                    }
                }
            }
            // --- 6. TÌM ĐIỂM THU GOM ---
            else {
                typeToSearch = detectWasteType(lowerQuestion);
                
                if (typeToSearch != null) {
                    answer = isEnglish 
                        ? "Here are suitable collection points for your request:"
                        : "Dưới đây là các điểm thu gom phù hợp với yêu cầu của bạn:";
                } else if (lowerQuestion.contains("điểm thu gom") || lowerQuestion.contains("trạm") || lowerQuestion.contains("collection point") || lowerQuestion.contains("station")) {
                     answer = isEnglish
                        ? "Here are some nearby collection points:"
                        : "Dưới đây là một số điểm thu gom gần đây:";
                     typeToSearch = "BATTERY"; // Mặc định
                } else {
                    // Gọi AI cho câu hỏi chung
                    answer = callGroqApi(question, isEnglish);
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
                        System.err.println("Database error: " + e.getMessage());
                        answer += isEnglish ? "\n(Connection error, cannot load points)" : "\n(Hiện tại không thể tải danh sách điểm thu gom do lỗi kết nối)";
                    }
                }
            }

        } catch (Exception e) {
            e.printStackTrace();
            answer = isEnglish 
                ? "An error occurred. Please try again later."
                : "Đã xảy ra lỗi khi xử lý yêu cầu của bạn. Vui lòng thử lại sau.";
        }

        response.addProperty("answer", answer);
        response.add("suggestions", suggestions);
        response.add("quickReplies", quickReplies);

        resp.getWriter().write(new Gson().toJson(response));
    }

    private String detectWasteType(String text) {
        String lower = text.toLowerCase();
        // Vietnamese keywords
        if (lower.contains("pin") || lower.contains("ắc quy")) return "BATTERY";
        if (lower.contains("thuốc") || lower.contains("y tế") || lower.contains("kim tiêm")) return "MEDICAL";
        if (lower.contains("hóa chất") || lower.contains("tẩy rửa") || lower.contains("sơn")) return "CHEMICAL";
        if (lower.contains("điện tử") || lower.contains("máy tính") || lower.contains("điện thoại") || lower.contains("tivi")) return "E_WASTE";
        if (lower.contains("quần áo") || lower.contains("vải")) return "TEXTILE";
        if (lower.contains("bán") || lower.contains("ve chai") || lower.contains("đồng nát")) return "DEALER";
        
        // English keywords
        if (lower.contains("battery")) return "BATTERY";
        if (lower.contains("medical") || lower.contains("medicine")) return "MEDICAL";
        if (lower.contains("chemical") || lower.contains("paint")) return "CHEMICAL";
        if (lower.contains("electronic") || lower.contains("computer") || lower.contains("phone") || lower.contains("tv")) return "E_WASTE";
        if (lower.contains("cloth") || lower.contains("textile")) return "TEXTILE";
        if (lower.contains("scrap")) return "DEALER";
        
        return null;
    }

    private String callGroqApi(String userQuestion, boolean isEnglish) {
        if (groqApiKey == null || groqApiKey.isEmpty()) {
            return isEnglish ? "Config Error: API Key missing." : "Lỗi cấu hình: Không tìm thấy Groq API Key.";
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
        
        String langInstruction = isEnglish 
            ? "ANSWER IN ENGLISH." 
            : "TRẢ LỜI BẰNG TIẾNG VIỆT.";

        systemMsg.addProperty("content", "You are an AI assistant for EcoGive, specializing in recycling and environmental protection.\n" +
                "IMPORTANT RULES:\n" +
                "1. You must ONLY answer questions related to recycling, waste sorting, and environmental protection.\n" +
                "2. If the user asks about other topics, politely refuse.\n" +
                "3. Provide concise, clear, and safe instructions.\n" +
                "4. " + langInstruction);
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
                return isEnglish 
                    ? "Sorry, I cannot connect to the AI server right now." 
                    : "Xin lỗi, hiện tại tôi không thể kết nối với máy chủ AI. Vui lòng thử lại sau.";
            }
            
            String responseBody = response.body().string();
            JsonObject jsonResponse = new Gson().fromJson(responseBody, JsonObject.class);
            return jsonResponse.getAsJsonArray("choices")
                    .get(0).getAsJsonObject()
                    .getAsJsonObject("message")
                    .get("content").getAsString();
        } catch (IOException e) {
            e.printStackTrace();
            return isEnglish 
                ? "Error calling AI: " + e.getMessage()
                : "Đã xảy ra lỗi khi gọi AI: " + e.getMessage();
        }
    }
}