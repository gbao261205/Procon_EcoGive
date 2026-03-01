package ecogive.Model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class LeaderboardHistory {
    private long historyId;
    private String seasonName;
    private long userId;
    private BigDecimal totalSeasonPoints;
    private int finalRank;
    private LocalDateTime recordedAt;

    // Getters and Setters
    public long getHistoryId() { return historyId; }
    public void setHistoryId(long historyId) { this.historyId = historyId; }

    public String getSeasonName() { return seasonName; }
    public void setSeasonName(String seasonName) { this.seasonName = seasonName; }

    public long getUserId() { return userId; }
    public void setUserId(long userId) { this.userId = userId; }

    public BigDecimal getTotalSeasonPoints() { return totalSeasonPoints; }
    public void setTotalSeasonPoints(BigDecimal totalSeasonPoints) { this.totalSeasonPoints = totalSeasonPoints; }

    public int getFinalRank() { return finalRank; }
    public void setFinalRank(int finalRank) { this.finalRank = finalRank; }

    public LocalDateTime getRecordedAt() { return recordedAt; }
    public void setRecordedAt(LocalDateTime recordedAt) { this.recordedAt = recordedAt; }
}
