import '../models/category.dart';
import '../models/chuong.dart';
import '../models/truyen.dart';
import '../processors/story_processor.dart';
import '../services/firestore_service.dart';

class AdminController {
  AdminController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  Stream<List<Story>> watchStories() => _firestoreService.getStories();

  Stream<List<StoryCategory>> watchCategories() {
    return _firestoreService.getCategories();
  }

  Future<void> addStory(AdminStoryFormData form) async {
    await _firestoreService.addStory(form.toNewStory());
  }

  Future<void> updateStory(Story currentStory, AdminStoryFormData form) async {
    await _firestoreService.updateStoryFull(form.toUpdatedStory(currentStory));
  }

  Future<void> deleteStory(Story story) async {
    await _firestoreService.deleteStory(story.id);
  }

  Future<void> addChapter(Story story, AdminChapterFormData form) async {
    await _firestoreService.addChapter(
      story.id,
      form.toChapter(defaultChapterNumber: story.chapterCount + 1),
    );
  }

  Future<void> addCategory(String name) async {
    await _firestoreService.addCategory(name.trim());
  }

  Future<void> updateCategory(StoryCategory category, String name) async {
    await _firestoreService.updateCategory(category.id, name.trim());
  }

  Future<void> deleteCategory(StoryCategory category) async {
    await _firestoreService.deleteCategory(category.id);
  }
}

class AdminStoryFormData {
  const AdminStoryFormData({
    required this.title,
    required this.author,
    required this.description,
    required this.coverImage,
    required this.genres,
    required this.freeChapters,
    required this.coinPerChapter,
  });

  final String title;
  final String author;
  final String description;
  final String coverImage;
  final List<String> genres;
  final int freeChapters;
  final int coinPerChapter;

  bool get isValid => title.trim().isNotEmpty;

  factory AdminStoryFormData.fromText({
    required String title,
    required String author,
    required String description,
    required String coverImage,
    required String genres,
    required String freeChapters,
    required String coinPerChapter,
  }) {
    final trimmedAuthor = author.trim();
    return AdminStoryFormData(
      title: title.trim(),
      author: trimmedAuthor.isEmpty ? 'Unknown' : trimmedAuthor,
      description: description.trim(),
      coverImage: coverImage.trim(),
      genres: StoryProcessor.parseCommaSeparated(genres),
      freeChapters: int.tryParse(freeChapters) ?? 3,
      coinPerChapter: int.tryParse(coinPerChapter) ?? 5,
    );
  }

  Story toNewStory() {
    final now = DateTime.now();
    return Story(
      id: '',
      title: title,
      author: author,
      coverImage: coverImage,
      description: description,
      genres: genres,
      chapterCount: 0,
      rating: 0.0,
      status: 'Đang ra',
      lastUpdated: now,
      chapters: const [],
      freeChapters: freeChapters,
      coinPerChapter: coinPerChapter,
      createdAt: now,
    );
  }

  Story toUpdatedStory(Story currentStory) {
    return Story(
      id: currentStory.id,
      title: title,
      author: author,
      coverImage: coverImage,
      description: description,
      genres: genres,
      chapterCount: currentStory.chapterCount,
      rating: currentStory.rating,
      status: currentStory.status,
      lastUpdated: DateTime.now(),
      chapters: currentStory.chapters,
      freeChapters: freeChapters,
      coinPerChapter: coinPerChapter,
      createdAt: currentStory.createdAt,
      views: currentStory.views,
      isHot: currentStory.isHot,
    );
  }
}

class AdminChapterFormData {
  const AdminChapterFormData({
    required this.chapterNumber,
    required this.title,
    required this.pages,
  });

  final int? chapterNumber;
  final String title;
  final List<String> pages;

  bool get isValid => title.trim().isNotEmpty;

  factory AdminChapterFormData.fromText({
    required String chapterNumber,
    required String title,
    required String pages,
  }) {
    return AdminChapterFormData(
      chapterNumber: int.tryParse(chapterNumber),
      title: title.trim(),
      pages: StoryProcessor.parseLines(pages),
    );
  }

  Chapter toChapter({required int defaultChapterNumber}) {
    return Chapter(
      chapterNumber: chapterNumber ?? defaultChapterNumber,
      title: title,
      pages: pages,
      publishDate: DateTime.now(),
    );
  }
}
