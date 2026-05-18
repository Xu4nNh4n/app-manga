import 'package:cloud_firestore/cloud_firestore.dart';

// Model cho Thể loại truyện (quản lý bởi Admin)
class StoryCategory {
  final String id;
  final String name;

  const StoryCategory({required this.id, required this.name});

  // Parse từ Firestore document
  factory StoryCategory.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>;
    return StoryCategory(id: doc.id, name: data['name'] ?? '');
  }

  // Chuyển sang Firestore map
  Map<String, dynamic> toFirestore() {
    return {'name': name};
  }
}
