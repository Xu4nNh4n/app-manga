# Nâng cấp Tìm kiếm Nâng cao (Advanced Search)

## Mô tả

Thay thế hoàn toàn `search_screen.dart` hiện tại bằng phiên bản mới với:
1. **Empty state** — không hiển thị gì khi chưa gõ
2. **Live auto-suggest** — dropdown gợi ý real-time theo từ khóa
3. **Advanced filter panel** — mở rộng/thu gọn, multi-select thể loại
4. **Combined filtering** — keyword AND (genre OR genre)

> [!NOTE]
> Chỉ cần sửa **1 file** (`search_screen.dart`). Không cần thêm file mới hay thay đổi model/service.

---

## Thiết kế UI

```
┌─────────────────────────────────────┐
│  ← Tìm Kiếm                        │  ← AppBar
├─────────────────────────────────────┤
│  🔍 [Tìm kiếm truyện...    ][X] ⚙️ │  ← Search bar + nút Nâng cao
├─────────────────────────────────────┤
│  ▼ PANEL NÂNG CAO (animated)        │  ← AnimatedContainer (ẩn/hiện)
│  ┌──────────────────────────────┐   │
│  │ Tiên hiệp  Kiếm hiệp  Drama │   │  ← Wrap of toggle chips
│  │ Ngôn tình  Hành động  Hài   │   │     (multi-select)
│  │ Kinh dị    Phiêu lưu  ...   │   │
│  ├──────────────────────────────┤   │
│  │  [Xóa bộ lọc]    [Áp dụng] │   │  ← Action buttons
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│  (NẾU chưa gõ gì → Empty state)    │
│                                     │
│  🔎 Nhập từ khóa để tìm truyện     │
│                                     │
├─────────────────────────────────────┤
│  (NẾU đang gõ → Auto-suggest list) │
│  ┌──────────────────────────────┐   │
│  │ 📖 Phàm Nhân Tu Tiên        │   │  ← Suggestion items
│  │    Vong Ngữ • Tiên hiệp     │   │     (compact cards)
│  │ 📖 Phàm Nhân Tu Ma           │   │
│  └──────────────────────────────┘   │
├─────────────────────────────────────┤
│  (NẾU không khớp → No results)     │
│  🔍✗ Không tìm thấy truyện nào     │
└─────────────────────────────────────┘
```

---

## State Management

| State | Kiểu | Mô tả |
|-------|------|--------|
| `_searchController` | `TextEditingController` | Text search input |
| `_isAdvancedOpen` | `bool` | Panel nâng cao đang mở? |
| `_selectedGenres` | `Set<String>` | Các thể loại đã chọn (multi-select) |
| `_suggestions` | `List<Story>` | Kết quả gợi ý real-time |
| `_hasSearched` | `bool` | Đã bắt đầu gõ chưa? (để phân biệt empty state vs no results) |

---

## Logic Lọc

```dart
void _performSearch(String query) {
  if (query.trim().isEmpty && _selectedGenres.isEmpty) {
    // Empty state → không hiển thị gì
    _suggestions = [];
    _hasSearched = false;
    return;
  }
  
  _hasSearched = true;
  _suggestions = sampleStories.where((story) {
    // 1. Lọc theo keyword (title hoặc author)
    final matchesQuery = query.trim().isEmpty ||
        story.title.toLowerCase().contains(query.toLowerCase()) ||
        story.author.toLowerCase().contains(query.toLowerCase());
        
    // 2. Lọc theo thể loại (OR giữa các genre đã chọn)
    final matchesGenre = _selectedGenres.isEmpty ||
        story.genres.any((g) => _selectedGenres.contains(g));
        
    return matchesQuery && matchesGenre;
  }).toList();
}
```

---

## Proposed Changes

### [MODIFY] [search_screen.dart](file:///d:/Code/code/Android/webdoctruyen/lib/screens/search_screen.dart)

Rewrite toàn bộ với:

1. **Search bar Row**: `TextField` + nút filter icon (badge hiển thị số genre đang chọn)
2. **Advanced panel**: `AnimatedCrossFade` hoặc `AnimatedContainer` với `Wrap` chứa các `FilterChip`
   - Mở rộng danh sách thể loại: thêm `Drama`, `Hài hước`, `Kinh dị`, `Phiêu lưu`, `Đời thường`
   - Nút "Xóa bộ lọc" + "Áp dụng"
3. **Content area**: 3 trạng thái:
   - Empty state (chưa gõ, chưa lọc)
   - Suggestion list (đang gõ / đã lọc)
   - No results
4. **Suggestion items**: dạng compact card (ảnh bìa nhỏ + tên + tác giả + genres)

---

## Verification Plan

```bash
flutter analyze
```

Test thủ công:
1. Mở tìm kiếm → empty state (trống, không hiện danh sách)
2. Gõ "Phàm" → auto-suggest hiện "Phàm Nhân Tu Tiên"
3. Xóa text → trở về empty state
4. Bấm nút Nâng cao → panel mở ra
5. Chọn "Tiên hiệp" → lọc (nếu không gõ gì: hiện tất cả truyện Tiên hiệp)
6. Gõ "Kiếm" + chọn "Tiên hiệp" → không khớp (Kiếm Khách thuộc Kiếm hiệp)
7. Chọn thêm "Kiếm hiệp" → hiện "Kiếm Khách Giang Hồ"
8. Bấm "Xóa bộ lọc" → reset genres
9. Bấm "Áp dụng" → đóng panel
