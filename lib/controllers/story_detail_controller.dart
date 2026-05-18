import 'package:flutter/foundation.dart';

import '../models/chuong.dart';
import '../models/truyen.dart';
import '../services/auth_service.dart';
import '../services/coin_service.dart';
import '../services/firestore_service.dart';
import 'chapter_access.dart';

class StoryDetailController extends ChangeNotifier {
  StoryDetailController({
    required this.story,
    FirestoreService? firestoreService,
    AuthService? authService,
    CoinService? coinService,
  }) : firestoreService = firestoreService ?? FirestoreService(),
       authService = authService ?? AuthService(),
       coinService = coinService ?? CoinService();

  final Story story;
  final FirestoreService firestoreService;
  final AuthService authService;
  final CoinService coinService;

  bool isFavorite = false;
  bool isDescriptionExpanded = false;
  bool isLoadingChapters = true;
  List<Chapter> chapters = [];

  Story get storyWithChapters => story.copyWith(chapters: chapters);

  Future<void> loadChapters() async {
    try {
      chapters = await firestoreService.getChaptersOnce(story.id);
    } catch (_) {
      chapters = [];
    } finally {
      isLoadingChapters = false;
      notifyListeners();
    }
  }

  Future<ChapterAccessAction> getChapterAccess(int chapterIndex) async {
    final chapter = chapters[chapterIndex];

    if (chapterIndex < story.freeChapters) {
      return ChapterAccessAction.read;
    }

    if (!authService.isLoggedIn) {
      return ChapterAccessAction.login;
    }

    final isUnlocked = await coinService.isChapterUnlocked(
      story.id,
      chapter.id,
    );
    return isUnlocked ? ChapterAccessAction.read : ChapterAccessAction.unlock;
  }

  bool isChapterLocked(int chapterIndex) {
    if (chapterIndex < story.freeChapters) {
      return false;
    }

    final chapter = chapters[chapterIndex];
    return !authService.canReadChapter(
      chapterIndex,
      freeChapters: story.freeChapters,
      storyId: story.id,
      chapterId: chapter.id,
    );
  }

  Future<CoinResult> unlockChapter(Chapter chapter) {
    return coinService.unlockChapter(
      storyId: story.id,
      chapterId: chapter.id,
      cost: story.coinPerChapter,
    );
  }

  void toggleFavorite() {
    isFavorite = !isFavorite;
    notifyListeners();
  }

  void toggleDescription() {
    isDescriptionExpanded = !isDescriptionExpanded;
    notifyListeners();
  }
}
