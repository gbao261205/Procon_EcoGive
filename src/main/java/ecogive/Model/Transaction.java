package ecogive.Model;

import java.time.LocalDateTime;

public class Transaction {
    private long transactionId;
    private long itemId;
    private long receiverId;
    private LocalDateTime exchangeDate;
    private TransactionStatus status;

    public Transaction() {
    }

    public Transaction(long transactionId, long itemId, long receiverId,
                       LocalDateTime exchangeDate, TransactionStatus status) {
        this.transactionId = transactionId;
        this.itemId = itemId;
        this.receiverId = receiverId;
        this.exchangeDate = exchangeDate;
        this.status = status;
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
}
