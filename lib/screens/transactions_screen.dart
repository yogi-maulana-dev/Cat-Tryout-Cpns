import 'package:flutter/material.dart';

import '../core/theme/app_colors.dart';
import '../models/transaction.dart';
import '../services/commerce_service.dart';
import 'packages_screen.dart' show rupiah;

class TransactionsScreen extends StatefulWidget {
  const TransactionsScreen({super.key});

  @override
  State<TransactionsScreen> createState() => _TransactionsScreenState();
}

class _TransactionsScreenState extends State<TransactionsScreen> {
  final _service = CommerceService();
  late Future<List<Transaction>> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.myTransactions();
  }

  Future<void> _refresh() async {
    setState(() => _future = _service.myTransactions());
    await _future;
  }

  Color _statusColor(String s) => switch (s) {
        'paid' => AppColors.primary,
        'waiting_verification' => AppColors.star,
        'rejected' => const Color(0xFFE05656),
        'expired' => AppColors.textSecondary,
        _ => AppColors.textSecondary,
      };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.surfaceAlt,
      appBar: AppBar(title: const Text('Transaksi Saya')),
      body: RefreshIndicator(
        onRefresh: _refresh,
        child: FutureBuilder<List<Transaction>>(
          future: _future,
          builder: (context, snap) {
            if (snap.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            }
            if (snap.hasError) {
              return ListView(children: [Padding(padding: const EdgeInsets.all(24), child: Text('${snap.error}', textAlign: TextAlign.center))]);
            }
            final items = snap.data ?? [];
            if (items.isEmpty) {
              return ListView(children: const [SizedBox(height: 120), Center(child: Text('Belum ada transaksi.'))]);
            }
            return ListView.separated(
              padding: const EdgeInsets.all(16),
              itemCount: items.length,
              separatorBuilder: (_, __) => const SizedBox(height: 12),
              itemBuilder: (context, i) {
                final t = items[i];
                final c = _statusColor(t.status);
                return Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(16), border: Border.all(color: AppColors.border)),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                    Row(children: [
                      Expanded(child: Text(t.packageName, style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.navy))),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(color: c.withValues(alpha: 0.12), borderRadius: BorderRadius.circular(999)),
                        child: Text(t.statusLabel, style: TextStyle(color: c, fontWeight: FontWeight.w700, fontSize: 11)),
                      ),
                    ]),
                    const SizedBox(height: 6),
                    Text(t.invoiceNo, style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                    const SizedBox(height: 8),
                    Row(children: [
                      Text(t.period == 'yearly' ? 'Tahunan' : 'Bulanan', style: const TextStyle(fontSize: 12, color: AppColors.textSecondary)),
                      const Spacer(),
                      Text(rupiah(t.amount), style: const TextStyle(fontWeight: FontWeight.w800, color: AppColors.primaryDark)),
                    ]),
                  ]),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
