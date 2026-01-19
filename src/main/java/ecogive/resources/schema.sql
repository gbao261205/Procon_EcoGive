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

-- ===========================
-- 3. CHÈN DỮ LIỆU MẪU (SEED DATA)
-- ===========================

-- 3.1 Users
INSERT INTO users (username, email, password_hash, role, phone_number, address, eco_points, reputation_score) VALUES
('admin', 'admin@ecogive.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'ADMIN', '0900000001', 'HQ EcoGive, TP.HCM', 1000.00, 5.00),
('greencorp', 'contact@greencorp.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'COLLECTOR_COMPANY', '0900000002', 'KCN Tân Bình, TP.HCM', 500.00, 4.80),
('recycle_vn', 'info@recyclevn.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'COLLECTOR_COMPANY', '0900000003', 'Quận 7, TP.HCM', 300.00, 4.50),
('nguyenvana', 'vana@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345678', 'Quận 1, TP.HCM', 50.00, 4.20),
('tranthib', 'thib@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345679', 'Quận 3, TP.HCM', 120.00, 4.90),
('lethic', 'thic@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345680', 'Quận 5, TP.HCM', 10.00, 3.50),
('phamvand', 'vand@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345681', 'Quận 10, TP.HCM', 200.00, 5.00),
('hoangthie', 'thie@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345682', 'Bình Thạnh, TP.HCM', 80.00, 4.00),
('vothif', 'thif@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345683', 'Gò Vấp, TP.HCM', 0.00, 1.00),
('dangvang', 'vang@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345684', 'Thủ Đức, TP.HCM', 30.00, 3.80);

-- 3.2 Categories - ĐÃ KHÔI PHỤC
INSERT INTO categories (name, fixed_points) VALUES
('Nội thất, Bàn ghế', 10.00),
('Quần áo, Giày dép', 3.50),
('Thiết bị điện tử nhỏ', 7.50),
('Sách, Văn phòng phẩm', 1.00),
('Nhựa tái chế', 2.00);

-- 3.3 Items
INSERT INTO items (giver_id, title, description, image_url, status, location, eco_points, category_id) VALUES
(4, 'Bàn học sinh cũ', 'Bàn gỗ ép, còn dùng tốt, hơi trầy xước.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785003/banHocSinh_t9no1d.png', 'AVAILABLE', ST_GeomFromText('POINT(106.698 10.771)'), 15.00, 1),
(4, 'Sách giáo khoa lớp 12', 'Trọn bộ sách giáo khoa, tặng cho em nào cần.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785038/s%C3%A1ch_gi%C3%A1o_khoa_l%E1%BB%9Bp_12_zxz5jw.jpg', 'AVAILABLE', ST_GeomFromText('POINT(106.698 10.771)'), 5.00, 4),
(5, 'Quần áo trẻ em 5 tuổi', 'Đồ bé trai, khoảng 5kg quần áo.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785121/qu%E1%BA%A7n_%C3%A1o_tr%E1%BA%BB_em_ymibjz.jpg', 'AVAILABLE', ST_GeomFromText('POINT(106.690 10.780)'), 10.00, 2),
(5, 'Xe đạp mini', 'Xe đạp cho bé tập đi, bị hỏng phanh.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785177/xe_%C4%91%E1%BA%A1p_mini_wnnwlk.webp', 'PENDING', ST_GeomFromText('POINT(106.690 10.780)'), 20.00, 1),
(6, 'Laptop Dell cũ hỏng', 'Hỏng main, bán xác hoặc tặng thợ.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785244/laptop_dell_x887g7.png', 'AVAILABLE', ST_GeomFromText('POINT(106.660 10.750)'), 50.00, 3),
(7, 'Tủ lạnh mini Sanyo', 'Vẫn chạy tốt, phù hợp sinh viên.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785294/t%E1%BB%A7_l%E1%BA%A1nh_mini_dglgud.jpg', 'COMPLETED', ST_GeomFromText('POINT(106.670 10.760)'), 100.00, 3),
(8, 'Giày thể thao size 42', 'Ít đi, còn mới 90%.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785354/gi%C3%A0y_th%E1%BB%83_thao_jzgakn.webp', 'AVAILABLE', ST_GeomFromText('POINT(106.710 10.800)'), 8.00, 2),
(9, 'Chai nhựa rỗng (10kg)', 'Đã phân loại sạch sẽ.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785418/chai_nh%E1%BB%B1a_r%E1%BB%97ng_bqy89w.png', 'AVAILABLE', ST_GeomFromText('POINT(106.680 10.820)'), 12.00, 5),
(10, 'Ghế sofa đơn', 'Màu xám, nệm êm.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785457/gh%E1%BA%BF_sofa_%C4%91%C6%A1n_tm9iqy.png', 'CONFIRMED', ST_GeomFromText('POINT(106.750 10.850)'), 30.00, 1),
(4, 'Màn hình máy tính 19 inch', 'Bị sọc màn hình nhẹ.', 'https://res.cloudinary.com/dwsspfalj/image/upload/v1768785497/M%C3%A0n_h%C3%ACnh_m%C3%A1y_t%C3%ADnh_19_inch_dg9c86.png', 'AVAILABLE', ST_GeomFromText('POINT(106.698 10.771)'), 15.00, 3);

-- 3.4 Collection Points
INSERT INTO collection_points (name, type, address, location, owner_id) VALUES
('Trạm thu gom Pin Q1', 'BATTERY', '123 Nguyễn Huệ, Q1', ST_GeomFromText('POINT(106.700 10.770)'), 1),
('Điểm thu gom rác điện tử GreenCorp', 'E_WASTE', 'KCN Tân Bình', ST_GeomFromText('POINT(106.620 10.810)'), 2),
('Thùng quần áo từ thiện Q3', 'TEXTILE', 'Công viên Lê Văn Tám', ST_GeomFromText('POINT(106.695 10.785)'), 1),
('Trạm tái chế RecycleVN Q7', 'DEALER', 'Nguyễn Văn Linh, Q7', ST_GeomFromText('POINT(106.720 10.730)'), 3),
('Điểm thu hồi thuốc hết hạn', 'MEDICAL', 'Bệnh viện Quận 5', ST_GeomFromText('POINT(106.665 10.755)'), 1),
('Cửa hàng thu mua phế liệu An Bình', 'INDIVIDUAL', 'Bình Thạnh', ST_GeomFromText('POINT(106.710 10.800)'), 2),
('Trạm xử lý hóa chất', 'CHEMICAL', 'KCN Hiệp Phước', ST_GeomFromText('POINT(106.750 10.650)'), 3),
('Điểm thu gom giấy vụn trường ĐH', 'DEALER', 'Thủ Đức (Làng ĐH)', ST_GeomFromText('POINT(106.800 10.870)'), 1),
('Trạm thu gom pin cũ siêu thị', 'BATTERY', 'Siêu thị BigC Gò Vấp', ST_GeomFromText('POINT(106.680 10.830)'), 2),
('Thùng thu gom quần áo cũ Q10', 'TEXTILE', 'Nhà văn hóa Q10', ST_GeomFromText('POINT(106.670 10.770)'), 3);

-- 3.5 Transactions
INSERT INTO transactions (item_id, receiver_id, exchange_date, status) VALUES
(6, 4, '2023-10-25 10:00:00', 'COMPLETED'),
(4, 8, '2023-10-26 14:00:00', 'CONFIRMED'),
(9, 5, '2023-10-27 09:00:00', 'CONFIRMED');
