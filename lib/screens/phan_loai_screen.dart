import 'package:flutter/material.dart';
import '../models/truyen.dart';
import '../services/firestore_service.dart';
import '../utils/constants.dart';
import 'truyen_detail_screen.dart';

// === DIALOG TÁI SỬ DỤNG: THÔNG BÁO TÍNH NĂNG ĐANG PHÁT TRIỂN ===
Future<void> showUnderDevelopmentDialog(
  BuildContext context, {
  String featureName = 'Tính năng này',
}) {
  return showDialog<void>(
    context: context,
    builder: (context) {
      return AlertDialog(
        title: const Text('Thông báo'),
        content: Text('$featureName đang chuẩn bị làm.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('OK'),
          ),
        ],
      );
    },
  );
}

// === MÀN HÌNH PHÂN LOẠI ===
class PhanLoaiScreen extends StatefulWidget {
  const PhanLoaiScreen({super.key});

  @override
  State<PhanLoaiScreen> createState() => _PhanLoaiScreenState();
}

class _PhanLoaiScreenState extends State<PhanLoaiScreen>
    with TickerProviderStateMixin {
  // === STATE ===
  bool _isLoading = true;
  int _hotTimeRange = 0; // 0 = 24h, 1 = 7 ngày
  final Set<String> _selectedTags = {};
  List<Story> _allStories = [];
  List<Story> _filteredStories = [];
  List<Story> _hotStories = [];

  // Tất cả thể loại
  final List<String> _allGenres = [
    'Tiên hiệp',
    'Huyền huyễn',
    'Kiếm hiệp',
    'Ngôn tình',
    'Hành động',
    'Võ thuật',
    'Lãng mạn',
    'Hiện đại',
    'Phiêu lưu',
    'Drama',
    'Hài hước',
    'Kinh dị',
    'Đời thường',
    'Xuyên không',
    'Trọng sinh',
    'Giả tưởng',
  ];

  // Animation controllers
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();

    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOutCubic,
    );

    _loadData();
  }

  @override
  void dispose() {
    _fadeController.dispose();
    super.dispose();
  }

  // Tải dữ liệu từ Firestore
  Future<void> _loadData() async {
    try {
      final stories = await FirestoreService().getStoriesOnce();
      if (!mounted) return;

      setState(() {
        _allStories = stories;
        _filteredStories = _getSortedByRating(_allStories);
        _hotStories = _getHotStories();
        _isLoading = false;
      });
      _fadeController.forward();
    } catch (e) {
      if (!mounted) return;
      setState(() => _isLoading = false);
      _fadeController.forward();
    }
  }

  // Sắp xếp theo rating giảm dần
  List<Story> _getSortedByRating(List<Story> stories) {
    final sorted = List<Story>.from(stories);
    sorted.sort((a, b) => b.rating.compareTo(a.rating));
    return sorted;
  }

  // Lấy truyện hot dựa trên views + isHot
  List<Story> _getHotStories() {
    List<Story> stories = List.from(_allStories);

    if (_hotTimeRange == 0) {
      // 24h: chỉ lấy truyện có isHot = true, sort theo views
      stories = stories.where((s) => s.isHot).toList();
    } else {
      // 7 ngày: lấy top truyện theo views (bao gồm cả non-hot)
      stories.sort((a, b) => b.views.compareTo(a.views));
      stories = stories.take(6).toList();
    }

    stories.sort((a, b) => b.views.compareTo(a.views));
    return stories;
  }

  // Toggle chọn tag
  void _toggleTag(String tag) {
    setState(() {
      if (_selectedTags.contains(tag)) {
        _selectedTags.remove(tag);
      } else {
        _selectedTags.add(tag);
      }
      _applyFilters();
    });
  }

  // Reset tất cả filter
  void _resetFilters() {
    setState(() {
      _selectedTags.clear();
      _applyFilters();
    });
  }

  // Áp dụng bộ lọc (logic OR)
  void _applyFilters() {
    if (_selectedTags.isEmpty) {
      _filteredStories = _getSortedByRating(_allStories);
    } else {
      final filtered = _allStories.where((story) {
        return story.genres.any((g) => _selectedTags.contains(g));
      }).toList();
      _filteredStories = _getSortedByRating(filtered);
    }
  }

  // Format lượt xem gọn (158200 → 158.2K)
  String _formatViews(int views) {
    if (views >= 1000000) {
      return '${(views / 1000000).toStringAsFixed(1)}M';
    } else if (views >= 1000) {
      return '${(views / 1000).toStringAsFixed(1)}K';
    }
    return views.toString();
  }

  // Tính CacheWidth cho ảnh (giống home_screen)
  int _cacheWidthFor(double logicalWidth) {
    final devicePixelRatio = MediaQuery.of(
      context,
    ).devicePixelRatio.clamp(1.0, 3.0);
    return (logicalWidth * devicePixelRatio).round();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: _isLoading ? _buildShimmerLoading(isDark) : _buildContent(isDark),
    );
  }

  // ==========================================
  // === NỘI DUNG CHÍNH ===
  // ==========================================
  Widget _buildContent(bool isDark) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: CustomScrollView(
        slivers: [
          // --- AppBar ---
          SliverAppBar(
            floating: true,
            snap: true,
            elevation: 0,
            backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
            title: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.gradientStart, AppColors.gradientEnd],
                    ),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  ),
                  child: const Icon(
                    Icons.category,
                    color: Colors.white,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.sm),
                const Text(AppStrings.phanLoai),
              ],
            ),
          ),

          // --- Section 1: ĐANG HOT ---
          SliverToBoxAdapter(child: _buildHotSection(isDark)),

          // --- Section 2: BỘ LỌC TAG ---
          SliverToBoxAdapter(child: _buildTagFilterSection(isDark)),

          // --- Section 3 Header: TRUYỆN NỔI BẬT ---
          SliverToBoxAdapter(
            child: _buildSectionHeader(
              AppStrings.truyenNoiBat,
              isDark,
              icon: Icons.star,
              subtitle:
                  '${_filteredStories.length} truyện • Sắp theo đánh giá',
            ),
          ),

          // --- Section 3 Content: GRID TRUYỆN ---
          _filteredStories.isEmpty
              ? SliverToBoxAdapter(child: _buildEmptyState(isDark))
              : SliverPadding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  sliver: SliverGrid(
                    gridDelegate:
                        const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          mainAxisSpacing: 12,
                          crossAxisSpacing: 12,
                          childAspectRatio: 0.55,
                        ),
                    delegate: SliverChildBuilderDelegate((context, index) {
                      final story = _filteredStories[index];
                      return _buildStoryGridCard(story, isDark);
                    }, childCount: _filteredStories.length),
                  ),
                ),

          // Khoảng trống dưới cùng
          const SliverToBoxAdapter(child: SizedBox(height: AppSpacing.xxxl)),
        ],
      ),
    );
  }

  // ==========================================
  // === SECTION: ĐANG HOT 🔥 ===
  // ==========================================
  Widget _buildHotSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header + Toggle 24h / 7 ngày
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              // Icon + Title
              const Icon(
                Icons.local_fire_department,
                color: AppColors.accent,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.dangHot,
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              const Spacer(),
              // Toggle: 24h | 7 ngày
              _buildTimeRangeToggle(isDark),
            ],
          ),
        ),

        // Horizontal list truyện hot
        SizedBox(
          height: 210,
          child: _hotStories.isEmpty
              ? Center(
                  child: Text(
                    'Chưa có truyện hot',
                    style: TextStyle(
                      color: isDark ? Colors.grey.shade500 : Colors.grey.shade400,
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                )
              : ListView.builder(
                  scrollDirection: Axis.horizontal,
                  padding:
                      const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
                  itemCount: _hotStories.length,
                  itemBuilder: (context, index) {
                    final story = _hotStories[index];
                    return _buildHotStoryCard(story, isDark, index);
                  },
                ),
        ),
      ],
    );
  }

  // Toggle tab 24h / 7 ngày
  Widget _buildTimeRangeToggle(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        color: isDark
            ? Colors.white.withValues(alpha: 0.08)
            : Colors.grey.shade100,
        borderRadius: BorderRadius.circular(AppRadius.full),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildToggleTab(AppStrings.trendingToday, 0, isDark),
          _buildToggleTab(AppStrings.trendingWeek, 1, isDark),
        ],
      ),
    );
  }

  Widget _buildToggleTab(String label, int index, bool isDark) {
    final isSelected = _hotTimeRange == index;

    return GestureDetector(
      onTap: () {
        if (_hotTimeRange != index) {
          setState(() {
            _hotTimeRange = index;
            _hotStories = _getHotStories();
          });
        }
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 250),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 7),
        decoration: BoxDecoration(
          gradient: isSelected
              ? const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                )
              : null,
          borderRadius: BorderRadius.circular(AppRadius.full),
        ),
        child: Text(
          label,
          style: TextStyle(
            fontSize: AppFontSizes.small,
            fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected
                ? Colors.white
                : (isDark ? Colors.grey.shade400 : Colors.grey.shade600),
          ),
        ),
      ),
    );
  }

  // Card truyện HOT (horizontal list)
  Widget _buildHotStoryCard(Story story, bool isDark, int index) {
    return GestureDetector(
      onTap: () => _navigateToDetail(story),
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa + overlays
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.accent.withValues(alpha: 0.3),
                      blurRadius: 12,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      // Ảnh bìa
                      Image.asset(
                        story.coverImage,
                        fit: BoxFit.cover,
                        filterQuality: FilterQuality.low,
                        cacheWidth: _cacheWidthFor(140),
                        errorBuilder: (context, error, stackTrace) {
                          return Container(
                            decoration: BoxDecoration(
                              gradient: LinearGradient(
                                colors: [
                                  AppColors.gradientStart
                                      .withValues(alpha: 0.6),
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
                          height: 60,
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
                      // Badge HOT (góc trái trên)
                      if (story.isHot)
                        Positioned(
                          top: 6,
                          left: 6,
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                              horizontal: 6,
                              vertical: 3,
                            ),
                            decoration: BoxDecoration(
                              gradient: const LinearGradient(
                                colors: [Color(0xFFFF6B35), AppColors.accent],
                              ),
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
                              boxShadow: [
                                BoxShadow(
                                  color: AppColors.accent
                                      .withValues(alpha: 0.4),
                                  blurRadius: 6,
                                  offset: const Offset(0, 2),
                                ),
                              ],
                            ),
                            child: const Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                Icon(Icons.whatshot,
                                    size: 10, color: Colors.white),
                                SizedBox(width: 2),
                                Text(
                                  'HOT',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 9,
                                    fontWeight: FontWeight.w900,
                                    letterSpacing: 0.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      // Ranking badge (góc phải trên)
                      Positioned(
                        top: 6,
                        right: 6,
                        child: Container(
                          width: 24,
                          height: 24,
                          decoration: BoxDecoration(
                            color: _getRankColor(index),
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black.withValues(alpha: 0.3),
                                blurRadius: 4,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: Center(
                            child: Text(
                              '${index + 1}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ),
                        ),
                      ),
                      // Views (góc dưới)
                      Positioned(
                        bottom: 6,
                        left: 6,
                        right: 6,
                        child: Row(
                          children: [
                            const Icon(
                              Icons.visibility,
                              size: 12,
                              color: Colors.white70,
                            ),
                            const SizedBox(width: 3),
                            Text(
                              _formatViews(story.views),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const Spacer(),
                            const Icon(
                              Icons.star,
                              size: 12,
                              color: AppColors.starGold,
                            ),
                            const SizedBox(width: 2),
                            Text(
                              story.rating.toString(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.sm),
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
          ],
        ),
      ),
    );
  }

  // Màu ranking (vàng, bạc, đồng, xám)
  Color _getRankColor(int index) {
    switch (index) {
      case 0:
        return const Color(0xFFFFD700); // Vàng
      case 1:
        return const Color(0xFFC0C0C0); // Bạc
      case 2:
        return const Color(0xFFCD7F32); // Đồng
      default:
        return Colors.grey.shade600;
    }
  }

  // ==========================================
  // === SECTION: BỘ LỌC TAG 🏷️ ===
  // ==========================================
  Widget _buildTagFilterSection(bool isDark) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header
        Padding(
          padding: const EdgeInsets.fromLTRB(
            AppSpacing.lg,
            AppSpacing.xl,
            AppSpacing.lg,
            AppSpacing.sm,
          ),
          child: Row(
            children: [
              Icon(
                Icons.label,
                color: AppColors.gradientEnd,
                size: 22,
              ),
              const SizedBox(width: 6),
              Text(
                AppStrings.theLoai,
                style: TextStyle(
                  fontSize: AppFontSizes.title,
                  fontWeight: FontWeight.w800,
                  color: isDark ? Colors.white : AppColors.primaryDark,
                ),
              ),
              if (_selectedTags.isNotEmpty) ...[
                const SizedBox(width: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 2,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.gradientStart.withValues(alpha: 0.15),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                  ),
                  child: Text(
                    '${_selectedTags.length} đã chọn',
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w700,
                      color: AppColors.gradientStart,
                    ),
                  ),
                ),
              ],
              const Spacer(),
              // Nút reset
              if (_selectedTags.isNotEmpty)
                GestureDetector(
                  onTap: _resetFilters,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 10,
                      vertical: 5,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.accent.withValues(alpha: 0.1),
                      borderRadius: BorderRadius.circular(AppRadius.full),
                      border: Border.all(
                        color: AppColors.accent.withValues(alpha: 0.3),
                      ),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.refresh, size: 14, color: AppColors.accent),
                        const SizedBox(width: 3),
                        Text(
                          AppStrings.resetFilter,
                          style: TextStyle(
                            fontSize: 11,
                            fontWeight: FontWeight.w600,
                            color: AppColors.accent,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
        ),

        // Tag chips (Wrap)
        Padding(
          padding:
              const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          child: Wrap(
            spacing: 8,
            runSpacing: 8,
            children: _allGenres.map((genre) {
              final isSelected = _selectedTags.contains(genre);
              return GestureDetector(
                onTap: () => _toggleTag(genre),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 8,
                  ),
                  decoration: BoxDecoration(
                    gradient: isSelected
                        ? const LinearGradient(
                            colors: [
                              AppColors.gradientStart,
                              AppColors.gradientEnd,
                            ],
                          )
                        : null,
                    color: isSelected
                        ? null
                        : (isDark
                            ? Colors.white.withValues(alpha: 0.08)
                            : Colors.grey.shade100),
                    borderRadius: BorderRadius.circular(AppRadius.full),
                    border: isSelected
                        ? null
                        : Border.all(
                            color: isDark
                                ? Colors.white.withValues(alpha: 0.15)
                                : Colors.grey.shade300,
                          ),
                    boxShadow: isSelected
                        ? [
                            BoxShadow(
                              color: AppColors.gradientStart
                                  .withValues(alpha: 0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 3),
                            ),
                          ]
                        : null,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isSelected) ...[
                        const Icon(
                          Icons.check,
                          size: 14,
                          color: Colors.white,
                        ),
                        const SizedBox(width: 4),
                      ],
                      Text(
                        genre,
                        style: TextStyle(
                          fontSize: AppFontSizes.body,
                          fontWeight:
                              isSelected ? FontWeight.w700 : FontWeight.w500,
                          color: isSelected
                              ? Colors.white
                              : (isDark
                                  ? Colors.white70
                                  : Colors.grey.shade700),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ),
        ),
      ],
    );
  }

  // ==========================================
  // === SECTION HEADER ===
  // ==========================================
  Widget _buildSectionHeader(
    String title,
    bool isDark, {
    IconData? icon,
    String? subtitle,
  }) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.md,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              if (icon != null) ...[
                Icon(icon, color: AppColors.starGold, size: 22),
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
          if (subtitle != null) ...[
            const SizedBox(height: 4),
            Text(
              subtitle,
              style: TextStyle(
                fontSize: AppFontSizes.small,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ==========================================
  // === CARD TRUYỆN (Grid 2 cột) ===
  // ==========================================
  Widget _buildStoryGridCard(Story story, bool isDark) {
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
              color:
                  (isDark ? Colors.black : Colors.grey).withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // === ẢNH BÌA + overlays ===
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
                                AppColors.gradientStart
                                    .withValues(alpha: 0.6),
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
                    // Badge HOT (góc trái trên)
                    if (story.isHot)
                      Positioned(
                        top: 6,
                        left: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 3,
                          ),
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(
                              colors: [Color(0xFFFF6B35), AppColors.accent],
                            ),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                            boxShadow: [
                              BoxShadow(
                                color: AppColors.accent
                                    .withValues(alpha: 0.4),
                                blurRadius: 6,
                                offset: const Offset(0, 2),
                              ),
                            ],
                          ),
                          child: const Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Icon(Icons.whatshot,
                                  size: 10, color: Colors.white),
                              SizedBox(width: 2),
                              Text(
                                'HOT',
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 9,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    // Stats overlay (rating + views)
                    Positioned(
                      bottom: 6,
                      left: 6,
                      right: 6,
                      child: Row(
                        children: [
                          // Rating
                          const Icon(Icons.star,
                              size: 12, color: AppColors.starGold),
                          const SizedBox(width: 2),
                          Text(
                            story.rating.toString(),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(width: 8),
                          // Views
                          const Icon(Icons.visibility,
                              size: 12, color: Colors.white70),
                          const SizedBox(width: 2),
                          Text(
                            _formatViews(story.views),
                            style: const TextStyle(
                              color: Colors.white,
                              fontSize: 10,
                              fontWeight: FontWeight.w600,
                            ),
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
                              borderRadius:
                                  BorderRadius.circular(AppRadius.full),
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
                    const SizedBox(height: 4),
                    // Tác giả
                    Text(
                      story.author,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                        fontSize: 11,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                    ),
                    const Spacer(),
                    // Genre tags (tối đa 2)
                    Wrap(
                      spacing: 4,
                      runSpacing: 4,
                      children: story.genres.take(2).map((genre) {
                        return Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: AppColors.gradientStart
                                .withValues(alpha: isDark ? 0.2 : 0.1),
                            borderRadius:
                                BorderRadius.circular(AppRadius.full),
                          ),
                          child: Text(
                            genre,
                            style: TextStyle(
                              fontSize: 9,
                              fontWeight: FontWeight.w600,
                              color: AppColors.gradientStart,
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ==========================================
  // === EMPTY STATE ===
  // ==========================================
  Widget _buildEmptyState(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(AppSpacing.xxxl),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Icon
          Container(
            width: 80,
            height: 80,
            decoration: BoxDecoration(
              color: AppColors.gradientStart.withValues(alpha: 0.1),
              shape: BoxShape.circle,
            ),
            child: Icon(
              Icons.search_off,
              size: 40,
              color: AppColors.gradientStart.withValues(alpha: 0.5),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),
          Text(
            AppStrings.noResults,
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white70 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            AppStrings.tryResetFilter,
            textAlign: TextAlign.center,
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          // Nút reset
          GestureDetector(
            onTap: _resetFilters,
            child: Container(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 10,
              ),
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.gradientStart, AppColors.gradientEnd],
                ),
                borderRadius: BorderRadius.circular(AppRadius.full),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.gradientStart.withValues(alpha: 0.3),
                    blurRadius: 10,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.refresh, size: 18, color: Colors.white),
                  SizedBox(width: 6),
                  Text(
                    'Xóa bộ lọc',
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSizes.body,
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // ==========================================
  // === SHIMMER LOADING ===
  // ==========================================
  Widget _buildShimmerLoading(bool isDark) {
    final baseColor = isDark ? AppColors.shimmerBase : Colors.grey.shade200;
    final highlightColor =
        isDark ? AppColors.shimmerHighlight : Colors.grey.shade300;

    return CustomScrollView(
      slivers: [
        // AppBar shimmer
        SliverAppBar(
          floating: true,
          snap: true,
          elevation: 0,
          backgroundColor: isDark ? AppColors.primaryDark : Colors.white,
          title: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
              ),
              const SizedBox(width: AppSpacing.sm),
              Container(
                width: 100,
                height: 20,
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(4),
                ),
              ),
            ],
          ),
        ),

        // Section hot shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Title shimmer
                _buildShimmerBox(150, 20, baseColor, highlightColor),
                const SizedBox(height: AppSpacing.lg),
                // Horizontal cards shimmer
                SizedBox(
                  height: 180,
                  child: ListView.builder(
                    scrollDirection: Axis.horizontal,
                    itemCount: 4,
                    itemBuilder: (context, index) {
                      return Container(
                        width: 140,
                        margin: const EdgeInsets.only(right: AppSpacing.md),
                        decoration: BoxDecoration(
                          color: baseColor,
                          borderRadius: BorderRadius.circular(AppRadius.md),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          ),
        ),

        // Tags shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(100, 20, baseColor, highlightColor),
                const SizedBox(height: AppSpacing.md),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: List.generate(8, (index) {
                    return Container(
                      width: 70 + (index % 3) * 20,
                      height: 34,
                      decoration: BoxDecoration(
                        color: baseColor,
                        borderRadius: BorderRadius.circular(AppRadius.full),
                      ),
                    );
                  }),
                ),
              ],
            ),
          ),
        ),

        // Grid shimmer
        SliverToBoxAdapter(
          child: Padding(
            padding: const EdgeInsets.all(AppSpacing.lg),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildShimmerBox(180, 20, baseColor, highlightColor),
                const SizedBox(height: AppSpacing.md),
              ],
            ),
          ),
        ),
        SliverPadding(
          padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
          sliver: SliverGrid(
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 2,
              mainAxisSpacing: 12,
              crossAxisSpacing: 12,
              childAspectRatio: 0.55,
            ),
            delegate: SliverChildBuilderDelegate((context, index) {
              return Container(
                decoration: BoxDecoration(
                  color: baseColor,
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
              );
            }, childCount: 4),
          ),
        ),
      ],
    );
  }

  Widget _buildShimmerBox(
    double width,
    double height,
    Color baseColor,
    Color highlightColor,
  ) {
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: baseColor,
        borderRadius: BorderRadius.circular(4),
      ),
    );
  }

  // ==========================================
  // === ĐIỀU HƯỚNG ===
  // ==========================================
  void _navigateToDetail(Story story) {
    Navigator.of(context).push(
      MaterialPageRoute(builder: (context) => StoryDetailScreen(story: story)),
    );
  }
}
