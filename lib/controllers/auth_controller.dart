import '../services/auth_service.dart';

class AuthController {
  AuthController({AuthService? authService})
    : _authService = authService ?? AuthService();

  final AuthService _authService;

  Future<AuthResult> login({required String email, required String password}) {
    return _authService.login(email, password);
  }

  Future<AuthResult> register({
    required String email,
    required String password,
    String? displayName,
  }) {
    return _authService.register(email, password, displayName: displayName);
  }
}
