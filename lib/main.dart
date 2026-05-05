import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'screens/splash_screen.dart';
import 'utils/themes.dart';

// === ENTRY POINT - ỨNG DỤNG ĐỌC TRUYỆN ===
void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Khởi tạo Firebase
  await Firebase.initializeApp();

  // Giam dung luong ImageCache de tranh peak RAM qua cao tren may ao RAM thap.
  final imageCache = PaintingBinding.instance.imageCache;
  imageCache.maximumSize = 80;
  imageCache.maximumSizeBytes = 40 << 20;

  // Cài đặt thanh trạng thái trong suốt
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
    ),
  );

  runApp(const TruyenHayApp());
}

class TruyenHayApp extends StatelessWidget {
  const TruyenHayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'MangaHay',
      debugShowCheckedModeBanner: false, // Ẩn banner debug
      // Theme sáng
      theme: AppThemes.lightTheme,

      // Theme tối
      darkTheme: AppThemes.darkTheme,

      // Tự động theo cài đặt hệ thống
      themeMode: ThemeMode.system,

      // Màn hình bắt đầu: Splash Screen
      home: const SplashScreen(),
    );
  }
}
