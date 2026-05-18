import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart';

import '../services/auth_service.dart';

class SplashController {
  SplashController({AuthService? authService}) : _authService = authService;

  AuthService? _authService;

  Future<void> init() async {
    try {
      await (_authService ??= AuthService()).init();
    } on FirebaseException catch (error) {
      if (error.code != 'no-app') rethrow;
      debugPrint('[SplashController] Firebase is not initialized.');
    }
  }
}
