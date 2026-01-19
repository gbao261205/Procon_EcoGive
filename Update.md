# Nhật ký Cập nhật Dự án EcoGive

Tài liệu này tổng hợp các thay đổi và tính năng mới đã được thực hiện từ ngày hôm qua đến hiện tại.

## 1. Tích hợp Cloudinary (Upload ảnh)
- **Mục tiêu**: Chuyển đổi từ việc lưu trữ ảnh cục bộ (local storage) sang dịch vụ đám mây Cloudinary để tăng tốc độ tải và giảm tải cho server.
- **Thay đổi**:
  - Thêm dependency `cloudinary-http44` vào `pom.xml`.
  - Tạo `CloudinaryService.java` để xử lý upload ảnh.
  - Cập nhật `PostItemServlet.java` để sử dụng service mới.
  - Cập nhật logic hiển thị ảnh ở `home.jsp`, `admin/items.jsp`, `profile.jsp` để hỗ trợ cả URL Cloudinary (bắt đầu bằng `http`) và URL cục bộ cũ.

## 2. Cải thiện Giao diện & Trải nghiệm (UI/UX)
### Bản đồ (Home Page)
- **Hiển thị ảnh**: Chuyển chế độ hiển thị ảnh trong popup bản đồ sang `object-fit: contain` để ảnh không bị cắt và hiển thị trọn vẹn.
- **Tối ưu hóa tải dữ liệu**:
  - Thêm phương thức `findAvailableInBounds` trong `ItemDAO` sử dụng `MBRContains` (MySQL Spatial) để chỉ lấy vật phẩm trong khung nhìn.
  - Cập nhật `ItemApiServlet` để nhận tham số toạ độ (`minLat`, `maxLat`, ...).
  - Cập nhật `home.jsp` để bắt sự kiện `moveend` của bản đồ và chỉ tải dữ liệu mới, kết hợp caching phía client (`loadedItemIds`) để tránh render lại.

### Trang Quản trị (Admin)
- **Modal Chi tiết**:
  - Thêm cửa sổ popup (Modal) khi click vào từng dòng sản phẩm để xem thông tin chi tiết và ảnh lớn hơn.
  - Tích hợp nút **Duyệt** và **Hủy** ngay trong Modal (chỉ hiện khi trạng thái là `PENDING`).
  - Thêm nút **Gỡ bỏ** (chuyển sang `CANCELLED`) cho các vật phẩm đang hiển thị (`AVAILABLE`).
- **Phân trang**:
  - Thêm chức năng phân trang cho danh sách vật phẩm (10 items/page).
  - Cập nhật `ItemDAO` và `AdminServlet` để hỗ trợ `LIMIT/OFFSET` và đếm tổng số lượng.

### Trang Cá nhân (Profile)
- **Quản lý tin đăng**:
  - Chuyển giao diện tab "Đồ đã tặng" từ dạng lưới (grid) sang dạng bảng (table) để hiển thị rõ ràng hơn.
  - Thêm cột "Hành động" cho phép người dùng:
    - **Hủy**: Nếu bài đăng đang chờ duyệt (`PENDING`).
    - **Gỡ bài**: Nếu bài đăng đang hiển thị (`AVAILABLE`).
- **Sửa lỗi**: Khắc phục lỗi `JasperException` do thẻ `fmt:formatDate` không hỗ trợ `LocalDateTime` bằng cách xử lý chuỗi thủ công với JSTL Functions (`fn:`).

## 3. Cấu trúc Database & Backend
- **ItemDAO**:
  - Thêm các phương thức hỗ trợ phân trang (`findAll` với limit/offset).
  - Thêm phương thức đếm số lượng (`countAll`).
  - Thêm truy vấn không gian (`findAvailableInBounds`).
- **ProfileServlet**: Thêm phương thức `doPost` để xử lý các action `cancel-item` và `remove-item` từ người dùng, có kiểm tra quyền sở hữu.

---
*Cập nhật lần cuối: [Thời gian hiện tại]*
