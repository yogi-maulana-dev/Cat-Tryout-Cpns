/// Metode pembayaran (dari GET /payment-methods atau embedded di transaksi).
class PaymentMethod {
  final int id;
  final String type; // bank_transfer | qris | gateway
  final String name;
  final String? accountNumber;
  final String? accountHolder;
  final String? qrisImage;
  final String? provider;
  final String? instructions;

  PaymentMethod({
    required this.id,
    required this.type,
    required this.name,
    this.accountNumber,
    this.accountHolder,
    this.qrisImage,
    this.provider,
    this.instructions,
  });

  bool get isBank => type == 'bank_transfer';
  bool get isQris => type == 'qris';

  factory PaymentMethod.fromJson(Map<String, dynamic> j) => PaymentMethod(
        id: j['id'] as int,
        type: (j['type'] ?? '') as String,
        name: (j['name'] ?? '') as String,
        accountNumber: j['account_number'] as String?,
        accountHolder: j['account_holder'] as String?,
        qrisImage: j['qris_image'] as String?,
        provider: j['provider'] as String?,
        instructions: j['instructions'] as String?,
      );
}
