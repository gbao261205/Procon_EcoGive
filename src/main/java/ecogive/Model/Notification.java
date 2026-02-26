package ecogive.Model;

import java.time.LocalDateTime;

public class Notification {
    private long notificationId;
    private long userId;
    private String content;
    private String type; // GIFT_REQUEST, TRADE_REQUEST, SYSTEM, etc.
    private Long referenceId; // Transaction ID or Item ID
    private boolean isRead;
    private LocalDateTime createdAt;

    public Notification() {}

    public Notification(long userId, String content, String type, Long referenceId) {
        this.userId = userId;
        this.content = content;
        this.type = type;
        this.referenceId = referenceId;
        this.isRead = false;
        this.createdAt = LocalDateTime.now();
    }

    public long getNotificationId() { return notificationId; }
    public void setNotificationId(long notificationId) { this.notificationId = notificationId; }

    public long getUserId() { return userId; }
    public void setUserId(long userId) { this.userId = userId; }

    public String getContent() { return content; }
    public void setContent(String content) { this.content = content; }

    public String getType() { return type; }
    public void setType(String type) { this.type = type; }

    public Long getReferenceId() { return referenceId; }
    public void setReferenceId(Long referenceId) { this.referenceId = referenceId; }

    public boolean isRead() { return isRead; }
    public void setRead(boolean read) { isRead = read; }

    public LocalDateTime getCreatedAt() { return createdAt; }
    public void setCreatedAt(LocalDateTime createdAt) { this.createdAt = createdAt; }
}
