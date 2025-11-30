-- ===========================
-- 1. TẠO DATABASE
-- ===========================
DROP DATABASE IF EXISTS EcoGive;
CREATE DATABASE EcoGive
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_unicode_ci;

USE EcoGive;

-- Cấu hình Database: Sử dụng engine InnoDB với hỗ trợ SPATIAL INDEX
-- 1. Bảng Người dùng (Users) 
CREATE TABLE users (
                       user_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       username VARCHAR(50) NOT NULL UNIQUE,
                       email VARCHAR(100) NOT NULL UNIQUE,
                       password_hash VARCHAR(255) NOT NULL,
                       eco_points DECIMAL(10, 2) DEFAULT 0.00,
                       reputation_score DECIMAL(3, 2) DEFAULT 1.00, -- Điểm đánh giá tin cậy (1.00 - 5.00)
                       join_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       role ENUM('USER', 'ADMIN') NOT NULL DEFAULT 'USER'
);

-- 2. Bảng Danh mục (Categories)
-- Phân loại vật phẩm và định nghĩa ĐIỂM CỐ ĐỊNH theo danh mục
CREATE TABLE categories (
                            category_id INT AUTO_INCREMENT PRIMARY KEY,
                            name VARCHAR(100) NOT NULL UNIQUE, -- Ví dụ: Nội thất, Quần áo, Thiết bị điện tử
                            fixed_points DECIMAL(5, 2) NOT NULL -- Điểm EcoPoints CỐ ĐỊNH được thưởng (Ví dụ: Nội thất = 10 điểm, Quần áo = 3 điểm)
);

-- 3. Bảng Vật phẩm (Items)
CREATE TABLE items (
                       item_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                       giver_id BIGINT NOT NULL,
                       title VARCHAR(255) NOT NULL,
                       description TEXT,
                       category_id INT NOT NULL,
                       image_url VARCHAR(255) NOT NULL, -- Cần có URL ảnh
                       status ENUM('AVAILABLE', 'PENDING', 'COMPLETED', 'CANCELLED') DEFAULT 'AVAILABLE',
                       post_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                       location POINT NOT NULL, -- Kiểu dữ liệu POINT cho GIS
                       FOREIGN KEY (giver_id) REFERENCES users(user_id),
                       FOREIGN KEY (category_id) REFERENCES categories(category_id)
);
-- TẠO SPATIAL INDEX
CREATE SPATIAL INDEX sp_index_location ON items (location);
-- 4. Bảng Điểm Thu gom Cố định (Collection Points) - KHÔNG ĐỔI
CREATE TABLE collection_points (
                                   point_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                   name VARCHAR(255) NOT NULL,
                                   type ENUM('E_WASTE', 'BATTERY', 'TEXTILE') NOT NULL,
                                   address TEXT,
                                   location POINT NOT NULL,
                                   UNIQUE INDEX unique_point_name (name)
);
-- 5. Bảng Yêu cầu Thu gom Chuyên biệt (Collection Requests) - KHÔNG ĐỔI
CREATE TABLE collection_requests (
                                     request_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                                     user_id BIGINT NOT NULL,
                                     item_type VARCHAR(100) NOT NULL, -- Ví dụ: Pin cũ, Quần áo nát
                                     status ENUM('SCHEDULED', 'COMPLETED', 'CANCELLED') DEFAULT 'SCHEDULED',
                                     pickup_date TIMESTAMP NOT NULL,
                                     address TEXT,
                                     location POINT NOT NULL, -- Vị trí lấy hàng chính xác
                                     FOREIGN KEY (user_id) REFERENCES users(user_id)
);
-- 6. Bảng Giao dịch (Transactions) - KHÔNG ĐỔI
CREATE TABLE transactions (
                              transaction_id BIGINT AUTO_INCREMENT PRIMARY KEY,
                              item_id BIGINT NOT NULL,
                              receiver_id BIGINT NOT NULL,
                              exchange_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
                              status ENUM('CONFIRMED', 'COMPLETED', 'CANCELED') DEFAULT 'CONFIRMED',
                              FOREIGN KEY (item_id) REFERENCES items(item_id),
                              FOREIGN KEY (receiver_id) REFERENCES users(user_id),
    -- Index phụ đ
                              INDEX idx_receiver_id (receiver_id)
);

-- Chèn dữ liệu mẫu cho Bảng 1: users (Người dùng)
INSERT INTO users (user_id, username, email, password_hash, eco_points, reputation_score, role) VALUES
                                                                                                    (101, 'test', 'test@example.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 150.50, 4.80, 'USER'),
                                                                                                    (102, 'tranthuy', 'thuy@example.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 85.00, 4.50, 'USER'),
                                                                                                    (103, 'leminhtam', 'tam@example.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 30.75, 5.00, 'USER'),
                                                                                                    (104, 'admin', 'admin@example.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 0.00, 3.00, 'ADMIN');
-- Chèn dữ liệu mẫu cho Bảng 2: categories (Danh mục)
INSERT INTO categories (category_id, name, fixed_points) VALUES
                                                             (1, 'Nội thất, Bàn ghế', 10.00), -- Điểm cố định cao
                                                             (2, 'Quần áo, Giày dép', 3.50),
                                                             (3, 'Thiết bị điện tử nhỏ', 7.50),
                                                             (4, 'Sách, Văn phòng phẩm', 1.00);

-- Chèn dữ liệu mẫu cho Bảng 3: items (Vật phẩm)
-- Sử dụng ST_GeomFromText('POINT(Kinh độ Vĩ độ)')
INSERT INTO items (item_id, giver_id, title, description, category_id, image_url, status, location) VALUES
                                                                                                        (1001, 101, 'Ghế làm việc xoay', 'Ghế còn mới 90%, cần thanh lý gấp.', 1, 'https://ecogive-storage.com/chair-001.jpg', 'AVAILABLE', ST_GeomFromText('POINT(106.698 10.771)')),
                                                                                                        (1002, 102, 'Đống quần áo trẻ em', 'Size 3-5 tuổi, còn rất sạch sẽ.', 2, 'https://ecogive-storage.com/clothes-002.jpg', 'AVAILABLE', ST_GeomFromText('POINT(106.695 10.775)')),
                                                                                                        (1003, 101, 'Bàn học sinh gỗ ép', 'Kích thước nhỏ, chân hơi xước.', 1, 'https://ecogive-storage.com/desk-003.jpg', 'AVAILABLE', ST_GeomFromText('POINT(106.690 10.768)')),
                                                                                                        (1004, 103, 'Quạt điện mini (hỏng)', 'Đã hỏng motor, phù hợp cho ai muốn lấy linh kiện.', 3, 'https://ecogive-storage.com/fan-004.jpg', 'PENDING', ST_GeomFromText('POINT(106.705 10.772)')),
                                                                                                        (1005, 102, 'Sách giáo trình cũ', 'Sách kinh tế, còn nguyên vẹn.', 4, 'https://ecogive-storage.com/book-005.jpg', 'AVAILABLE', ST_GeomFromText('POINT(106.700 10.779)'));

-- Chèn dữ liệu mẫu cho Bảng 4: collection_points (Điểm Thu gom Cố định)
INSERT INTO collection_points (point_id, name, type, address, location) VALUES
                                                                            (2001, 'Điểm Thu gom Pin Quận 1', 'BATTERY', '123 Đường Nguyễn Huệ, Quận 1', ST_GeomFromText('POINT(106.701 10.773)')),
                                                                            (2002, 'Điểm Thu gom Đồ điện tử Thủ Đức', 'E_WASTE', '300 Đường Võ Văn Ngân, Thủ Đức', ST_GeomFromText('POINT(106.760 10.850)')),
                                                                            (2003, 'Thùng Thu gom Vải Vóc', 'TEXTILE', 'Công viên Hoàng Văn Thụ', ST_GeomFromText('POINT(106.670 10.795)'));

-- Chèn dữ liệu mẫu cho Bảng 5: collection_requests (Yêu cầu Thu gom Chuyên biệt)
INSERT INTO collection_requests (request_id, user_id, item_type, status, pickup_date, address, location) VALUES
                                                                                                             (3001, 101, 'Pin AA/AAA', 'SCHEDULED', '2025-12-01 10:00:00', '15 đường Đề Thám, Q1', ST_GeomFromText('POINT(106.705 10.771)')),
                                                                                                             (3002, 103, 'Quần áo nát', 'COMPLETED', '2025-11-20 14:30:00', '290 đường Hai Bà Trưng, Q3', ST_GeomFromText('POINT(106.690 10.785)')),
                                                                                                             (3003, 102, 'Máy tính bảng cũ hỏng', 'SCHEDULED', '2025-12-03 09:00:00', '35 đường Cộng Hòa, Tân Bình', ST_GeomFromText('POINT(106.660 10.800)'));

-- Chèn dữ liệu mẫu cho Bảng 6: transactions (Giao dịch)
INSERT INTO transactions (transaction_id, item_id, receiver_id, exchange_date, status) VALUES
                                                                                           (4001, 1004, 103, '2025-11-26 11:00:00', 'COMPLETED'), -- Fan đã được trao cho Tam
                                                                                           (4002, 1001, 104, '2025-11-27 15:00:00', 'CONFIRMED'), -- Ghế đang chờ xác nhận
                                                                                           (4003, 1005, 101, '2025-11-27 18:00:00', 'COMPLETED'); -- Sách đã được trao cho Hải