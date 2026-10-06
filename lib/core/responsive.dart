import 'package:flutter/widgets.dart';

/// Helper responsif tanpa dependency tambahan.
///
/// Breakpoint:
///   mobile  : < 768
///   tablet  : 768 - 1199
///   desktop : >= 1200
enum DeviceType { mobile, tablet, desktop }

class Responsive {
  Responsive._();

  static const double tabletMin = 768;
  static const double desktopMin = 1200;

  static DeviceType typeOf(BuildContext context) =>
      fromWidth(MediaQuery.sizeOf(context).width);

  static DeviceType fromWidth(double width) {
    if (width >= desktopMin) return DeviceType.desktop;
    if (width >= tabletMin) return DeviceType.tablet;
    return DeviceType.mobile;
  }

  static bool isMobile(BuildContext c) => typeOf(c) == DeviceType.mobile;
  static bool isTablet(BuildContext c) => typeOf(c) == DeviceType.tablet;
  static bool isDesktop(BuildContext c) => typeOf(c) == DeviceType.desktop;

  /// Pilih nilai sesuai device (fallback tablet→mobile, desktop→tablet).
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    T? desktop,
  }) {
    switch (typeOf(context)) {
      case DeviceType.desktop:
        return desktop ?? tablet ?? mobile;
      case DeviceType.tablet:
        return tablet ?? mobile;
      case DeviceType.mobile:
        return mobile;
    }
  }

  /// Padding horizontal halaman sesuai lebar layar.
  static double pagePadding(BuildContext context) =>
      value(context, mobile: 20, tablet: 32, desktop: 24);
}

/// Builder ringkas berbasis [DeviceType].
class ResponsiveBuilder extends StatelessWidget {
  const ResponsiveBuilder({super.key, required this.builder});

  final Widget Function(BuildContext context, DeviceType device) builder;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) =>
          builder(context, Responsive.fromWidth(constraints.maxWidth)),
    );
  }
}
