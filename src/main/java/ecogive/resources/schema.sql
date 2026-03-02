-- ===========================
-- 1. TẠO DATABASE
-- ===========================
DROP DATABASE IF EXISTS EcoGive;
CREATE DATABASE EcoGive
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE EcoGive;

-- ===========================
-- 2. TẠO BẢNG
-- ===========================

-- Bảng 1: Người dùng (Users)
CREATE TABLE users (
    user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    username VARCHAR(50) NOT NULL UNIQUE,
    display_name VARCHAR(100) NULL,
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    phone_number VARCHAR(20) NULL,
    address TEXT NULL,
    -- Thay đổi và thêm mới các cột điểm số
    season_points DECIMAL(10, 2) DEFAULT 0.00,
    current_points DECIMAL(10, 2) DEFAULT 0.00,
    lifetime_points DECIMAL(10, 2) DEFAULT 0.00,
    tier ENUM('STANDARD', 'SILVER', 'GOLD', 'DIAMOND') DEFAULT 'STANDARD',
    reputation_score DECIMAL(3, 2) DEFAULT 1.00,
    role ENUM('USER', 'ADMIN', 'COLLECTOR_COMPANY') NOT NULL DEFAULT 'USER',
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    reset_token VARCHAR(255) NULL,
    reset_token_expiry TIMESTAMP NULL,
    is_verified BOOLEAN DEFAULT FALSE,
    verification_token VARCHAR(255) NULL,
    is_company_verified BOOLEAN DEFAULT FALSE,
    company_verification_status ENUM('NONE', 'PENDING', 'VERIFIED', 'REJECTED') DEFAULT 'NONE',
    verification_document VARCHAR(255) NULL
);

-- Bảng 2: Danh mục (Categories)
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    fixed_points DECIMAL(5, 2) NOT NULL DEFAULT 0.00
);

-- Bảng 3: Vật phẩm (Items)
CREATE TABLE items (
    item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    giver_id BIGINT NOT NULL,
    category_id INT,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    condition_percentage INT DEFAULT 100,
    image_url VARCHAR(255) NOT NULL,
    status ENUM('AVAILABLE', 'PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED', 'TRADE_PENDING', 'TRADE_COMPLETED') DEFAULT 'AVAILABLE',
    eco_points DECIMAL(10, 2) DEFAULT 0.00,
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    address VARCHAR(255),
    location POINT NOT NULL,
    FOREIGN KEY (giver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);
CREATE SPATIAL INDEX sp_index_location ON items (location);

-- Bảng 4: Loại hình điểm thu gom (Collection Point Types)
CREATE TABLE collection_point_types (
    type_code VARCHAR(50) PRIMARY KEY,
    display_name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50) DEFAULT '♻️'
);

-- Bảng 5: Điểm Thu gom (Collection Points)
CREATE TABLE collection_points (
    point_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    address TEXT,
    location POINT NOT NULL,
    owner_id BIGINT NULL,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE SET NULL,
    FOREIGN KEY (type) REFERENCES collection_point_types(type_code) ON UPDATE CASCADE
);
CREATE SPATIAL INDEX sp_index_cp_location ON collection_points (location);

-- Bảng 6: Giao dịch (Transactions)
CREATE TABLE transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    transaction_type ENUM('GIVE', 'TRADE') DEFAULT 'GIVE',
    offer_item_id BIGINT NULL,
    status ENUM('PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELED', 'PENDING_TRADE') DEFAULT 'PENDING',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE INDEX idx_unique_transaction (transaction_id)
);

-- Bảng 7: Tin nhắn (Messages)
CREATE TABLE messages (
    message_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    content TEXT CHARACTER SET utf8mb4,
    image_url VARCHAR(255) NULL,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    is_read BOOLEAN DEFAULT FALSE,
    FOREIGN KEY (sender_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Bảng 8: Yêu cầu Thu gom (Collection Requests)
CREATE TABLE collection_requests (
    request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    item_type VARCHAR(100) NOT NULL,
    status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED') DEFAULT 'SCHEDULED',
    pickup_date TIMESTAMP NOT NULL,
    address TEXT,
    location POINT NOT NULL,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Bảng 9: Quà tặng (Rewards)
CREATE TABLE rewards (
    reward_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    point_cost DECIMAL(10,2) NOT NULL,
    image_url VARCHAR(255),
    stock INT DEFAULT 0,
    type ENUM('ADMIN', 'SPONSOR') DEFAULT 'ADMIN',
    sponsor_name VARCHAR(255) NULL,
    status ENUM('PENDING', 'APPROVED', 'REJECTED', 'HIDDEN') DEFAULT 'APPROVED',
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP
);

-- Bảng 10: Lịch sử đổi quà (Reward Redemptions)
CREATE TABLE reward_redemptions (
    redemption_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    reward_id BIGINT NOT NULL,
    points_spent DECIMAL(10,2) NOT NULL,
    redeemed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('PENDING', 'COMPLETED', 'CANCELLED') DEFAULT 'PENDING',
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (reward_id) REFERENCES rewards(reward_id) ON DELETE CASCADE
);

-- Bảng 11: Lịch sử mùa giải (Leaderboard History)
CREATE TABLE leaderboard_history (
    history_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    season_name VARCHAR(100) NOT NULL,
    user_id BIGINT NOT NULL,
    total_season_points DECIMAL(10,2) NOT NULL,
    final_rank INT NOT NULL,
    recorded_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Bảng 12: Thông báo
CREATE TABLE IF NOT EXISTS notifications (
    notification_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    user_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    message TEXT NOT NULL,
    is_read BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);

CREATE TABLE daily_points (
    user_id BIGINT NOT NULL,
    date DATE NOT NULL,
    points_earned DECIMAL(10,2) DEFAULT 0.00,
    PRIMARY KEY (user_id, date),
    FOREIGN KEY (user_id) REFERENCES users(user_id) ON DELETE CASCADE
);