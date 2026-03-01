package ecogive.Model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class RewardRedemption {
    private long redemptionId;
    private long userId;
    private long rewardId;
    private BigDecimal pointsSpent;
    private LocalDateTime redeemedAt;
    private String status; // PENDING, COMPLETED, CANCELLED

    public RewardRedemption() {
    }

    public long getRedemptionId() {
        return redemptionId;
    }

    public void setRedemptionId(long redemptionId) {
        this.redemptionId = redemptionId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public long getRewardId() {
        return rewardId;
    }

    public void setRewardId(long rewardId) {
        this.rewardId = rewardId;
    }

    public BigDecimal getPointsSpent() {
        return pointsSpent;
    }

    public void setPointsSpent(BigDecimal pointsSpent) {
        this.pointsSpent = pointsSpent;
    }

    public LocalDateTime getRedeemedAt() {
        return redeemedAt;
    }

    public void setRedeemedAt(LocalDateTime redeemedAt) {
        this.redeemedAt = redeemedAt;
    }

    public String getStatus() {
        return status;
    }

    public void setStatus(String status) {
        this.status = status;
    }
}
