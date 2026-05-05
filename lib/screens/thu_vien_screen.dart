import 'package:flutter/material.dart';
import '../utils/constants.dart';
import '../widgets/truyen_card.dart';
import 'truyen_detail_screen.dart';

// === MÀN HÌNH THƯ VIỆN (Giai đoạn 1: cơ bản) ===
class LibraryScreen extends StatefulWidget {
  const LibraryScreen({super.key});

  @override
  State<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends State<LibraryScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text(AppStrings.library),
        centerTitle: true,
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: AppColors.gradientStart,
          indicatorWeight: 3,
          labelColor: AppColors.gradientStart,
          unselectedLabelColor: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
          labelStyle: const TextStyle(
            fontWeight: FontWeight.w600,
            fontSize: AppFontSizes.body,
          ),
          tabs: const [
            Tab(text: AppStrings.reading),
            Tab(text: AppStrings.favorites),
            Tab(text: AppStrings.finished),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          // Tab: Đang đọc (sẽ kết nối Firestore user data sau)
          _buildEmptyState(
            'Chưa có truyện đang đọc',
            Icons.menu_book_outlined,
          ),
          // Tab: Yêu thích
          _buildEmptyState(
            'Chưa có truyện yêu thích',
            Icons.favorite_border,
          ),
          // Tab: Đã đọc xong
          _buildEmptyState(
            'Chưa có truyện đã đọc xong',
            Icons.check_circle_outline,
          ),
        ],
      ),
    );
  }


  // Empty state
  Widget _buildEmptyState(String message, IconData icon) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            icon,
            size: 64,
            color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
          ),
          const SizedBox(height: AppSpacing.lg),
          Text(
            message,
            style: TextStyle(
              fontSize: AppFontSizes.medium,
              color: isDark ? Colors.grey.shade500 : Colors.grey.shade600,
            ),
          ),
          const SizedBox(height: AppSpacing.sm),
          Text(
            'Hãy thêm truyện yêu thích vào đây nhé! 📚',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              color: isDark ? Colors.grey.shade600 : Colors.grey.shade400,
            ),
          ),
        ],
      ),
    );
  }
}
