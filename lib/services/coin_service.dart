import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'auth_service.dart';

// === SERVICE QUẢN LÝ COIN ===
class CoinService {
  static final CoinService _instance = CoinService._internal();
  factory CoinService() => _instance;
  CoinService._internal();

  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final AuthService _auth = AuthService();

  // === GÓI NẠP XU (Demo - ấn là nạp luôn) ===
  static const List<CoinPackage> packages = [
    CoinPackage(id: 'pack_10k', name: '1,000 Xu', coins: 1000, price: '10,000đ', priceValue: 10000),
    CoinPackage(id: 'pack_20k', name: '2,000 Xu', coins: 2000, price: '20,000đ', priceValue: 20000),
    CoinPackage(id: 'pack_50k', name: '5,500 Xu', coins: 5500, price: '50,000đ', priceValue: 50000),
    CoinPackage(id: 'pack_100k', name: '12,000 Xu', coins: 12000, price: '100,000đ', priceValue: 100000),
    CoinPackage(id: 'pack_200k', name: '25,000 Xu', coins: 25000, price: '200,000đ', priceValue: 200000),
    CoinPackage(id: 'pack_500k', name: '70,000 Xu', coins: 70000, price: '500,000đ', priceValue: 500000),
  ];

  // Lấy số xu hiện tại (stream real-time)
  Stream<int> getUserCoins() {
    final user = _auth.firebaseUser;
    if (user == null) return Stream.value(0);

    return _db
        .collection('users')
        .doc(user.uid)
        .snapshots()
        .map((doc) {
      final data = doc.data();
      return (data?['coins'] ?? 0) as int;
    });
  }

  // Lấy số xu một lần
  Future<int> getUserCoinsOnce() async {
    final user = _auth.firebaseUser;
    if (user == null) return 0;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      return (doc.data()?['coins'] ?? 0) as int;
    } catch (e) {
      debugPrint('[CoinService] Error getting coins: $e');
      return 0;
    }
  }

  // Nạp xu (demo - ấn là nạp luôn)
  Future<bool> purchaseCoins(CoinPackage package) async {
    final user = _auth.firebaseUser;
    if (user == null) return false;

    try {
      await _db.collection('users').doc(user.uid).update({
        'coins': FieldValue.increment(package.coins),
      });

      // Refresh cached user data
      await _auth.refreshUserData();
      return true;
    } catch (e) {
      debugPrint('[CoinService] Error purchasing coins: $e');
      return false;
    }
  }

  // Mở khóa chương bằng coin
  Future<CoinResult> unlockChapter({
    required String storyId,
    required String chapterId,
    required int cost,
  }) async {
    final user = _auth.firebaseUser;
    if (user == null) return CoinResult.error('Vui lòng đăng nhập');

    try {
      // Kiểm tra đã mở khóa chưa
      final key = '${storyId}_$chapterId';
      final userDoc = await _db.collection('users').doc(user.uid).get();
      final userData = userDoc.data() ?? {};
      final unlockedChapters = Map<String, dynamic>.from(
        userData['unlockedChapters'] ?? {},
      );

      if (unlockedChapters[key] == true) {
        return CoinResult.success('Chương đã được mở khóa trước đó');
      }

      // Kiểm tra đủ coin
      final currentCoins = (userData['coins'] ?? 0) as int;
      if (currentCoins < cost) {
        return CoinResult.error(
          'Không đủ xu! Bạn cần $cost xu nhưng chỉ có $currentCoins xu',
        );
      }

      // Trừ coin + Lưu unlock
      await _db.collection('users').doc(user.uid).update({
        'coins': FieldValue.increment(-cost),
        'unlockedChapters.$key': true,
      });

      // Refresh cached data
      await _auth.refreshUserData();

      return CoinResult.success('Đã mở khóa thành công! (-$cost xu)');
    } catch (e) {
      debugPrint('[CoinService] Error unlocking chapter: $e');
      return CoinResult.error('Lỗi mở khóa: $e');
    }
  }

  // Kiểm tra chương đã mở khóa chưa
  Future<bool> isChapterUnlocked(String storyId, String chapterId) async {
    final user = _auth.firebaseUser;
    if (user == null) return false;

    try {
      final doc = await _db.collection('users').doc(user.uid).get();
      final data = doc.data() ?? {};
      final unlockedChapters = Map<String, dynamic>.from(
        data['unlockedChapters'] ?? {},
      );
      final key = '${storyId}_$chapterId';
      return unlockedChapters[key] == true;
    } catch (e) {
      return false;
    }
  }
}

// === GÓI NẠP XU ===
class CoinPackage {
  final String id;
  final String name; // "1,000 Xu"
  final int coins; // Số xu nhận được
  final String price; // "10,000đ"
  final int priceValue; // 10000 (cho sort)

  const CoinPackage({
    required this.id,
    required this.name,
    required this.coins,
    required this.price,
    required this.priceValue,
  });

  // Tính bonus percentage
  String get bonus {
    final actualRate = (coins / (priceValue / 10000) - 1000);
    if (actualRate > 0) {
      final pct = ((coins / (priceValue / 10000) - 1000) / 1000 * 100).round();
      if (pct > 0) return '+$pct%';
    }
    return '';
  }
}

// === KẾT QUẢ GIAO DỊCH COIN ===
class CoinResult {
  final bool isSuccess;
  final String message;

  CoinResult._({required this.isSuccess, required this.message});

  factory CoinResult.success(String message) =>
      CoinResult._(isSuccess: true, message: message);

  factory CoinResult.error(String message) =>
      CoinResult._(isSuccess: false, message: message);
}
