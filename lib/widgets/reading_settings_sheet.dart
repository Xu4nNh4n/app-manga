import 'package:flutter/material.dart';
import '../utils/constants.dart';

// === BOTTOM SHEET CÀI ĐẶT ĐỌC TRUYỆN TRANH (MANGA) ===
class MangaReadingSettingsSheet extends StatelessWidget {
  final Color backgroundColor; // Màu nền hiện tại
  final bool isFitWidth; // Chế độ fit width
  final ValueChanged<Color> onBackgroundChanged; // Callback đổi màu nền
  final ValueChanged<bool> onFitWidthChanged; // Callback đổi fit mode

  const MangaReadingSettingsSheet({
    super.key,
    required this.backgroundColor,
    required this.isFitWidth,
    required this.onBackgroundChanged,
    required this.onFitWidthChanged,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      padding: const EdgeInsets.all(AppSpacing.xl),
      decoration: BoxDecoration(
        color: isDark ? AppColors.primaryMid : Colors.white,
        borderRadius: const BorderRadius.vertical(
          top: Radius.circular(AppRadius.xl),
        ),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thanh kéo (drag handle)
          Center(
            child: Container(
              width: 40,
              height: 4,
              decoration: BoxDecoration(
                color: Colors.grey.shade400,
                borderRadius: BorderRadius.circular(2),
              ),
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Tiêu đề ---
          Text(
            '⚙️ Cài Đặt Đọc Truyện',
            style: TextStyle(
              fontSize: AppFontSizes.title,
              fontWeight: FontWeight.w700,
              color: isDark ? Colors.white : AppColors.primaryDark,
            ),
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Chế độ hiển thị ảnh ---
          Text(
            'Chế độ hiển thị',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            children: [
              Expanded(
                child: _buildModeButton(
                  context: context,
                  icon: Icons.fit_screen,
                  label: 'Fit Width',
                  description: 'Ảnh vừa màn hình',
                  isSelected: isFitWidth,
                  onTap: () => onFitWidthChanged(true),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              Expanded(
                child: _buildModeButton(
                  context: context,
                  icon: Icons.photo_size_select_actual,
                  label: 'Original',
                  description: 'Kích thước gốc',
                  isSelected: !isFitWidth,
                  onTap: () => onFitWidthChanged(false),
                ),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Màu nền ---
          Text(
            'Màu nền',
            style: TextStyle(
              fontSize: AppFontSizes.body,
              fontWeight: FontWeight.w600,
              color: isDark ? Colors.white70 : Colors.black87,
            ),
          ),
          const SizedBox(height: AppSpacing.md),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              _buildColorOption(
                context: context,
                color: Colors.black,
                label: 'Đen',
                isSelected: backgroundColor == Colors.black,
                onTap: () => onBackgroundChanged(Colors.black),
              ),
              _buildColorOption(
                context: context,
                color: const Color(0xFF1A1A2E),
                label: 'Tối',
                isSelected: backgroundColor == const Color(0xFF1A1A2E),
                onTap: () => onBackgroundChanged(const Color(0xFF1A1A2E)),
              ),
              _buildColorOption(
                context: context,
                color: const Color(0xFF2D2D2D),
                label: 'Xám',
                isSelected: backgroundColor == const Color(0xFF2D2D2D),
                onTap: () => onBackgroundChanged(const Color(0xFF2D2D2D)),
              ),
              _buildColorOption(
                context: context,
                color: Colors.white,
                label: 'Trắng',
                isSelected: backgroundColor == Colors.white,
                onTap: () => onBackgroundChanged(Colors.white),
              ),
            ],
          ),
          const SizedBox(height: AppSpacing.xl),

          // --- Hướng dẫn zoom ---
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(AppSpacing.lg),
            decoration: BoxDecoration(
              color: AppColors.gradientStart.withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(AppRadius.md),
            ),
            child: Row(
              children: [
                const Icon(
                  Icons.touch_app,
                  color: AppColors.gradientStart,
                  size: 24,
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Mẹo đọc truyện',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: AppFontSizes.body,
                          color: isDark ? Colors.white : AppColors.primaryDark,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        '• Chạm màn hình: ẩn/hiện controls\n'
                        '• Kéo 2 ngón: zoom ảnh (1x → 4x)\n'
                        '• Vuốt dọc: đọc trang tiếp',
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                          height: 1.5,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
        ],
      ),
    );
  }

  // Widget nút chọn chế độ hiển thị
  Widget _buildModeButton({
    required BuildContext context,
    required IconData icon,
    required String label,
    required String description,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(AppSpacing.lg),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.gradientStart.withValues(alpha: 0.15)
              : (isDark ? AppColors.cardDark : Colors.grey.shade100),
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: isSelected
                ? AppColors.gradientStart
                : (isDark ? Colors.white10 : Colors.grey.shade300),
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Column(
          children: [
            Icon(
              icon,
              size: 28,
              color: isSelected
                  ? AppColors.gradientStart
                  : (isDark ? Colors.white54 : Colors.grey.shade600),
            ),
            const SizedBox(height: 6),
            Text(
              label,
              style: TextStyle(
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.body,
                color: isSelected
                    ? AppColors.gradientStart
                    : (isDark ? Colors.white70 : Colors.black87),
              ),
            ),
            const SizedBox(height: 2),
            Text(
              description,
              style: TextStyle(
                fontSize: 10,
                color: isDark ? Colors.grey.shade500 : Colors.grey.shade500,
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Widget tùy chọn màu nền
  Widget _buildColorOption({
    required BuildContext context,
    required Color color,
    required String label,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Column(
        children: [
          AnimatedContainer(
            duration: const Duration(milliseconds: 200),
            width: 50,
            height: 50,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(
                color: isSelected
                    ? AppColors.gradientStart
                    : Colors.grey.shade400,
                width: isSelected ? 3 : 1,
              ),
              boxShadow: isSelected
                  ? [
                      BoxShadow(
                        color: AppColors.gradientStart.withValues(alpha: 0.3),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : [],
            ),
            child: isSelected
                ? Icon(
                    Icons.check,
                    color: color == Colors.white
                        ? AppColors.gradientStart
                        : Colors.white,
                    size: 20,
                  )
                : null,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: TextStyle(
              fontSize: AppFontSizes.small,
              color: Theme.of(context).brightness == Brightness.dark
                  ? Colors.white70
                  : Colors.black54,
            ),
          ),
        ],
      ),
    );
  }
}

// === GIỮ LẠI CLASS CŨ ĐỂ TƯƠNG THÍCH (nếu cần) ===
// ReadingSettingsSheet giờ không còn dùng nữa
// nhưng giữ lại không bị lỗi import
class ReadingSettingsSheet extends StatelessWidget {
  final double fontSize;
  final Color backgroundColor;
  final Color textColor;
  final ValueChanged<double> onFontSizeChanged;
  final ValueChanged<int> onThemeChanged;

  const ReadingSettingsSheet({
    super.key,
    required this.fontSize,
    required this.backgroundColor,
    required this.textColor,
    required this.onFontSizeChanged,
    required this.onThemeChanged,
  });

  @override
  Widget build(BuildContext context) {
    // Redirect sang MangaReadingSettingsSheet
    return const SizedBox.shrink();
  }
}
