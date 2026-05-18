# Tổng Quan Source Code WebDocTruyen

**Ngày tạo:** 18/05/2026  
**Project:** `webdoctruyen`  
**Loại app:** Flutter app đọc truyện/manga, có đăng nhập, quản lý truyện, đọc chương miễn phí/trả xu và dữ liệu Firebase.

---

## 1. App Này Làm Gì?

Source này là một ứng dụng đọc truyện tranh/truyện chữ kiểu MangaHay. Người dùng có thể:

- Xem danh sách truyện ở trang chủ.
- Tìm kiếm truyện theo tên, tác giả và thể loại.
- Lọc truyện theo thể loại.
- Xem chi tiết truyện và danh sách chương.
- Đọc chương truyện bằng màn đọc riêng.
- Đăng nhập/đăng ký tài khoản.
- Dùng xu để mở khóa chương trả phí.
- Nạp xu demo trong màn cá nhân.
- Admin có thể thêm/sửa/xóa truyện, chương và thể loại.

Backend đang dùng Firebase:

- `Firebase Auth`: đăng nhập, đăng ký, trạng thái tài khoản.
- `Cloud Firestore`: lưu truyện, chương, thể loại, user, xu, chương đã mở khóa.
- `Firebase Storage`: có service sẵn để upload ảnh bìa/trang truyện.

---

## 2. Cấu Trúc Tổng Quát

```text
lib/
  main.dart
  controllers/
  processors/
  models/
  services/
  screens/
  widgets/
  utils/
assets/
docs/
test/
```

Ý nghĩa từng tầng:

| Thư mục | Nhiệm vụ |
|---|---|
| `main.dart` | Điểm chạy app, init Firebase, set theme và mở `SplashScreen`. |
| `controllers/` | Điều phối logic cho màn hình: load data, gọi service, xử lý hành động người dùng. |
| `widgets/` | Component UI tái sử dụng. |
| `assets/` | Ảnh bìa, ảnh manga demo. |
| `docs/` | Tài liệu dự án. |
| `test/` | Test Flutter. |

---

## 3. Luồng Chạy App

```text
main.dart
  -> Firebase.initializeApp()
  -> TruyenHayApp
  -> SplashScreen
  -> SplashController.init()
  -> Home / Library / Profile
```

Giải thích:

- `main.dart` khởi tạo Firebase trước khi app chạy.
- `SplashScreen` hiển thị logo, đợi init tài khoản xong rồi vào app.
- `MainNavigation` giữ bottom navigation gồm Trang chủ, Thư viện, Cá nhân.
- Mỗi màn hình chính gọi controller riêng để xử lý data.

---

## 4. Quy Ước Tên Trong Source

| Tên | Ý nghĩa |
|---|---|
| `truyen` / `Story` | Một truyện. |
| `category` / `StoryCategory` | Thể loại truyện. |
| `controller` | Lớp điều khiển logic cho màn hình. |
| `service` | Lớp nói chuyện trực tiếp với Firebase/backend. |
| `processor` | Lớp xử lý dữ liệu thuần như lọc, sort, format. |
| `screen` | Màn hình UI đầy đủ. |
| `widget` | Component UI nhỏ có thể tái sử dụng. |

Quy tắc dễ nhớ:

- Muốn sửa giao diện: vào `screens/` hoặc `widgets/`.
- Muốn sửa logic màn hình: vào `controllers/`.
- Muốn sửa cách lọc/search/sort: vào `processors/`.
- Muốn sửa cấu trúc dữ liệu: vào `models/`.
- Muốn sửa màu, chữ, spacing: vào `utils/`.

---

## 5. Thư Mục `controllers/`

Controller là lớp trung gian giữa UI và service. UI gọi controller, controller gọi service/processor.

| File | Làm gì? | Được dùng bởi |
|---|---|---|
| `admin_controller.dart` | Xử lý thêm/sửa/xóa truyện, chương, thể loại. Parse form admin thành `Story`/`Chapter`. | `admin_screen.dart` |
| `auth_controller.dart` | Đăng nhập, đăng ký thông qua `AuthService`. | `login_screen.dart`, `register_screen.dart` |
| `story_search_controller.dart` | Load truyện/thể loại, search theo query, filter theo genre, đóng/mở panel nâng cao. | `search_screen.dart` |
| `chapter_access.dart` | Enum quyết định chương được đọc, cần login hay cần unlock. | `reading_controller.dart`, `story_detail_controller.dart` |
| `home_controller.dart` | Stream danh sách truyện trang chủ, format thời gian cập nhật. | `home_screen.dart` |
| `profile_controller.dart` | Lấy trạng thái tài khoản, xu, nạp xu, đăng xuất. | `profile_screen.dart` |
| `reading_controller.dart` | Điều khiển màn đọc: chương hiện tại, progress, fit width, màu nền, unlock chương. | `doc_truyen_screen.dart` |
| `splash_controller.dart` | Init auth khi splash chạy. Có xử lý nhẹ để test không vỡ nếu Firebase chưa init. | `splash_screen.dart` |

---

## 6. Thư Mục `processors/`

| File | Làm gì? |
|---|---|
| `story_processor.dart` | Chứa xử lý thuần cho truyện: sort rating, filter genre, search, lấy truyện hot, format lượt xem, format thời gian, parse chuỗi thể loại/trang. |

Khi nào thêm vào `processors/`?

- Khi logic không cần `BuildContext`.
- Không cần gọi Firebase.
- Có thể test độc lập.
- Ví dụ: sắp xếp, lọc, chuyển đổi chuỗi, format số/ngày.

---


| File | Dữ liệu |
|---|---|
| `truyen.dart` | Model `Story`: title, author, coverImage, description, genres, chapterCount, rating, status, views, freeChapters, coinPerChapter. |
| `chuong.dart` | Model `Chapter`: chapterNumber, title, pages, publishDate. |
| `category.dart` | Model `StoryCategory`: id, name. |
| `account.dart` | Model `AppUser`: uid, email, displayName, role, coins, unlockedChapters. |

Các model có nhiệm vụ:

- Đọc dữ liệu từ Firestore.
- Chuyển dữ liệu thành map để lưu lên Firestore.
- Giữ cấu trúc dữ liệu thống nhất toàn app.

---

## 8. Thư Mục `services/`

Service là nơi duy nhất nên nói chuyện trực tiếp với Firebase/backend.

| File | Làm gì? |
|---|---|
| `auth_service.dart` | Đăng ký, đăng nhập, đăng xuất, cache user hiện tại, kiểm tra quyền đọc chương. |
| `coin_service.dart` | Lấy xu, nạp xu demo, mở khóa chương bằng xu, kiểm tra chương đã unlock chưa. |
| `firestore_service.dart` | CRUD truyện, chương, thể loại, search cơ bản, lấy hot/top views. |
| `storage_service.dart` | Upload ảnh bìa và trang truyện lên Firebase Storage, xóa file. |

Quy tắc:

- `screens/` không nên gọi service trực tiếp.
- `controllers/` gọi service.
- Nếu đổi cấu trúc Firestore collection, sửa chủ yếu trong `services/` và `models/`.

---

## 9. Thư Mục `screens/`

| File | Màn hình | Controller chính |
|---|---|---|
| `splash_screen.dart` | Màn mở app/logo. | `SplashController` |
| `main_navigation.dart` | Bottom navigation chính. | Không cần controller riêng. |
| `home_screen.dart` | Trang chủ, banner, truyện mới, truyện đề xuất. | `HomeController` |
| `search_screen.dart` | Tìm kiếm nâng cao. | `StorySearchController` |
| `search_screen.dart` | Tìm kiếm nâng cao và lọc theo thể loại. | `StorySearchController` |
| `truyen_detail_screen.dart` | Chi tiết truyện, danh sách chương, unlock. | `StoryDetailController` |
| `doc_truyen_screen.dart` | Màn đọc truyện/manga reader. | `ReadingController` |
| `profile_screen.dart` | Cá nhân, ví xu, admin entry, logout. | `ProfileController` |
| `login_screen.dart` | Đăng nhập. | `AuthController` |
| `register_screen.dart` | Đăng ký. | `AuthController` |
| `admin_screen.dart` | Quản trị truyện/chương/thể loại. | `AdminController` |
| `thu_vien_screen.dart` | Thư viện, hiện đang là empty state/chờ phát triển. | Chưa cần controller |

---

## 10. Thư Mục `widgets/`

| File | Làm gì? |
|---|---|
| `truyen_card.dart` | Card hiển thị truyện ngang/dọc. |
| `chuong_list_tile.dart` | Item danh sách chương, có trạng thái khóa/mở. |
| `login_wall_overlay.dart` | Dialog yêu cầu đăng nhập/đăng ký khi cần đọc nội dung khóa. |
| `reading_settings_sheet.dart` | Bottom sheet cài đặt đọc truyện: màu nền, fit width/original. |

Khi UI bị lặp lại ở nhiều màn hình, nên tách vào `widgets/`.

---

## 11. Thư Mục `utils/`

| File | Làm gì? |
|---|---|
| `constants.dart` | Màu, spacing, radius, font size, chuỗi text dùng chung. |
| `themes.dart` | Theme sáng/tối của app. |

Nếu muốn đổi màu chủ đạo, font size, text chung như tên app, vào đây trước.

---

## 12. Các Luồng Xử Lý Chính

### 12.1. Luồng đăng nhập

```text
LoginScreen
  -> AuthController.login()
  -> AuthService.login()
  -> FirebaseAuth.signInWithEmailAndPassword()
  -> load user từ Firestore
  -> MainNavigation
```

### 12.2. Luồng đăng ký

```text
RegisterScreen
  -> AuthController.register()
  -> AuthService.register()
  -> FirebaseAuth.createUserWithEmailAndPassword()
  -> tạo document users/{uid}
  -> tặng 100 xu
  -> MainNavigation
```

### 12.3. Luồng xem trang chủ

```text
HomeScreen
  -> HomeController.watchStories()
  -> FirestoreService.getStories()
  -> collection stories
  -> render banner/grid/list
```

### 12.4. Luồng tìm kiếm

```text
SearchScreen
  -> StorySearchController.loadInitialData()
  -> FirestoreService.getStoriesOnce()
  -> FirestoreService.getCategoriesOnce()
  -> StoryProcessor.searchStories()
  -> render kết quả
```

### 12.5. Luồng lọc theo thể loại

```text
SearchScreen / HomeScreen / các màn khác
  -> StoryProcessor.filterByGenres()
  -> StoryProcessor.searchStories()
  -> render danh sách truyện theo thể loại
```

### 12.6. Luồng mở chi tiết truyện

```text
StoryDetailScreen
  -> StoryDetailController.loadChapters()
  -> FirestoreService.getChaptersOnce(storyId)
  -> render thông tin truyện + danh sách chương
```

### 12.7. Luồng đọc chương

```text
StoryDetailScreen hoặc ReadingScreen
  -> kiểm tra chương miễn phí
  -> nếu chưa login: show LoginWall
  -> nếu đã login nhưng chưa unlock: show unlock dialog
  -> nếu được đọc: mở ReadingScreen
```

### 12.8. Luồng mở khóa chương bằng xu

```text
StoryDetailController / ReadingController
  -> CoinService.unlockChapter()
  -> kiểm tra user
  -> kiểm tra đủ xu
  -> trừ xu
  -> lưu unlockedChapters.{storyId_chapterId} = true
  -> AuthService.refreshUserData()
  -> cho đọc chương
```

### 12.9. Luồng admin thêm truyện

```text
AdminScreen
  -> AdminController.addStory()
  -> AdminStoryFormData.fromText()
  -> StoryProcessor.parseCommaSeparated()
  -> FirestoreService.addStory()
  -> collection stories
```

### 12.10. Luồng admin thêm chương

```text
AdminScreen
  -> AdminController.addChapter()
  -> AdminChapterFormData.fromText()
  -> StoryProcessor.parseLines()
  -> FirestoreService.addChapter()
  -> stories/{storyId}/chapters
  -> tăng chapterCount
```

---

## 13. Firestore Collection Đang Dùng

```text
stories
  {storyId}
    title
    author
    coverImage
    description
    genres
    chapterCount
    rating
    status
    views
    isHot
    freeChapters
    coinPerChapter
    createdAt
    updatedAt

    chapters
      {chapterId}
        chapterNumber
        title
        pages
        publishDate

categories
  {categoryId}
    name

users
  {uid}
    email
    displayName
    role
    coins
    unlockedChapters
    createdAt
```

---

## 14. Muốn Sửa Gì Thì Vào Đâu?

| Muốn sửa | Vào file/thư mục |
|---|---|
| Đổi màu app, spacing, text chung | `lib/utils/constants.dart` |
| Đổi theme sáng/tối | `lib/utils/themes.dart` |
| Sửa trang chủ | `lib/screens/home_screen.dart`, `lib/controllers/home_controller.dart` |
| Sửa tìm kiếm | `lib/screens/search_screen.dart`, `lib/controllers/story_search_controller.dart`, `lib/processors/story_processor.dart` |
| Sửa lọc theo thể loại/hot stories | `lib/screens/search_screen.dart`, `lib/controllers/story_search_controller.dart`, `lib/processors/story_processor.dart` |
| Sửa chi tiết truyện | `lib/screens/truyen_detail_screen.dart`, `lib/controllers/story_detail_controller.dart` |
| Sửa màn đọc truyện | `lib/screens/doc_truyen_screen.dart`, `lib/controllers/reading_controller.dart` |
| Sửa đăng nhập/đăng ký | `lib/screens/login_screen.dart`, `lib/screens/register_screen.dart`, `lib/controllers/auth_controller.dart`, `lib/services/auth_service.dart` |
| Sửa nạp xu/mở khóa chương | `lib/controllers/profile_controller.dart`, `lib/controllers/reading_controller.dart`, `lib/controllers/story_detail_controller.dart`, `lib/services/coin_service.dart` |
| Sửa admin CRUD | `lib/screens/admin_screen.dart`, `lib/controllers/admin_controller.dart`, `lib/services/firestore_service.dart` |
| Sửa model dữ liệu truyện | `lib/models/truyen.dart` |
| Sửa model dữ liệu chương | `lib/models/chuong.dart` |
| Sửa Firebase queries | `lib/services/firestore_service.dart` |
| Sửa upload ảnh | `lib/services/storage_service.dart` |

---

## 15. Ghi Chú Cho Lần Phát Triển Tiếp Theo

Nên giữ nguyên hướng tách này:

```text
Screen -> Controller -> Service -> Firebase
Screen -> Controller -> Processor
```

Không nên để `screens/` gọi Firebase trực tiếp. Nếu một màn hình bắt đầu dài và khó đọc:

1. Tách state/logic sang `controllers/`.
2. Tách xử lý dữ liệu thuần sang `processors/`.
3. Tách UI nhỏ lặp lại sang `widgets/`.
4. Chỉ để `screens/` làm nhiệm vụ dựng giao diện và gọi hàm controller.

Như vậy sau này đọc source sẽ dễ hơn: nhìn tên file là biết phần đó chịu trách nhiệm gì.

---

## 16. Những Phần Nên Bổ Sung Để Dễ Đọc Source Hơn

Phần này giải thích sâu hơn cách source đang chạy và vì sao đã tách thành `screens`, `controllers`, `services`, `processors`, `models`.

### 16.1. Data Flow Tổng Quát

Luồng dữ liệu nên hiểu theo hướng này:

```text
Screen
  -> Controller
  -> Service
  -> Firebase
  -> Model
  -> Controller cập nhật state
  -> Screen render UI
```

Ví dụ với trang chi tiết truyện:

```text
StoryDetailScreen
  -> StoryDetailController.loadChapters()
  -> FirestoreService.getChaptersOnce(storyId)
  -> Firebase Firestore: stories/{storyId}/chapters
  -> Chapter.fromFirestore()
  -> controller.chapters
  -> StoryDetailScreen render danh sách chương
```

Ý chính:

- `Screen` nhận thao tác người dùng và hiển thị UI.
- `Controller` quyết định cần load gì, xử lý gì, gọi service nào.
- `Service` nói chuyện trực tiếp với Firebase.
- `Model` chuyển dữ liệu Firebase thành object Dart.
- UI không nên tự parse dữ liệu Firebase.

### 16.2. State Management Đang Dùng Gì?

Hiện app chưa dùng Provider, Riverpod, BLoC hay Redux.

State hiện tại đang dùng:

| Cách quản lý state | Đang dùng ở đâu | Mục đích |
|---|---|---|
| `setState()` | Nhiều screen như `HomeScreen`, `ReadingScreen`, `ProfileScreen` | Cập nhật UI cục bộ trong một màn hình. |
| `StreamBuilder` | `AdminScreen`, `ProfileScreen` | Nghe dữ liệu realtime từ Firestore hoặc stream xu. |
| `ChangeNotifier` controller | `StorySearchController`, `StoryDetailController` | Controller tự giữ state và báo UI rebuild. |
| Controller thường | `HomeController`, `AuthController`, `ProfileController`, `SplashController` | Bọc logic/service nhưng không cần notify state phức tạp. |
| `AnimationController` | Splash, Search panel, Reader controls | Điều khiển animation. |
| `ScrollController`, `PageController`, `TabController` | Reader, Home carousel, Library | Điều khiển scroll/page/tab. |

Kết luận: app đang theo kiểu state đơn giản, dùng `setState` + controller riêng. Nếu app lớn hơn, có thể nâng cấp lên Provider hoặc Riverpod mà không cần phá nhiều logic vì controller đã được tách sẵn.

### 16.3. Dependency Map Theo Từng Màn Hình

| Màn hình | Dependency chính |
|---|---|
| `SplashScreen` | `SplashController` -> `AuthService` |
| `MainNavigation` | `HomeScreen`, `LibraryScreen`, `ProfileScreen` |
| `HomeScreen` | `HomeController` -> `FirestoreService` -> `Story` |
| `SearchScreen` | `StorySearchController` -> `FirestoreService` -> `Story`, `StoryCategory`; dùng `StoryProcessor` để search/filter |
| `SearchScreen` | `StorySearchController` -> `FirestoreService` -> `Story`, `StoryCategory`; dùng `StoryProcessor` để search/lọc |
| `StoryDetailScreen` | `StoryDetailController` -> `FirestoreService`, `AuthService`, `CoinService` -> `Story`, `Chapter` |
| `ReadingScreen` | `ReadingController` -> `AuthService`, `CoinService` -> `Story`, `Chapter` |
| `ProfileScreen` | `ProfileController` -> `AuthService`, `CoinService` |
| `LoginScreen` | `AuthController` -> `AuthService` |
| `RegisterScreen` | `AuthController` -> `AuthService` |
| `AdminScreen` | `AdminController` -> `FirestoreService` -> `Story`, `Chapter`, `StoryCategory`; dùng `StoryProcessor` để parse form |
| `LibraryScreen` | Hiện chủ yếu render empty state, chưa có controller riêng |

### 16.4. Quy Tắc Thư Mục Nào Không Nên Làm Gì

| Thư mục | Nên làm | Không nên làm |
|---|---|---|
| `screens/` | Render UI, nhận input người dùng, gọi controller | Không gọi Firebase trực tiếp, không parse data phức tạp, không nhét business logic dài |
| `controllers/` | Giữ state màn hình, gọi service/processor, quyết định luồng xử lý | Không render UI widget lớn, không chứa query Firebase chi tiết nếu service đã có |
| `services/` | Gọi Firebase/Auth/Storage, xử lý backend API | Không dùng `BuildContext`, không show dialog/snackbar, không render UI |
| `processors/` | Hàm thuần: filter, sort, format, parse string | Không đụng Firebase, không dùng `BuildContext`, không gọi service |
| `models/` | Định nghĩa dữ liệu, `fromFirestore`, `toFirestore` | Không gọi service, không chứa UI |
| `widgets/` | Component UI tái sử dụng | Không gọi Firebase trực tiếp, không giữ logic nghiệp vụ lớn |
| `utils/` | Constant, theme, style dùng chung | Không chứa logic màn hình hoặc Firebase |

Nếu thấy một file trong `screens/` bắt đầu quá dài, ưu tiên tách theo thứ tự:

```text
logic -> controllers/
data processing -> processors/
UI lặp lại -> widgets/
Firebase query -> services/
```

### 16.5. Lifecycle Và Dispose

Những object cần dọn dẹp để tránh leak:

| Loại | Ví dụ trong app | Cần làm gì |
|---|---|---|
| `AnimationController` | Splash, Search, Reader | Gọi `.dispose()` trong `dispose()`. |
| `ScrollController` | `ReadingScreen` | Remove listener rồi `.dispose()`. |
| `PageController` | `HomeScreen` banner carousel | `.dispose()`. |
| `TabController` | `LibraryScreen` | `.dispose()`. |
| `Timer` | Home auto scroll, Splash navigation timer | `.cancel()` trong `dispose()`. |
| `StreamSubscription` | `HomeScreen` nghe stories | `.cancel()` trong `dispose()`. |
| `TextEditingController` | Login, Register, Search, Admin form | `.dispose()` nếu controller sống cùng screen. |
| `FocusNode` | Search input | `.dispose()`. |
| `ChangeNotifier` controller | Search, Category, StoryDetail | Remove listener và `.dispose()`. |

Quy tắc an toàn:

- Sau `await`, luôn kiểm tra `if (!mounted) return;` trước khi dùng `context`.
- Timer tạo trong screen phải hủy được.
- Listener thêm ở `initState()` thì phải remove ở `dispose()`.
- Stream tự tạo subscription thì phải cancel.

### 16.6. Error Handling

App hiện xử lý lỗi theo hướng nhẹ, ưu tiên không crash UI.

| Tình huống | Hiện đang xử lý ở đâu | Cách xử lý |
|---|---|---|
| Login fail | `AuthService.login()` -> `LoginScreen` | Trả `AuthResult.error`, hiển thị message lỗi trong form. |
| Register fail | `AuthService.register()` -> `RegisterScreen` | Trả `AuthResult.error`, hiển thị message lỗi. |
| Không đủ xu | `CoinService.unlockChapter()` | Trả `CoinResult.error`, screen show snackbar lỗi. |
| Chưa đăng nhập khi đọc chương khóa | `StoryDetailController`, `ReadingController` | Trả action `login`, screen show `LoginWallDialog`. |
| Chương cần mở khóa | `chapter_access.dart` + controller | Trả action `unlock`, screen show dialog mua bằng xu. |
| Data Firestore lỗi khi load chương | `StoryDetailController.loadChapters()` | Catch lỗi, set danh sách chương rỗng, tắt loading. |
| Search/load thể loại lỗi | `StorySearchController` | Catch lỗi, dùng list rỗng. |
| Lỗi upload/delete storage | `StorageService` | Debug print hoặc rethrow tùy hàm. |
| Mất mạng | Firebase throw exception | Một số nơi catch và không crash; nên bổ sung snackbar/retry sau. |

Điểm nên cải thiện sau:

- Thêm UI lỗi rõ ràng: nút “Thử lại”.
- Chuẩn hóa class lỗi chung thay vì chỉ string message.
- Log lỗi có ngữ cảnh: màn nào, action nào, id truyện/chương nào.

### 16.7. Quy Ước Đặt Tên

| Loại file | Quy ước | Ví dụ |
|---|---|---|
| Controller | `xxx_controller.dart` | `home_controller.dart`, `reading_controller.dart` |
| Service | `xxx_service.dart` | `auth_service.dart`, `firestore_service.dart` |
| Processor | `xxx_processor.dart` | `story_processor.dart` |
| Model | Danh từ số ít, theo dữ liệu | `truyen.dart`, `chuong.dart`, `account.dart` |
| Screen | `xxx_screen.dart` | `home_screen.dart`, `search_screen.dart` |
| Widget | Tên component UI | `truyen_card.dart`, `chuong_list_tile.dart` |
| Constant/theme | Tên chức năng dùng chung | `constants.dart`, `themes.dart` |

Quy tắc class:

- Screen class dùng tên rõ nghĩa: `HomeScreen`, `SearchScreen`.
- Controller class dùng hậu tố `Controller`: `HomeController`.
- Service class dùng hậu tố `Service`: `AuthService`.
- Model class dùng danh từ: `Story`, `Chapter`, `AppUser`.
- Enum dùng tên mô tả trạng thái/action: `ChapterAccessAction`.

### 16.8. Luồng Quyền Truy Cập Nội Dung

Quyền đọc chương hiện dựa trên:

- `freeChapters` trong `Story`.
- User đã đăng nhập hay chưa.
- User đã mở khóa chương bằng xu hay chưa.

Luồng quyết định:

```text
Người dùng bấm chương
  -> chapterIndex < story.freeChapters?
      -> Có: cho đọc miễn phí
      -> Không:
          -> user chưa đăng nhập?
              -> Hiện login wall
              -> user đã đăng nhập:
                  -> chương đã unlock?
                      -> Có: cho đọc
                      -> Không: hiện dialog mở khóa bằng xu
```

Các class liên quan:

| File | Vai trò |
|---|---|
| `chapter_access.dart` | Định nghĩa `ChapterAccessAction`: `read`, `login`, `unlock`. |
| `AuthService.canReadChapter()` | Kiểm tra chương miễn phí hoặc đã unlock trong cache user. |
| `CoinService.isChapterUnlocked()` | Kiểm tra Firestore xem chương đã unlock chưa. |
| `CoinService.unlockChapter()` | Trừ xu và lưu trạng thái unlock. |
| `StoryDetailController.getChapterAccess()` | Quyết định khi bấm chương ở màn chi tiết. |
| `ReadingController.accessForChapter()` | Quyết định khi chuyển chương trong màn đọc. |

### 16.9. Kế Hoạch Mở Rộng Tương Lai

Những phần nên làm tiếp để app mạnh hơn:

| Tính năng | Gợi ý nơi xử lý |
|---|---|
| Pagination danh sách truyện | `FirestoreService`, `HomeController`, `StorySearchController` |
| Offline cache | Service riêng hoặc dùng Firestore cache/local database |
| Đồng bộ yêu thích | `ProfileController` hoặc controller/library riêng, collection `users/{uid}/favorites` |
| Download chapter | Service download/cache ảnh, controller cho màn đọc |
| Notification chương mới | Firebase Cloud Messaging + service notification |
| History đọc gần đây | Lưu `lastRead` theo user/story/chapter |
| Continue reading | `HomeScreen` hoặc `LibraryScreen`, lấy từ history |
| Comment/rating truyện | Chưa triển khai; dự kiến collection `stories/{storyId}/comments`, controller chi tiết truyện |
| Admin upload ảnh thật | Kết nối `StorageService` vào `AdminController` |
| Search tốt hơn | Algolia/Meilisearch hoặc index keywords trong Firestore |
| Payment thật | Service thanh toán riêng thay cho nạp xu demo |
| Test controller/processor | Unit test cho `StoryProcessor`, `ReadingController`, `StorySearchController` |

### 16.10. Tại Sao Tách Như Vậy?

Việc tách source hiện tại nhằm giảm cảm giác “vibe code”, tức là code chạy được nhưng khó hiểu, khó sửa, khó biết lỗi nằm đâu.

Lý do tách từng tầng:

| Tầng | Vì sao cần tách? |
|---|---|
| `Screen` | UI nên gọn, chỉ tập trung hiển thị và nhận thao tác. Nếu UI vừa query Firebase vừa xử lý logic thì rất nhanh rối. |
| `Controller` | Gom logic màn hình vào một chỗ. Khi cần hiểu màn này xử lý gì, đọc controller trước sẽ nhanh hơn đọc cả file UI dài. |
| `Processor` | Chứa hàm thuần nên dễ test, dễ sửa. Ví dụ search/filter/sort không phụ thuộc Flutter hay Firebase. |
| `Service` | Cô lập Firebase/backend. Sau này đổi backend hoặc đổi collection chỉ cần sửa service nhiều hơn là sửa toàn UI. |
| `Model` | Giữ cấu trúc dữ liệu thống nhất. Firestore trả map phức tạp, model giúp app dùng object rõ ràng. |
| `Widget` | Tách UI lặp lại để màn hình ngắn hơn và giao diện nhất quán. |

Ví dụ trước khi tách:

```text
SearchScreen
  vừa load Firestore
  vừa giữ danh sách truyện
  vừa filter/search
  vừa render UI
```

Sau khi tách:

```text
SearchScreen
  -> render UI, nhận input

StorySearchController
  -> giữ state search, gọi service, gọi processor

StoryProcessor
  -> filter/search thuần

FirestoreService
  -> lấy stories/categories từ Firebase
```

Kết quả:

- Dễ đọc hơn vì mỗi file có một nhiệm vụ rõ.
- Dễ debug hơn vì biết lỗi UI, logic hay Firebase.
- Dễ test hơn vì processor/controller có thể test riêng.
- Dễ mở rộng hơn vì thêm tính năng không cần sửa quá nhiều nơi.
