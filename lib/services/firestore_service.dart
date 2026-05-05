import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import '../models/truyen.dart';
import '../models/chuong.dart';
import '../models/category.dart';

// === SERVICE FIRESTORE - CRUD TRUYỆN & CHƯƠNG ===
class FirestoreService {
  static final FirestoreService _instance = FirestoreService._internal();
  factory FirestoreService() => _instance;
  FirestoreService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // === STORIES ===

  // Lấy tất cả truyện (stream real-time)
  Stream<List<Story>> getStories() {
    return _db
        .collection('stories')
        .orderBy('updatedAt', descending: true)
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Story.fromFirestore(doc)).toList();
    });
  }

  // Lấy tất cả truyện (một lần)
  Future<List<Story>> getStoriesOnce() async {
    final snapshot = await _db
        .collection('stories')
        .orderBy('updatedAt', descending: true)
        .get();
    return snapshot.docs.map((doc) => Story.fromFirestore(doc)).toList();
  }

  // Lấy một truyện theo ID
  Future<Story?> getStoryById(String storyId) async {
    try {
      final doc = await _db.collection('stories').doc(storyId).get();
      if (!doc.exists) return null;
      return Story.fromFirestore(doc);
    } catch (e) {
      debugPrint('[FirestoreService] Error getting story: $e');
      return null;
    }
  }

  // Thêm truyện mới
  Future<String> addStory(Story story) async {
    final docRef = await _db.collection('stories').add(story.toFirestore());
    return docRef.id;
  }

  // Cập nhật truyện (partial fields)
  Future<void> updateStory(String storyId, Map<String, dynamic> data) async {
    await _db.collection('stories').doc(storyId).update(data);
  }

  // Cập nhật toàn bộ truyện (dùng cho Edit Story)
  Future<void> updateStoryFull(Story story) async {
    await _db.collection('stories').doc(story.id).update(story.toFirestore());
  }

  // Tăng views
  Future<void> incrementViews(String storyId) async {
    await _db.collection('stories').doc(storyId).update({
      'views': FieldValue.increment(1),
    });
  }

  // === CHAPTERS ===

  // Lấy danh sách chương của một truyện (stream)
  Stream<List<Chapter>> getChapters(String storyId) {
    return _db
        .collection('stories')
        .doc(storyId)
        .collection('chapters')
        .orderBy('chapterNumber')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList();
    });
  }

  // Lấy danh sách chương (một lần)
  Future<List<Chapter>> getChaptersOnce(String storyId) async {
    final snapshot = await _db
        .collection('stories')
        .doc(storyId)
        .collection('chapters')
        .orderBy('chapterNumber')
        .get();
    return snapshot.docs.map((doc) => Chapter.fromFirestore(doc)).toList();
  }

  // Thêm chương mới
  Future<String> addChapter(String storyId, Chapter chapter) async {
    final docRef = await _db
        .collection('stories')
        .doc(storyId)
        .collection('chapters')
        .add(chapter.toFirestore());

    // Cập nhật chapterCount và updatedAt trong story
    await _db.collection('stories').doc(storyId).update({
      'chapterCount': FieldValue.increment(1),
      'updatedAt': Timestamp.now(),
    });

    return docRef.id;
  }

  // === CATEGORIES ===

  // Lấy tất cả thể loại (stream real-time)
  Stream<List<StoryCategory>> getCategories() {
    return _db
        .collection('categories')
        .orderBy('name')
        .snapshots()
        .map((snapshot) {
      return snapshot.docs.map((doc) => StoryCategory.fromFirestore(doc)).toList();
    });
  }

  // Lấy tất cả thể loại (một lần)
  Future<List<StoryCategory>> getCategoriesOnce() async {
    final snapshot = await _db
        .collection('categories')
        .orderBy('name')
        .get();
    return snapshot.docs.map((doc) => StoryCategory.fromFirestore(doc)).toList();
  }

  // Thêm thể loại mới
  Future<String> addCategory(String name) async {
    final docRef = await _db.collection('categories').add({'name': name});
    return docRef.id;
  }

  // Cập nhật thể loại
  Future<void> updateCategory(String categoryId, String newName) async {
    await _db.collection('categories').doc(categoryId).update({'name': newName});
  }

  // Xóa thể loại
  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  // === SEARCH / FILTER ===

  // Tìm truyện theo tên
  Future<List<Story>> searchStories(String query) async {
    // Firestore không hỗ trợ full-text search, nên dùng client-side filter
    final stories = await getStoriesOnce();
    final lowerQuery = query.toLowerCase();
    return stories.where((s) {
      return s.title.toLowerCase().contains(lowerQuery) ||
          s.author.toLowerCase().contains(lowerQuery) ||
          s.description.toLowerCase().contains(lowerQuery);
    }).toList();
  }

  // Lấy truyện hot (isHot = true hoặc views cao)
  Future<List<Story>> getHotStories() async {
    final snapshot = await _db
        .collection('stories')
        .where('isHot', isEqualTo: true)
        .orderBy('views', descending: true)
        .get();
    return snapshot.docs.map((doc) => Story.fromFirestore(doc)).toList();
  }

  // Lấy truyện top views  
  Future<List<Story>> getTopViewsStories({int limit = 10}) async {
    final snapshot = await _db
        .collection('stories')
        .orderBy('views', descending: true)
        .limit(limit)
        .get();
    return snapshot.docs.map((doc) => Story.fromFirestore(doc)).toList();
  }
}

