/// Error API terstruktur (dipetakan dari envelope { success:false, message, errors }
/// atau dari kegagalan jaringan).
class ApiException implements Exception {
  final String message;
  final int? statusCode;

  /// Map error validasi Laravel: { field: [pesan, ...] }.
  final Map<String, dynamic>? errors;

  /// True bila kegagalan jaringan/timeout (tanpa respons HTTP dari server).
  final bool isNetwork;

  /// Kode mesin dari backend (mis. 'need_member', 'quota_exceeded',
  /// 'attempt_limit') untuk memicu aksi UI spesifik.
  final String? code;

  /// Isi field `data` dari envelope error (bila ada). Berguna mis. saat start
  /// ditolak karena ada attempt berjalan: backend dapat menyertakan id attempt
  /// di sini sehingga UI bisa menawarkan untuk melanjutkannya.
  final Map<String, dynamic>? payload;

  ApiException(this.message,
      {this.statusCode, this.errors, this.isNetwork = false, this.code, this.payload});

  /// Error yang bisa diselesaikan dengan upgrade membership.
  bool get needsUpgrade => code == 'need_member' || code == 'quota_exceeded' || code == 'attempt_limit';

  bool get isValidation => statusCode == 422;
  bool get isUnauthorized => statusCode == 401;
  bool get isForbidden => statusCode == 403;
  bool get isNotFound => statusCode == 404;
  bool get isConflict => statusCode == 409; // mis. double submit / attempt tak aktif
  bool get isServer => statusCode != null && statusCode! >= 500;

  /// Pesan validasi pertama (untuk ditampilkan cepat di UI).
  String get firstError {
    if (errors != null && errors!.isNotEmpty) {
      final first = errors!.values.first;
      if (first is List && first.isNotEmpty) return first.first.toString();
      return first.toString();
    }
    return message;
  }

  @override
  String toString() => 'ApiException($statusCode): $message';
}
