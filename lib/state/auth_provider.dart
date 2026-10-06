import 'package:flutter/foundation.dart';

import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/user.dart';
import '../services/auth_service.dart';

enum AuthStatus { unknown, authenticated, unauthenticated }

class AuthProvider extends ChangeNotifier {
  final AuthService _auth;
  final TokenStorage _tokenStorage;

  AuthProvider({AuthService? auth, TokenStorage? tokenStorage})
      : _auth = auth ?? AuthService(),
        _tokenStorage = tokenStorage ?? TokenStorage() {
    // Sesi kedaluwarsa (401 pada permintaan ber-token) → paksa logout global.
    ApiClient.onUnauthorized = _onUnauthorized;
  }

  /// Dipicu dari ApiClient saat token ditolak server. Hindari aksi ganda bila
  /// sudah tidak terautentikasi.
  void _onUnauthorized() {
    if (status == AuthStatus.unauthenticated) return;
    forceLogout();
  }

  /// Logout lokal tanpa memanggil API (dipakai saat token sudah tak valid).
  Future<void> forceLogout() async {
    await _tokenStorage.clear();
    _set(AuthStatus.unauthenticated, null);
  }

  AuthStatus status = AuthStatus.unknown;
  User? user;

  /// Dipanggil saat splash: kalau ada token valid → authenticated.
  Future<void> bootstrap() async {
    final token = await _tokenStorage.read();
    if (token == null || token.isEmpty) {
      _set(AuthStatus.unauthenticated, null);
      return;
    }
    try {
      final me = await _auth.me();
      _set(AuthStatus.authenticated, me);
    } catch (_) {
      await _tokenStorage.clear();
      _set(AuthStatus.unauthenticated, null);
    }
  }

  Future<void> login(String email, String password, {String? captchaId, String? captcha}) async {
    final res = await _auth.login(
      email: email,
      password: password,
      captchaId: captchaId,
      captcha: captcha,
    );
    _set(AuthStatus.authenticated, res.user);
  }

  Future<void> register(String name, String email, String password,
      {String? nomorHp, String? captchaId, String? captcha}) async {
    final res = await _auth.register(
      name: name,
      email: email,
      password: password,
      nomorHp: nomorHp,
      captchaId: captchaId,
      captcha: captcha,
    );
    _set(AuthStatus.authenticated, res.user);
  }

  Future<void> logout() async {
    await _auth.logout();
    _set(AuthStatus.unauthenticated, null);
  }

  void _set(AuthStatus s, User? u) {
    status = s;
    user = u;
    notifyListeners();
  }
}
