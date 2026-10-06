import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../widgets/cta_section.dart';
import '../widgets/faq_section.dart';
import '../widgets/features_section.dart';
import '../widgets/hero_section.dart';
import '../widgets/how_it_works_section.dart';
import '../widgets/landing_actions.dart';
import '../widgets/landing_footer.dart';
import '../widgets/landing_navbar.dart';
import '../widgets/pricing_section.dart';
import '../widgets/result_preview_section.dart';
import '../widgets/stats_section.dart';
import '../widgets/testimonials_section.dart';
import '../widgets/tryout_preview_section.dart';

/// Landing page BisaPNS.id (Flutter Web, responsive desktop/tablet/mobile).
///
/// Navbar sticky di atas + konten yang dapat di-scroll. CTA & menu diarahkan
/// lewat [LandingActions] (satu titik ganti routing saat backend siap).
class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final _scrollController = ScrollController();

  final _featuresKey = GlobalKey();
  final _pricingKey = GlobalKey();
  final _faqKey = GlobalKey();
  final _demoKey = GlobalKey();

  late final LandingActions _actions = LandingActions(
    scrollToFeatures: () => _scrollTo(_featuresKey),
    scrollToPricing: () => _scrollTo(_pricingKey),
    scrollToFaq: () => _scrollTo(_faqKey),
    scrollToDemo: () => _scrollTo(_demoKey),
    scrollToTop: _scrollTop,
  );

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _scrollTop() {
    _scrollController.animateTo(0,
        duration: const Duration(milliseconds: 450), curve: Curves.easeInOut);
  }

  void _scrollTo(GlobalKey key) {
    final ctx = key.currentContext;
    if (ctx == null) return;
    Scrollable.ensureVisible(
      ctx,
      duration: const Duration(milliseconds: 500),
      curve: Curves.easeInOut,
      alignment: 0.02,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.background,
      endDrawer: LandingMobileMenu(actions: _actions),
      body: SafeArea(
        bottom: false,
        child: Column(
          children: [
            LandingNavbar(
              actions: _actions,
              onOpenMenu: () => _scaffoldKey.currentState?.openEndDrawer(),
            ),
            Expanded(
              child: SingleChildScrollView(
                controller: _scrollController,
                child: Column(
                  children: [
                    HeroSection(actions: _actions),
                    const StatsSection(),
                    KeyedSubtree(key: _featuresKey, child: const FeaturesSection()),
                    const HowItWorksSection(),
                    KeyedSubtree(key: _pricingKey, child: PricingSection(actions: _actions)),
                    KeyedSubtree(key: _demoKey, child: const TryoutPreviewSection()),
                    const ResultPreviewSection(),
                    const TestimonialsSection(),
                    KeyedSubtree(key: _faqKey, child: const FaqSection()),
                    CtaSection(actions: _actions),
                    LandingFooter(actions: _actions),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
