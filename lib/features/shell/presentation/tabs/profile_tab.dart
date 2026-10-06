import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/theme/app_radius.dart';
import '../../../../core/ui/ui.dart';
import '../../../../models/user.dart';
import '../../../../screens/history_screen.dart';
import '../../../../screens/packages_screen.dart';
import '../../../../screens/transactions_screen.dart';
import '../../../../state/auth_provider.dart';

class ProfileTab extends StatelessWidget {
  const ProfileTab({super.key});

  @override
  Widget build(BuildContext context) {
    final auth = context.watch<AuthProvider>();
    final user = auth.user;
    final memberAktif = user?.memberAktif ?? false;

    return Scaffold(
      appBar: AppBar(title: const Text('Profil')),
      body: ContentWidth(
        child: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          _IdentityCard(user: user),
          const SizedBox(height: 16),

          // MEMBERSHIP
          const SectionHeader(title: 'Membership'),
          const SizedBox(height: 8),
          if (memberAktif)
            _ActiveMemberCard(expiredAt: user?.memberExpiredAt, onRenew: () => _goPackages(context))
          else
            _UpgradeCard(onUpgrade: () => _goPackages(context)),
          const SizedBox(height: 20),

          // AKUN
          const SectionHeader(title: 'Akun'),
          const SizedBox(height: 8),
          _MenuTile(
            icon: Icons.history_rounded,
            label: 'Riwayat Tryout',
            subtitle: 'Lihat hasil pengerjaanmu',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const HistoryScreen())),
          ),
          _MenuTile(
            icon: Icons.workspace_premium_rounded,
            label: 'Paket Tryout',
            subtitle: 'Berlangganan atau perpanjang',
            onTap: () => _goPackages(context),
          ),
          _MenuTile(
            icon: Icons.receipt_long_rounded,
            label: 'Transaksi Saya',
            subtitle: 'Riwayat & status pembayaran',
            onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const TransactionsScreen())),
          ),
          const SizedBox(height: 20),

          _MenuTile(icon: Icons.logout_rounded, label: 'Keluar', danger: true, onTap: () => _confirmLogout(context, auth)),
          const SizedBox(height: 16),
          const Center(
            child: Text('BisaPNS.id • v1.0.0', style: TextStyle(color: AppColors.textSecondary, fontSize: 12)),
          ),
        ],
        ),
      ),
    );
  }

  void _goPackages(BuildContext context) =>
      Navigator.push(context, MaterialPageRoute(builder: (_) => const PackagesScreen()));

  void _confirmLogout(BuildContext context, AuthProvider auth) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Keluar'),
        content: const Text('Anda yakin ingin keluar dari akun?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Batal')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              auth.logout();
            },
            child: const Text('Keluar'),
          ),
        ],
      ),
    );
  }
}

class _IdentityCard extends StatelessWidget {
  const _IdentityCard({required this.user});
  final User? user;

  @override
  Widget build(BuildContext context) {
    final isAdmin = user?.isAdmin ?? false;
    return AppCard(
      child: Row(children: [
        CircleAvatar(
          radius: 30,
          backgroundColor: AppColors.primaryLight,
          child: Text(
            (user?.name.isNotEmpty ?? false) ? user!.name[0].toUpperCase() : 'U',
            style: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w800, fontSize: 24),
          ),
        ),
        const SizedBox(width: 14),
        Expanded(
          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
            Row(children: [
              Flexible(
                child: Text(user?.name ?? '-',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w800, color: AppColors.textPrimary)),
              ),
              if (isAdmin) ...[
                const SizedBox(width: 8),
                const StatusBadge(label: 'Admin', tone: BadgeTone.info),
              ],
            ]),
            const SizedBox(height: 3),
            _IconLine(icon: Icons.mail_outline_rounded, text: user?.email ?? '-'),
            if ((user?.nomorHp ?? '').isNotEmpty) _IconLine(icon: Icons.phone_outlined, text: user!.nomorHp!),
          ]),
        ),
      ]),
    );
  }
}

class _IconLine extends StatelessWidget {
  const _IconLine({required this.icon, required this.text});
  final IconData icon;
  final String text;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(top: 3),
      child: Row(children: [
        Icon(icon, size: 14, color: AppColors.textSecondary),
        const SizedBox(width: 6),
        Flexible(
          child: Text(text,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(color: AppColors.textSecondary, fontSize: 13)),
        ),
      ]),
    );
  }
}

class _ActiveMemberCard extends StatelessWidget {
  const _ActiveMemberCard({required this.expiredAt, required this.onRenew});
  final DateTime? expiredAt;
  final VoidCallback onRenew;

  @override
  Widget build(BuildContext context) {
    final sisaHari = expiredAt?.difference(DateTime.now()).inDays;
    final segeraHabis = sisaHari != null && sisaHari <= 7;

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: const BoxDecoration(gradient: AppColors.ctaGradient, borderRadius: AppRadius.brXl),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Icon(Icons.workspace_premium_rounded, color: Colors.white, size: 26),
          const SizedBox(width: 10),
          const Text('Member Aktif',
              style: TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 16)),
          const Spacer(),
          if (sisaHari != null)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(color: Colors.white.withValues(alpha: 0.22), borderRadius: AppRadius.brPill),
              child: Text(sisaHari > 0 ? '$sisaHari hari lagi' : 'Berakhir hari ini',
                  style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700, fontSize: 12)),
            ),
        ]),
        const SizedBox(height: 10),
        Text(
          expiredAt != null
              ? 'Berlaku sampai ${DateFormat('d MMMM yyyy').format(expiredAt!.toLocal())}'
              : 'Akses penuh ke semua fitur premium.',
          style: const TextStyle(color: Colors.white, fontSize: 13),
        ),
        if (segeraHabis) ...[
          const SizedBox(height: 14),
          SizedBox(
            width: double.infinity,
            child: FilledButton.icon(
              onPressed: onRenew,
              icon: const Icon(Icons.autorenew_rounded, size: 18),
              label: const Text('Perpanjang Sekarang'),
              style: FilledButton.styleFrom(
                backgroundColor: Colors.white,
                foregroundColor: AppColors.primaryDark,
                minimumSize: const Size(0, 46),
              ),
            ),
          ),
        ],
      ]),
    );
  }
}

class _UpgradeCard extends StatelessWidget {
  const _UpgradeCard({required this.onUpgrade});
  final VoidCallback onUpgrade;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      highlighted: true,
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          Container(
            height: 44,
            width: 44,
            decoration: const BoxDecoration(color: AppColors.primaryLight, borderRadius: AppRadius.brMd),
            child: const Icon(Icons.lock_open_rounded, color: AppColors.primary),
          ),
          const SizedBox(width: 12),
          const Expanded(
            child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
              Text('Akun Gratis', style: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textPrimary, fontSize: 15)),
              SizedBox(height: 2),
              Text('Upgrade untuk buka semua tryout premium & pembahasan.',
                  style: TextStyle(color: AppColors.textSecondary, fontSize: 12.5, height: 1.35)),
            ]),
          ),
        ]),
        const SizedBox(height: 14),
        PrimaryButton(label: 'Lihat Paket Membership', icon: Icons.workspace_premium_rounded, onPressed: onUpgrade),
      ]),
    );
  }
}

class _MenuTile extends StatelessWidget {
  const _MenuTile({required this.icon, required this.label, required this.onTap, this.subtitle, this.danger = false});
  final IconData icon;
  final String label;
  final String? subtitle;
  final VoidCallback onTap;
  final bool danger;

  @override
  Widget build(BuildContext context) {
    final color = danger ? AppColors.danger : AppColors.textPrimary;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Material(
        color: AppColors.surface,
        borderRadius: AppRadius.brMd,
        child: InkWell(
          borderRadius: AppRadius.brMd,
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
            decoration: BoxDecoration(borderRadius: AppRadius.brMd, border: Border.all(color: AppColors.border)),
            child: Row(children: [
              Container(
                height: 38,
                width: 38,
                decoration: BoxDecoration(
                  color: (danger ? AppColors.danger : AppColors.primary).withValues(alpha: 0.10),
                  borderRadius: AppRadius.brSm,
                ),
                child: Icon(icon, size: 20, color: danger ? AppColors.danger : AppColors.primary),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  Text(label, style: TextStyle(fontWeight: FontWeight.w700, color: color, fontSize: 14)),
                  if (subtitle != null)
                    Text(subtitle!, style: const TextStyle(color: AppColors.textSecondary, fontSize: 12)),
                ]),
              ),
              if (!danger) const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondary),
            ]),
          ),
        ),
      ),
    );
  }
}
