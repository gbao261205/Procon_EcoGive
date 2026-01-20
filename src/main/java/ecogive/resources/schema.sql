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
    email VARCHAR(100) NOT NULL UNIQUE,
    password_hash VARCHAR(255) NOT NULL,
    eco_points DECIMAL(10, 2) DEFAULT 0.00,
    reputation_score DECIMAL(3, 2) DEFAULT 1.00,
    join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    role ENUM('USER', 'ADMIN', 'COLLECTOR_COMPANY') NOT NULL DEFAULT 'USER',
    phone_number VARCHAR(20) NULL,
    address TEXT NULL
);

-- Bảng 2: Danh mục (Categories) - ĐÃ KHÔI PHỤC
CREATE TABLE categories (
    category_id INT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(100) NOT NULL UNIQUE,
    fixed_points DECIMAL(5, 2) NOT NULL DEFAULT 0.00
);

-- Bảng 3: Vật phẩm (Items)
CREATE TABLE items (
    item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    giver_id BIGINT NOT NULL,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    category_id INT, -- Khóa ngoại trỏ đến categories
    image_url VARCHAR(255) NOT NULL,
    status ENUM('AVAILABLE', 'PENDING', 'CONFIRMED', 'COMPLETED', 'CANCELLED') DEFAULT 'AVAILABLE',
    post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    location POINT NOT NULL,
    eco_points DECIMAL(10, 2) DEFAULT 0.00, -- Điểm cụ thể cho item này (có thể khác fixed_points)
    FOREIGN KEY (giver_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (category_id) REFERENCES categories(category_id) ON DELETE SET NULL
);
CREATE SPATIAL INDEX sp_index_location ON items (location);

-- Bảng 4: Điểm Thu gom (Collection Points)
CREATE TABLE collection_points (
    point_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    name VARCHAR(255) NOT NULL,
    type ENUM('E_WASTE', 'BATTERY', 'TEXTILE', 'MEDICAL', 'CHEMICAL', 'DEALER', 'INDIVIDUAL') NOT NULL,
    address TEXT,
    location POINT NOT NULL,
    owner_id BIGINT NULL,
    FOREIGN KEY (owner_id) REFERENCES users(user_id) ON DELETE SET NULL
);
CREATE SPATIAL INDEX sp_index_cp_location ON collection_points (location);

-- Bảng 5: Giao dịch (Transactions)
CREATE TABLE transactions (
    transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    item_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    exchange_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    status ENUM('CONFIRMED', 'COMPLETED', 'CANCELED') DEFAULT 'CONFIRMED',
    FOREIGN KEY (item_id) REFERENCES items(item_id) ON DELETE CASCADE,
    FOREIGN KEY (receiver_id) REFERENCES users(user_id) ON DELETE CASCADE
);

-- Bảng 6: Đánh giá (Reviews)
CREATE TABLE reviews (
    review_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    transaction_id BIGINT NOT NULL,
    reviewer_id BIGINT NOT NULL,
    rated_user_id BIGINT NOT NULL,
    rating INT NOT NULL CHECK (rating >= 1 AND rating <= 5),
    comment TEXT,
    created_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (transaction_id) REFERENCES transactions(transaction_id) ON DELETE CASCADE,
    FOREIGN KEY (reviewer_id) REFERENCES users(user_id) ON DELETE CASCADE,
    FOREIGN KEY (rated_user_id) REFERENCES users(user_id) ON DELETE CASCADE,
    UNIQUE INDEX idx_unique_transaction (transaction_id)
);

-- Bảng 7: Tin nhắn (Messages)
CREATE TABLE messages (
    message_id BIGINT AUTO_INCREMENT PRIMARY KEY,
    sender_id BIGINT NOT NULL,
    receiver_id BIGINT NOT NULL,
    content TEXT CHARACTER SET utf8mb4 NOT NULL,
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

