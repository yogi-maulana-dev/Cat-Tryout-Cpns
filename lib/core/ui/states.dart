import 'package:flutter/material.dart';

import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import 'app_button.dart';

/// Tampilan loading terpusat.
class LoadingState extends StatelessWidget {
  const LoadingState({super.key, this.message});
  final String? message;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const CircularProgressIndicator(),
        if (message != null) ...[
          const SizedBox(height: 12),
          Text(message!, style: const TextStyle(color: AppColors.textSecondary)),
        ],
      ]),
    );
  }
}

/// Empty state dengan ikon, judul, deskripsi, aksi opsional.
class EmptyState extends StatelessWidget {
  const EmptyState({
    super.key,
    this.icon = Icons.inbox_rounded,
    required this.title,
    this.message,
    this.actionLabel,
    this.onAction,
  });

  final IconData icon;
  final String title;
  final String? message;
  final String? actionLabel;
  final VoidCallback? onAction;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 72,
            width: 72,
            decoration: const BoxDecoration(color: AppColors.primaryLight, shape: BoxShape.circle),
            child: Icon(icon, size: 36, color: AppColors.primary),
          ),
          const SizedBox(height: 16),
          Text(title, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          if (message != null) ...[
            const SizedBox(height: 6),
            Text(message!, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          ],
          if (actionLabel != null && onAction != null) ...[
            const SizedBox(height: 18),
            SizedBox(width: 200, child: PrimaryButton(label: actionLabel!, onPressed: onAction)),
          ],
        ]),
      ),
    );
  }
}

/// Error state dengan tombol "Coba Lagi".
class ErrorStateView extends StatelessWidget {
  const ErrorStateView({super.key, required this.message, this.onRetry});
  final String message;
  final VoidCallback? onRetry;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          Container(
            height: 72,
            width: 72,
            decoration: const BoxDecoration(color: Color(0xFFFEE2E2), shape: BoxShape.circle),
            child: const Icon(Icons.cloud_off_rounded, size: 36, color: AppColors.danger),
          ),
          const SizedBox(height: 16),
          const Text('Terjadi Masalah', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.textPrimary)),
          const SizedBox(height: 6),
          Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondary)),
          if (onRetry != null) ...[
            const SizedBox(height: 18),
            SizedBox(width: 200, child: PrimaryButton(label: 'Coba Lagi', icon: Icons.refresh_rounded, onPressed: onRetry)),
          ],
        ]),
      ),
    );
  }
}

/// Kotak skeleton (shimmer sederhana) untuk placeholder loading.
class SkeletonBox extends StatefulWidget {
  const SkeletonBox({super.key, this.height = 16, this.width = double.infinity, this.radius = 8});
  final double height;
  final double width;
  final double radius;

  @override
  State<SkeletonBox> createState() => _SkeletonBoxState();
}

class _SkeletonBoxState extends State<SkeletonBox> with SingleTickerProviderStateMixin {
  late final AnimationController _c = AnimationController(vsync: this, duration: const Duration(milliseconds: 1100))..repeat(reverse: true);

  @override
  void dispose() {
    _c.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _c,
      builder: (_, __) => Container(
        height: widget.height,
        width: widget.width,
        decoration: BoxDecoration(
          color: Color.lerp(const Color(0xFFE2E8F0), const Color(0xFFF1F5F9), _c.value),
          borderRadius: BorderRadius.circular(widget.radius),
        ),
      ),
    );
  }
}

/// Daftar skeleton kartu (untuk list yang sedang dimuat).
class SkeletonList extends StatelessWidget {
  const SkeletonList({super.key, this.count = 5});
  final int count;

  @override
  Widget build(BuildContext context) {
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: count,
      separatorBuilder: (_, __) => const SizedBox(height: 12),
      itemBuilder: (_, __) => Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppColors.surface, borderRadius: AppRadius.brLg, border: Border.all(color: AppColors.border)),
        child: const Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          SkeletonBox(height: 16, width: 180),
          SizedBox(height: 10),
          SkeletonBox(height: 12, width: 120),
        ]),
      ),
    );
  }
}
