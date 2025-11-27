package ecogive.Model;


import java.time.LocalDateTime;

public class CollectionRequest {
    private long requestId;
    private long userId;
    private String itemType;
    private CollectionRequestStatus status;
    private LocalDateTime pickupDate;
    private String address;
    private GeoPoint location;

    public CollectionRequest() {
    }

    public CollectionRequest(long requestId, long userId, String itemType,
                             CollectionRequestStatus status, LocalDateTime pickupDate,
                             String address, GeoPoint location) {
        this.requestId = requestId;
        this.userId = userId;
        this.itemType = itemType;
        this.status = status;
        this.pickupDate = pickupDate;
        this.address = address;
        this.location = location;
    }

    public long getRequestId() {
        return requestId;
    }

    public void setRequestId(long requestId) {
        this.requestId = requestId;
    }

    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getItemType() {
        return itemType;
    }

    public void setItemType(String itemType) {
        this.itemType = itemType;
    }

    public CollectionRequestStatus getStatus() {
        return status;
    }

    public void setStatus(CollectionRequestStatus status) {
        this.status = status;
    }

    public LocalDateTime getPickupDate() {
        return pickupDate;
    }

    public void setPickupDate(LocalDateTime pickupDate) {
        this.pickupDate = pickupDate;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public GeoPoint getLocation() {
        return location;
    }

    public void setLocation(GeoPoint location) {
        this.location = location;
    }
}
