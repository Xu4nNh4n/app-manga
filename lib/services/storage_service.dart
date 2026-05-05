import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';

// === SERVICE FIREBASE STORAGE - UPLOAD / DOWNLOAD ẢNH ===
class StorageService {
  static final StorageService _instance = StorageService._internal();
  factory StorageService() => _instance;
  StorageService._internal();

  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Upload ảnh bìa truyện
  Future<String> uploadCoverImage(File file, String storyId) async {
    try {
      final ref = _storage.ref('covers/$storyId.jpg');
      final uploadTask = await ref.putFile(
        file,
        SettableMetadata(contentType: 'image/jpeg'),
      );
      return await uploadTask.ref.getDownloadURL();
    } catch (e) {
      debugPrint('[StorageService] Error uploading cover: $e');
      rethrow;
    }
  }

  // Upload nhiều trang truyện (chapter pages)
  Future<List<String>> uploadChapterPages(
    List<File> files,
    String storyId,
    int chapterNumber,
  ) async {
    final urls = <String>[];
    for (int i = 0; i < files.length; i++) {
      try {
        final ref = _storage.ref(
          'chapters/$storyId/ch$chapterNumber/page_${i + 1}.jpg',
        );
        final uploadTask = await ref.putFile(
          files[i],
          SettableMetadata(contentType: 'image/jpeg'),
        );
        final url = await uploadTask.ref.getDownloadURL();
        urls.add(url);
      } catch (e) {
        debugPrint('[StorageService] Error uploading page ${i + 1}: $e');
        rethrow;
      }
    }
    return urls;
  }

  // Xóa file theo URL
  Future<void> deleteFile(String url) async {
    try {
      final ref = _storage.refFromURL(url);
      await ref.delete();
    } catch (e) {
      debugPrint('[StorageService] Error deleting file: $e');
    }
  }
}
