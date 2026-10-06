import 'package:flutter/material.dart';

import '../core/money.dart' as money;
import '../core/promo.dart';
import '../core/server_clock.dart';
import '../core/theme/app_colors.dart';
import '../core/ui/promo_countdown.dart';
import '../core/wib.dart';
import '../models/package.dart';
import '../services/commerce_service.dart';
import 'checkout_screen.dart';
import 'transactions_screen.dart';

/// Format Rupiah kompak ("Rp30.000" / "Gratis"). Dipertahankan di sini karena
/// diimpor layar lain; delegasi ke helper terpusat [money.rupiah].
String rupiah(int n) => money.rupiah(n);

class PackagesScreen extends StatefulWidget {
  const PackagesScreen({super.key});

  @override
  State<PackagesScreen> createState() => _PackagesScreenState();
}

class _PackagesScreenState extends State<PackagesScreen> {
  final _service = CommerceService();
  late Future<PackageCatalog> _future;

  @override
  void initState() {
    super.initState();
    _future = _service.catalog();
  }

  void _reload() => setState(() => _future = _service.catalog());

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
      body: FutureBuilder<PackageCatalog>(
        future: _future,
        builder: (context, snap) {
          if (snap.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snap.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: Column(mainAxisSize: MainAxisSize.min, children: [
                  Text('${snap.error}', textAlign: TextAlign.center),
                  const SizedBox(height: 12),
                  OutlinedButton(onPressed: _reload, child: const Text('Coba lagi')),
                ]),
              ),
            );
          }
          final catalog = snap.data!;
          final packages = catalog.packages;
          if (packages.isEmpty) {
            return const Center(child: Text('Belum ada paket tersedia.'));
          }
          return LayoutBuilder(builder: (context, c) {
            final wide = c.maxWidth >= 900;
            final cards = [
              for (final p in packages)
                _PackageCard(package: p, clock: catalog.clock),
            ];
            if (wide) {
              return Center(
                child: ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 1100),
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: IntrinsicHeight(
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          for (var i = 0; i < cards.length; i++) ...[
                            if (i > 0) const SizedBox(width: 16),
                            Expanded(child: cards[i]),
                          ],
                        ],
                      ),
                    ),
                  ),
                ),
              );
            }
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                for (final card in cards) ...[card, const SizedBox(height: 14)],
              ],
            );
          });
        },
      ),
    );
  }
}

/// Aksen warna per tier paket.
class _TierStyle {
  final Color accent;
  final String label;
  const _TierStyle(this.accent, this.label);

  static _TierStyle of(Package p) {
    final key = (p.slug ?? p.name).toLowerCase();
    if (key.contains('platinum')) return const _TierStyle(AppColors.info, 'Unggulan');
    if (key.contains('gold')) return const _TierStyle(AppColors.warning, 'Populer');
    if (key.contains('bronze')) return const _TierStyle(Color(0xFFB45309), 'Gratis');
    return _TierStyle(AppColors.primary, p.isPopular ? 'Populer' : '');
  }
}

class _PackageCard extends StatefulWidget {
  const _PackageCard({required this.package, required this.clock});
  final Package package;
  final ServerClock clock;

  @override
  State<_PackageCard> createState() => _PackageCardState();
}

class _PackageCardState extends State<_PackageCard> {
  Package get p => widget.package;

  PromoState get _state => p.promoStateAt(widget.clock.now());

  @override
  Widget build(BuildContext context) {
    final style = _TierStyle.of(p);
    final state = _state;
    final promoActive = state == PromoState.active;
    final highlighted = promoActive || (p.slug ?? '').toLowerCase().contains('platinum');
    final effectivePrice = p.effectivePriceAt(widget.clock.now());

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: highlighted ? style.accent : AppColors.border,
          width: highlighted ? 2 : 1,
        ),
        boxShadow: const [BoxShadow(color: Color(0x0F0F2A43), blurRadius: 18, offset: Offset(0, 8))],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Header: nama + badge tier / PROMO
          Row(children: [
            Text(p.name,
                style: const TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: AppColors.navy)),
            const Spacer(),
            if (promoActive)
              _Badge(text: 'PROMO ${p.discountPercentValue}%', color: AppColors.danger)
            else if (style.label.isNotEmpty)
              _Badge(text: style.label, color: style.accent),
          ]),
          if ((p.description ?? '').isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(p.description!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
          ],
          const SizedBox(height: 14),

          // Harga
          _PriceBlock(package: p, state: state, effectivePrice: effectivePrice),

          // Countdown promo
          if (promoActive && p.promoWindow != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.danger.withValues(alpha: 0.06),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.danger.withValues(alpha: 0.25)),
              ),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Row(children: [
                  Icon(Icons.local_fire_department_rounded, size: 16, color: AppColors.danger),
                  SizedBox(width: 6),
                  Text('Berakhir dalam',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.danger)),
                ]),
                const SizedBox(height: 8),
                PromoCountdown(
                  clock: widget.clock,
                  endsAt: p.promoWindow!.endsAt,
                  onEnded: () => setState(() {}),
                ),
                const SizedBox(height: 6),
                Text('Promo berakhir ${formatWib(p.promoWindow!.endsAt)}',
                    style: const TextStyle(fontSize: 11, color: AppColors.textSecondary)),
              ]),
            ),
          ] else if (state == PromoState.notStarted && p.promoWindow != null) ...[
            const SizedBox(height: 12),
            _InfoLine(
              icon: Icons.schedule_rounded,
              color: AppColors.info,
              text: 'Promo mulai ${formatWib(p.promoWindow!.startsAt)}',
            ),
          ],

          const SizedBox(height: 14),

          // Masa aktif & kuota try out
          Wrap(spacing: 8, runSpacing: 8, children: [
            _Chip(
              icon: Icons.event_available_rounded,
              text: 'Masa aktif ${p.durationDays} hari',
            ),
            _Chip(
              icon: Icons.assignment_turned_in_rounded,
              text: p.tryoutQuota == null ? 'Try out tanpa batas' : '${p.tryoutQuota}x try out',
            ),
          ]),

          const SizedBox(height: 14),

          for (final f in p.features)
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
                backgroundColor: p.isFree ? AppColors.surfaceAlt : (highlighted ? style.accent : AppColors.primary),
                foregroundColor: p.isFree ? AppColors.primaryDark : Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 14),
              ),
              onPressed: p.isFree
                  ? null
                  : () => Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CheckoutScreen(package: p, clock: widget.clock),
                        ),
                      ),
              child: Text(p.isFree ? 'Paket Gratis' : 'Pilih Paket'),
            ),
          ),
        ],
      ),
    );
  }
}

/// Blok harga: normal / promo (coret) tergantung fase promo.
class _PriceBlock extends StatelessWidget {
  const _PriceBlock({required this.package, required this.state, required this.effectivePrice});
  final Package package;
  final PromoState state;
  final int effectivePrice;

  @override
  Widget build(BuildContext context) {
    final promoActive = state == PromoState.active;
    if (promoActive) {
      return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(crossAxisAlignment: CrossAxisAlignment.center, children: [
          Text(money.rupiah(package.normalPrice),
              style: const TextStyle(
                fontSize: 15,
                color: AppColors.textSecondary,
                decoration: TextDecoration.lineThrough,
                decorationColor: AppColors.textSecondary,
              )),
          const SizedBox(width: 8),
          _Badge(text: '-${package.discountPercentValue}%', color: AppColors.danger),
        ]),
        const SizedBox(height: 2),
        Text(money.rupiah(effectivePrice),
            style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.navy)),
      ]);
    }
    return Text(money.rupiah(effectivePrice),
        style: const TextStyle(fontSize: 30, fontWeight: FontWeight.w900, color: AppColors.navy));
  }
}

class _Badge extends StatelessWidget {
  const _Badge({required this.text, required this.color});
  final String text;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(color: color, borderRadius: BorderRadius.circular(999)),
      child: Text(text, style: const TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800)),
    );
  }
}

class _Chip extends StatelessWidget {
  const _Chip({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: AppColors.surfaceAlt,
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: AppColors.border),
      ),
      child: Row(mainAxisSize: MainAxisSize.min, children: [
        Icon(icon, size: 15, color: AppColors.primaryDark),
        const SizedBox(width: 6),
        Text(text, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.textPrimary)),
      ]),
    );
  }
}

class _InfoLine extends StatelessWidget {
  const _InfoLine({required this.icon, required this.color, required this.text});
  final IconData icon;
  final Color color;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Row(children: [
      Icon(icon, size: 16, color: color),
      const SizedBox(width: 8),
      Expanded(child: Text(text, style: TextStyle(fontSize: 12.5, color: color, fontWeight: FontWeight.w600))),
    ]);
  }
}
