import '../core/api_client.dart';
import '../core/token_storage.dart';
import '../models/user.dart';

class AuthResult {
  final User user;
  final String token;
  AuthResult(this.user, this.token);
}

class AuthService {
  final ApiClient _api;
  final TokenStorage _tokenStorage;

  AuthService({ApiClient? api, TokenStorage? tokenStorage})
      : _api = api ?? ApiClient(),
        _tokenStorage = tokenStorage ?? TokenStorage();

  /// GET /auth/captcha → { id, image (data URI PNG) }
  Future<Map<String, dynamic>> captcha() async {
    final data = await _api.get('auth/captcha');
    return Map<String, dynamic>.from(data);
  }

  /// POST /auth/register (captcha opsional — wajib bila backend mengaktifkannya)
  Future<AuthResult> register({
    required String name,
    required String email,
    required String password,
    String? nomorHp,
    String? captchaId,
    String? captcha,
  }) async {
    final data = await _api.post('auth/register', body: {
      'name': name,
      'email': email,
      'password': password,
      'password_confirmation': password,
      'device_name': 'flutter',
      if (nomorHp != null && nomorHp.isNotEmpty) 'nomor_hp': nomorHp,
      if (captchaId != null) 'captcha_id': captchaId,
      if (captcha != null) 'captcha': captcha,
    });
    return _handleAuth(data);
  }

  /// POST /auth/login
  Future<AuthResult> login({
    required String email,
    required String password,
    String? captchaId,
    String? captcha,
  }) async {
    final data = await _api.post('auth/login', body: {
      'email': email,
      'password': password,
      'device_name': 'flutter',
      if (captchaId != null) 'captcha_id': captchaId,
      if (captcha != null) 'captcha': captcha,
    });
    return _handleAuth(data);
  }

  /// POST /auth/forgot-password
  Future<void> forgotPassword(String email) async {
    await _api.post('auth/forgot-password', body: {'email': email});
  }

  /// POST /auth/reset-password
  Future<void> resetPassword({
    required String email,
    required String token,
    required String password,
  }) async {
    await _api.post('auth/reset-password', body: {
      'email': email,
      'token': token,
      'password': password,
      'password_confirmation': password,
    });
  }

  /// GET /auth/me
  Future<User> me() async {
    final data = await _api.get('auth/me');
    return User.fromJson(Map<String, dynamic>.from(data));
  }

  /// POST /auth/logout — hapus token di server & lokal.
  Future<void> logout() async {
    try {
      await _api.post('auth/logout');
    } finally {
      await _tokenStorage.clear();
    }
  }

  Future<AuthResult> _handleAuth(dynamic data) async {
    final map = Map<String, dynamic>.from(data);
    final token = map['token'].toString();
    await _tokenStorage.save(token);
    return AuthResult(User.fromJson(Map<String, dynamic>.from(map['user'])), token);
  }
}
