import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/truyen.dart';
import '../models/chuong.dart';
import '../services/auth_service.dart';
import '../services/coin_service.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import '../widgets/chuong_list_tile.dart';
import '../widgets/login_wall_overlay.dart';
import 'doc_truyen_screen.dart';

// === MÀN HÌNH CHI TIẾT TRUYỆN ===
class StoryDetailScreen extends StatefulWidget {
  final Story story;

  const StoryDetailScreen({super.key, required this.story});

  @override
  State<StoryDetailScreen> createState() => _StoryDetailScreenState();
}

class _StoryDetailScreenState extends State<StoryDetailScreen> {
  bool _isFavorite = false;
  bool _isDescriptionExpanded = false;
  final _authService = AuthService();
  final _coinService = CoinService();
  List<Chapter> _chapters = [];
  bool _isLoadingChapters = true;

  @override
  void initState() {
    super.initState();
    _loadChapters();
  }

  Future<void> _loadChapters() async {
    try {
      final chapters = await FirestoreService().getChaptersOnce(widget.story.id);
      if (mounted) {
        setState(() {
          _chapters = chapters;
          _isLoadingChapters = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() => _isLoadingChapters = false);
      }
    }
  }

  // Xử lý khi bấm vào chương
  void _onChapterTap(int chapterIndex) {
    final story = widget.story;
    final chapter = _chapters[chapterIndex];

    // Chương miễn phí
    if (chapterIndex < story.freeChapters) {
      _openReading(chapterIndex);
      return;
    }

    // Chưa đăng nhập
    if (!_authService.isLoggedIn) {
      showLoginWallDialog(context);
      return;
    }

    // Kiểm tra đã mở khóa chưa
    _coinService.isChapterUnlocked(story.id, chapter.id).then((unlocked) {
      if (unlocked) {
        _openReading(chapterIndex);
      } else {
        // Hiển thị popup mua bằng coin
        _showUnlockDialog(chapterIndex, chapter);
      }
    });
  }

  void _openReading(int chapterIndex) {
    // Tạo story với chapters đã load
    final storyWithChapters = widget.story.copyWith(chapters: _chapters);
    Navigator.of(context).push(
      MaterialPageRoute(
        builder: (context) => ReadingScreen(
          story: storyWithChapters,
          initialChapterIndex: chapterIndex,
        ),
      ),
    );
  }

  void _showUnlockDialog(int chapterIndex, Chapter chapter) {
    final story = widget.story;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: isDark ? AppColors.cardDark : Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.lg),
        ),
        title: Row(
          children: [
            const Text('🪙', style: TextStyle(fontSize: 24)),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                'Mở khóa chương',
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
              'Chương ${chapter.chapterNumber}: ${chapter.title}',
              style: TextStyle(
                fontWeight: FontWeight.w600,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 12),
            Text(
              'Cần ${story.coinPerChapter} xu để mở khóa chương này.',
              style: TextStyle(
                color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(
              'Hủy',
              style: TextStyle(
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ),
          ElevatedButton.icon(
            onPressed: () async {
              Navigator.pop(context);
              final result = await _coinService.unlockChapter(
                storyId: story.id,
                chapterId: chapter.id,
                cost: story.coinPerChapter,
              );

              if (!mounted) return;

              if (result.isSuccess) {
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text('✅ ${result.message}'),
                    backgroundColor: AppColors.success,
                    behavior: SnackBarBehavior.floating,
                  ),
                );
                _openReading(chapterIndex);
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

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final story = widget.story;

    return Scaffold(
      body: CustomScrollView(
        slivers: [
          // --- SliverAppBar với ảnh bìa ---
          SliverAppBar(
            expandedHeight: 300,
            pinned: true,
            stretch: true,
            backgroundColor: isDark ? AppColors.primaryDark : AppColors.gradientStart,
            flexibleSpace: FlexibleSpaceBar(
              background: Stack(
                fit: StackFit.expand,
                children: [
                  // Ảnh bìa
                  Hero(
                    tag: 'cover_${story.id}',
                    child: story.coverImage.startsWith('http')
                        ? CachedNetworkImage(
                            imageUrl: story.coverImage,
                            fit: BoxFit.cover,
                            placeholder: (context, url) => Container(
                              color: AppColors.shimmerBase,
                            ),
                            errorWidget: (context, url, error) => Container(
                              decoration: const BoxDecoration(
                                gradient: LinearGradient(
                                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                ),
                              ),
                            ),
                          )
                        : Image.asset(
                            story.coverImage,
                            fit: BoxFit.cover,
                            errorBuilder: (context, error, stackTrace) {
                              return Container(
                                decoration: const BoxDecoration(
                                  gradient: LinearGradient(
                                    colors: [AppColors.gradientStart, AppColors.gradientEnd],
                                  ),
                                ),
                              );
                            },
                          ),
                  ),
                  // Gradient overlay
                  Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        colors: [
                          Colors.transparent,
                          Colors.black.withValues(alpha: 0.8),
                        ],
                      ),
                    ),
                  ),
                  // Thông tin truyện ở dưới
                  Positioned(
                    bottom: AppSpacing.xl,
                    left: AppSpacing.lg,
                    right: AppSpacing.lg,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Tên truyện
                        Text(
                          story.title,
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: AppFontSizes.heading + 4,
                            fontWeight: FontWeight.w800,
                            height: 1.2,
                          ),
                        ),
                        const SizedBox(height: 6),
                        // Tác giả
                        Text(
                          'Tác giả: ${story.author}',
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.85),
                            fontSize: AppFontSizes.medium,
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            // Nút yêu thích
            actions: [
              IconButton(
                icon: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 300),
                  transitionBuilder: (child, animation) {
                    return ScaleTransition(scale: animation, child: child);
                  },
                  child: Icon(
                    _isFavorite ? Icons.favorite : Icons.favorite_border,
                    key: ValueKey(_isFavorite),
                    color: _isFavorite ? AppColors.accent : Colors.white,
                    size: 28,
                  ),
                ),
                onPressed: () {
                  setState(() => _isFavorite = !_isFavorite);
                  // Hiện snackbar thông báo
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text(
                        _isFavorite
                            ? 'Đã thêm vào Thư Viện ❤️'
                            : 'Đã xóa khỏi Thư Viện',
                      ),
                      duration: const Duration(seconds: 1),
                      behavior: SnackBarBehavior.floating,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.sm),
                      ),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- Nội dung chi tiết ---
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(AppSpacing.lg),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // --- Thống kê nhanh ---
                  _buildQuickStats(story, isDark),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Thể loại (Chips) ---
                  Wrap(
                    spacing: AppSpacing.sm,
                    runSpacing: AppSpacing.sm,
                    children: story.genres.map((genre) {
                      return Chip(
                        label: Text(genre),
                        materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Nút "Đọc Ngay" ---
                  SizedBox(
                    width: double.infinity,
                    height: 52,
                    child: ElevatedButton(
                      onPressed: () {
                        if (_chapters.isNotEmpty) {
                          _openReading(0);
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.gradientStart,
                        foregroundColor: Colors.white,
                        elevation: 4,
                        shadowColor: AppColors.gradientStart.withValues(alpha: 0.4),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      ),
                      child: const Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.play_arrow, size: 24),
                          SizedBox(width: AppSpacing.sm),
                          Text(
                            AppStrings.readNow,
                            style: TextStyle(
                              fontSize: AppFontSizes.medium,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.xl),

                  // --- Mô tả (có nút Xem thêm) ---
                  Text(
                    'Giới Thiệu',
                    style: TextStyle(
                      fontSize: AppFontSizes.title,
                      fontWeight: FontWeight.w700,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: AppSpacing.sm),
                  AnimatedCrossFade(
                    firstChild: Text(
                      story.description,
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    secondChild: Text(
                      story.description,
                      style: TextStyle(
                        fontSize: AppFontSizes.body,
                        color: isDark ? Colors.grey.shade300 : Colors.grey.shade700,
                        height: 1.6,
                      ),
                    ),
                    crossFadeState: _isDescriptionExpanded
                        ? CrossFadeState.showSecond
                        : CrossFadeState.showFirst,
                    duration: const Duration(milliseconds: 300),
                  ),
                  GestureDetector(
                    onTap: () {
                      setState(() =>
                          _isDescriptionExpanded = !_isDescriptionExpanded);
                    },
                    child: Padding(
                      padding: const EdgeInsets.symmetric(vertical: AppSpacing.sm),
                      child: Text(
                        _isDescriptionExpanded ? 'Thu gọn ▲' : 'Xem thêm ▼',
                        style: const TextStyle(
                          color: AppColors.gradientStart,
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.body,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: AppSpacing.lg),

                  // --- Danh sách chương ---
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        AppStrings.chapters,
                        style: TextStyle(
                          fontSize: AppFontSizes.title,
                          fontWeight: FontWeight.w700,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      Row(
                        children: [
                          // Chỉ báo chương miễn phí
                          if (!_authService.isLoggedIn)
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 2,
                              ),
                              margin: const EdgeInsets.only(right: 8),
                              decoration: BoxDecoration(
                                color: AppColors.success.withValues(alpha: 0.1),
                                borderRadius: BorderRadius.circular(AppRadius.full),
                              ),
                              child: Text(
                                '${story.freeChapters} chương miễn phí',
                                style: TextStyle(
                                  fontSize: 10,
                                  fontWeight: FontWeight.w600,
                                  color: AppColors.success,
                                ),
                              ),
                            ),
                          Text(
                            '${_chapters.length} chương',
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
                              color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                  const SizedBox(height: AppSpacing.md),
                ],
              ),
            ),
          ),

          // --- Danh sách chương (SliverList) ---
          if (_isLoadingChapters)
            const SliverToBoxAdapter(
              child: Padding(
                padding: EdgeInsets.all(AppSpacing.xxl),
                child: Center(child: CircularProgressIndicator()),
              ),
            )
          else
            SliverPadding(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
              sliver: SliverList(
                delegate: SliverChildBuilderDelegate(
                  (context, index) {
                    final chapter = _chapters[index];
                    // Lôgic khóa: nếu chưa đăng nhập và >= freeChapters
                    bool isLocked = false;
                    if (index >= story.freeChapters) {
                       isLocked = !_authService.canReadChapter(index, freeChapters: story.freeChapters, storyId: story.id, chapterId: chapter.id);
                    }
                    return ChapterListTile(
                      chapter: chapter,
                      isLocked: isLocked,
                      onTap: () => _onChapterTap(index),
                    );
                  },
                  childCount: _chapters.length,
                ),
              ),
            ),

          // Khoảng trống dưới cùng
          const SliverToBoxAdapter(
            child: SizedBox(height: AppSpacing.xxxl),
          ),
        ],
      ),
    );
  }

  // === THỐNG KÊ NHANH ===
  Widget _buildQuickStats(Story story, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.lg),
      decoration: BoxDecoration(
        color: isDark ? AppColors.cardDark : Colors.grey.shade50,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: isDark ? Colors.white10 : Colors.grey.shade200,
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceAround,
        children: [
          _buildStatItem(
            icon: Icons.star,
            iconColor: AppColors.starGold,
            value: story.rating.toString(),
            label: 'Đánh giá',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            icon: Icons.menu_book,
            iconColor: AppColors.gradientStart,
            value: '${story.chapterCount}',
            label: 'Chương',
            isDark: isDark,
          ),
          _buildDivider(isDark),
          _buildStatItem(
            icon: story.status == 'Hoàn thành'
                ? Icons.check_circle
                : Icons.access_time,
            iconColor: story.status == 'Hoàn thành'
                ? AppColors.success
                : AppColors.accent,
            value: story.status,
            label: 'Trạng thái',
            isDark: isDark,
          ),
        ],
      ),
    );
  }

  Widget _buildStatItem({
    required IconData icon,
    required Color iconColor,
    required String value,
    required String label,
    required bool isDark,
  }) {
    return Column(
      children: [
        Icon(icon, color: iconColor, size: 24),
        const SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: AppFontSizes.body,
            fontWeight: FontWeight.w700,
            color: isDark ? Colors.white : AppColors.primaryDark,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.small,
            color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          ),
        ),
      ],
    );
  }

  Widget _buildDivider(bool isDark) {
    return Container(
      width: 1,
      height: 40,
      color: isDark ? Colors.white10 : Colors.grey.shade300,
    );
  }
}
