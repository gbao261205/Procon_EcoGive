package ecogive.Model;

public enum TransactionStatus {
    PENDING,            // Đang chờ trao đổi (GIVE)
    CONFIRMED,          // Người cho đã xác nhận giao đồ (GIVE)
    COMPLETED,          // Hoàn tất (GIVE & TRADE)
    CANCELED,           // Đã hủy
    
    // --- TRADE STATUS ---
    PENDING_TRADE,          // Chờ B đồng ý trao đổi
    WAITING_ADMIN_APPROVAL, // B đã đồng ý, chờ Admin duyệt
    TRADE_APPROVED,         // Admin đã duyệt, cho phép tiến hành
    TRADE_REJECTED,         // Admin từ chối

    CONFIRMED_BY_A,     // A đã xác nhận (Ready)
    CONFIRMED_BY_B      // B đã xác nhận (Ready)
}
