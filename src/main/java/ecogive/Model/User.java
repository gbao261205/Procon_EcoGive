package ecogive.Model;

import java.math.BigDecimal;
import java.time.LocalDateTime;

public class User {
    private long userId;
    private String username;
    private String email;
    private String passwordHash;
    private BigDecimal ecoPoints;
    private BigDecimal reputationScore;
    private LocalDateTime joinDate;
    private Role role;
    private String phoneNumber; // Thêm số điện thoại
    private String address;     // Thêm địa chỉ

    public User() {
    }

    // Constructor cũ vẫn giữ
    public User(long userId, String username, String email, String passwordHash,
                BigDecimal ecoPoints, BigDecimal reputationScore, LocalDateTime joinDate, Role role) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.ecoPoints = ecoPoints;
        this.reputationScore = reputationScore;
        this.joinDate = joinDate;
        this.role = role;
    }
    
    // Thêm constructor mới đầy đủ hơn (tùy chọn)
    public User(long userId, String username, String email, String passwordHash, BigDecimal ecoPoints, BigDecimal reputationScore, LocalDateTime joinDate, Role role, String phoneNumber, String address) {
        this.userId = userId;
        this.username = username;
        this.email = email;
        this.passwordHash = passwordHash;
        this.ecoPoints = ecoPoints;
        this.reputationScore = reputationScore;
        this.joinDate = joinDate;
        this.role = role;
        this.phoneNumber = phoneNumber;
        this.address = address;
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

    public BigDecimal getEcoPoints() {
        return ecoPoints;
    }

    public void setEcoPoints(BigDecimal ecoPoints) {
        this.ecoPoints = ecoPoints;
    }

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
}
