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

## 👤 Authentication

<div align="center">
<img width="250" alt="1" src="https://github.com/user-attachments/assets/af7d5ec6-177b-49cc-bbd5-999cc924403e" />
<img width="250" alt="2" src="https://github.com/user-attachments/assets/b32f7a5f-12c3-4940-a318-35070c272755" />
<img width="250" alt="3" src="https://github.com/user-attachments/assets/10a38e69-04f2-4aad-bd09-744b4318b5ce" />
</div>

## 🏠 Home Screen

<div align="center">
<img width="250" alt="4" src="https://github.com/user-attachments/assets/36031a76-dc76-45d1-90c4-1101feb25150" />
</div>

## 📖 Detail Screen

<div align="center">
<img width="250" alt="5" src="https://github.com/user-attachments/assets/4ada3b37-99da-406a-92a4-747de21dc096" />
</div>

## 📖 Reader Screen

<div align="center">
<img width="250" alt="6" src="https://github.com/user-attachments/assets/9fd58878-d8b9-494b-9b06-6361452c2b0c" />
</div>

## 🔍 Search & Filter

<div align="center">
<img width="250" alt="7" src="https://github.com/user-attachments/assets/a17d388a-5f71-4d77-830a-1404ed33d115" />
</div>

## 📚 Library

<div align="center">
<img width="250" alt="8" src="https://github.com/user-attachments/assets/2839ebf3-2d11-4879-a1b6-70cfda8b5f2a" />
<img width="250" alt="9" src="https://github.com/user-attachments/assets/90aea13d-1b07-4865-9dee-b1843a726ff3" />
<img width="250" alt="10" src="https://github.com/user-attachments/assets/faa11dd8-3cb9-447e-b152-6e8cbc5ef1c9" />
</div>

## 👤 Profile

<div align="center">
  <img width="250" alt="11" src="https://github.com/user-attachments/assets/a0a95c42-6cbe-428e-9cb1-451d42de85b8" />
</div>

## 🔔 Interaction

<div align="center">
<img width="250" alt="12" src="https://github.com/user-attachments/assets/0a414f0c-1245-4d53-82fd-c0d0346ebfe0" />
<img width="250" alt="13" src="https://github.com/user-attachments/assets/a94fef5a-7225-40cd-a6fe-296d0c616767" />
</div>
