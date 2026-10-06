import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../core/server_clock.dart';
import '../models/package.dart';
import '../models/payment_method.dart';
import '../models/transaction.dart';

/// Hasil `GET /packages`: daftar paket + jam server untuk countdown promo.
class PackageCatalog {
  final List<Package> packages;

  /// Jam tersinkron server; dipakai agar countdown/harga promo mengacu waktu
  /// server (tidak bisa dicurangi dengan memundurkan jam perangkat).
  final ServerClock clock;

  PackageCatalog(this.packages, this.clock);
}

/// Konsumsi endpoint paket & pembayaran peserta.
class CommerceService {
  final ApiClient _api;

  CommerceService({ApiClient? api}) : _api = api ?? ApiClient();

  /// Mengembalikan paket + jam server.
  ///
  /// Mendukung dua bentuk respons pada field `data` envelope:
  ///  - List paket (format lama), atau
  ///  - Map `{ packages: [...], server_time: "ISO8601" }` (format baru, membawa
  ///    waktu server untuk countdown promo).
  Future<PackageCatalog> catalog() async {
    final data = await _api.get('packages');

    List rawList;
    ServerClock clock;
    if (data is Map) {
      final list = (data['packages'] ?? data['items'] ?? data['data'] ?? const []) as List;
      rawList = list;
      final st = data['server_time'] ?? data['now'];
      final parsed = st == null ? null : DateTime.tryParse(st.toString());
      clock = parsed != null ? ServerClock(parsed) : ServerClock.fromDevice();
    } else {
      rawList = data as List;
      clock = ServerClock.fromDevice();
    }

    final packages =
        rawList.map((e) => Package.fromJson(Map<String, dynamic>.from(e))).toList();
    return PackageCatalog(packages, clock);
  }

  /// Kompat lama: hanya daftar paket.
  Future<List<Package>> packages() async => (await catalog()).packages;

  Future<List<PaymentMethod>> paymentMethods() async {
    final data = await _api.get('payment-methods');
    return (data as List).map((e) => PaymentMethod.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<List<Transaction>> myTransactions() async {
    final data = await _api.get('me/transactions');
    final list = (data is Map && data['data'] is List) ? data['data'] as List : (data as List);
    return list.map((e) => Transaction.fromJson(Map<String, dynamic>.from(e))).toList();
  }

  Future<Transaction> createTransaction({
    required int packageId,
    required String period,
    int? paymentMethodId,
  }) async {
    final data = await _api.post('transactions', body: {
      'package_id': packageId,
      'period': period,
      if (paymentMethodId != null) 'payment_method_id': paymentMethodId,
    });
    return Transaction.fromJson(Map<String, dynamic>.from(data));
  }

  Future<Transaction> uploadProof({
    required String transactionId,
    required List<int> bytes,
    required String filename,
  }) async {
    final form = FormData.fromMap({
      'proof': MultipartFile.fromBytes(bytes, filename: filename),
    });
    final data = await _api.post('transactions/$transactionId/proof', body: form);
    return Transaction.fromJson(Map<String, dynamic>.from(data));
  }
}
