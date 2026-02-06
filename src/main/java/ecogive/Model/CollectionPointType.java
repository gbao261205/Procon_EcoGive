package ecogive.Model;

public class CollectionPointType {
    private String typeCode;
    private String displayName;
    private String description;
    private String icon;

    public CollectionPointType() {
    }

    public CollectionPointType(String typeCode, String displayName, String icon) {
        this.typeCode = typeCode;
        this.displayName = displayName;
        this.icon = icon;
    }

    public String getTypeCode() {
        return typeCode;
    }

    public void setTypeCode(String typeCode) {
        this.typeCode = typeCode;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getDescription() {
        return description;
    }

    public void setDescription(String description) {
        this.description = description;
    }

    public String getIcon() {
        return icon;
    }

    public void setIcon(String icon) {
        this.icon = icon;
    }
}
