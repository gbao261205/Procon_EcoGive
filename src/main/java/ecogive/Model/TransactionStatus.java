package ecogive.Model;

public enum TransactionStatus {
    PENDING,            // Đang chờ trao đổi
    CONFIRMED,          // Người cho đã xác nhận giao đồ
    COMPLETED,          // Hoàn tất (Người nhận xác nhận)
    CANCELED            // Đã hủy
}
