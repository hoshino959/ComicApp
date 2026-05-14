<div align="center">

# 📚 ComicApp

Ứng dụng đọc truyện tranh được phát triển bằng Flutter, Firebase & MangaDex API.

<img src="https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter"/>
<img src="https://img.shields.io/badge/Firebase-Backend-orange?style=for-the-badge&logo=firebase"/>
<img src="https://img.shields.io/badge/MangaDex-API-red?style=for-the-badge"/>
<img src="https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android"/>

</div>

---

# ✨ Giới thiệu

ComicApp là ứng dụng đọc truyện tranh trên Android được xây dựng bằng Flutter kết hợp Firebase và MangaDex API.

Ứng dụng cho phép người dùng:

- Đọc truyện online
- Tìm kiếm truyện theo tên/cấu hình
- Theo dõi tiến độ đọc truyện
- Lưu truyện yêu thích
- Bình luận theo truyện/chapter
- Nhận thông báo chapter mới
- Tùy chỉnh Dark Mode / Light Mode

---

# 🚀 Tính năng chính

## 👤 Authentication
- Đăng ký tài khoản
- Đăng nhập
- Đăng xuất
- Quên mật khẩu
- Firebase Authentication

---

## 👤 Hồ sơ cá nhân
- Chỉnh sửa avatar
- Chỉnh sửa:
  - Bio
  - Giới tính
  - Tên hiển thị
- Upload avatar bằng Cloudinary
- Lưu dữ liệu với Firebase Firestore

---

## 📚 Thư viện cá nhân
- Lưu tiến độ truyện đang đọc
- Hiển thị lịch sử đọc truyện
- Hiển thị truyện đã yêu thích
- Hiển thị truyện đã lưu

Dữ liệu được đồng bộ bằng Firebase Firestore.

---

## 🔔 Thông báo
- Thông báo khi:
  - Comment được reply
  - Truyện có chapter mới

Sử dụng Firebase Firestore để lưu dữ liệu thông báo.

---

## 🔍 Tìm kiếm truyện

### Tìm kiếm cơ bản
- Tìm kiếm truyện theo tên

### Tìm kiếm nâng cao
- Lọc theo:
  - Thể loại
  - Tác giả
  - Tiêu đề

Dữ liệu truyện được lấy từ MangaDex API.

---

## 🏠 Trang chủ
- Banner truyện nổi bật
- Danh sách truyện mới cập nhật

---

## 📖 Đọc truyện

### Chi tiết truyện
- Thông tin truyện
- Ảnh bìa
- Mô tả
- Tác giả
- Thể loại

### Chapter
- Danh sách chapter
- Đọc truyện theo chapter
- Đọc truyện mới nhất/cũ nhất

### Bình luận
- Bình luận theo truyện
- Bình luận theo chapter
- Thích comment
- Reply comment

### Truyện liên quan
- Hiển thị các truyện có cùng tác giả

### Tương tác
- Thêm truyện vào:
  - Yêu thích
  - Lưu truyện
  - Theo dõi thông báo

---

## 🌙 Giao diện
- Dark Mode / Light Mode
- Responsive UI
- Provider State Management

---

# 🛠️ Công nghệ sử dụng

| Công nghệ | Mô tả |
|---|---|
| Flutter | Framework phát triển ứng dụng |
| Dart | Ngôn ngữ lập trình |
| Firebase Authentication | Xác thực người dùng |
| Cloud Firestore | Database realtime |
| Provider | State Management |
| Cloudinary | Upload & lưu trữ avatar |
| MangaDex API | Dữ liệu truyện tranh |
| CachedNetworkImage | Cache hình ảnh |

---

# 📱 Screenshots

> Bạn có thể thêm ảnh giao diện tại đây

## 🏠 Home Screen
![Home](screenshots/home.png)

## 📖 Detail Screen
![Detail](screenshots/detail.png)

## 🌙 Dark Mode
![DarkMode](screenshots/darkmode.png)

## 👤 Profile Screen
![Profile](screenshots/profile.png)
