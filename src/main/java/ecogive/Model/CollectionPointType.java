package ecogive.Model;

public enum CollectionPointType {
    E_WASTE("Rác thải điện tử"),
    BATTERY("Pin"),
    TEXTILE("Quần áo"),
    MEDICAL("Y tế"),
    CHEMICAL("Hóa chất"),
    DEALER("Đại lý"),
    INDIVIDUAL("Cá nhân");

    private final String displayName;

    CollectionPointType(String displayName) {
        this.displayName = displayName;
    }

    public String getDisplayName() {
        return displayName;
    }
}
