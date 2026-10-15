/// Konfigurasi endpoint backend Laravel (Try Out Bayog).
///
/// Nilai dapat diatur saat build tanpa mengubah kode, memakai `--dart-define`.
/// Ini penting untuk deploy ke hosting/VPS (produksi) vs development lokal.
///
/// Contoh build web produksi (arahkan ke API domain + Reverb TLS):
///   flutter build web --release \
///     --dart-define=API_HOST=https://api.bisapns.id \
///     --dart-define=REVERB_HOST=api.bisapns.id \
///     --dart-define=REVERB_PORT=443 \
///     --dart-define=REVERB_TLS=true \
///     --dart-define=REVERB_KEY=<REVERB_APP_KEY backend>
///
/// Default (tanpa dart-define) = development lokal:
///  - Android emulator      : http://10.0.2.2:8000
///  - iOS simulator/desktop : http://127.0.0.1:8000
///  - Flutter web           : http://127.0.0.1:8000  (pastikan CORS backend mengizinkan)
///  - HP fisik (USB/Wi-Fi)  : http://<IP-komputer>:8000
class ApiConfig {
  /// Host backend. Override: `--dart-define=API_HOST=https://api.domain.com`.
  /// (Tanpa trailing slash.) Web/Chrome & desktop default: 127.0.0.1.
  static const String host =
      String.fromEnvironment('API_HOST', defaultValue: 'http://127.0.0.1:8000');

  /// Semua endpoint berada di bawah /api/v1 (lihat backend routes/api.php).
  /// Trailing slash WAJIB: Dio menggabung baseUrl + path relatif ("auth/login")
  /// tanpa menyisipkan "/", jadi tanpa ini URL jadi ".../v1auth/login" (404).
  static const String baseUrl = '$host/api/v1/';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ---------------------------------------------------------------------------
  // Reverb (WebSocket) — HARUS sinkron dengan .env backend (REVERB_APP_KEY dst).
  //   Dev  : host 127.0.0.1 (atau 10.0.2.2 emulator), port 8080, TLS off.
  //   Prod : host = domain, port 443, TLS on (wss://), lewat reverse proxy.
  // Override lewat --dart-define=REVERB_HOST / REVERB_PORT / REVERB_TLS / REVERB_KEY.
  // ---------------------------------------------------------------------------
  static const String reverbKey =
      String.fromEnvironment('REVERB_KEY', defaultValue: 'hjzsmbcgratenape3cuq');
  static const String reverbCluster = 'mt1'; // diabaikan Reverb, tapi paket wajib isi
  static const String reverbHost =
      String.fromEnvironment('REVERB_HOST', defaultValue: '127.0.0.1');
  static const int reverbPort =
      int.fromEnvironment('REVERB_PORT', defaultValue: 8080);
  static const bool reverbUseTLS =
      bool.fromEnvironment('REVERB_TLS', defaultValue: false);

  /// Endpoint auth channel privat (Sanctum) di backend.
  static const String broadcastingAuthUrl = '$host/api/v1/broadcasting/auth';
}
