import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import 'tabs/exams_tab.dart';
import 'tabs/home_tab.dart';
import 'tabs/profile_tab.dart';
import 'tabs/ranking_tab.dart';

/// Kerangka utama aplikasi peserta.
/// - Mobile/tablet (< 1024): bottom navigation.
/// - Desktop/laptop (>= 1024): NavigationRail di kiri (bukan bottom nav HP).
class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _index = 0;

  void _go(int i) => setState(() => _index = i);

  static const _items = [
    (icon: Icons.home_outlined, active: Icons.home_rounded, label: 'Beranda'),
    (icon: Icons.assignment_outlined, active: Icons.assignment_rounded, label: 'Tryout'),
    (icon: Icons.leaderboard_outlined, active: Icons.leaderboard_rounded, label: 'Ranking'),
    (icon: Icons.person_outline_rounded, active: Icons.person_rounded, label: 'Profil'),
  ];

  @override
  Widget build(BuildContext context) {
    final tabs = [
      HomeTab(onSelectTab: _go),
      const ExamsTab(),
      const RankingTab(),
      const ProfileTab(),
    ];
    final content = IndexedStack(index: _index, children: tabs);

    return LayoutBuilder(
      builder: (context, c) {
        final desktop = c.maxWidth >= 1024;
        if (desktop) {
          return Scaffold(
            body: Row(children: [
              _SideNav(index: _index, onSelect: _go, extended: c.maxWidth >= 1200),
              const VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
              Expanded(child: content),
            ]),
          );
        }
        return Scaffold(
          body: content,
          bottomNavigationBar: DecoratedBox(
            decoration: const BoxDecoration(
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: BottomNavigationBar(
              currentIndex: _index,
              onTap: _go,
              items: [
                for (final it in _items)
                  BottomNavigationBarItem(
                    icon: Icon(it.icon),
                    activeIcon: Icon(it.active),
                    label: it.label,
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}

/// Navigasi samping untuk desktop/laptop.
class _SideNav extends StatelessWidget {
  const _SideNav({required this.index, required this.onSelect, required this.extended});

  final int index;
  final ValueChanged<int> onSelect;
  final bool extended;

  @override
  Widget build(BuildContext context) {
    return NavigationRail(
      backgroundColor: AppColors.surface,
      selectedIndex: index,
      onDestinationSelected: onSelect,
      extended: extended,
      minExtendedWidth: 220,
      labelType: extended ? null : NavigationRailLabelType.all,
      groupAlignment: -0.9,
      indicatorColor: AppColors.primaryLight,
      selectedIconTheme: const IconThemeData(color: AppColors.primaryDark),
      unselectedIconTheme: const IconThemeData(color: AppColors.textSecondary),
      selectedLabelTextStyle: const TextStyle(color: AppColors.primaryDark, fontWeight: FontWeight.w700),
      unselectedLabelTextStyle: const TextStyle(color: AppColors.textSecondary, fontWeight: FontWeight.w600),
      leading: _RailBrand(extended: extended),
      destinations: [
        for (final it in _MainShellState._items)
          NavigationRailDestination(
            icon: Icon(it.icon),
            selectedIcon: Icon(it.active),
            label: Text(it.label),
          ),
      ],
    );
  }
}

class _RailBrand extends StatelessWidget {
  const _RailBrand({required this.extended});
  final bool extended;

  @override
  Widget build(BuildContext context) {
    final logo = Container(
      height: 36,
      width: 36,
      decoration: const BoxDecoration(color: AppColors.primary, borderRadius: AppRadius.brMd),
      child: const Icon(Icons.menu_book_rounded, color: Colors.white, size: 20),
    );
    return Padding(
      padding: EdgeInsets.fromLTRB(extended ? 12 : 0, 16, extended ? 12 : 0, 20),
      child: extended
          ? Row(mainAxisSize: MainAxisSize.min, children: [
              logo,
              const SizedBox(width: 10),
              const Text('BisaPNS.id',
                  style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16, color: AppColors.textPrimary)),
            ])
          : logo,
    );
  }
}
