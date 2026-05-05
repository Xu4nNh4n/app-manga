// Model cho tài khoản người dùng (Firebase Auth + Firestore)
class AppUser {
  final String uid; // Firebase Auth UID
  final String email; // Email đăng nhập
  final String displayName; // Tên hiển thị
  final String role; // 'admin' hoặc 'user'
  final int coins; // Số xu hiện có
  final Map<String, bool> unlockedChapters; // {"storyId_chapterId": true}
  final DateTime createdAt;

  const AppUser({
    required this.uid,
    required this.email,
    required this.displayName,
    required this.role,
    this.coins = 0,
    this.unlockedChapters = const {},
    required this.createdAt,
  });

  // Parse từ Firestore
  factory AppUser.fromFirestore(Map<String, dynamic> data, String uid) {
    return AppUser(
      uid: uid,
      email: data['email'] ?? '',
      displayName: data['displayName'] ?? '',
      role: data['role'] ?? 'user',
      coins: (data['coins'] ?? 0).toInt(),
      unlockedChapters: Map<String, bool>.from(data['unlockedChapters'] ?? {}),
      createdAt: data['createdAt'] != null
          ? (data['createdAt'] as dynamic).toDate()
          : DateTime.now(),
    );
  }

  // Chuyển sang Firestore map
  Map<String, dynamic> toFirestore() {
    return {
      'email': email,
      'displayName': displayName,
      'role': role,
      'coins': coins,
      'unlockedChapters': unlockedChapters,
      'createdAt': createdAt,
    };
  }

  // Kiểm tra quyền
  bool get isAdmin => role == 'admin';
  bool get isUser => role == 'user';
}
