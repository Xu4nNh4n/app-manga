import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import '../models/truyen.dart';
import '../utils/constants.dart';

// === CARD HIỂN THỊ MỘT TRUYỆN ===

// --- Card ngang (dùng trong danh sách "Truyện Hot") ---
class StoryCardHorizontal extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const StoryCardHorizontal({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 140,
        margin: const EdgeInsets.only(right: AppSpacing.md),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Ảnh bìa truyện
            Hero(
              tag: 'cover_${story.id}',
              child: Container(
                height: 190,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.md),
                  boxShadow: [
                    BoxShadow(
                      color: AppColors.gradientStart.withValues(alpha: 0.3),
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
                      _buildCoverImage(story.coverImage),
                      // Gradient overlay phía dưới
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
                                Colors.black.withValues(alpha: 0.7),
                              ],
                            ),
                          ),
                        ),
                      ),
                      // Rating ở góc
                      Positioned(
                        bottom: 6,
                        right: 6,
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: 6,
                            vertical: 2,
                          ),
                          decoration: BoxDecoration(
                            color: Colors.black54,
                            borderRadius: BorderRadius.circular(AppRadius.sm),
                          ),
                          child: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              const Icon(
                                Icons.star,
                                color: AppColors.starGold,
                                size: 12,
                              ),
                              const SizedBox(width: 2),
                              Text(
                                story.rating.toString(),
                                style: const TextStyle(
                                  color: Colors.white,
                                  fontSize: 11,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ],
                          ),
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
                fontWeight: FontWeight.w600,
                fontSize: AppFontSizes.body,
                color: isDark ? Colors.white : AppColors.primaryDark,
              ),
            ),
            const SizedBox(height: 2),
            // Tác giả
            Text(
              story.author,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                fontSize: AppFontSizes.small,
                color: isDark ? Colors.grey.shade400 : Colors.grey.shade600,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String imageUrl) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          color: AppColors.gradientStart.withValues(alpha: 0.3),
          child: const Icon(Icons.book, size: 40, color: Colors.white70),
        ),
      );
    }
    return Image.asset(
      imageUrl,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        color: AppColors.gradientStart.withValues(alpha: 0.3),
        child: const Icon(Icons.book, size: 40, color: Colors.white70),
      ),
    );
  }
}

// --- Card dọc (dùng trong danh sách "Mới Cập Nhật") ---
class StoryCardVertical extends StatelessWidget {
  final Story story;
  final VoidCallback onTap;

  const StoryCardVertical({
    super.key,
    required this.story,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: AppSpacing.md),
        padding: const EdgeInsets.all(AppSpacing.md),
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
        child: Row(
          children: [
            // Ảnh bìa nhỏ
            Hero(
              tag: 'cover_list_${story.id}',
              child: ClipRRect(
                borderRadius: BorderRadius.circular(AppRadius.sm),
                child: _buildCoverImage(
                  story.coverImage,
                  width: 80,
                  height: 110,
                ),
              ),
            ),
            const SizedBox(width: AppSpacing.md),
            // Thông tin truyện
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
                      fontWeight: FontWeight.w700,
                      fontSize: AppFontSizes.medium,
                      color: isDark ? Colors.white : AppColors.primaryDark,
                    ),
                  ),
                  const SizedBox(height: 4),
                  // Tác giả
                  Text(
                    story.author,
                    style: TextStyle(
                      fontSize: AppFontSizes.small,
                      color: isDark
                          ? Colors.grey.shade400
                          : Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 6),
                  // Thể loại (chips)
                  Wrap(
                    spacing: 4,
                    runSpacing: 4,
                    children: story.genres.take(2).map((genre) {
                      return Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.gradientStart.withValues(
                            alpha: isDark ? 0.2 : 0.1,
                          ),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Text(
                          genre,
                          style: TextStyle(
                            fontSize: 10,
                            color: AppColors.gradientStart,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                  const SizedBox(height: 8),
                  // Rating + Số chương + Trạng thái
                  Row(
                    children: [
                      // Rating
                      const Icon(
                        Icons.star,
                        color: AppColors.starGold,
                        size: 14,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        story.rating.toString(),
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          fontWeight: FontWeight.w600,
                          color: isDark ? Colors.white70 : Colors.black87,
                        ),
                      ),
                      const SizedBox(width: AppSpacing.md),
                      // Số chương
                      Icon(
                        Icons.menu_book,
                        size: 14,
                        color: isDark
                            ? Colors.grey.shade400
                            : Colors.grey.shade600,
                      ),
                      const SizedBox(width: 2),
                      Text(
                        '${story.chapterCount} chương',
                        style: TextStyle(
                          fontSize: AppFontSizes.small,
                          color: isDark
                              ? Colors.grey.shade400
                              : Colors.grey.shade600,
                        ),
                      ),
                      const Spacer(),
                      // Trạng thái
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 8,
                          vertical: 2,
                        ),
                        decoration: BoxDecoration(
                          color: story.status == 'Hoàn thành'
                              ? AppColors.success.withValues(alpha: 0.15)
                              : AppColors.accent.withValues(alpha: 0.15),
                          borderRadius: BorderRadius.circular(AppRadius.xl),
                        ),
                        child: Text(
                          story.status,
                          style: TextStyle(
                            fontSize: 10,
                            fontWeight: FontWeight.w600,
                            color: story.status == 'Hoàn thành'
                                ? AppColors.success
                                : AppColors.accent,
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCoverImage(String imageUrl, {double? width, double? height}) {
    if (imageUrl.startsWith('http')) {
      return CachedNetworkImage(
        imageUrl: imageUrl,
        width: width,
        height: height,
        fit: BoxFit.cover,
        errorWidget: (context, url, error) => Container(
          width: width,
          height: height,
          color: AppColors.gradientStart.withValues(alpha: 0.3),
          child: const Icon(Icons.book, color: Colors.white70),
        ),
      );
    }
    return Image.asset(
      imageUrl,
      width: width,
      height: height,
      fit: BoxFit.cover,
      errorBuilder: (context, error, stackTrace) => Container(
        width: width,
        height: height,
        color: AppColors.gradientStart.withValues(alpha: 0.3),
        child: const Icon(Icons.book, color: Colors.white70),
      ),
    );
  }
}
