package ecogive.Model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class Item {
    private long itemId;
    private long giverId;
    private String title;
    private String description;
    private int categoryId;
    private String imageUrl;
    private ItemStatus status;
    private LocalDateTime postDate;
    private GeoPoint location;
    private String giverName;
    private BigDecimal ecoPoints; // Số điểm thưởng cho vật phẩm

    public Item() {
    }

    // Constructor đầy đủ
    public Item(long itemId, long giverId, String title, String description, int categoryId, String imageUrl, ItemStatus status, LocalDateTime postDate, GeoPoint location, String giverName, BigDecimal ecoPoints) {
        this.itemId = itemId;
        this.giverId = giverId;
        this.title = title;
        this.description = description;
        this.categoryId = categoryId;
        this.imageUrl = imageUrl;
        this.status = status;
        this.postDate = postDate;
        this.location = location;
        this.giverName = giverName;
        this.ecoPoints = ecoPoints;
    }

    // Getters and Setters
    public String getGiverName() {
        return giverName;
    }

    public void setGiverName(String giverName) {
        this.giverName = giverName;
    }

    public long getItemId() {
        return itemId;
    }

    public void setItemId(long itemId) {
        this.itemId = itemId;
    }

    public long getGiverId() {
        return giverId;
    }

    public void setGiverId(long giverId) {
        this.giverId = giverId;
    }

    public String getTitle() {
        return title;
    }

    public void setTitle(String title) {
        this.title = title;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public int getCategoryId() {
        return categoryId;
    }

    public void setCategoryId(int categoryId) {
        this.categoryId = categoryId;
    }

    public String getImageUrl() {
        return imageUrl;
    }

    public void setImageUrl(String imageUrl) {
        this.imageUrl = imageUrl;
    }

    public ItemStatus getStatus() {
        return status;
    }

    public void setStatus(ItemStatus status) {
        this.status = status;
    }

    public LocalDateTime getPostDate() {
        return postDate;
    }

    public void setPostDate(LocalDateTime postDate) {
        this.postDate = postDate;
    }

    public GeoPoint getLocation() {
        return location;
    }

    public void setLocation(GeoPoint location) {
        this.location = location;
    }

    public BigDecimal getEcoPoints() {
        return ecoPoints;
    }

    public void setEcoPoints(BigDecimal ecoPoints) {
        this.ecoPoints = ecoPoints;
    }
}
