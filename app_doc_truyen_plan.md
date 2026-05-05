# 📖 KẾ HOẠCH XÂY DỰNG APP ĐỌC TRUYỆN

> **Mục tiêu**: Xây dựng ứng dụng đọc truyện bằng Flutter, hỗ trợ đọc offline, giao diện đẹp, dễ sử dụng.

---

## 1. TỔNG QUAN CÁC MÀN HÌNH

### 🗺️ Sơ đồ navigation

```
Splash Screen (2s)
    │
    ▼
Trang Đăng Nhập / Đăng Ký (tuỳ chọn)
    │
    ▼
┌─────────────── Bottom Navigation Bar ───────────────┐
│                                                      │
│  🏠 Trang Chủ    📚 Thư Viện    👤 Cá Nhân          │
│                                                      │
└──────────────────────────────────────────────────────┘
    │                   │               │
    ▼                   ▼               ▼
Chi Tiết Truyện    DS Yêu Thích     Cài Đặt
    │                                   │
    ▼                              Đổi Theme/Font
DS Chương
    │
    ▼
Màn Hình Đọc Truyện ← (Quan trọng nhất!)
```

---

## 2. CHI TIẾT TỪNG MÀN HÌNH

---

### 📱 Màn hình 1: Splash Screen
- **Loại Widget**: `StatefulWidget` (có animation)
- **Mô tả**: Màn hình chào mừng, hiển thị logo app 2-3 giây rồi tự chuyển sang trang chủ
- **Thành phần**:
  - [ ] Logo app (Image)
  - [ ] Tên app (Text)
  - [ ] Animation fade-in hoặc scale
  - [ ] Auto navigate sau 2s (dùng `Future.delayed`)

---

### 🏠 Màn hình 2: Trang Chủ (Home)
- **Loại Widget**: `StatelessWidget` (hoặc Stateful nếu có tìm kiếm)
- **Mô tả**: Hiển thị danh sách truyện, truyện hot, truyện mới cập nhật
- **Thành phần**:
  - [ ] **AppBar**: Tên app + icon tìm kiếm
  - [ ] **Banner/Carousel**: Truyện nổi bật (slide ngang)
  - [ ] **Section "Truyện Hot"**: Danh sách ngang (ListView horizontal)
  - [ ] **Section "Mới Cập Nhật"**: Danh sách dọc (ListView vertical)
  - [ ] **Mỗi item truyện gồm**: Ảnh bìa, Tên truyện, Tác giả, Số chương, Rating
- **Widget cần dùng**:
  - `ListView`, `GridView`
  - `Card`, `Container`, `ClipRRect` (bo tròn ảnh)
  - `PageView` (cho banner carousel)

---

### 🔍 Màn hình 3: Tìm Kiếm
- **Loại Widget**: `StatefulWidget`
- **Mô tả**: Tìm truyện theo tên, tác giả, thể loại
- **Thành phần**:
  - [ ] **TextField**: Ô nhập từ khóa tìm kiếm
  - [ ] **Chip/Filter**: Lọc theo thể loại (Tiên hiệp, Kiếm hiệp, Ngôn tình, Huyền huyễn...)
  - [ ] **Kết quả tìm kiếm**: Danh sách truyện phù hợp
  - [ ] **Lịch sử tìm kiếm**: Hiển thị các từ khóa đã tìm
- **Widget cần dùng**:
  - `TextField`, `SearchBar`
  - `Chip`, `FilterChip`, `Wrap`
  - `ListView`

---

### 📋 Màn hình 4: Chi Tiết Truyện
- **Loại Widget**: `StatefulWidget` (nút yêu thích toggle)
- **Mô tả**: Hiển thị thông tin đầy đủ của 1 truyện
- **Thành phần**:
  - [ ] **Ảnh bìa lớn** (có thể dùng `SliverAppBar` cho đẹp)
  - [ ] **Tên truyện** (Text, fontSize lớn, bold)
  - [ ] **Tác giả** (Text)
  - [ ] **Thể loại** (Chip tags: "Tiên hiệp", "Hành động"...)
  - [ ] **Trạng thái**: Đang ra / Hoàn thành
  - [ ] **Số chương**: Ví dụ "1200 chương"
  - [ ] **Rating**: Sao đánh giá (⭐⭐⭐⭐⭐)
  - [ ] **Nút "Đọc ngay"** (ElevatedButton → đi đến chương 1)
  - [ ] **Nút "Thêm vào thư viện"** (IconButton trái tim ❤️)
  - [ ] **Mô tả/Tóm tắt truyện** (Text dài, có nút "Xem thêm")
  - [ ] **Danh sách chương** (ListView, bấm vào → đọc chương)
- **Widget cần dùng**:
  - `CustomScrollView`, `SliverAppBar` (giống bài 5 chương 3 của bạn!)
  - `Chip`, `Row`, `Column`
  - `ExpansionTile` hoặc `ReadMoreText`

---

### 📄 Màn hình 5: Đọc Truyện (⭐ QUAN TRỌNG NHẤT)
- **Loại Widget**: `StatefulWidget`
- **Mô tả**: Màn hình đọc nội dung chương truyện
- **Thành phần**:
  - [ ] **AppBar**: Tên chương + nút quay lại
  - [ ] **Nội dung chương**: Text dài, scroll được
  - [ ] **Thanh điều khiển dưới đáy** (Bottom Bar):
    - [ ] Nút "Chương trước" (←)
    - [ ] Nút "Chương sau" (→)
    - [ ] Nút "Danh sách chương"
  - [ ] **Nút cài đặt đọc** (floating hoặc trong drawer):
    - [ ] Đổi cỡ chữ (nhỏ / vừa / lớn)
    - [ ] Đổi font chữ
    - [ ] Đổi màu nền (trắng / vàng nhạt / tối)
    - [ ] Chế độ tối (dark mode)
    - [ ] Thanh kéo brightness
  - [ ] **Thanh tiến trình** (đọc đến đâu rồi)
  - [ ] **Đánh dấu trang** (bookmark)
  - [ ] **Auto scroll** (tự cuộn, tuỳ chọn tốc độ)
- **Widget cần dùng**:
  - `SingleChildScrollView` hoặc `ListView`
  - `Slider` (đổi cỡ chữ, brightness)
  - `BottomSheet` hoặc `Drawer` (cài đặt đọc)
  - `SharedPreferences` (lưu cài đặt đọc)
- **Biến state cần có**:
  ```dart
  double _fontSize = 18.0;        // Cỡ chữ
  Color _backgroundColor;         // Màu nền
  Color _textColor;               // Màu chữ
  bool _isDarkMode = false;       // Chế độ tối
  int _currentChapter = 1;        // Chương hiện tại
  double _scrollPosition = 0.0;   // Vị trí đọc
  ```

---

### 📚 Màn hình 6: Thư Viện (Library)
- **Loại Widget**: `StatefulWidget`
- **Mô tả**: Truyện đã lưu / yêu thích / đang đọc
- **Thành phần**:
  - [ ] **Tab Bar**: "Đang đọc" | "Yêu thích" | "Đã đọc xong"
  - [ ] **Danh sách truyện**: Mỗi item có ảnh bìa + tên + chương đọc gần nhất
  - [ ] **Swipe để xóa**: Vuốt để xóa khỏi thư viện
  - [ ] **Sắp xếp**: Theo tên / thời gian đọc / mới cập nhật
- **Widget cần dùng**:
  - `TabBar`, `TabBarView`
  - `Dismissible` (vuốt xóa)
  - `GridView` hoặc `ListView`

---

### 👤 Màn hình 7: Trang Cá Nhân (Profile)
- **Loại Widget**: `StatelessWidget`
- **Mô tả**: Thông tin người dùng, thống kê, cài đặt
- **Thành phần**:
  - [ ] **Avatar + Tên người dùng**
  - [ ] **Thống kê**: Số truyện đã đọc, số giờ đọc, streak
  - [ ] **Menu cài đặt**:
    - [ ] Giao diện (theme sáng/tối)
    - [ ] Cỡ chữ mặc định
    - [ ] Thông báo chương mới
    - [ ] Xóa cache/dữ liệu
    - [ ] Về ứng dụng (version, credits)
  - [ ] **Nút đăng xuất** (nếu có đăng nhập)
- **Widget cần dùng**:
  - `ListTile`, `SwitchListTile`
  - `CircleAvatar`

---

### 🔐 Màn hình 8: Đăng Nhập / Đăng Ký (Tuỳ chọn)
- **Loại Widget**: `StatefulWidget`
- **Mô tả**: Form đăng nhập/đăng ký tài khoản
- **Thành phần**:
  - [ ] **TextField**: Email, Mật khẩu
  - [ ] **Nút đăng nhập** (ElevatedButton)
  - [ ] **Đăng nhập với Google/Facebook** (tuỳ chọn)
  - [ ] **Link "Quên mật khẩu"**
  - [ ] **Link "Đăng ký tài khoản mới"**

---

## 3. CẤU TRÚC THƯ MỤC ĐỀ XUẤT

```
lib/
├── main.dart                          # Entry point
│
├── models/                            # Dữ liệu
│   ├── truyen.dart                    # Class Truyen (tên, tác giả, ảnh...)
│   ├── chuong.dart                    # Class Chuong (số chương, nội dung)
│   └── user.dart                      # Class User (thông tin người dùng)
│
├── screens/                           # Các màn hình
│   ├── splash_screen.dart
│   ├── home_screen.dart
│   ├── search_screen.dart
│   ├── truyen_detail_screen.dart
│   ├── doc_truyen_screen.dart         # ⭐ Màn hình đọc
│   ├── thu_vien_screen.dart
│   ├── profile_screen.dart
│   └── login_screen.dart
│
├── widgets/                           # Widget tái sử dụng
│   ├── truyen_card.dart               # Card hiển thị 1 truyện
│   ├── chuong_list_tile.dart          # 1 dòng chương trong danh sách
│   ├── reading_settings_sheet.dart    # Bottom sheet cài đặt đọc
│   └── search_bar_custom.dart         # Thanh tìm kiếm
│
├── services/                          # Logic xử lý
│   ├── truyen_service.dart            # Load/lưu truyện
│   ├── storage_service.dart           # Lưu local (SharedPreferences)
│   └── api_service.dart               # Gọi API (nếu có server)
│
├── utils/                             # Tiện ích
│   ├── constants.dart                 # Màu sắc, font size, strings...
│   └── themes.dart                    # Theme sáng/tối
│
└── data/                              # Dữ liệu mẫu (test)
    └── sample_truyen.dart             # Danh sách truyện mẫu
```

---

## 4. DỮ LIỆU TRUYỆN (MODEL)

### Class Truyện
```dart
class Truyen {
  final String id;
  final String tenTruyen;
  final String tacGia;
  final String anhBia;          // URL hoặc asset path
  final String moTa;
  final List<String> theLoai;   // ["Tiên hiệp", "Hành động"]
  final int soChuong;
  final double rating;          // 4.5
  final String trangThai;       // "Đang ra" hoặc "Hoàn thành"
  final DateTime ngayCapNhat;
}
```

### Class Chương
```dart
class Chuong {
  final int soChuong;
  final String tenChuong;       // "Chương 1: Khởi đầu"
  final String noiDung;         // Nội dung text dài
  final DateTime ngayDang;
}
```

---

## 5. NGUỒN DỮ LIỆU TRUYỆN

Có nhiều cách lấy nội dung truyện:

| Cách | Mô tả | Độ khó |
|------|--------|--------|
| **📁 Local (assets)** | Lưu .txt hoặc .json trong thư mục assets | ⭐ Dễ |
| **📦 SQLite** | Lưu truyện vào database local | ⭐⭐ Trung bình |
| **🌐 API** | Gọi API từ server để lấy truyện | ⭐⭐⭐ Khó |
| **🔥 Firebase** | Dùng Firestore lưu trữ truyện | ⭐⭐ Trung bình |

### Gợi ý cho người mới: Bắt đầu với **Local (assets)**
```
assets/
├── truyen/
│   ├── truyen_1/
│   │   ├── info.json          # Thông tin truyện
│   │   ├── chuong_1.txt       # Nội dung chương 1
│   │   ├── chuong_2.txt
│   │   └── cover.jpg          # Ảnh bìa
│   ├── truyen_2/
│   │   ├── info.json
│   │   ├── chuong_1.txt
│   │   └── cover.jpg
```

---

## 6. CÁC PACKAGE HỮU ÍCH

| Package | Công dụng |
|---------|-----------|
| **`shared_preferences`** | Lưu cài đặt đọc (cỡ chữ, theme, chương đọc gần nhất) |
| **`sqflite`** | Database local để lưu truyện offline |
| **`cached_network_image`** | Cache ảnh bìa truyện |
| **`flutter_html`** | Hiển thị nội dung HTML (nếu truyện có format) |
| **`google_fonts`** | Đổi font chữ đọc truyện |
| **`provider`** | Quản lý state (theme, thư viện, bookmark...) |
| **`shimmer`** | Hiệu ứng loading skeleton |
| **`carousel_slider`** | Banner truyện nổi bật trượt ngang |
| **`flutter_local_notifications`** | Thông báo chương mới |
| **`path_provider`** | Lưu file truyện vào bộ nhớ máy |

---

## 7. THỨ TỰ LÀM (ROADMAP)

### 🟢 Giai đoạn 1: Cơ bản (1-2 tuần)
- [ ] Tạo project Flutter mới
- [ ] Thiết kế model Truyen, Chuong
- [ ] Tạo dữ liệu mẫu (3-5 truyện, mỗi truyện 2-3 chương)
- [ ] Làm **Trang Chủ** (danh sách truyện)
- [ ] Làm **Chi Tiết Truyện** (thông tin + danh sách chương)
- [ ] Làm **Màn Hình Đọc** (hiển thị nội dung + chuyển chương)

### 🟡 Giai đoạn 2: Nâng cao (2-3 tuần)
- [ ] Thêm **Bottom Navigation Bar** (Trang chủ, Thư viện, Cá nhân)
- [ ] Làm **Trang Tìm Kiếm** (tìm theo tên, lọc thể loại)
- [ ] Làm **Thư Viện** (yêu thích, đang đọc)
- [ ] Thêm **Cài đặt đọc** (đổi cỡ chữ, màu nền, dark mode)
- [ ] Lưu **vị trí đọc** (SharedPreferences)
- [ ] Lưu **chương đọc gần nhất**

### 🔴 Giai đoạn 3: Hoàn thiện (3-4 tuần)
- [ ] Thêm **Splash Screen** với animation
- [ ] Thêm **Đăng nhập** (Firebase Auth)
- [ ] Chuyển sang **database** (SQLite hoặc Firebase)
- [ ] Thêm **thông báo** chương mới
- [ ] Tối ưu **performance** (lazy loading, cache)
- [ ] Thêm **auto scroll** khi đọc
- [ ] Thêm **bookmark** đánh dấu trang
- [ ] Polish UI/UX cho đẹp

---

## 8. LƯU Ý QUAN TRỌNG

### ⚠️ Về bản quyền
- Không nên lấy truyện từ nguồn không có bản quyền
- Có thể dùng truyện **miễn phí/mở** (public domain) để test
- Hoặc tự viết nội dung mẫu

### 💡 Tips
1. **Bắt đầu nhỏ**: Làm 3 màn hình trước (Home → Detail → Đọc), xong rồi mở rộng
2. **Dữ liệu mẫu trước**: Dùng text cứng, sau đó mới chuyển sang database/API
3. **UI trước, logic sau**: Làm giao diện đẹp trước, sau đó thêm chức năng
4. **Tách widget**: Mỗi card truyện, mỗi list tile chương → tách thành widget riêng

---

## 9. THAM KHẢO GIAO DIỆN

Các app đọc truyện nổi tiếng có thể tham khảo UI:
- **Wattpad** - Giao diện sạch, đơn giản
- **TruyenFull** - Layout kiểu Việt Nam quen thuộc
- **Kindle** - Chế độ đọc chuyên nghiệp
- **Google Play Books** - Material Design chuẩn

---

> 📝 **Ghi chú**: File này là bản kế hoạch ban đầu. Bạn có thể chỉnh sửa, thêm bớt tính năng tùy theo nhu cầu. Khi sẵn sàng bắt tay vào code, hãy bắt đầu từ **Giai đoạn 1**!
