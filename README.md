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

# 🏗️ Architecture

Ứng dụng được tổ chức theo hướng **Feature-based structure** kết hợp với phân tách layer cơ bản:

- **Presentation Layer**
  - Screens, Widgets
  - Xử lý UI & tương tác người dùng

- **Data Layer**
  - API Services (MangaDex API)
  - Firebase Services (Auth, Firestore)

- **State Management**
  - Sử dụng Provider (ChangeNotifier)

⚠️ Lưu ý:
- Chưa áp dụng Clean Architecture hoàn chỉnh
- Chưa sử dụng Repository & UseCase layer
- Business logic vẫn nằm một phần trong UI

📌 Phù hợp với ứng dụng quy mô nhỏ → trung bình

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

## 🏠 Trang chủ
- Banner truyện nổi bật
- Danh sách truyện mới cập nhật
- Carousel truyện random

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

## 📖 Đọc truyện

### Chi tiết truyện
- Ảnh bìa
- Tên truyện
- Mô tả
- Tác giả
- Thể loại
- Trạng thái

### Chapter
- Danh sách chapter
- Sắp xếp chapter mới/cũ
- Đọc truyện theo chapter
- Đọc truyện mới nhất/cũ nhất

### Bình luận
- Bình luận theo truyện
- Bình luận theo chapter
- Thích comment
- Reply comment

### Reader Screen
- Đọc truyện theo chiều dọc
- Responsive UI
- Tối ưu trải nghiệm mobile
- Theo dõi tiến độ đọc

### Truyện liên quan
- Hiển thị các truyện có cùng tác giả

### Tương tác
- Thêm truyện vào:
  - Yêu thích
  - Lưu truyện
  - Theo dõi thông báo

---

## 💬 Hệ thống bình luận
- Bình luận theo truyện
- Reply comment
- Like comment
- Report comment
- Realtime update với Firestore
- Hiển thị thông tin user
- Nested replies
- Quản lý trạng thái hiển thị replies
- Realtime sync dữ liệu comment

---

## 📚 Thư viện cá nhân
- Theo dõi tiến độ đọc
- Xem lịch sử đọc truyện
- Lưu truyện yêu thích
- Lưu truyện để đọc sau

Dữ liệu được đồng bộ bằng Firebase Firestore.

---

## 🔔 Notification System
- Thông báo khi:
  - Comment được reply
  - Truyện có chapter mới

Sử dụng Firebase Firestore để lưu dữ liệu thông báo.

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
| Carousel Slider |	Banner & slider |
| Smooth Page Indicator | Indicator cho carousel |

---

# 📂 Cấu trúc thư mục

```bash
lib/
│
├── api/
│   ├── api_service.dart
│   └── notify_services.dart
│
├── comment/
│   ├── comment_section.dart
│   ├── report_dialog.dart
│   └── show_info_user.dart
│
├── models/
│   ├── chapter_model.dart
│   ├── chapter_page_model.dart
│   ├── comic_detail_model.dart
│   ├── comic_model.dart
│   ├── genre_model.dart
│   └── reading_comic.dart
│
├── screens/
│   ├── detail_screen.dart
│   ├── home_screen.dart
│   ├── main_screen.dart
│   ├── notify_screen.dart
│   ├── reading_screen.dart
│   └── search_screen.dart
│
├── theme/
│   ├── app_colors.dart
│   ├── app_dark_colors.dart
│   ├── app_light_colors.dart
│   └── theme_provider.dart
│
├── user/
│   ├── library_all.dart
│   ├── library_fav_saved.dart
│   ├── library_screen.dart
│   ├── login_page.dart
│   ├── profile_screen.dart
│   └── user_screen.dart
│
├── widgets/
│   ├── chapter_item.dart
│   ├── comic_card.dart
│   ├── custom_dropdown.dart
│   ├── expandable_description.dart
│   ├── genre_tag.dart
│   ├── reading_carousel.dart
│   ├── reading_grid.dart
│   ├── reading_list.dart
│   ├── related_comics_tab.dart
│   ├── status_chip.dart
│   └── stat_item.dart
│
├── auth_gate.dart
├── firebase_options.dart
└── main.dart
```

---

# 🔄 App Flow

Luồng khởi động:

1. App start
2. Mở trực tiếp Home Screen

📌 Lưu ý:
- Authentication được xử lý bên trong các chức năng cụ thể (profile, comment, library...)
- Nếu user chưa đăng nhập, app sẽ yêu cầu login khi cần

Luồng chính:
- Home → Detail → Chapter → Reading → Comment

Luồng phụ:
- Search → Detail
- Profile → Login (nếu chưa đăng nhập) → User Profile
- Library → Login (nếu chưa đăng nhập)
- Notification → Detail

---

# 🧩 Mô tả cấu trúc

| Thư mục | Chức năng |
|---|---|
| `api/` | Xử lý API MangaDex & Notification Services |
| `comment/` | Hệ thống comment, report & thông tin user |
| `models/` | Data models của ứng dụng |
| `screens/` | Các màn hình chính của app |
| `theme/` | Quản lý màu sắc & Dark/Light Mode |
| `user/` | Chức năng người dùng, profile & thư viện |
| `widgets/` | Các widget reusable dùng nhiều nơi |
| `main.dart` | Entry point của ứng dụng |
| `auth_gate.dart` | Điều hướng xác thực đăng nhập |
| `firebase_options.dart` | Firebase configuration |

---

# ⚙️ Setup & Run

## 1. Clone project

```bash
git clone https://github.com/hoshino959/ComicApp.git
cd ComicApp
```

## 2. Cài dependencies

```bash
flutter pub get
```

## 3. Cấu hình Firebase

- Thêm file `google-services.json` vào:

```text
android/app/
```

- Enable:
  - Firebase Authentication
  - Cloud Firestore

## 4. Run app

```bash
flutter run
```

---

# 📱 Screenshots

## 👤 Authentication

<div align="center">
<img width="200" alt="1" src="https://github.com/user-attachments/assets/16e9b4cc-bacc-4e2d-9b58-1eba2e2d98a5" />
<img width="200" alt="2" src="https://github.com/user-attachments/assets/487b833e-9dbb-45d7-8fea-1c9ff46ec491" />
<img width="200" alt="3" src="https://github.com/user-attachments/assets/35eb32d5-208f-4712-b28a-c2ed80f7e8e2" />
<img width="200" alt="4" src="https://github.com/user-attachments/assets/e1fecd2f-4dd7-4128-9b5f-2ad522cea152" />
<img width="200" alt="5" src="https://github.com/user-attachments/assets/1e9df50b-801e-4703-969f-b8fcdbc4db3f" />
<img width="200" alt="6" src="https://github.com/user-attachments/assets/99dabaad-6e48-4829-92cd-af519dd9b754" />
</div>

## 👤 Hồ sơ cá nhân

<div align="center">
<img width="200" alt="19" src="https://github.com/user-attachments/assets/659752d0-19c8-415a-8ecc-3e48706eb2f4" />
<img width="200" alt="20" src="https://github.com/user-attachments/assets/4e550eef-5a2b-4455-afe9-b0bdf58f2f77" />
</div>

## 🏠 Trang chủ

<div align="center">
<img width="200" alt="7" src="https://github.com/user-attachments/assets/f6a585f9-cb6e-4410-b488-0476e710e669" />
<img width="200" alt="8" src="https://github.com/user-attachments/assets/93e16bc7-dd40-4e5b-8c78-e4c621ddae8a" />
</div>

## 🔍 Tìm kiếm truyện

<div align="center">
<img width="200" alt="13" src="https://github.com/user-attachments/assets/9f70cf77-80d5-453e-9e4e-82c5d94c1409" />
<img width="200" alt="14" src="https://github.com/user-attachments/assets/78f26ba0-604c-409a-ab58-d317950febbd" />
<img width="200" alt="15" src="https://github.com/user-attachments/assets/3ab59196-ddd0-4a72-9146-b8c40890f254" />
</div>

## 📖 Chi tiết truyện & Chapter

<div align="center">
<img width="200" alt="9" src="https://github.com/user-attachments/assets/6fcab3ff-6c7c-4488-b89d-4d5b75d09ccd" />
<img width="200" alt="10" src="https://github.com/user-attachments/assets/a7b8a6d7-4932-40e7-a46b-5d512b010cd3" />
</div>

## 📖 Reader Screen

<div align="center">
<img width="200" alt="11" src="https://github.com/user-attachments/assets/e7b13921-ff1b-4012-b942-c5ef92d304d7" />
<img width="200" alt="12" src="https://github.com/user-attachments/assets/971c7818-c770-445f-8185-338acb748ab3" />
</div>

## 📖 Truyện liên quan

<div align="center">
<img width="200" alt="23" src="https://github.com/user-attachments/assets/92f68ac0-0872-42d8-a388-1b2476ac48c1" />
</div>

## 💬 Hệ thống bình luận

<div align="center">
<img width="200" alt="21" src="https://github.com/user-attachments/assets/350e578c-e836-4b42-8e65-ac0984d73abb" />
</div>

## 📚 Thư viện cá nhân

<div align="center">
<img width="200" alt="16" src="https://github.com/user-attachments/assets/a28c60f4-93e8-4d7c-a4de-14cd05d922c7" />
<img width="200" alt="17" src="https://github.com/user-attachments/assets/fa782f6d-8c33-417d-8457-43ee646b06bf" />
<img width="200" alt="18" src="https://github.com/user-attachments/assets/981ec9c6-2243-4454-bfa4-ec42f7aab939" />
</div>

## 🔔 Notification System

<div align="center">
<img width="200" alt="22" src="https://github.com/user-attachments/assets/c48ecaab-5e35-4cdf-af66-fa9d6eceb2f6" />
</div>

---

# ⚠️ Limitations

- Chưa áp dụng Clean Architecture
- State management sử dụng Provider → khó scale lớn
- Chưa tối ưu caching nâng cao
- Chưa có unit test / integration test
- Performance chưa tối ưu khi load Reading History:
  - Việc đồng bộ dữ liệu lịch sử đọc cần nhiều lần truy vấn (Firestore + API)
  - Chưa áp dụng caching hoặc batch request
  - Có thể gây delay khi render Library

---

# 🚀 Future Improvements

- Refactor sang Clean Architecture
- Áp dụng Riverpod hoặc BLoC
- Tối ưu performance khi đọc chapter dài
- Thêm unit test & integration test
- Tối ưu performance cho Reading History:
  - Áp dụng caching (local storage / Hive)
  - Giảm số lần gọi API & Firestore
  - Sử dụng batch fetch hoặc pagination
