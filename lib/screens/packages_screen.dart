import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/package.dart';
import '../services/commerce_service.dart';
import 'checkout_screen.dart';
import 'transactions_screen.dart';

String rupiah(int n) {
  if (n <= 0) return 'Gratis';
  final s = n.toString();
  final b = StringBuffer();
  for (var i = 0; i < s.length; i++) {
    if (i > 0 && (s.length - i) % 3 == 0) b.write('.');
    b.write(s[i]);
  }
  return 'Rp$b';
}

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _service = CommerceService();
  late Future<List<Package>> _future;
  bool _yearly = false;

  @override
  void initState() {
    super.initState();
    _future = _service.packages();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(
        title: const Text('Paket Tryout'),
        actions: [
          IconButton(
            tooltip: 'Riwayat transaksi',
            icon: const Icon(Icons.receipt_long_rounded),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const TransactionsScreen()),
            ),
          ),
        ],
      ),
      body: FutureBuilder<List<Package>>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(child: Padding(padding: const EdgeInsets.all(24), child: Text('${snap.error}', textAlign: TextAlign.center)));
          }
          final packages = snap.data ?? [];
          if (packages.isEmpty) {
            return const Center(child: Text('Belum ada paket tersedia.'));
          }
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              _PeriodToggle(yearly: _yearly, onChanged: (v) => setState(() => _yearly = v)),
              const SizedBox(height: 16),
              for (final p in packages) ...[
                _PackageCard(package: p, yearly: _yearly),
                const SizedBox(height: 14),
              ],
            ],
          );
        },
      ),
    );
  }
}

class _PeriodToggle extends StatelessWidget {
  const _PeriodToggle({required this.yearly, required this.onChanged});
  final bool yearly;
  final ValueChanged<bool> onChanged;

  @override
  Widget build(BuildContext context) {
    Widget seg(String label, bool active, VoidCallback onTap) => Expanded(
          child: GestureDetector(
            onTap: onTap,
            child: Container(
              padding: const EdgeInsets.symmetric(vertical: 10),
              decoration: BoxDecoration(
                color: active ? AppColors.primary : Colors.transparent,
                borderRadius: BorderRadius.circular(999),
              ),
              alignment: Alignment.center,
              child: Text(label,
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: active ? Colors.white : AppColors.textSecondary,
                  )),
            ),
          ),
        );

    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(999), border: Border.all(color: AppColors.border)),
      child: Row(children: [
        seg('Bulanan', !yearly, () => onChanged(false)),
        seg('Tahunan (hemat)', yearly, () => onChanged(true)),
      ]),
    );
  }
}

class _PackageCard extends StatelessWidget {
  const _PackageCard({required this.package, required this.yearly});
  final Package package;
  final bool yearly;

  @override
  Widget build(BuildContext context) {
    final price = package.priceFor(yearly);
    final highlighted = package.isPopular;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: highlighted ? AppColors.primary : AppColors.border, width: highlighted ? 2 : 1),
        boxShadow: const [BoxShadow(color: Color(0x0F0F2A43), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [
            Text(package.name, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const Spacer(),
            if (highlighted)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(color: AppColors.primary, borderRadius: BorderRadius.circular(999)),
                child: const Text('Populer', style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w700)),
              ),
          ]),
          if (package.description != null) ...[
            const SizedBox(height: 4),
            Text(package.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 12),
          Row(crossAxisAlignment: CrossAxisAlignment.baseline, textBaseline: TextBaseline.alphabetic, children: [
            Text(rupiah(price), style: const TextStyle(fontSize: 26, fontWeight: FontWeight.w800, color: AppColors.navy)),
            if (price > 0)
              Text(yearly ? '/tahun' : '/bulan', style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ]),
          const SizedBox(height: 14),
          for (final f in package.features)
            Padding(
              padding: const EdgeInsets.only(bottom: 8),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Icon(Icons.check_circle_rounded, size: 18, color: AppColors.primary),
                const SizedBox(width: 8),
                Expanded(child: Text(f, style: const TextStyle(fontSize: 13.5, color: AppColors.textPrimary))),
              ]),
            ),
          const SizedBox(height: 8),
          SizedBox(
            width: double.infinity,
            child: FilledButton(
              style: FilledButton.styleFrom(
                backgroundColor: package.isFree ? AppColors.surfaceAlt : AppColors.primary,
                foregroundColor: package.isFree ? AppColors.primaryDark : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: package.isFree
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => CheckoutScreen(package: package, yearly: yearly)),
                      ),
              child: Text(package.isFree ? 'Paket Gratis' : 'Pilih Paket'),
            ),
          ),
        ],
      ),
    );
  }
}
