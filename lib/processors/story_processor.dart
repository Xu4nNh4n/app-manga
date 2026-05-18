import '../models/truyen.dart';

class StoryProcessor {
  static List<Story> searchStories(
    Iterable<Story> stories, {
    required String query,
    required Set<String> selectedGenres,
  }) {
    final trimmedQuery = query.trim().toLowerCase();

    if (trimmedQuery.isEmpty && selectedGenres.isEmpty) {
      return [];
    }

    return stories.where((story) {
      final matchesQuery =
          trimmedQuery.isEmpty ||
          story.title.toLowerCase().contains(trimmedQuery) ||
          story.author.toLowerCase().contains(trimmedQuery);
      final matchesGenre =
          selectedGenres.isEmpty || story.genres.any(selectedGenres.contains);

      return matchesQuery && matchesGenre;
    }).toList();
  }

  static String formatTimeAgo(DateTime date, {DateTime? now}) {
    final diff = (now ?? DateTime.now()).difference(date);

    if (diff.inMinutes < 1) return 'Vừa xong';
    if (diff.inMinutes < 60) return '${diff.inMinutes} phút trước';
    if (diff.inHours < 24) return '${diff.inHours} giờ trước';
    if (diff.inDays < 7) return '${diff.inDays} ngày trước';

    final day = date.day.toString().padLeft(2, '0');
    final month = date.month.toString().padLeft(2, '0');
    return '$day-$month-${date.year}';
  }

  static List<String> parseCommaSeparated(String value) {
    return value
        .split(',')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }

  static List<String> parseLines(String value) {
    return value
        .split('\n')
        .map((item) => item.trim())
        .where((item) => item.isNotEmpty)
        .toList();
  }
}
