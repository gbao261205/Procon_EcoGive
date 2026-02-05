-- 3.1 Users
INSERT INTO users (username, email, password_hash, role, phone_number, address, eco_points, reputation_score, is_verified) VALUES
('admin', 'admin@ecogive.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'ADMIN', '0900000001', 'HQ EcoGive, TP.HCM', 1000.00, 5.00, 1),
('greencorp', 'contact@greencorp.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'COLLECTOR_COMPANY', '0900000002', 'KCN Tân Bình, TP.HCM', 500.00, 4.80, 1),
('recycle_vn', 'info@recyclevn.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'COLLECTOR_COMPANY', '0900000003', 'Quận 7, TP.HCM', 300.00, 4.50, 1),
('nguyenvana', 'vana@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345678', 'Quận 1, TP.HCM', 50.00, 4.20, 1),
('tranthib', 'thib@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345679', 'Quận 3, TP.HCM', 120.00, 4.90, 1),
('lethic', 'thic@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345680', 'Quận 5, TP.HCM', 10.00, 3.50, 1),
('phamvand', 'vand@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345681', 'Quận 10, TP.HCM', 200.00, 5.00, 1),
('hoangthie', 'thie@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345682', 'Bình Thạnh, TP.HCM', 80.00, 4.00, 1),
('vothif', 'thif@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345683', 'Gò Vấp, TP.HCM', 0.00, 1.00, 1),
('dangvang', 'vang@gmail.com', '$2a$10$1NLA.hCR59G19C4zWfVx5.IZQ1KO77LmNrKJzk.GuvmuAmR6Jbzxm', 'USER', '0912345684', 'Thủ Đức, TP.HCM', 30.00, 3.80, 1);

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