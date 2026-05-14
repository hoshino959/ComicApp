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

Dự án được thực hiện nhằm nâng cao kỹ năng Mobile Development với Flutter và Firebase.

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
  - Nội dung R18

Dữ liệu truyện được lấy từ MangaDex API.

---

## 🏠 Trang chủ
- Banner truyện nổi bật
- Danh sách truyện mới cập nhật
- Hiển thị dữ liệu realtime từ MangaDex API

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

### Bình luận
- Bình luận theo truyện
- Bình luận theo chapter
- Thích comment
- Reply comment

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
| Firebase Cloud Messaging | Push Notification |
| Provider | State Management |
| Cloudinary | Upload & lưu trữ avatar |
| MangaDex API | Dữ liệu truyện tranh |
| CachedNetworkImage | Cache hình ảnh |

---

# 📂 Cấu trúc thư mục

```plaintext
lib/
│
├── models/          # Data models
├── screens/         # UI screens
├── widgets/         # Reusable widgets
├── services/        # Firebase/API services
├── providers/       # State management
├── theme/           # Theme & dark mode
├── utils/           # Helper functions
└── main.dart
```

---

# ⚙️ Cài đặt dự án

## 1️⃣ Clone repository

```bash
git clone https://github.com/hoshino959/ComicApp.git
```

---

## 2️⃣ Di chuyển vào thư mục project

```bash
cd ComicApp
```

---

## 3️⃣ Cài dependencies

```bash
flutter pub get
```

---

## 4️⃣ Firebase Setup

Tạo project trên Firebase và bật:

- Firebase Authentication
- Cloud Firestore
- Firebase Cloud Messaging

Sau đó thêm file:

```plaintext
google-services.json
```

vào:

```plaintext
android/app/google-services.json
```

---

## 5️⃣ Cloudinary Setup

Tạo tài khoản Cloudinary và cấu hình API dùng để upload avatar người dùng.

---

## 6️⃣ Chạy ứng dụng

```bash
flutter run
```

---

# 🌐 API sử dụng

## MangaDex API

Dùng để:
- Lấy danh sách truyện
- Lấy thông tin truyện
- Danh sách chapter
- Tìm kiếm & lọc truyện

```plaintext
https://api.mangadex.org
```

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

---

# 🎯 Mục tiêu dự án

Dự án được thực hiện nhằm:

- Học Flutter & Firebase
- Làm việc với REST API thực tế
- Xây dựng ứng dụng mobile hoàn chỉnh
- Cải thiện kỹ năng UI/UX
- Tìm hiểu State Management với Provider
- Áp dụng Firebase vào ứng dụng thực tế
