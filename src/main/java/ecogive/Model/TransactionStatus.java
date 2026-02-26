package ecogive.Model;

public enum TransactionStatus {
    PENDING,            // Đang chờ trao đổi (GIVE)
    CONFIRMED,          // Người cho đã xác nhận giao đồ (GIVE)
    COMPLETED,          // Hoàn tất (GIVE & TRADE)
    CANCELED,           // Đã hủy

    PENDING_TRADE,      // Chờ B đồng ý trao đổi
    TRADE_ACCEPTED,     // B đã đồng ý (Thay thế cho TRADE_APPROVED)

    CONFIRMED_BY_A,     // A đã xác nhận (Ready)
    CONFIRMED_BY_B      // B đã xác nhận (Ready)
}
