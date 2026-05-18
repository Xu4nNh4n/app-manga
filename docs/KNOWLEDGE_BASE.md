# Tài Liệu Chuyển Đổi & Kiến Trúc Dự Án (MangaHay App)

> **LƯU Ý DÀNH CHO AI TRONG PHIÊN LÀM VIỆC TIẾP THEO:** 
> Vui lòng đọc sát tài liệu này trước khi chỉnh sửa bộ source nhằm tránh bẻ gãy cấu trúc Firebase mà phiên trước đã dày công thiết lập.

## 1. Mục tiêu đã hoàn tất
Dự án đã thực hiện di chuyển (migration) 100% từ cấu trúc dữ liệu Local rác (`.json` và `sample_truyen.dart`) sang cơ sở lưu trữ online của Firebase. Các phần mềm đã được tích hợp bao gồm: **Firestore**, **Firebase Auth**, và **Firebase Storage**. Hình nền và trang truyện đều được kéo xuống qua luồng xử lý CachedNetworkImage.

## 2. Các Collection trong Firestore (Database)
- **`users` (Collection):**
  - **Dữ liệu Lưu:** Quản lý thông tin tài khoản người dùng và Auth.
  - **Các field chính:** `uid`, `email`, `displayName`, `coins` (ví xu - tự động cấp 100 xu cho new user), `role` (gồm 2 quyền chính `'user'` và `'admin'`), `unlockedChapters` (Lịch sử mở khóa chương dưới dạng Map String->Bool: `{"storyId_chapterId": true}`).

- **`stories` (Collection chính):**
  - **Các field chính:** `id`, `title`, `author`, `coverImage` (URL ảnh), `description`, `genres`, `rating`, `views`, `status`, `chapterCount`, `updatedAt`, `isHot`.
  - **Thêm field định giá:** `freeChapters` (số chương đầu được đọc miễn phí) và `coinPerChapter` (Giá xu mỗi chương).
  - **`chapters` (Sub-Collection nằm trong mỗi ID truyện):** Quản lý chi tiết nội dung truyện. Data của nó có list URL hình ảnh trong `pages`, `chapterNumber`...

- **`categories` (Collection mới):**
  - Quản lý danh sách thể loại động. Thay thế cho việc gán cứng (hardcode) thể loại trong code.
  - Model: `StoryCategory` (để tránh trùng tên với lớp Category mặc định của Flutter).

## 3. Kiến trúc State và Dịch vụ (Services)
- `AuthService` (`services/auth_service.dart`): Chịu trách nhiệm Login/Register.
  - **Quan trọng:** Hàm `canReadChapter` đã được sửa lỗi fallback. Nó chỉ trả về `true` nếu chương miễn phí hoặc đã được mua (có trong `unlockedChapters`). Nếu chưa mua, nó trả về `false` bất kể trạng thái đăng nhập.
- `FirestoreService` (`services/firestore_service.dart`):
  - Bổ sung CRUD cho `categories`.
  - Bổ sung `updateStoryFull` để hỗ trợ chỉnh sửa thông tin truyện từ Admin.
- `CoinService` (`services/coin_service.dart`): Xử lý giao dịch trừ xu và lưu trạng thái mở khóa vào Firestore.

## 4. UI/UX & Logic đặc biệt
- **Admin Panel** (`admin_screen.dart`): Đã nâng cấp lên giao diện Tab (Truyện & Thể loại).
  - Hỗ trợ **Sửa truyện** (Edit Story) đổ dữ liệu cũ vào form.
  - Hỗ trợ Quản lý Thể loại (Thêm/Sửa/Xóa).
- **Logic Chuyển Chương (`doc_truyen_screen.dart`):**
  - Khi người dùng nhấn sang chương tiếp theo bị khóa:
    - Nếu chưa login: Hiện `LoginWallDialog`.
    - Nếu đã login: Hiện `_showUnlockDialog` (Hộp thoại mua chương bằng xu).
    - Sau khi mua thành công: Tự động refresh và chuyển vào nội dung chương mới.
- **Search Screen**: Thể loại trong bộ lọc Filter được load động từ collection `categories` trên Firestore.

## 5. Tác vụ đề xuất nếu User làm tiếp (Nhiệm vụ cho tương lai)
1. **Thiết lập Rule Bảo Mật (Firestore Security Rules):** Cần phải setup rules để chặn user tự ý đổi thông số `'role'` của họ thành admin hoặc sửa đổi mục `coins` trái phép.
2. **Khu vực bình luận (Comments):** Có thể phát triển collection con `comments` bên trong từng truyện hoặc từng chương và bổ sung giao diện.
3. **Quản lý User cho Admin:** Thêm chức năng cho Admin xem danh sách user, cộng/trừ xu cho user hoặc khóa tài khoản.
4. **Download Offline:** Xử lý local cache qua shared_preferences hoặc SQLite nội bộ bổ sung tính năng đọc tải lên máy lúc có kết nối.
