package ecogive.Model;

public class CollectionPoint {
    private long pointId;
    private String name;
    private CollectionPointType type;
    private String address;
    private GeoPoint location;
    private long ownerId;
    private String ownerName;
    private String ownerRole; // Thêm vai trò của chủ sở hữu

    public CollectionPoint() {
    }

    public CollectionPoint(long pointId, String name, CollectionPointType type,
                           String address, GeoPoint location, long ownerId) {
        this.pointId = pointId;
        this.name = name;
        this.type = type;
        this.address = address;
        this.location = location;
        this.ownerId = ownerId;
    }
    
    // Getters and Setters
    public long getPointId() { return pointId; }
    public void setPointId(long pointId) { this.pointId = pointId; }
    public String getName() { return name; }
    public void setName(String name) { this.name = name; }
    public CollectionPointType getType() { return type; }
    public void setType(CollectionPointType type) { this.type = type; }
    public String getAddress() { return address; }
    public void setAddress(String address) { this.address = address; }
    public GeoPoint getLocation() { return location; }
    public void setLocation(GeoPoint location) { this.location = location; }
    public long getOwnerId() { return ownerId; }
    public void setOwnerId(long ownerId) { this.ownerId = ownerId; }
    public String getOwnerName() { return ownerName; }
    public void setOwnerName(String ownerName) { this.ownerName = ownerName; }
    public String getOwnerRole() { return ownerRole; }
    public void setOwnerRole(String ownerRole) { this.ownerRole = ownerRole; }

    // Helper methods
    public double getLatitude() {
        return (location != null) ? location.getLatitude() : 0.0;
    }

    public double getLongitude() {
        return (location != null) ? location.getLongitude() : 0.0;
    }
}
