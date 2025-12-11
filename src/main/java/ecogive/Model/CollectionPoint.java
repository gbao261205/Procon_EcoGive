package ecogive.Model;

public class CollectionPoint {
    private long pointId;
    private String name;
    private CollectionPointType type;
    private String address;
    private GeoPoint location;
    private long companyId;

    public CollectionPoint() {
    }

    public CollectionPoint(long pointId, String name, CollectionPointType type,
                           String address, GeoPoint location, long companyId) {
        this.pointId = pointId;
        this.name = name;
        this.type = type;
        this.address = address;
        this.location = location;
        this.companyId = companyId;
    }

    public long getPointId() {
        return pointId;
    }

    public void setPointId(long pointId) {
        this.pointId = pointId;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public CollectionPointType getType() {
        return type;
    }

    public void setType(CollectionPointType type) {
        this.type = type;
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

    public long getCompanyId() {
        return companyId;
    }

    public void setCompanyId(long companyId) {
        this.companyId = companyId;
    }
}
