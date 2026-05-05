import 'dart:async';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/truyen.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'truyen_detail_screen.dart';
import 'search_screen.dart';
import 'doc_truyen_screen.dart';

// === MÀN HÌNH TRANG CHỦ ===
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  // Controller cho banner carousel
  final PageController _bannerController = PageController(
    viewportFraction: 0.85,
  );
  Timer? _autoScrollTimer;
  int _currentBannerPage = 0;

  // Data từ Firestore
  List<Story> _stories = [];
  bool _isLoading = true;
  StreamSubscription? _storiesSubscription;

  @override
  void initState() {
    super.initState();
    _loadStories();
    _startAutoScroll();
  }

  void _loadStories() {
    _storiesSubscription = FirestoreService().getStories().listen((stories) {
      if (mounted) {
        setState(() {
          _stories = stories;
          _isLoading = false;
        });
      }
    });
  }

  // Tự động scroll banner mỗi 4 giây
  void _startAutoScroll() {
    _autoScrollTimer?.cancel();
    _autoScrollTimer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted || !_bannerController.hasClients || _stories.isEmpty) {
        return;
      }

      final nextPage = (_currentBannerPage + 1) % _stories.length;
      _bannerController.animateToPage(
        nextPage,
        duration: const Duration(milliseconds: 500),
        curve: Curves.easeInOut,
      );
    });
  }

  int _cacheWidthFor(double logicalWidth) {
    final devicePixelRatio = MediaQuery.of(
      context,
    ).devicePixelRatio.clamp(1.0, 3.0);
    return (logicalWidth * devicePixelRatio).round();
  }

  @override
  void dispose() {
    _autoScrollTimer?.cancel();
    _bannerController.dispose();
    _storiesSubscription?.cancel();
    super.dispose();
  }

  // Helper: hiển thị ảnh (hỗ trợ cả URL và asset path)
  Widget _buildCoverImage(String imageUrl, {double? width, BoxFit fit = BoxFit.cover}) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: fit,
        width: width,
        placeholder: (context, url) => Container(
          color: AppColors.shimmerBase,
          child: const Center(child: CircularProgressIndicator(strokeWidth: 2)),
        ),
        errorWidget: (context, url, error) => Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.gradientStart, AppColors.gradientEnd],
            ),
          ),
          child: const Center(child: Icon(Icons.book, size: 40, color: Colors.white54)),
        ),
      );
    }
    return Image.asset(
      imageUrl,
      fit: fit,
      width: width,
      filterQuality: FilterQuality.low,
      errorBuilder: (context, error, stackTrace) => Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [AppColors.gradientStart, AppColors.gradientEnd],
          ),
        ),
        child: const Center(child: Icon(Icons.book, size: 40, color: Colors.white54)),
      ),
    );
  }

  // Điều hướng đến trang chi tiết truyện
  void _navigateToDetail(Story story) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StoryDetailScreen(story: story)),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : CustomScrollView(
        slivers: [
          // --- AppBar ---
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
            title: Row(
              children: [
                // Icon sách
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.collections_bookmark,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(AppStrings.appName),
              ],
            ),
            actions: [
              // Nút tìm kiếm
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  Navigator.of(context).push(
                    MaterialPageRoute(
                      builder: (context) => const SearchScreen(),
                    ),
                  );
                },
              ),
            ],
          ),

          // --- Banner Carousel ---
          SliverToBoxAdapter(child: _buildBannerCarousel(isDark)),

          // ============================================
          // === SECTION 1: CẬP NHẬT GẦN ĐÂY (Grid) ===
          // ============================================
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              AppStrings.newUpdates,
              isDark,
              icon: Icons.update,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                mainAxisSpacing: 12,
                crossAxisSpacing: 12,
                childAspectRatio: 0.58,
              ),
              delegate: SliverChildBuilderDelegate((context, index) {
                final story = _stories[index];
                return _buildRecentUpdateCard(story, isDark);
              }, childCount: _stories.length),
            ),
          ),

          // ============================================
          // === SECTION 2: TRUYỆN ĐỀ XUẤT (List)    ===
          // ============================================
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              AppStrings.featured,
              isDark,
              icon: Icons.recommend,
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            sliver: SliverList(
              delegate: SliverChildBuilderDelegate((context, index) {
                final story = _stories[index];
                return _buildFeaturedCard(story, isDark);
              }, childCount: _stories.length),
            ),
          ),

          // Khoảng trống dưới cùng
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  // =========================================
  // === BANNER CAROUSEL ===
  // =========================================
  Widget _buildBannerCarousel(bool isDark) {
    final screenWidth = MediaQuery.of(context).size.width;
    final bannerWidth = screenWidth * 0.85;

    return Column(
      children: [
        SizedBox(
          height: 220,
          child: PageView.builder(
            controller: _bannerController,
            itemCount: _stories.length,
            onPageChanged: (index) {
              setState(() => _currentBannerPage = index);
            },
            itemBuilder: (context, index) {
              final story = _stories[index];
              return GestureDetector(
                onTap: () => _navigateToDetail(story),
                child: AnimatedBuilder(
                  listenable: _bannerController,
                  builder: (context, child) {
                    return Container(
                      margin: const EdgeInsets.symmetric(
                        horizontal: AppSpacing.sm,
                        vertical: AppSpacing.lg,
                      ),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        boxShadow: [
                          BoxShadow(
                            color: AppColors.gradientStart.withValues(
                              alpha: 0.3,
                            ),
                            blurRadius: 15,
                            offset: const Offset(0, 8),
                          ),
                        ],
                      ),
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.lg),
                        child: Stack(
                          fit: StackFit.expand,
                          children: [
                            // Ảnh nền
                            Image.asset(
                              story.coverImage,
                              fit: BoxFit.cover,
                              filterQuality: FilterQuality.low,
                              cacheWidth: _cacheWidthFor(bannerWidth),
                              errorBuilder: (context, error, stackTrace) {
                                return Container(
                                  decoration: const BoxDecoration(
                                    gradient: LinearGradient(
                                      colors: [
                                        AppColors.gradientStart,
                                        AppColors.gradientEnd,
                                      ],
                                    ),
                                  ),
                                );
                              },
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
                            // Thông tin truyện
                            Positioned(
                              bottom: AppSpacing.lg,
                              left: AppSpacing.lg,
                              right: AppSpacing.lg,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    story.title,
                                    style: const TextStyle(
                                      color: Colors.white,
                                      fontSize: AppFontSizes.heading,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    '${story.author} • ${story.chapterCount} chương',
                                    style: TextStyle(
                                      color: Colors.white.withValues(
                                        alpha: 0.8,
                                      ),
                                      fontSize: AppFontSizes.body,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              );
            },
          ),
        ),
        // Dots indicator
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: List.generate(
            _stories.length,
            (index) => AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.symmetric(horizontal: 3),
              width: _currentBannerPage == index ? 24 : 8,
              height: 8,
              decoration: BoxDecoration(
                color: _currentBannerPage == index
                    ? AppColors.gradientStart
                    : (isDark ? Colors.grey.shade700 : Colors.grey.shade300),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // =========================================
  // === SECTION HEADER ===
  // =========================================
  Widget _buildSectionHeader(String title, bool isDark, {IconData? icon}) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.gradientStart, size: 22),
                const SizedBox(width: 6),
              ],
              Text(
                title,
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
            ],
          ),
          TextButton(
            onPressed: () {},
            child: Text(
              'Xem tất cả',
              style: TextStyle(
                color: AppColors.gradientStart,
                fontSize: AppFontSizes.body,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ====================================================
  // === CARD CẬP NHẬT GẦN ĐÂY (Grid 2 cột) ===
  // === Thiết kế theo hình: ảnh bìa lớn + chương mới ===
  // ====================================================
  Widget _buildRecentUpdateCard(Story story, bool isDark) {
    // Lấy 2 chương mới nhất
    final latestChapters = story.chapters.reversed.take(2).toList();
    final gridImageWidth =
        (MediaQuery.of(context).size.width - (AppSpacing.lg * 2) - 12) / 2;

    return GestureDetector(
      onTap: () => _navigateToDetail(story),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withValues(
                alpha: 0.15,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === ẢNH BÌA LỚN + stats overlay ===
            Expanded(
              flex: 3,
              child: ClipRRect(
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(AppRadius.md),
                ),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    // Ảnh bìa
                    Image.asset(
                      story.coverImage,
                      fit: BoxFit.cover,
                      filterQuality: FilterQuality.low,
                      cacheWidth: _cacheWidthFor(gridImageWidth),
                      errorBuilder: (context, error, stackTrace) {
                        return Container(
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.topLeft,
                              end: Alignment.bottomRight,
                              colors: [
                                AppColors.gradientStart.withValues(alpha: 0.6),
                                AppColors.gradientEnd.withValues(alpha: 0.6),
                              ],
                            ),
                          ),
                          child: const Center(
                            child: Icon(
                              Icons.book,
                              size: 40,
                              color: Colors.white54,
                            ),
                          ),
                        );
                      },
                    ),
                    // Gradient overlay dưới
                    Positioned(
                      bottom: 0,
                      left: 0,
                      right: 0,
                      child: Container(
                        height: 50,
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
                    ),
                    // Stats overlay (views + rating)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      right: 6,
                      child: Row(
                        children: [
                          // Rating
                          _buildOverlayStat(
                            Icons.star,
                            AppColors.starGold,
                            story.rating.toString(),
                          ),
                          const SizedBox(width: 6),
                          // Số chương
                          _buildOverlayStat(
                            Icons.menu_book,
                            Colors.white70,
                            '${story.chapterCount}',
                          ),
                          const Spacer(),
                          // Trạng thái
                          Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 2,
                            ),
                            decoration: BoxDecoration(
                              color: story.status == 'Hoàn thành'
                                  ? AppColors.success.withValues(alpha: 0.85)
                                  : AppColors.accent.withValues(alpha: 0.85),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                            ),
                            child: Text(
                              story.status == 'Hoàn thành'
                                  ? 'Hoàn thành'
                                  : 'Đang ra',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 8,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),

            // === THÔNG TIN DƯỚI ẢNH ===
            Expanded(
              flex: 2,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Tên truyện
                    Text(
                      story.title,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontWeight: FontWeight.w700,
                        fontSize: AppFontSizes.body,
                        color: isDark ? Colors.white : AppColors.primaryDark,
                        height: 1.2,
                      ),
                    ),
                    const Spacer(),
                    // Chương mới nhất
                    ...latestChapters.map((ch) {
                      return Padding(
                        padding: const EdgeInsets.only(bottom: 3),
                        child: Row(
                          children: [
                            Icon(
                              Icons.local_fire_department,
                              size: 13,
                              color: AppColors.accent,
                            ),
                            const SizedBox(width: 3),
                            Expanded(
                              child: Text(
                                'Ch.${ch.chapterNumber}',
                                style: TextStyle(
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                  color: isDark
                                      ? Colors.white70
                                      : Colors.grey.shade700,
                                ),
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            Text(
                              _formatTimeAgo(ch.publishDate),
                              style: TextStyle(
                                fontSize: 10,
                                color: isDark
                                    ? Colors.grey.shade500
                                    : Colors.grey.shade500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Stats chip nhỏ trên ảnh
  Widget _buildOverlayStat(IconData icon, Color iconColor, String value) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: iconColor),
        const SizedBox(width: 2),
        Text(
          value,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 10,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }

  // ===================================================
  // === CARD TRUYỆN ĐỀ XUẤT (List dọc) ===
  // === Thiết kế theo hình: ảnh trái + info phải ===
  // ===================================================
  Widget _buildFeaturedCard(Story story, bool isDark) {
    return GestureDetector(
      onTap: () => _navigateToDetail(story),
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: isDark ? AppColors.cardDark : Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.md),
          boxShadow: [
            BoxShadow(
              color: (isDark ? Colors.black : Colors.grey).withValues(
                alpha: 0.12,
              ),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // --- Header: Số chương + Rating + Stats ---
            Row(
              children: [
                // Số chương
                Text(
                  '${story.chapterCount} Chương',
                  style: TextStyle(
                    fontSize: AppFontSizes.small,
                    color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const Spacer(),
                // Rating
                Icon(Icons.star, color: AppColors.starGold, size: 16),
                const SizedBox(width: 2),
                Text(
                  story.rating.toString(),
                  style: TextStyle(
                    fontSize: AppFontSizes.small,
                    fontWeight: FontWeight.w700,
                    color: isDark ? Colors.white : Colors.black87,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppSpacing.sm),

            // --- Body: Ảnh bìa + Thông tin ---
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Ảnh bìa (bên trái)
                ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  child: Image.asset(
                    story.coverImage,
                    width: 90,
                    height: 125,
                    fit: BoxFit.cover,
                    filterQuality: FilterQuality.low,
                    cacheWidth: _cacheWidthFor(90),
                    errorBuilder: (context, error, stackTrace) {
                      return Container(
                        width: 90,
                        height: 125,
                        decoration: BoxDecoration(
                          gradient: LinearGradient(
                            colors: [
                              AppColors.gradientStart.withValues(alpha: 0.5),
                              AppColors.gradientEnd.withValues(alpha: 0.5),
                            ],
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.sm),
                        ),
                        child: const Icon(
                          Icons.book,
                          color: Colors.white70,
                          size: 32,
                        ),
                      );
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),

                // Thông tin (bên phải)
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Tên truyện
                      Text(
                        story.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontWeight: FontWeight.w800,
                          fontSize: AppFontSizes.medium,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 6),

                      // Thể loại (genre tags)
                      Wrap(
                        spacing: 4,
                        runSpacing: 4,
                        children: story.genres.take(3).map((genre) {
                          return Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 8,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              color: AppColors.gradientStart.withValues(
                                alpha: isDark ? 0.2 : 0.1,
                              ),
                              borderRadius: BorderRadius.circular(
                                AppRadius.full,
                              ),
                              border: Border.all(
                                color: AppColors.gradientStart.withValues(
                                  alpha: 0.3,
                                ),
                              ),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(
                                  Icons.label,
                                  size: 10,
                                  color: AppColors.gradientStart,
                                ),
                                const SizedBox(width: 3),
                                Text(
                                  genre,
                                  style: TextStyle(
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.gradientStart,
                                  ),
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      ),
                      const SizedBox(height: 8),

                      // Mô tả ngắn (2 dòng)
                      Text(
                        story.description,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 10),

                      // Nút "ĐỌC TRUYỆN"
                      GestureDetector(
                        onTap: () {
                          if (story.chapters.isNotEmpty) {
                            Navigator.of(context).push(
                              MaterialPageRoute(
                                builder: (context) => ReadingScreen(
                                  story: story,
                                  initialChapterIndex: 0,
                                ),
                              ),
                            );
                          }
                        },
                        child: Text(
                          'ĐỌC TRUYỆN',
                          style: TextStyle(
                            fontSize: AppFontSizes.body,
                            fontWeight: FontWeight.w800,
                            color: AppColors.accent,
                            letterSpacing: 0.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  // Format thời gian dạng "x phút trước", "x ngày trước"
  String _formatTimeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';
    return '${date.day.toString().padLeft(2, '0')}-${date.month.toString().padLeft(2, '0')}-${date.year}';
  }
}

// AnimatedBuilder helper (tương tự AnimatedWidget)
class AnimatedBuilder extends AnimatedWidget {
  final Widget Function(BuildContext context, Widget? child) builder;

  const AnimatedBuilder({
    super.key,
    required super.listenable,
    required this.builder,
  });

  @override
  Widget build(BuildContext context) {
    return builder(context, null);
  }
}
