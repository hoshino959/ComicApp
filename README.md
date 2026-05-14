<div align="center">

# 📚 ComicApp

Ứng dụng đọc truyện tranh được phát triển bằng Flutter & Firebase.

<img src="https://img.shields.io/badge/Flutter-3.x-blue?style=for-the-badge&logo=flutter"/>
<img src="https://img.shields.io/badge/Firebase-Backend-orange?style=for-the-badge&logo=firebase"/>
<img src="https://img.shields.io/badge/Platform-Android-green?style=for-the-badge&logo=android"/>

</div>

---

# ✨ Giới thiệu

ComicApp là ứng dụng đọc truyện tranh trên Android được xây dựng nhằm giúp người dùng:

- Đọc truyện online
- Tìm kiếm truyện nhanh chóng
- Lưu truyện yêu thích
- Bình luận truyện
- Trải nghiệm giao diện hiện đại với Dark Mode

Dự án được phát triển bằng Flutter kết hợp Firebase để quản lý dữ liệu và xác thực người dùng.

---

# 🚀 Tính năng chính

## 👤 Authentication
- Đăng ký tài khoản
- Đăng nhập
- Đăng xuất
- Firebase Authentication

## 📖 Đọc truyện
- Hiển thị danh sách truyện
- Xem chi tiết truyện
- Danh sách chapter
- Đọc chapter online

## 🔍 Tìm kiếm
- Tìm kiếm truyện theo tên
- Lọc truyện nhanh

## ❤️ Yêu thích
- Thêm/Xóa truyện yêu thích
- Đồng bộ dữ liệu với Firebase

## 💬 Bình luận
- Người dùng có thể bình luận truyện
- Hiển thị thời gian và thông tin người dùng

## 🌙 Giao diện
- Dark Mode / Light Mode
- Responsive UI

---

# 🛠️ Công nghệ sử dụng

| Công nghệ | Mô tả |
|---|---|
| Flutter | Framework phát triển ứng dụng |
| Dart | Ngôn ngữ lập trình |
| Firebase Auth | Xác thực người dùng |
| Cloud Firestore | Database realtime |
| Firebase Storage | Lưu trữ hình ảnh |
| Provider | State Management |
| Cloudinary | Quản lý và lưu trữ hình ảnh |

---

# 📂 Cấu trúc thư mục

```plaintext
lib/
│
├── models/        # Data models
├── screens/       # UI screens
├── widgets/       # Reusable widgets
├── services/      # Firebase services
├── providers/     # State management
├── theme/         # Theme & dark mode
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

Tạo project trên Firebase:

- Firebase Authentication
- Cloud Firestore
- Firebase Storage

Sau đó tải file:

```plaintext
google-services.json
```

và đặt vào:

```plaintext
android/app/google-services.json
```

---

## 5️⃣ Chạy ứng dụng

```bash
flutter run
```

---

# 📱 Screenshots

> Bạn có thể thêm ảnh giao diện ở đây

## 🏠 Home Screen
![Home](screenshots/home.png)

## 📖 Detail Screen
![Detail](screenshots/detail.png)

## 🌙 Dark Mode
![DarkMode](screenshots/darkmode.png)

---

# 🎯 Mục tiêu dự án

Dự án được thực hiện nhằm:

- Học Flutter & Firebase
- Xây dựng ứng dụng thực tế
- Cải thiện kỹ năng Mobile Development
- Tìm hiểu State Management với Provider

---

# 👨‍💻 Tác giả

## None Nope

- GitHub: https://github.com/hoshino959

---

# 📄 License

This project is for educational and personal development purposes.
