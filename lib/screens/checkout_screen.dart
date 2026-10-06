import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import '../core/money.dart' as money;
import '../core/server_clock.dart';
import '../core/theme/app_colors.dart';
import '../core/wib.dart';
import '../models/package.dart';
import '../models/payment_method.dart';
import '../models/transaction.dart';
import '../services/commerce_service.dart';
import 'transactions_screen.dart';

class CheckoutScreen extends StatefulWidget {
  const CheckoutScreen({super.key, required this.package, required this.clock});
  final Package package;
  final ServerClock clock;

  @override
  State<CheckoutScreen> createState() => _CheckoutScreenState();
}

class _CheckoutScreenState extends State<CheckoutScreen> {
  final _service = CommerceService();
  late Future<List<PaymentMethod>> _methodsFuture;
  PaymentMethod? _selected;
  Transaction? _trx;
  bool _loading = false;
  bool _proofSent = false;
  String? _error;

  // Paket adalah pembelian satu kali (masa aktif ditentukan paket). Kita tetap
  // mengirim period untuk kompatibilitas kontrak backend.
  static const String _period = 'monthly';

  /// Harga untuk DITAMPILKAN (indikatif). Harga final selalu dihitung server
  /// saat order dibuat — browser tidak pernah mengirim harga.
  int get _displayPrice => widget.package.effectivePriceAt(widget.clock.now());

  bool get _promoActive => widget.package.isPromoActiveAt(widget.clock.now());

  @override
  void initState() {
    super.initState();
    _methodsFuture = _service.paymentMethods();
  }

  Future<void> _createOrder() async {
    if (_selected == null) {
      setState(() => _error = 'Pilih metode pembayaran dulu.');
      return;
    }
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      // Hanya mengirim id paket + metode. Harga ditentukan & divalidasi server.
      final trx = await _service.createTransaction(
          packageId: widget.package.id, period: _period, paymentMethodId: _selected!.id);
      setState(() => _trx = trx);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _uploadProof() async {
    final x = await ImagePicker().pickImage(source: ImageSource.gallery, imageQuality: 85);
    if (x == null) return;
    setState(() {
      _loading = true;
      _error = null;
    });
    try {
      final bytes = await x.readAsBytes();
      await _service.uploadProof(transactionId: _trx!.id, bytes: bytes, filename: x.name);
      setState(() => _proofSent = true);
    } catch (e) {
      setState(() => _error = '$e');
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(title: Text(_trx == null ? 'Checkout' : 'Pembayaran')),
      body: _trx == null ? _buildSelect() : _buildPay(),
    );
  }

  Widget _card({required Widget child}) => Container(
        width: double.infinity,
        margin: const EdgeInsets.only(bottom: 14),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
            color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
        child: child,
      );

  Widget _summary() {
    final p = widget.package;
    return _card(
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Ringkasan', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
        const SizedBox(height: 10),
        Row(children: [
          Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text(p.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
              const SizedBox(height: 2),
              Text(
                'Masa aktif ${p.durationDays} hari • '
                '${p.tryoutQuota == null ? 'try out tanpa batas' : '${p.tryoutQuota}x try out'}',
                style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
              ),
            ]),
          ),
        ]),
        const Divider(height: 22),
        if (_promoActive) ...[
          _row('Harga normal', money.rupiah(p.normalPrice), struck: true),
          const SizedBox(height: 4),
          _row('Diskon', '-${p.discountPercentValue}%', valueColor: AppColors.danger),
          const SizedBox(height: 8),
          _row('Harga promo', money.rupiah(_displayPrice), bold: true),
          if (p.promoWindow != null) ...[
            const SizedBox(height: 8),
            Row(children: [
              const Icon(Icons.local_offer_rounded, size: 14, color: AppColors.danger),
              const SizedBox(width: 6),
              Expanded(
                child: Text('Harga promo berlaku sampai ${formatWib(p.promoWindow!.endsAt)}',
                    style: const TextStyle(fontSize: 11.5, color: AppColors.textSecondary)),
              ),
            ]),
          ],
        ] else
          _row('Total', money.rupiah(_displayPrice), bold: true),
        const SizedBox(height: 8),
        const Text(
          'Harga final dikonfirmasi oleh server saat pesanan dibuat.',
          style: TextStyle(fontSize: 11, color: AppColors.textSecondary),
        ),
      ]),
    );
  }

  Widget _row(String label, String value, {bool bold = false, bool struck = false, Color? valueColor}) {
    return Row(children: [
      Expanded(child: Text(label, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13))),
      Text(
        value,
        style: TextStyle(
          fontWeight: bold ? FontWeight.w800 : FontWeight.w600,
          fontSize: bold ? 18 : 14,
          color: valueColor ?? (bold ? AppColors.navy : AppColors.textPrimary),
          decoration: struck ? TextDecoration.lineThrough : null,
          decorationColor: AppColors.textSecondary,
        ),
      ),
    ]);
  }

  Widget _buildSelect() {
    return ListView(padding: const EdgeInsets.all(16), children: [
      _summary(),
      const Text('Pilih Metode Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
      const SizedBox(height: 10),
      FutureBuilder<List<PaymentMethod>>(
        future: _methodsFuture,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator()));
          }
          final methods = snap.data ?? [];
          if (methods.isEmpty) return const Text('Belum ada metode pembayaran.');
          return Column(children: [
            for (final m in methods)
              Container(
                margin: const EdgeInsets.only(bottom: 10),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(14),
                  border: Border.all(
                      color: _selected?.id == m.id ? AppColors.primary : AppColors.border,
                      width: _selected?.id == m.id ? 2 : 1),
                ),
                child: ListTile(
                  onTap: () => setState(() => _selected = m),
                  leading: Icon(
                    _selected?.id == m.id ? Icons.radio_button_checked : Icons.radio_button_off,
                    color: _selected?.id == m.id ? AppColors.primary : AppColors.textSecondary,
                  ),
                  title: Text(m.name, style: const TextStyle(fontWeight: FontWeight.w600, color: AppColors.navy)),
                  subtitle: Text(m.isQris ? 'QRIS' : (m.isBank ? 'Transfer Bank' : 'Gateway'),
                      style: const TextStyle(fontSize: 12)),
                ),
              ),
          ]);
        },
      ),
      if (_error != null)
        Padding(padding: const EdgeInsets.only(top: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
      const SizedBox(height: 8),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: _loading ? null : _createOrder,
        child: Text(_loading ? 'Memproses…' : 'Buat Pesanan • ${money.rupiah(_displayPrice)}'),
      ),
    ]);
  }

  Widget _buildPay() {
    final t = _trx!;
    final m = t.paymentMethod;
    return ListView(padding: const EdgeInsets.all(16), children: [
      _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Text('Invoice', style: TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          Text(t.invoiceNo, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
        ]),
        const Divider(height: 20),
        Row(children: [
          const Text('Total', style: TextStyle(color: AppColors.textSecondary)),
          const Spacer(),
          // Nilai dari server (otoritatif), bukan dari harga yang ditampilkan browser.
          Text(money.rupiah(t.amount),
              style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
        ]),
      ])),
      if (m != null)
        _card(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(m.name, style: const TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
          const SizedBox(height: 10),
          if (m.isBank) ...[
            Text('No. Rekening: ${m.accountNumber ?? "-"}', style: const TextStyle(color: AppColors.textPrimary)),
            Text('a.n. ${m.accountHolder ?? "-"}', style: const TextStyle(color: AppColors.textSecondary)),
          ] else if (m.isQris && m.qrisImage != null) ...[
            Center(child: Image.network(m.qrisImage!, height: 200, errorBuilder: (_, __, ___) => const Text('Gagal memuat QRIS'))),
          ],
          if (m.instructions != null) ...[
            const SizedBox(height: 10),
            Text(m.instructions!, style: const TextStyle(fontSize: 13, color: AppColors.textSecondary)),
          ],
        ])),
      _card(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        const Text('Unggah Bukti Pembayaran', style: TextStyle(fontWeight: FontWeight.w700, color: AppColors.navy)),
        const SizedBox(height: 8),
        if (_proofSent)
          const Row(children: [
            Icon(Icons.check_circle_rounded, color: AppColors.primary),
            SizedBox(width: 8),
            Expanded(child: Text('Bukti terkirim. Menunggu verifikasi admin.', style: TextStyle(color: AppColors.primaryDark))),
          ])
        else
          OutlinedButton.icon(
            style: OutlinedButton.styleFrom(foregroundColor: AppColors.primaryDark, side: const BorderSide(color: AppColors.primary)),
            onPressed: _loading ? null : _uploadProof,
            icon: const Icon(Icons.upload_file_rounded),
            label: Text(_loading ? 'Mengunggah…' : 'Pilih & Unggah Bukti'),
          ),
      ])),
      if (_error != null)
        Padding(padding: const EdgeInsets.only(bottom: 8), child: Text(_error!, style: const TextStyle(color: Colors.red))),
      FilledButton(
        style: FilledButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
        onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
        child: const Text('Lihat Status Transaksi'),
      ),
    ]);
  }
}
