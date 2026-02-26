package ecogive.Model;

public enum ItemStatus {
    AVAILABLE,      // Đang hiển thị trên bản đồ (Đã duyệt)
    PENDING,        // Chờ Admin duyệt (cho Post Item thông thường)
    CONFIRMED,      // Đã có người xin (Giver xác nhận cho)
    COMPLETED,      // Giao dịch hoàn tất (Ẩn khỏi map)
    CANCELLED,      // Đã hủy
    
    // --- TRADE STATUS ---
    TRADE_PENDING,   // Item được tạo riêng để đi trao đổi (Không hiện map, KHÔNG cần Admin duyệt)
    TRADE_COMPLETED  // Item trao đổi đã hoàn tất (Tương đương COMPLETED nhưng đánh dấu rõ nguồn gốc)
}
