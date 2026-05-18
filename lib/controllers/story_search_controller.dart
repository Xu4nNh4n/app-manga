import 'package:flutter/foundation.dart';

import '../models/truyen.dart';
import '../processors/story_processor.dart';
import '../services/firestore_service.dart';

class StorySearchController extends ChangeNotifier {
  StorySearchController({FirestoreService? firestoreService})
    : _firestoreService = firestoreService ?? FirestoreService();

  final FirestoreService _firestoreService;

  bool isAdvancedOpen = false;
  bool hasSearched = false;
  final Set<String> selectedGenres = {};
  List<String> allGenres = [];
  List<Story> suggestions = [];

  List<Story> _allStories = [];

  Future<void> loadInitialData() async {
    await Future.wait([_loadAllStories(), _loadCategories()]);
    notifyListeners();
  }

  void performSearch(String query) {
    final trimmedQuery = query.trim();
    hasSearched = trimmedQuery.isNotEmpty || selectedGenres.isNotEmpty;
    suggestions = StoryProcessor.searchStories(
      _allStories,
      query: query,
      selectedGenres: selectedGenres,
    );
    notifyListeners();
  }

  void toggleAdvancedPanel() {
    isAdvancedOpen = !isAdvancedOpen;
    notifyListeners();
  }

  void toggleGenre(String genre, String query) {
    if (selectedGenres.contains(genre)) {
      selectedGenres.remove(genre);
    } else {
      selectedGenres.add(genre);
    }
    performSearch(query);
  }

  void clearFilters(String query) {
    selectedGenres.clear();
    performSearch(query);
  }

  Future<void> _loadAllStories() async {
    try {
      _allStories = await _firestoreService.getStoriesOnce();
    } catch (_) {
      _allStories = [];
    }
  }

  Future<void> _loadCategories() async {
    try {
      final categories = await _firestoreService.getCategoriesOnce();
      allGenres = categories.map((category) => category.name).toList();
    } catch (_) {
      allGenres = [];
    }
  }
}
