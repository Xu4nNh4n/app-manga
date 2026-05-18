import '../services/auth_service.dart';
import '../services/coin_service.dart';

export '../services/coin_service.dart' show CoinPackage, CoinService;

class ProfileController {
  ProfileController({AuthService? authService, CoinService? coinService})
    : authService = authService ?? AuthService(),
      coinService = coinService ?? CoinService();

  final AuthService authService;
  final CoinService coinService;

  bool get isLoggedIn => authService.isLoggedIn;
  bool get isAdmin => authService.isAdmin;
  String get displayName => authService.displayName;
  String get displayRole => authService.displayRole;

  Stream<int> getUserCoins() => coinService.getUserCoins();

  Future<bool> purchaseCoins(CoinPackage package) {
    return coinService.purchaseCoins(package);
  }

  Future<void> logout() => authService.logout();
}
