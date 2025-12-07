package ecogive.Model;

public class CollectionPoint {
    private long pointId;
    private String name;
    private CollectionPointType type;
    private String address;
    private GeoPoint location; // Object chứa lat, lng


    // 1. Constructor mặc định
    public CollectionPoint() {
    }

    // 2. Constructor đầy đủ (Dùng khi load từ DB)
    public CollectionPoint(long pointId, String name, CollectionPointType type,
                           String address, GeoPoint location) {
        this.pointId = pointId;
        this.name = name;
        this.type = type;
        this.address = address;
        this.location = location;
    }

    // 3. Constructor tiện ích (Dùng khi tạo mới từ Form - chưa có ID)
    public CollectionPoint(String name, CollectionPointType type, String address, double lat, double lng) {
        this.name = name;
        this.type = type;
        this.address = address;
        this.location = new GeoPoint(lng, lat); // Lưu ý thứ tự constructor của GeoPoint
    }

    // --- GETTERS & SETTERS CHUẨN ---

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

    // --- CÁC HÀM HELPER (QUAN TRỌNG CHO JSP/JSON) ---
    // Giúp gọi ${st.latitude} hoặc json.latitude trực tiếp mà không cần qua st.location.latitude

    public double getLatitude() {
        return (location != null) ? location.getLatitude() : 0.0;
    }

    public void setLatitude(double lat) {
        if (this.location == null) {
            this.location = new GeoPoint(0, lat);
        } else {
            // Giả sử GeoPoint có setter, nếu không thì phải new GeoPoint mới
            // Cách an toàn nhất là tạo mới để tránh immutable issue
            this.location = new GeoPoint(this.location.getLongitude(), lat);
        }
    }

    public double getLongitude() {
        return (location != null) ? location.getLongitude() : 0.0;
    }

    public void setLongitude(double lng) {
        if (this.location == null) {
            this.location = new GeoPoint(lng, 0);
        } else {
            this.location = new GeoPoint(lng, this.location.getLatitude());
        }
    }
}