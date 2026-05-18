import 'package:cloud_firestore/cloud_firestore.dart';
import 'chuong.dart';

// Model cho một truyện
class Story {
  final String id; // ID duy nhất (Firestore doc ID)
  final String title; // Tên truyện
  final String author; // Tác giả
  final String coverImage; // URL ảnh bìa (Firebase Storage)
  final String description; // Mô tả / Tóm tắt truyện
  final List<String> genres; // Thể loại (VD: ["Tiên hiệp", "Hành động"])
  final int chapterCount; // Tổng số chương
  final double rating; // Đánh giá (0-5 sao)
  final String status; // Trạng thái: "Đang ra" hoặc "Hoàn thành"
  final DateTime lastUpdated; // Ngày cập nhật gần nhất
  final int views; // Số lượt xem
  final bool isHot; // Truyện đang hot?
  final int freeChapters; // Số chương miễn phí
  final int coinPerChapter; // Giá coin cho mỗi chương trả phí
  final DateTime createdAt; // Ngày tạo

  // Chapters được load riêng từ subcollection
  final List<Chapter> chapters;

  const Story({
    required this.id,
    required this.title,
    required this.author,
    required this.coverImage,
    required this.description,
    required this.genres,
    required this.chapterCount,
    required this.rating,
    required this.status,
    required this.lastUpdated,
    required this.chapters,
    this.views = 0,
    this.isHot = false,
    this.freeChapters = 3,
    this.coinPerChapter = 5,
    DateTime? createdAt,
  }) : createdAt = createdAt ?? lastUpdated;

  // Parse từ Firestore document
  factory Story.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Story(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverImage: data['coverImage'] ?? '',
      description: data['description'] ?? '',
      genres: List<String>.from(data['genres'] ?? []),
      chapterCount: (data['chapterCount'] ?? 0).toInt(),
      rating: (data['rating'] ?? 0.0).toDouble(),
      status: data['status'] ?? 'Đang ra',
      lastUpdated:
          (data['updatedAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      views: (data['views'] ?? 0).toInt(),
      isHot: data['isHot'] ?? false,
      freeChapters: (data['freeChapters'] ?? 3).toInt(),
      coinPerChapter: (data['coinPerChapter'] ?? 5).toInt(),
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      chapters: [], // Chapters được load riêng từ subcollection
    );
  }

  // Chuyển sang Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'title': title,
      'author': author,
      'coverImage': coverImage,
      'description': description,
      'genres': genres,
      'chapterCount': chapterCount,
      'rating': rating,
      'status': status,
      'updatedAt': Timestamp.fromDate(lastUpdated),
      'views': views,
      'isHot': isHot,
      'freeChapters': freeChapters,
      'coinPerChapter': coinPerChapter,
      'createdAt': Timestamp.fromDate(createdAt),
    };
  }

  // Copy with để cập nhật chapters
  Story copyWith({List<Chapter>? chapters, int? views}) {
    return Story(
      id: id,
      title: title,
      author: author,
      coverImage: coverImage,
      description: description,
      genres: genres,
      chapterCount: chapterCount,
      rating: rating,
      status: status,
      lastUpdated: lastUpdated,
      chapters: chapters ?? this.chapters,
      views: views ?? this.views,
      isHot: isHot,
      freeChapters: freeChapters,
      coinPerChapter: coinPerChapter,
      createdAt: createdAt,
    );
  }
}
