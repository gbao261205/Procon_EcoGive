package ecogive.Controller;

import com.google.gson.Gson;
import com.google.gson.JsonArray;
import com.google.gson.JsonObject;
import ecogive.Model.CollectionPoint;
import ecogive.Model.CollectionPointType;
import ecogive.dao.CollectionPointDAO;
import jakarta.servlet.ServletException;
import jakarta.servlet.annotation.WebServlet;
import jakarta.servlet.http.HttpServlet;
import jakarta.servlet.http.HttpServletRequest;
import jakarta.servlet.http.HttpServletResponse;

import java.io.IOException;
import java.util.List;

@WebServlet("/api/ai-assistant")
public class AiAssistantServlet extends HttpServlet {

    private final CollectionPointDAO pointDAO = new CollectionPointDAO();

    @Override
    protected void doPost(HttpServletRequest req, HttpServletResponse resp) throws ServletException, IOException {
        resp.setContentType("application/json");
        resp.setCharacterEncoding("UTF-8");

        String question = req.getParameter("question");
        JsonObject response = new JsonObject();

        if (question == null || question.trim().isEmpty()) {
            response.addProperty("answer", "Bạn cần giúp gì về việc phân loại rác hoặc tìm điểm thu gom?");
            response.add("suggestions", new JsonArray());
            resp.getWriter().write(new Gson().toJson(response));
            return;
        }

        question = question.toLowerCase();
        String answer = "";
        CollectionPointType typeToSearch = null;

        // --- LOGIC PHÂN TÍCH TỪ KHÓA (AI ĐƠN GIẢN) ---

        if (question.contains("pin") || question.contains("ắc quy")) {
            answer = "Pin cũ chứa kim loại nặng độc hại, tuyệt đối không bỏ thùng rác thường. Bạn có thể mang đến các điểm thu gom Pin dưới đây:";
            typeToSearch = CollectionPointType.BATTERY;
        }
        else if (question.contains("thuốc") || question.contains("y tế") || question.contains("kim tiêm")) {
            answer = "Rác thải y tế cần xử lý chuyên biệt để tránh lây nhiễm. Hãy liên hệ các trạm y tế hoặc điểm thu gom sau:";
            typeToSearch = CollectionPointType.MEDICAL;
        }
        else if (question.contains("hóa chất") || question.contains("tẩy rửa") || question.contains("sơn")) {
            answer = "Hóa chất thừa cần được xử lý tại các cơ sở chuyên dụng. Dưới đây là gợi ý cho bạn:";
            typeToSearch = CollectionPointType.CHEMICAL;
        }
        else if (question.contains("điện tử") || question.contains("máy tính") || question.contains("điện thoại") || question.contains("tivi")) {
            answer = "Đồ điện tử cũ (E-Waste) có thể tái chế được các linh kiện quý. Bạn có thể mang đến các điểm này:";
            typeToSearch = CollectionPointType.E_WASTE;
        }
        else if (question.contains("quần áo") || question.contains("vải")) {
            answer = "Quần áo cũ có thể quyên góp từ thiện hoặc tái chế. Xem các điểm nhận đồ vải tại đây:";
            typeToSearch = CollectionPointType.TEXTILE;
        }
        else if (question.contains("bán") || question.contains("ve chai") || question.contains("đồng nát")) {
            answer = "Nếu bạn muốn bán phế liệu, hãy liên hệ các đại lý hoặc cá nhân thu mua uy tín gần đây:";
            typeToSearch = CollectionPointType.DEALER; // Hoặc INDIVIDUAL
        }
        else {
            answer = "Xin lỗi, tôi chưa hiểu rõ loại rác bạn đang đề cập. Hãy thử các từ khóa như: 'pin', 'thuốc cũ', 'đồ điện tử', 'quần áo'...";
        }

        // --- TÌM KIẾM DỮ LIỆU ---
        JsonArray suggestions = new JsonArray();
        if (typeToSearch != null) {
            try {
                // Bạn cần thêm hàm findByTypeLimit(type, limit) trong DAO nếu muốn tối ưu
                // Ở đây dùng tạm hàm findByType
                List<CollectionPoint> points = pointDAO.findByType(typeToSearch);
                int count = 0;
                for (CollectionPoint p : points) {
                    if (count >= 3) break; // Chỉ gợi ý tối đa 3 điểm
                    JsonObject pJson = new JsonObject();
                    pJson.addProperty("name", p.getName());
                    pJson.addProperty("address", p.getAddress());
                    pJson.addProperty("lat", p.getLatitude());
                    pJson.addProperty("lng", p.getLongitude());
                    suggestions.add(pJson);
                    count++;
                }
            } catch (Exception e) {
                e.printStackTrace();
            }
        }

        response.addProperty("answer", answer);
        response.add("suggestions", suggestions);

        resp.getWriter().write(new Gson().toJson(response));
    }
}