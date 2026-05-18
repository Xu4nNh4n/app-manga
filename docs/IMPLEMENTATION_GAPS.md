# Các phần chưa có logic thật

> Ghi nhớ nhanh các màn/luồng hiện mới là UI, demo, hoặc placeholder.

## Đã xác nhận

- `lib/screens/thu_vien_screen.dart`: 3 tab `Đang đọc / Yêu thích / Đã đọc xong` mới là khung UI, chưa lấy dữ liệu Firestore.
- `lib/screens/home_screen.dart`: nút `Xem tất cả` hiện vẫn để trống (`onPressed: () {}`), chưa điều hướng hay mở danh sách đầy đủ.
- `lib/screens/truyen_detail_screen.dart` + `lib/controllers/story_detail_controller.dart`: nút tim chỉ đổi trạng thái local, chưa lưu `favorites` cho user.
- `lib/screens/truyen_detail_screen.dart`: chưa có bình luận truyện hay đánh giá sao từ user, chỉ đang hiển thị `story.rating` có sẵn từ Firestore.
- `lib/screens/admin_screen.dart` + `lib/controllers/admin_controller.dart`: form sửa truyện chưa có field đổi `status`, nên admin chỉ sửa được thông tin khác; trạng thái truyện vẫn giữ nguyên từ record cũ.
- `lib/services/firestore_service.dart`: mới có `addChapter`, chưa có `updateChapter`/`deleteChapter`; hiện cũng chưa thấy UI sửa chương trong admin.
- `lib/screens/home_screen.dart` + `lib/screens/thu_vien_screen.dart`: chưa có `history`/`continue reading` thật (mục đọc gần đây hoặc đọc tiếp).
- `lib/screens/doc_truyen_screen.dart` + `lib/controllers/reading_controller.dart`: chưa có lưu tiến độ đọc/đánh dấu hoàn tất theo user để đẩy vào tab `Đã đọc xong`.
- `lib/screens/profile_screen.dart`: đổi theme đang báo snackbar, chưa có toggle theme thật.
- `lib/screens/profile_screen.dart` + `lib/services/coin_service.dart`: nạp xu là luồng demo, chưa có thanh toán thật.
- `lib/screens/profile_screen.dart`: mục thông báo hiện chưa có logic hoạt động.

## Ghi chú

- `status` của truyện (`Đang ra` / `Hoàn thành`) chỉ là trạng thái nội dung chung của truyện, không phải trạng thái đọc của từng user.
- `rating` hiện tại là số liệu hiển thị của truyện, chưa phải đánh giá sao do user nhập.
- Sửa chương hiện chưa có luồng riêng; hệ thống chỉ hỗ trợ thêm chương mới.
- `onPressed: () {}` ở `HomeScreen` cho nút `Xem tất cả` vẫn là no-op.
- Khi làm tiếp phần Thư Viện, nên tách dữ liệu theo user (`users/{uid}` hoặc subcollection riêng) để tránh nhầm giữa trạng thái truyện và trạng thái đọc cá nhân.

## Audit cấu trúc folder

| Folder | File tiêu biểu | Vai trò hiện tại | Có nên tách thêm? |
|---|---|---|---|
| `lib/screens/` | `admin_screen.dart`, `doc_truyen_screen.dart`, `profile_screen.dart`, `truyen_detail_screen.dart` | UI chính + event handler + gọi controller/service | Có, nếu muốn UI gọn hơn |
| `lib/controllers/` | `admin_controller.dart`, `reading_controller.dart`, `story_detail_controller.dart` | Logic/state cho màn hình | Chủ yếu ổn, chỉ cần giữ thuần logic |
| `lib/services/` | `firestore_service.dart`, `auth_service.dart`, `coin_service.dart` | Truy cập Firebase/auth/coin | Không cần UI |
| `lib/widgets/` | `truyen_card.dart`, `chuong_list_tile.dart` | Widget tái sử dụng | Ổn, chỉ nên giữ presentation |