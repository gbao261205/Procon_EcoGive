package ecogive.util;

import io.github.cdimascio.dotenv.Dotenv;

public class EnvUtils {
    // Load .env nhưng không báo lỗi nếu file không tồn tại (ignoreIfMissing)
    private static final Dotenv dotenv = Dotenv.configure().ignoreIfMissing().load();

    public static String get(String key) {
        // 1. Ưu tiên lấy từ file .env (cho Local)
        String value = dotenv.get(key);
        
        // 2. Nếu không có trong .env, lấy từ System Environment (cho Render/Docker)
        if (value == null || value.isEmpty()) {
            value = System.getenv(key);
        }
        
        return value;
    }
}
