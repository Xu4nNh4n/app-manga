import 'package:cloud_firestore/cloud_firestore.dart';

// Model cho một chương truyện
class Chapter {
  final String id; // Firestore doc ID
  final int chapterNumber; // Số thứ tự chương
  final String title; // Tiêu đề chương
  final List<String> pages; // Danh sách URL ảnh (Firebase Storage)
  final DateTime publishDate; // Ngày phát hành

  const Chapter({
    this.id = '',
    required this.chapterNumber,
    required this.title,
    required this.pages,
    required this.publishDate,
  });

  // Số trang
  int get pageCount => pages.length;

  // Parse từ Firestore document
  factory Chapter.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return Chapter(
      id: doc.id,
      chapterNumber: (data['chapterNumber'] ?? 0).toInt(),
      title: data['title'] ?? '',
      pages: List<String>.from(data['pages'] ?? []),
      publishDate: (data['publishDate'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  // Chuyển sang Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'chapterNumber': chapterNumber,
      'title': title,
      'pages': pages,
      'publishDate': Timestamp.fromDate(publishDate),
    };
  }
}
