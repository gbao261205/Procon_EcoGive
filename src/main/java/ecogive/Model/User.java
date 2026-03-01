package ecogive.Model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class User {
    private long userId;
    private String username;
    private String displayName;
    private String email;
    private String passwordHash;
    
    // --- MỚI: Hệ thống 3 quỹ điểm ---
    private BigDecimal currentPoints;  // Điểm khả dụng để đổi quà
    private BigDecimal lifetimePoints; // Điểm tích lũy trọn đời (xét hạng)
    private BigDecimal seasonPoints;   // Điểm mùa giải (đua top)
    private Tier tier;                 // Hạng thành viên (STANDARD, SILVER, GOLD, DIAMOND)

    private BigDecimal reputationScore;
    private LocalDateTime joinDate;
    private Role role;
    private String phoneNumber;
    private String address;
    private String resetToken;
    private LocalDateTime resetTokenExpiry;
    private boolean isVerified;
    private String verificationToken;

    // --- Xác thực doanh nghiệp ---
    private boolean isCompanyVerified;
    private String companyVerificationStatus; // NONE, PENDING, VERIFIED, REJECTED
    private String verificationDocument;

    public User() {
        this.currentPoints = BigDecimal.ZERO;
        this.lifetimePoints = BigDecimal.ZERO;
        this.seasonPoints = BigDecimal.ZERO;
        this.tier = Tier.STANDARD;
    }

    // Constructor cũ (để tương thích ngược nếu cần, nhưng nên update dần)
    public User(long userId, String username, String displayName, String email, String passwordHash,
                BigDecimal ecoPoints, BigDecimal reputationScore, LocalDateTime joinDate, Role role) {
        this.userId = userId;
        this.username = username;
        this.displayName = displayName;
        this.email = email;
        this.passwordHash = passwordHash;
        // Map ecoPoints cũ vào cả 3 loại điểm mới tạm thời
        this.currentPoints = ecoPoints;
        this.lifetimePoints = ecoPoints;
        this.seasonPoints = ecoPoints;
        this.tier = Tier.STANDARD;
        
        this.reputationScore = reputationScore;
        this.joinDate = joinDate;
        this.role = role;
    }

    // Getters and Setters
    public long getUserId() {
        return userId;
    }

    public void setUserId(long userId) {
        this.userId = userId;
    }

    public String getUsername() {
        return username;
    }

    public void setUsername(String username) {
        this.username = username;
    }

    public String getDisplayName() {
        return displayName;
    }

    public void setDisplayName(String displayName) {
        this.displayName = displayName;
    }

    public String getEmail() {
        return email;
    }

    public void setEmail(String email) {
        this.email = email;
    }

    public String getPasswordHash() {
        return passwordHash;
    }

    public void setPasswordHash(String passwordHash) {
        this.passwordHash = passwordHash;
    }

    // --- Getter/Setter cho điểm mới ---
    public BigDecimal getCurrentPoints() {
        return currentPoints;
    }

    public void setCurrentPoints(BigDecimal currentPoints) {
        this.currentPoints = currentPoints;
    }

    public BigDecimal getLifetimePoints() {
        return lifetimePoints;
    }

    public void setLifetimePoints(BigDecimal lifetimePoints) {
        this.lifetimePoints = lifetimePoints;
    }

    public BigDecimal getSeasonPoints() {
        return seasonPoints;
    }

    public void setSeasonPoints(BigDecimal seasonPoints) {
        this.seasonPoints = seasonPoints;
    }

    public Tier getTier() {
        return tier;
    }

    public void setTier(Tier tier) {
        this.tier = tier;
    }

    // Giữ lại getEcoPoints để tương thích ngược với code cũ chưa sửa kịp (trả về currentPoints)
    public BigDecimal getEcoPoints() {
        return currentPoints;
    }

    public void setEcoPoints(BigDecimal ecoPoints) {
        this.currentPoints = ecoPoints;
    }
    // ----------------------------------

    public BigDecimal getReputationScore() {
        return reputationScore;
    }

    public void setReputationScore(BigDecimal reputationScore) {
        this.reputationScore = reputationScore;
    }

    public LocalDateTime getJoinDate() {
        return joinDate;
    }

    public void setJoinDate(LocalDateTime joinDate) {
        this.joinDate = joinDate;
    }

    public Role getRole() {
        return role;
    }

    public void setRole(Role role) {
        this.role = role;
    }

    public String getPhoneNumber() {
        return phoneNumber;
    }

    public void setPhoneNumber(String phoneNumber) {
        this.phoneNumber = phoneNumber;
    }

    public String getAddress() {
        return address;
    }

    public void setAddress(String address) {
        this.address = address;
    }

    public String getResetToken() {
        return resetToken;
    }

    public void setResetToken(String resetToken) {
        this.resetToken = resetToken;
    }

    public LocalDateTime getResetTokenExpiry() {
        return resetTokenExpiry;
    }

    public void setResetTokenExpiry(LocalDateTime resetTokenExpiry) {
        this.resetTokenExpiry = resetTokenExpiry;
    }

    public boolean isVerified() {
        return isVerified;
    }

    public void setVerified(boolean verified) {
        isVerified = verified;
    }

    public String getVerificationToken() {
        return verificationToken;
    }

    public void setVerificationToken(String verificationToken) {
        this.verificationToken = verificationToken;
    }

    public boolean isCompanyVerified() {
        return isCompanyVerified;
    }

    public void setCompanyVerified(boolean companyVerified) {
        isCompanyVerified = companyVerified;
    }

    public String getCompanyVerificationStatus() {
        return companyVerificationStatus;
    }

    public void setCompanyVerificationStatus(String companyVerificationStatus) {
        this.companyVerificationStatus = companyVerificationStatus;
    }

    public String getVerificationDocument() {
        return verificationDocument;
    }

    public void setVerificationDocument(String verificationDocument) {
        this.verificationDocument = verificationDocument;
    }
}
