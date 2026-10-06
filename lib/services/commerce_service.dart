import 'package:dio/dio.dart';

import '../core/api_client.dart';
import '../models/package.dart';
import '../models/payment_method.dart';
import '../models/transaction.dart';

/// Konsumsi endpoint paket & pembayaran peserta.
class CommerceService {
  final ApiClient _api;

  CommerceService({ApiClient? api}) : _api = api ?? ApiClient();

  Future<List<Package>> packages() async {
    final data = await _api.get('packages');
    return (data as List).map((e) => Package.fromJson(Map<String, dynamic>.from(e))).toList();
  }

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
