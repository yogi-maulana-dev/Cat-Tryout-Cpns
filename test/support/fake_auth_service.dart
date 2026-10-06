import 'package:try_out_bayog/services/auth_service.dart';

/// PNG 1x1 transparan (data URI) untuk captcha palsu di test.
const String kTinyPngDataUri =
    'data:image/png;base64,iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mNk+M9QDwADhgGAWjR9awAAAABJRU5ErkJggg==';

/// AuthService palsu untuk test — tidak menyentuh jaringan.
class FakeAuthService extends AuthService {
  FakeAuthService({this.captchaEnabled = true});

  final bool captchaEnabled;
  int captchaCalls = 0;

  @override
  Future<Map<String, dynamic>> captcha() async {
    captchaCalls++;
    if (!captchaEnabled) {
      // Simulasikan captcha nonaktif/tak terjangkau.
      throw Exception('captcha unavailable');
    }
    return {'id': 'cap-$captchaCalls', 'image': kTinyPngDataUri};
  }
}
