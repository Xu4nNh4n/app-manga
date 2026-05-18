import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../controllers/chapter_access.dart';
import '../controllers/reading_controller.dart';
import '../models/truyen.dart';
import '../utils/constants.dart';
import '../widgets/login_wall_overlay.dart';
import '../widgets/reading_settings_sheet.dart';

// === ⭐ MÀN HÌNH ĐỌC TRUYỆN TRANH - MANGA READER ===
class ReadingScreen extends StatefulWidget {
  final Story story;
  final int initialChapterIndex; // Chương bắt đầu đọc

  const ReadingScreen({
    super.key,
    required this.story,
    required this.initialChapterIndex,
  });

  @override
  State<ReadingScreen> createState() => _ReadingScreenState();
}

class _ReadingScreenState extends State<ReadingScreen>
    with TickerProviderStateMixin {
  // === STATE VARIABLES ===
  late final ReadingController _reader;
  final ScrollController _scrollController = ScrollController();

  // Animation controller (ẩn/hiện controls)
  late AnimationController _controlsAnimController;
  late Animation<double> _controlsFadeAnimation;

  @override
  void initState() {
    super.initState();
    _reader = ReadingController(
      story: widget.story,
      initialChapterIndex: widget.initialChapterIndex,
    );

    // Animation cho controls
    _controlsAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 250),
    );
    _controlsFadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _controlsAnimController, curve: Curves.easeInOut),
    );
    _controlsAnimController.forward();

    // Lắng nghe scroll để tính tiến trình đọc + page indicator
    _scrollController.addListener(_updateReadingProgress);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_updateReadingProgress);
    _scrollController.dispose();
    _controlsAnimController.dispose();
    super.dispose();
  }

  // Cập nhật thanh tiến trình + trang hiện tại
  void _updateReadingProgress() {
    _reader.updateReadingProgress(_scrollController);
    setState(() {});
  }

  // Toggle hiện/ẩn thanh điều khiển
  void _toggleControls() {
    setState(() {
      _reader.toggleControls();
      if (_reader.showControls) {
        _controlsAnimController.forward();
      } else {
        _controlsAnimController.reverse();
      }
    });
  }

  // Chuyển chương
  void _changeChapter(int newIndex) {
    if (newIndex >= 0 && newIndex < _reader.story.chapters.length) {
      switch (_reader.accessForChapter(newIndex)) {
        case ChapterAccessAction.read:
          _goToChapter(newIndex);
          return;
        case ChapterAccessAction.login:
          showLoginWallDialog(context);
          return;
        case ChapterAccessAction.unlock:
          _showUnlockDialog(newIndex);
          return;
      }
    }
  }

  // Chuyển thẳng đến chương (không kiểm tra quyền)
  void _goToChapter(int newIndex) {
    setState(() {
      _reader.goToChapter(newIndex);
    });

    if (_scrollController.hasClients) {
      _scrollController.animateTo(
        0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
  }

  // Dialog mở khóa chương bằng xu
  void _showUnlockDialog(int chapterIndex) {
    final story = _reader.story;
    final chapter = story.chapters[chapterIndex];
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            const Text('🔒 ', style: TextStyle(fontSize: 20)),
            Expanded(
              child: Text(
                'Chương ${chapter.chapterNumber}',
                style: TextStyle(
                  color: isDark ? Colors.white : AppColors.primaryDark,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              chapter.title,
              style: TextStyle(
                fontSize: AppFontSizes.medium,
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white70 : Colors.grey.shade800,
              ),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.amber.withValues(alpha: 0.1),
                borderRadius: BorderRadius.circular(AppRadius.sm),
                border: Border.all(color: Colors.amber.withValues(alpha: 0.3)),
              ),
              child: Row(
                children: [
                  const Text('🪙', style: TextStyle(fontSize: 24)),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Cần ${story.coinPerChapter} xu để mở khóa chương này',
                      style: TextStyle(
                        color: isDark
                            ? Colors.amber.shade200
                            : Colors.amber.shade800,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: Text(
              'Để sau',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(ctx);
              final result = await _reader.unlockChapter(chapterIndex);

              if (!mounted) return;

              if (result.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${result.message}'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                // Tự động chuyển sang chương vừa mua
                _goToChapter(chapterIndex);
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('❌ ${result.message}'),
                    backgroundColor: AppColors.accent,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
              }
            },
            icon: const Text('🪙', style: TextStyle(fontSize: 16)),
            label: Text('Mở khóa (${story.coinPerChapter} xu)'),
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.amber.shade700,
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Hiện danh sách chương (Bottom Sheet)
  void _showChapterList() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) {
        final isDark = Theme.of(context).brightness == Brightness.dark;
        return Container(
          height: MediaQuery.of(context).size.height * 0.6,
          decoration: BoxDecoration(
            color: isDark ? AppColors.primaryMid : Colors.white,
            borderRadius: const BorderRadius.vertical(
              top: Radius.circular(AppRadius.xl),
            ),
          ),
          child: Column(
            children: [
              // Drag handle
              Padding(
                padding: const EdgeInsets.all(AppSpacing.md),
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: Colors.grey.shade400,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              // Tiêu đề
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppSpacing.lg,
                  vertical: AppSpacing.sm,
                ),
                child: Text(
                  '${AppStrings.chapters} (${_reader.story.chapters.length})',
                  style: TextStyle(
                    fontSize: AppFontSizes.title,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : AppColors.primaryDark,
                  ),
                ),
              ),
              const Divider(),
              // Danh sách chương
              Expanded(
                child: ListView.builder(
                  itemCount: _reader.story.chapters.length,
                  itemBuilder: (context, index) {
                    final chapter = _reader.story.chapters[index];
                    final isCurrent = index == _reader.currentChapterIndex;
                    final isLocked = _reader.isChapterLocked(index);
                    return ListTile(
                      leading: Container(
                        width: 32,
                        height: 32,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: isCurrent
                              ? AppColors.gradientStart
                              : (isDark
                                    ? AppColors.cardDark
                                    : Colors.grey.shade100),
                        ),
                        child: Center(
                          child: Text(
                            '${chapter.chapterNumber}',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w700,
                              color: isCurrent
                                  ? Colors.white
                                  : (isDark
                                        ? Colors.white70
                                        : Colors.grey.shade700),
                            ),
                          ),
                        ),
                      ),
                      title: Text(
                        chapter.title,
                        style: TextStyle(
                          fontWeight: isCurrent
                              ? FontWeight.w700
                              : FontWeight.w500,
                          color: isCurrent
                              ? AppColors.gradientStart
                              : (isDark ? Colors.white : AppColors.primaryDark),
                        ),
                      ),
                      subtitle: Text(
                        '${chapter.pageCount} trang',
                        style: TextStyle(
                          fontSize: 12,
                          color: isDark
                              ? Colors.grey.shade500
                              : Colors.grey.shade600,
                        ),
                      ),
                      trailing: isCurrent
                          ? const Icon(
                              Icons.play_circle_filled,
                              color: AppColors.gradientStart,
                            )
                          : isLocked
                          ? Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 6,
                                    vertical: 2,
                                  ),
                                  decoration: BoxDecoration(
                                    gradient: const LinearGradient(
                                      colors: [
                                        AppColors.gradientStart,
                                        AppColors.gradientEnd,
                                      ],
                                    ),
                                    borderRadius: BorderRadius.circular(
                                      AppRadius.full,
                                    ),
                                  ),
                                  child: const Text(
                                    'VIP',
                                    style: TextStyle(
                                      fontSize: 9,
                                      fontWeight: FontWeight.w800,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 4),
                                const Icon(
                                  Icons.lock,
                                  size: 18,
                                  color: AppColors.gradientStart,
                                ),
                              ],
                            )
                          : null,
                      onTap: () {
                        Navigator.pop(context);
                        _changeChapter(index);
                      },
                    );
                  },
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  // Hiện cài đặt đọc
  void _showReadingSettings() {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      isScrollControlled: true,
      builder: (context) => MangaReadingSettingsSheet(
        backgroundColor: _reader.backgroundColor,
        isFitWidth: _reader.isFitWidth,
        onBackgroundChanged: (color) {
          setState(() => _reader.setBackgroundColor(color));
        },
        onFitWidthChanged: (value) {
          setState(() => _reader.setFitWidth(value));
        },
      ),
    );
  }

  // Cập nhật hàm helper render ảnh
  Widget _buildPageImage(
    String imagePath, {
    BoxFit fit = BoxFit.contain,
    double? width,
  }) {
    if (imagePath.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imagePath,
        fit: fit,
        width: width,
        placeholder: (context, url) => Container(
          height: 400,
          color: _reader.backgroundColor,
          child: Center(
            child: CircularProgressIndicator(
              color: AppColors.gradientStart.withValues(alpha: 0.5),
            ),
          ),
        ),
        errorWidget: (context, url, error) => _buildErrorImage(),
      );
    }
    return Image.asset(
      imagePath,
      fit: fit,
      width: width,
      errorBuilder: (context, error, stackTrace) => _buildErrorImage(),
    );
  }

  Widget _buildErrorImage() {
    return Container(
      height: 400,
      color: Colors.grey.shade900,
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.broken_image, size: 48, color: Colors.grey.shade600),
            const SizedBox(height: 8),
            Text(
              'Không thể tải trang này',
              style: TextStyle(color: Colors.grey.shade500, fontSize: 14),
            ),
          ],
        ),
      ),
    );
  }

  // Mở trang truyện fullscreen để zoom (double-tap)
  void _openFullscreenPage(String imagePath) {
    Navigator.of(context).push(
      PageRouteBuilder(
        opaque: false,
        barrierColor: Colors.black87,
        barrierDismissible: true,
        pageBuilder: (context, animation, secondaryAnimation) {
          return FadeTransition(
            opacity: animation,
            child: Scaffold(
              backgroundColor: Colors.black,
              body: GestureDetector(
                onTap: () => Navigator.of(context).pop(), // Tap để đóng
                child: Center(
                  child: InteractiveViewer(
                    minScale: 1.0,
                    maxScale: 5.0, // Zoom tối đa 5x
                    child: _buildPageImage(imagePath, fit: BoxFit.contain),
                  ),
                ),
              ),
            ),
          );
        },
        transitionDuration: const Duration(milliseconds: 200),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final chapter = _reader.currentChapter;
    final hasPrevious = _reader.hasPrevious;
    final hasNext = _reader.hasNext;

    return Scaffold(
      backgroundColor: _reader.backgroundColor,
      body: Stack(
        children: [
          // === NỘI DUNG TRANG TRUYỆN TRANH ===
          GestureDetector(
            onTap: _toggleControls, // Bấm để ẩn/hiện controls
            child: ListView.builder(
              controller: _scrollController,
              padding: EdgeInsets.only(
                top: _reader.showControls
                    ? MediaQuery.of(context).padding.top + 56
                    : 0,
                bottom: _reader.showControls ? 80 : 0,
              ),
              itemCount: chapter.pages.length + 1, // +1 cho phần cuối chương
              itemBuilder: (context, index) {
                // Phần cuối chương - nút chuyển chương
                if (index == chapter.pages.length) {
                  return _buildEndOfChapter(hasPrevious, hasNext);
                }

                // Trang truyện tranh — double tap để zoom
                return GestureDetector(
                  onDoubleTap: () => _openFullscreenPage(chapter.pages[index]),
                  child: Container(
                    width: double.infinity,
                    color: _reader.backgroundColor,
                    child: _buildPageImage(
                      chapter.pages[index],
                      fit: _reader.isFitWidth
                          ? BoxFit.fitWidth
                          : BoxFit.contain,
                      width: _reader.isFitWidth
                          ? MediaQuery.of(context).size.width
                          : null,
                    ),
                  ),
                );
              },
            ),
          ),

          // === THANH TIẾN TRÌNH ĐỌC (luôn hiển thị) ===
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            child: SafeArea(
              bottom: false,
              child: LinearProgressIndicator(
                value: _reader.readingProgress,
                backgroundColor: Colors.transparent,
                valueColor: const AlwaysStoppedAnimation<Color>(
                  AppColors.gradientStart,
                ),
                minHeight: 2,
              ),
            ),
          ),

          // === APPBAR (ẩn/hiện) ===
          if (_reader.showControls)
            Positioned(
              top: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _controlsFadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.topCenter,
                      end: Alignment.bottomCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    bottom: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.sm,
                      ),
                      child: Row(
                        children: [
                          // Nút quay lại
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () => Navigator.of(context).pop(),
                          ),
                          // Tên truyện + chương
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  _reader.story.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: AppFontSizes.body,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                Text(
                                  'Ch.${_reader.currentChapterIndex + 1} • Trang ${_reader.currentPageDisplay}/${chapter.pageCount}',
                                  style: TextStyle(
                                    color: Colors.white.withValues(alpha: 0.7),
                                    fontSize: AppFontSizes.small,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          // Nút cài đặt
                          IconButton(
                            icon: const Icon(
                              Icons.settings,
                              color: Colors.white,
                            ),
                            onPressed: _showReadingSettings,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // === BOTTOM BAR (ẩn/hiện) ===
          if (_reader.showControls)
            Positioned(
              bottom: 0,
              left: 0,
              right: 0,
              child: FadeTransition(
                opacity: _controlsFadeAnimation,
                child: Container(
                  decoration: BoxDecoration(
                    gradient: LinearGradient(
                      begin: Alignment.bottomCenter,
                      end: Alignment.topCenter,
                      colors: [
                        Colors.black.withValues(alpha: 0.85),
                        Colors.black.withValues(alpha: 0.0),
                      ],
                    ),
                  ),
                  child: SafeArea(
                    top: false,
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.lg,
                        vertical: AppSpacing.md,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          // Chương trước
                          _buildControlButton(
                            icon: Icons.skip_previous,
                            label: 'Ch. Trước',
                            onPressed: hasPrevious
                                ? () => _changeChapter(
                                    _reader.currentChapterIndex - 1,
                                  )
                                : null,
                          ),
                          // Danh sách chương
                          _buildControlButton(
                            icon: Icons.list,
                            label: 'DS Chương',
                            onPressed: _showChapterList,
                          ),
                          // Fit width / original
                          _buildControlButton(
                            icon: _reader.isFitWidth
                                ? Icons.fit_screen
                                : Icons.width_full,
                            label: _reader.isFitWidth
                                ? 'Fit Width'
                                : 'Original',
                            onPressed: () {
                              setState(
                                () => _reader.setFitWidth(!_reader.isFitWidth),
                              );
                            },
                          ),
                          // Chương sau
                          _buildControlButton(
                            icon: Icons.skip_next,
                            label: 'Ch. Sau',
                            onPressed: hasNext
                                ? () => _changeChapter(
                                    _reader.currentChapterIndex + 1,
                                  )
                                : null,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ),

          // === PAGE INDICATOR (góc phải dưới, luôn hiện) ===
          Positioned(
            bottom: _reader.showControls ? 80 : 16,
            right: 16,
            child: AnimatedOpacity(
              opacity: _reader.showControls ? 0.0 : 1.0,
              duration: const Duration(milliseconds: 250),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 10,
                  vertical: 5,
                ),
                decoration: BoxDecoration(
                  color: Colors.black.withValues(alpha: 0.6),
                  borderRadius: BorderRadius.circular(AppRadius.xl),
                ),
                child: Text(
                  '${_reader.currentPageDisplay} / ${chapter.pageCount}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 12,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // === NÚT ĐIỀU KHIỂN BOTTOM BAR ===
  Widget _buildControlButton({
    required IconData icon,
    required String label,
    required VoidCallback? onPressed,
  }) {
    final isDisabled = onPressed == null;
    return GestureDetector(
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            icon,
            color: isDisabled
                ? Colors.white.withValues(alpha: 0.3)
                : Colors.white.withValues(alpha: 0.9),
            size: 24,
          ),
          const SizedBox(height: 2),
          Text(
            label,
            style: TextStyle(
              fontSize: 10,
              color: isDisabled
                  ? Colors.white.withValues(alpha: 0.3)
                  : Colors.white.withValues(alpha: 0.7),
            ),
          ),
        ],
      ),
    );
  }

  // === PHẦN CUỐI CHƯƠNG ===
  Widget _buildEndOfChapter(bool hasPrevious, bool hasNext) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxl),
      color: _reader.backgroundColor,
      child: Column(
        children: [
          const SizedBox(height: AppSpacing.xl),
          // Icon kết thúc
          Icon(Icons.auto_stories, size: 48, color: Colors.grey.shade600),
          const SizedBox(height: AppSpacing.lg),
          Text(
            '— Hết chương ${_reader.currentChapterIndex + 1} —',
            style: TextStyle(
              color: Colors.grey.shade500,
              fontSize: AppFontSizes.medium,
              fontStyle: FontStyle.italic,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          // Nút chuyển chương
          Row(
            children: [
              if (hasPrevious)
                Expanded(
                  child: OutlinedButton.icon(
                    onPressed: () =>
                        _changeChapter(_reader.currentChapterIndex - 1),
                    icon: const Icon(Icons.arrow_back),
                    label: const Text('Chương trước'),
                    style: OutlinedButton.styleFrom(
                      foregroundColor: Colors.grey.shade400,
                      side: BorderSide(color: Colors.grey.shade700),
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
              if (hasPrevious && hasNext) const SizedBox(width: AppSpacing.md),
              if (hasNext)
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: () =>
                        _changeChapter(_reader.currentChapterIndex + 1),
                    icon: const Text('Chương sau'),
                    label: const Icon(Icons.arrow_forward),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.gradientStart,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: AppSpacing.xxxl),
        ],
      ),
    );
  }
}
