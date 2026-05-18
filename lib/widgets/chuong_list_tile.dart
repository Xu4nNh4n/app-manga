import 'package:flutter/material.dart';
import '../models/chuong.dart';
import '../utils/constants.dart';

// === WIDGET HIỂN THỊ MỘT CHƯƠNG TRONG DANH SÁCH ===
class ChapterListTile extends StatelessWidget {
  final Chapter chapter;
  final VoidCallback onTap;
  final bool isCurrentChapter; // Đánh dấu chương đang đọc
  final bool isLocked; // Chương bị khóa (cần đăng nhập)

  const ChapterListTile({
    super.key,
    required this.chapter,
    required this.onTap,
    this.isCurrentChapter = false,
    this.isLocked = false,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(AppRadius.sm),
      child: Container(
        padding: const EdgeInsets.symmetric(
          horizontal: AppSpacing.lg,
          vertical: AppSpacing.md,
        ),
        decoration: BoxDecoration(
          // Highlight chương đang đọc
          color: isCurrentChapter
              ? AppColors.gradientStart.withValues(alpha: isDark ? 0.15 : 0.08)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isCurrentChapter
              ? Border.all(
                  color: AppColors.gradientStart.withValues(alpha: 0.3),
                  width: 1,
                )
              : null,
        ),
        child: Opacity(
          opacity: isLocked ? 0.7 : 1.0,
          child: Row(
            children: [
              // Số chương (hình tròn)
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  gradient: isCurrentChapter
                      ? const LinearGradient(
                          colors: [
                            AppColors.gradientStart,
                            AppColors.gradientEnd,
                          ],
                        )
                      : null,
                  color: isCurrentChapter
                      ? null
                      : (isDark ? AppColors.cardDark : Colors.grey.shade100),
                ),
                child: Center(
                  child: Text(
                    '${chapter.chapterNumber}',
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      fontWeight: FontWeight.w700,
                      color: isCurrentChapter
                          ? Colors.white
                          : (isDark ? Colors.white70 : Colors.grey.shade700),
                    ),
                  ),
                ),
              ),
              const SizedBox(width: AppSpacing.md),
              // Tên chương + ngày đăng
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Text(
                            chapter.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontSize: AppFontSizes.body,
                              fontWeight: isCurrentChapter
                                  ? FontWeight.w700
                                  : FontWeight.w500,
                              color: isCurrentChapter
                                  ? AppColors.gradientStart
                                  : (isDark
                                        ? Colors.white
                                        : AppColors.primaryDark),
                            ),
                          ),
                        ),
                        // Badge VIP
                        if (isLocked) ...[
                          const SizedBox(width: 6),
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
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${chapter.pageCount} trang • ${_formatDate(chapter.publishDate)}',
                      style: TextStyle(
                        fontSize: AppFontSizes.small,
                        color: isDark
                            ? Colors.grey.shade500
                            : Colors.grey.shade500,
                      ),
                    ),
                  ],
                ),
              ),
              // Icon: khóa hoặc mũi tên
              Icon(
                isLocked
                    ? Icons.lock
                    : (isCurrentChapter
                          ? Icons.play_circle_filled
                          : Icons.chevron_right),
                color: isLocked
                    ? AppColors.gradientStart.withValues(alpha: 0.6)
                    : (isCurrentChapter
                          ? AppColors.gradientStart
                          : (isDark
                                ? Colors.grey.shade600
                                : Colors.grey.shade400)),
                size: 20,
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Format ngày tháng
  String _formatDate(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }
}
