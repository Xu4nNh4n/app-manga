import 'package:flutter/material.dart';

import '../models/chuong.dart';
import '../models/truyen.dart';
import '../services/auth_service.dart';
import '../services/coin_service.dart';
import 'chapter_access.dart';

class ReadingController {
  ReadingController({
    required this.story,
    required int initialChapterIndex,
    AuthService? authService,
    CoinService? coinService,
  }) : currentChapterIndex = initialChapterIndex,
       _authService = authService ?? AuthService(),
       _coinService = coinService ?? CoinService();

  final Story story;
  final AuthService _authService;
  final CoinService _coinService;

  int currentChapterIndex;
  bool showControls = true;
  double readingProgress = 0.0;
  Color backgroundColor = Colors.black;
  bool isFitWidth = true;
  int currentPageDisplay = 1;

  Chapter get currentChapter => story.chapters[currentChapterIndex];
  bool get hasPrevious => currentChapterIndex > 0;
  bool get hasNext => currentChapterIndex < story.chapters.length - 1;

  void updateReadingProgress(ScrollController scrollController) {
    if (!scrollController.hasClients ||
        scrollController.position.maxScrollExtent <= 0) {
      return;
    }

    final progress =
        scrollController.offset / scrollController.position.maxScrollExtent;
    currentPageDisplay = (progress * currentChapter.pageCount).ceil().clamp(
      1,
      currentChapter.pageCount,
    );
    readingProgress = progress.clamp(0.0, 1.0);
  }

  void toggleControls() {
    showControls = !showControls;
  }

  ChapterAccessAction accessForChapter(int chapterIndex) {
    if (chapterIndex < 0 || chapterIndex >= story.chapters.length) {
      return ChapterAccessAction.unlock;
    }

    final chapter = story.chapters[chapterIndex];
    final canRead = _authService.canReadChapter(
      chapterIndex,
      freeChapters: story.freeChapters,
      storyId: story.id,
      chapterId: chapter.id,
    );

    if (canRead) return ChapterAccessAction.read;
    return _authService.isLoggedIn
        ? ChapterAccessAction.unlock
        : ChapterAccessAction.login;
  }

  bool isChapterLocked(int chapterIndex) {
    return accessForChapter(chapterIndex) != ChapterAccessAction.read;
  }

  void goToChapter(int chapterIndex) {
    currentChapterIndex = chapterIndex;
    readingProgress = 0.0;
    currentPageDisplay = 1;
  }

  void setBackgroundColor(Color color) {
    backgroundColor = color;
  }

  void setFitWidth(bool value) {
    isFitWidth = value;
  }

  Future<CoinResult> unlockChapter(int chapterIndex) async {
    final chapter = story.chapters[chapterIndex];
    final result = await _coinService.unlockChapter(
      storyId: story.id,
      chapterId: chapter.id,
      cost: story.coinPerChapter,
    );

    if (result.isSuccess) {
      await _authService.refreshUserData();
    }

    return result;
  }
}
