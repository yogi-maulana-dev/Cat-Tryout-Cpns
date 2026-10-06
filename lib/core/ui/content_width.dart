import 'package:flutter/material.dart';

/// Membatasi lebar konten & memusatkannya di layar lebar (tablet/desktop web),
/// tetap full-width di mobile. Membuat app mobile-first tetap nyaman dibaca
/// saat dibuka di web desktop.
class ContentWidth extends StatelessWidget {
  const ContentWidth({super.key, required this.child, this.maxWidth = 720});

  final Widget child;
  final double maxWidth;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: ConstrainedBox(
        constraints: BoxConstraints(maxWidth: maxWidth),
        child: child,
      ),
    );
  }
}
