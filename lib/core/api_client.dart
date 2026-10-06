import 'package:dio/dio.dart';

import 'api_config.dart';
import 'api_exception.dart';
import 'token_storage.dart';

/// Wrapper Dio: menambahkan Bearer token otomatis, meng-handle envelope
/// { success, message, data }, dan memetakan error ke [ApiException].
///
/// Semua method mengembalikan isi field `data` dari envelope.
class ApiClient {
  /// Dipanggil saat permintaan ber-token ditolak 401 (sesi kedaluwarsa).
  /// Di-set oleh AuthProvider untuk memaksa logout & kembali ke login.
  static void Function()? onUnauthorized;

  final Dio _dio;
  final TokenStorage _tokenStorage;

  ApiClient({Dio? dio, TokenStorage? tokenStorage})
      : _tokenStorage = tokenStorage ?? TokenStorage(),
        _dio = dio ??
            Dio(BaseOptions(
              baseUrl: ApiConfig.baseUrl,
              connectTimeout: ApiConfig.connectTimeout,
              receiveTimeout: ApiConfig.receiveTimeout,
              headers: {'Accept': 'application/json'},
              // Jangan lempar untuk 4xx; kita map sendiri jadi ApiException.
              validateStatus: (status) => status != null && status < 500,
            )) {
    _dio.interceptors.add(InterceptorsWrapper(
      onRequest: (options, handler) async {
        final token = await _tokenStorage.read();
        if (token != null && token.isNotEmpty) {
          options.headers['Authorization'] = 'Bearer $token';
          options.extra['_authed'] = true; // tandai permintaan ber-token
        }
        handler.next(options);
      },
    ));
  }

  Future<dynamic> get(String path, {Map<String, dynamic>? query}) =>
      _send(() => _dio.get(path, queryParameters: query));

  Future<dynamic> post(String path, {Object? body}) =>
      _send(() => _dio.post(path, data: body));

  Future<dynamic> put(String path, {Object? body}) =>
      _send(() => _dio.put(path, data: body));

  Future<dynamic> delete(String path) => _send(() => _dio.delete(path));

  Future<dynamic> _send(Future<Response> Function() request) async {
    late Response res;
    try {
      res = await request();
    } on DioException catch (e) {
      throw _mapDioError(e);
    }

    final status = res.statusCode ?? 0;
    final data = res.data;
    final bool ok = data is Map && data['success'] == true;

    if (status >= 200 && status < 300 && ok) {
      return data['data'];
    }

    // Sesi kedaluwarsa pada permintaan ber-token → paksa logout (sekali).
    if (status == 401 && res.requestOptions.extra['_authed'] == true) {
      onUnauthorized?.call();
    }

    // Envelope error dari backend.
    if (data is Map) {
      throw ApiException(
        (data['message'] ?? 'Terjadi kesalahan.').toString(),
        statusCode: status,
        errors: data['errors'] is Map ? Map<String, dynamic>.from(data['errors']) : null,
        code: data['code']?.toString(),
        payload: data['data'] is Map ? Map<String, dynamic>.from(data['data']) : null,
      );
    }
    throw ApiException('Respons server tidak valid.', statusCode: status);
  }

  /// Pesan ramah (bahasa Indonesia) untuk kegagalan Dio/jaringan & 5xx.
  ApiException _mapDioError(DioException e) {
    final status = e.response?.statusCode;

    switch (e.type) {
      case DioExceptionType.connectionTimeout:
      case DioExceptionType.sendTimeout:
      case DioExceptionType.receiveTimeout:
        return ApiException('Koneksi ke server timeout. Coba lagi.', isNetwork: true);
      case DioExceptionType.connectionError:
        return ApiException('Tidak dapat terhubung ke server. Periksa koneksi internetmu.', isNetwork: true);
      case DioExceptionType.cancel:
        return ApiException('Permintaan dibatalkan.', isNetwork: true);
      case DioExceptionType.badCertificate:
        return ApiException('Sertifikat server tidak valid.', isNetwork: true);
      case DioExceptionType.badResponse:
      default:
        // 5xx: utamakan pesan envelope bila ada, jika tidak pakai pesan ramah.
        final data = e.response?.data;
        if (data is Map && data['message'] != null) {
          return ApiException(data['message'].toString(), statusCode: status);
        }
        if (status != null && status >= 500) {
          return ApiException('Server sedang bermasalah. Coba beberapa saat lagi.', statusCode: status);
        }
        return ApiException(
          e.message ?? 'Terjadi kesalahan jaringan.',
          statusCode: status,
          isNetwork: status == null,
        );
    }
  }
}
