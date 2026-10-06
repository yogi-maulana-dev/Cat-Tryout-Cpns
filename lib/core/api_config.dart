/// Konfigurasi endpoint backend Laravel (Try Out Bayog).
///
/// Ganti [host] sesuai lingkungan menjalankan backend `php artisan serve`:
///  - Android emulator      : http://10.0.2.2:8000   (10.0.2.2 = localhost host)
///  - iOS simulator/desktop : http://127.0.0.1:8000
///  - Flutter web           : http://127.0.0.1:8000  (pastikan CORS backend mengizinkan)
///  - HP fisik (USB/Wi-Fi)  : http://<IP-komputer>:8000  (mis. 192.168.1.10)
class ApiConfig {
  /// Ubah satu baris ini saja saat pindah lingkungan.
  /// Web/Chrome & desktop: 127.0.0.1 ; Emulator Android: 10.0.2.2
  static const String host = 'http://127.0.0.1:8000';

  /// Semua endpoint berada di bawah /api/v1 (lihat backend routes/api.php).
  /// Trailing slash WAJIB: Dio menggabung baseUrl + path relatif ("auth/login")
  /// tanpa menyisipkan "/", jadi tanpa ini URL jadi ".../v1auth/login" (404).
  static const String baseUrl = '$host/api/v1/';

  static const Duration connectTimeout = Duration(seconds: 15);
  static const Duration receiveTimeout = Duration(seconds: 20);

  // ---------------------------------------------------------------------------
  // Reverb (WebSocket) — HARUS sinkron dengan .env backend (REVERB_APP_KEY dst).
  //   Dev  : host 10.0.2.2 (emulator), port 8080, TLS off.
  //   Prod : host = domain, port 443, TLS on (mis. wss://api.example).
  // ---------------------------------------------------------------------------
  static const String reverbKey = 'hjzsmbcgratenape3cuq'; // = REVERB_APP_KEY backend
  static const String reverbCluster = 'mt1'; // diabaikan Reverb, tapi paket wajib isi
  static const String reverbHost = '127.0.0.1';
  static const int reverbPort = 8080;
  static const bool reverbUseTLS = false;

  /// Endpoint auth channel privat (Sanctum) di backend.
  static const String broadcastingAuthUrl = '$host/api/v1/broadcasting/auth';
}
