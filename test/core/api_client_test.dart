import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:try_out_bayog/core/api_client.dart';
import 'package:try_out_bayog/core/api_exception.dart';
import 'package:try_out_bayog/core/token_storage.dart';

/// TokenStorage palsu (tanpa secure storage asli).
class _FakeTokenStorage extends TokenStorage {
  String? token;
  _FakeTokenStorage([this.token]);
  @override
  Future<String?> read() async => token;
  @override
  Future<void> save(String t) async => token = t;
  @override
  Future<void> clear() async => token = null;
}

/// Adapter yang mengembalikan respons kalengan, atau melempar DioException.
class _FakeAdapter implements HttpClientAdapter {
  _FakeAdapter.response(this.status, this.body) : error = null;
  _FakeAdapter.failure(this.error)
      : status = 0,
        body = const {};

  final int status;
  final Object body;
  final DioExceptionType? error;

  @override
  void close({bool force = false}) {}

  @override
  Future<ResponseBody> fetch(RequestOptions options, Stream<List<int>>? requestStream, Future<void>? cancelFuture) async {
    if (error != null) {
      throw DioException(requestOptions: options, type: error!);
    }
    return ResponseBody.fromString(
      jsonEncode(body),
      status,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }
}

ApiClient _client(_FakeAdapter adapter, {TokenStorage? storage}) {
  final dio = Dio(BaseOptions(
    baseUrl: 'http://test.local/',
    validateStatus: (s) => s != null && s < 500,
  ))
    ..httpClientAdapter = adapter;
  return ApiClient(dio: dio, tokenStorage: storage ?? _FakeTokenStorage());
}

void main() {
  tearDown(() => ApiClient.onUnauthorized = null);

  group('ApiException', () {
    test('helper status getters', () {
      expect(ApiException('x', statusCode: 401).isUnauthorized, isTrue);
      expect(ApiException('x', statusCode: 403).isForbidden, isTrue);
      expect(ApiException('x', statusCode: 404).isNotFound, isTrue);
      expect(ApiException('x', statusCode: 422).isValidation, isTrue);
      expect(ApiException('x', statusCode: 409).isConflict, isTrue);
      expect(ApiException('x', statusCode: 500).isServer, isTrue);
      expect(ApiException('x', isNetwork: true).isNetwork, isTrue);
    });

    test('firstError mengambil pesan validasi pertama', () {
      final e = ApiException('umum', statusCode: 422, errors: {
        'email': ['Email wajib diisi', 'lain'],
      });
      expect(e.firstError, 'Email wajib diisi');
    });
  });

  group('ApiClient envelope', () {
    test('sukses mengembalikan field data', () async {
      final api = _client(_FakeAdapter.response(200, {'success': true, 'data': {'x': 1}}));
      final data = await api.get('ping');
      expect(data, {'x': 1});
    });

    test('error envelope dipetakan ke ApiException', () async {
      final api = _client(_FakeAdapter.response(422, {
        'success': false,
        'message': 'Validasi gagal',
        'errors': {'email': ['wajib']},
      }));
      expect(
        () => api.post('x'),
        throwsA(isA<ApiException>()
            .having((e) => e.statusCode, 'status', 422)
            .having((e) => e.firstError, 'firstError', 'wajib')),
      );
    });
  });

  group('ApiClient 401 auto-logout', () {
    test('memicu onUnauthorized untuk permintaan ber-token', () async {
      var called = false;
      ApiClient.onUnauthorized = () => called = true;
      final api = _client(
        _FakeAdapter.response(401, {'success': false, 'message': 'Unauthenticated'}),
        storage: _FakeTokenStorage('token-abc'),
      );
      await expectLater(() => api.get('me'), throwsA(isA<ApiException>()));
      expect(called, isTrue);
    });

    test('TIDAK memicu onUnauthorized bila tanpa token (mis. login gagal)', () async {
      var called = false;
      ApiClient.onUnauthorized = () => called = true;
      final api = _client(
        _FakeAdapter.response(401, {'success': false, 'message': 'Kredensial salah'}),
        storage: _FakeTokenStorage(), // tanpa token
      );
      await expectLater(() => api.post('auth/login'), throwsA(isA<ApiException>()));
      expect(called, isFalse);
    });
  });

  group('ApiClient network error', () {
    test('connectionError → pesan ramah & isNetwork', () async {
      final api = _client(_FakeAdapter.failure(DioExceptionType.connectionError));
      expect(
        () => api.get('x'),
        throwsA(isA<ApiException>().having((e) => e.isNetwork, 'isNetwork', isTrue)),
      );
    });
  });
}
