package ecogive.Model;

import java.time.LocalDateTime;

public class Transaction {
    private long transactionId;
    private long itemId;
    private long receiverId;
    private LocalDateTime exchangeDate;
    private TransactionStatus status;
    private LocalDateTime giverConfirmedDate;
    
    // --- MỚI CHO TRADE ---
    private String transactionType; // "GIVE" hoặc "TRADE"
    private Long offerItemId;       // Item mà người nhận mang ra đổi (có thể null)

    public Transaction() {
    }

    public long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(long transactionId) {
        this.transactionId = transactionId;
    }

    public long getItemId() {
        return itemId;
    }

    public void setItemId(long itemId) {
        this.itemId = itemId;
    }

    public long getReceiverId() {
        return receiverId;
    }

    public void setReceiverId(long receiverId) {
        this.receiverId = receiverId;
    }

    public LocalDateTime getExchangeDate() {
        return exchangeDate;
    }

    public void setExchangeDate(LocalDateTime exchangeDate) {
        this.exchangeDate = exchangeDate;
    }

    public TransactionStatus getStatus() {
        return status;
    }

    public void setStatus(TransactionStatus status) {
        this.status = status;
    }

    public LocalDateTime getGiverConfirmedDate() {
        return giverConfirmedDate;
    }

    public void setGiverConfirmedDate(LocalDateTime giverConfirmedDate) {
        this.giverConfirmedDate = giverConfirmedDate;
    }

    public String getTransactionType() {
        return transactionType;
    }

    public void setTransactionType(String transactionType) {
        this.transactionType = transactionType;
    }

    public Long getOfferItemId() {
        return offerItemId;
    }

    public void setOfferItemId(Long offerItemId) {
        this.offerItemId = offerItemId;
    }
}
