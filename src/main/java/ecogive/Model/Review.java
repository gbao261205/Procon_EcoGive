package ecogive.Model;

import java.sql.Timestamp;

public class Review {
    // 1. Các trường khớp với Bảng trong Database
    private long reviewId;
    private long transactionId;
    private long reviewerId;
    private long ratedUserId;
    private int rating;
    private String comment;
    private Timestamp createdAt;

    // 2. Trường phụ (Không có trong bảng reviews, dùng để hiển thị tên người đánh giá)
    private String reviewerName;

    // Constructor mặc định
    public Review() {
    }

    // Constructor đầy đủ (nếu cần)
    public Review(long reviewId, long transactionId, long reviewerId, long ratedUserId, int rating, String comment, Timestamp createdAt) {
        this.reviewId = reviewId;
        this.transactionId = transactionId;
        this.reviewerId = reviewerId;
        this.ratedUserId = ratedUserId;
        this.rating = rating;
        this.comment = comment;
        this.createdAt = createdAt;
    }

    // --- GETTERS & SETTERS ---

    public long getReviewId() {
        return reviewId;
    }

    public void setReviewId(long reviewId) {
        this.reviewId = reviewId;
    }

    public long getTransactionId() {
        return transactionId;
    }

    public void setTransactionId(long transactionId) {
        this.transactionId = transactionId;
    }

    public long getReviewerId() {
        return reviewerId;
    }

    public void setReviewerId(long reviewerId) {
        this.reviewerId = reviewerId;
    }

    public long getRatedUserId() {
        return ratedUserId;
    }

    public void setRatedUserId(long ratedUserId) {
        this.ratedUserId = ratedUserId;
    }

    public int getRating() {
        return rating;
    }

    public void setRating(int rating) {
        this.rating = rating;
    }

    public String getComment() {
        return comment;
    }

    public void setComment(String comment) {
        this.comment = comment;
    }

    public Timestamp getCreatedAt() {
        return createdAt;
    }

    public void setCreatedAt(Timestamp createdAt) {
        this.createdAt = createdAt;
    }

    // Getter & Setter cho trường phụ reviewerName
    public String getReviewerName() {
        return reviewerName;
    }

    public void setReviewerName(String reviewerName) {
        this.reviewerName = reviewerName;
    }
}