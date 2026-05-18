import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import '../models/account.dart';

// === SERVICE XÁC THỰC - FIREBASE AUTH (Singleton) ===
class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Cache user data từ Firestore
  AppUser? _cachedUser;

  // === GETTERS ===
  User? get firebaseUser => _auth.currentUser;
  bool get isLoggedIn => _auth.currentUser != null;
  String get displayName =>
      _cachedUser?.displayName ??
      firebaseUser?.email?.split('@').first ??
      'Khách';
  String get displayRole =>
      _cachedUser?.isAdmin == true ? 'Quản trị viên' : 'Người dùng';
  bool get isAdmin => _cachedUser?.isAdmin ?? false;
  AppUser? get currentUser => _cachedUser;

  // Stream theo dõi auth state thay đổi
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // === KHỞI TẠO ===
  Future<void> init() async {
    if (_auth.currentUser != null) {
      await _loadUserData();
    }
  }

  // Load user data từ Firestore
  Future<void> _loadUserData() async {
    final user = _auth.currentUser;
    if (user == null) return;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      if (doc.exists) {
        _cachedUser = AppUser.fromFirestore(
          doc.data() as Map<String, dynamic>,
          user.uid,
        );
      }
    } catch (e) {
      debugPrint('[AuthService] Error loading user data: $e');
    }
  }

  // === ĐĂNG KÝ ===
  Future<AuthResult> register(
    String email,
    String password, {
    String? displayName,
  }) async {
    // Validate
    if (email.trim().isEmpty) {
      return AuthResult.error('Vui lòng nhập email');
    }
    if (password.length < 6) {
      return AuthResult.error('Mật khẩu phải có ít nhất 6 ký tự');
    }

    try {
      // Tạo account Firebase Auth
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      final user = credential.user;
      if (user == null) return AuthResult.error('Đăng ký thất bại');

      // Tạo user document trong Firestore
      final appUser = AppUser(
        uid: user.uid,
        email: email.trim(),
        displayName: displayName ?? email.split('@').first,
        role: 'user',
        coins: 100, // Tặng 100 xu cho user mới!
        unlockedChapters: {},
        createdAt: DateTime.now(),
      );

      await _db.collection('users').doc(user.uid).set(appUser.toFirestore());
      _cachedUser = appUser;

      return AuthResult.success('Đăng ký thành công! 🎉 Tặng bạn 100 xu');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.error('Lỗi đăng ký: $e');
    }
  }

  // === ĐĂNG NHẬP ===
  Future<AuthResult> login(String email, String password) async {
    // Validate
    if (email.trim().isEmpty) {
      return AuthResult.error('Vui lòng nhập email');
    }
    if (password.isEmpty) {
      return AuthResult.error('Vui lòng nhập mật khẩu');
    }

    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );

      await _loadUserData();

      return AuthResult.success('Đăng nhập thành công!');
    } on FirebaseAuthException catch (e) {
      return AuthResult.error(_mapAuthError(e.code));
    } catch (e) {
      return AuthResult.error('Lỗi đăng nhập: $e');
    }
  }

  // === ĐĂNG XUẤT ===
  Future<void> logout() async {
    await _auth.signOut();
    _cachedUser = null;
  }

  // === KIỂM TRA QUYỀN ĐỌC CHƯƠNG ===
  bool canReadChapter(
    int chapterIndex, {
    int freeChapters = 3,
    String storyId = '',
    String chapterId = '',
  }) {
    // Chương miễn phí (chapterIndex bắt đầu từ 0)
    if (chapterIndex < freeChapters) return true;

    // Chưa đăng nhập → không đọc được
    if (!isLoggedIn) return false;

    // Đã đăng nhập → kiểm tra đã mở khóa chưa
    if (_cachedUser != null && storyId.isNotEmpty && chapterId.isNotEmpty) {
      final key = '${storyId}_$chapterId';
      return _cachedUser!.unlockedChapters[key] == true;
    }

    // Chưa có data unlock → mặc định KHÔNG cho đọc chương trả phí
    return false;
  }

  // Refresh cached user data
  Future<void> refreshUserData() async {
    await _loadUserData();
  }

  // Dịch mã lỗi Firebase Auth sang tiếng Việt
  String _mapAuthError(String code) {
    switch (code) {
      case 'email-already-in-use':
        return 'Email đã được sử dụng bởi tài khoản khác';
      case 'invalid-email':
        return 'Email không hợp lệ';
      case 'weak-password':
        return 'Mật khẩu quá yếu (tối thiểu 6 ký tự)';
      case 'user-not-found':
        return 'Tài khoản không tồn tại';
      case 'wrong-password':
        return 'Mật khẩu không chính xác';
      case 'invalid-credential':
        return 'Email hoặc mật khẩu không đúng';
      case 'too-many-requests':
        return 'Quá nhiều lần thử. Vui lòng đợi một lát';
      case 'user-disabled':
        return 'Tài khoản đã bị khóa';
      default:
        return 'Đã xảy ra lỗi ($code)';
    }
  }
}

// === KẾT QUẢ XÁC THỰC ===
class AuthResult {
  final bool isSuccess;
  final String message;

  AuthResult._({required this.isSuccess, required this.message});

  factory AuthResult.success(String message) =>
      AuthResult._(isSuccess: true, message: message);

  factory AuthResult.error(String message) =>
      AuthResult._(isSuccess: false, message: message);
}
