import 'payment_method.dart';

/// Transaksi pembelian paket (dari /transactions).
class Transaction {
  final String id;
  final String invoiceNo;
  final String packageName;
  final String period; // monthly | yearly
  final int amount;
  final String? methodType;
  final String? methodName;
  final String status; // pending | waiting_verification | paid | rejected | expired
  final String? paymentProof;
  final DateTime? expiresAt;
  final DateTime? createdAt;
  final PaymentMethod? paymentMethod;

  Transaction({
    required this.id,
    required this.invoiceNo,
    required this.packageName,
    required this.period,
    required this.amount,
    required this.status,
    this.methodType,
    this.methodName,
    this.paymentProof,
    this.expiresAt,
    this.createdAt,
    this.paymentMethod,
  });

  String get statusLabel => const {
        'pending': 'Menunggu Pembayaran',
        'waiting_verification': 'Menunggu Verifikasi',
        'paid': 'Lunas',
        'rejected': 'Ditolak',
        'expired': 'Kedaluwarsa',
      }[status] ?? status;

  factory Transaction.fromJson(Map<String, dynamic> j) => Transaction(
        id: j['id'].toString(),
        invoiceNo: (j['invoice_no'] ?? '') as String,
        packageName: (j['package_name'] ?? '') as String,
        period: (j['period'] ?? 'monthly') as String,
        amount: (j['amount'] ?? 0) as int,
        methodType: j['method_type'] as String?,
        methodName: j['method_name'] as String?,
        status: (j['status'] ?? 'pending') as String,
        paymentProof: j['payment_proof'] as String?,
        expiresAt: j['expires_at'] != null ? DateTime.tryParse(j['expires_at']) : null,
        createdAt: j['created_at'] != null ? DateTime.tryParse(j['created_at']) : null,
        paymentMethod: j['payment_method'] is Map
            ? PaymentMethod.fromJson(Map<String, dynamic>.from(j['payment_method']))
            : null,
      );
}
