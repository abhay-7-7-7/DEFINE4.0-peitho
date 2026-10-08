import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../core/theme/bk_tokens.dart';

/// Shell scaffold — wraps main sections with a brutalist bottom navigation bar.
class ShellScaffold extends StatelessWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  static const _navItems = [
    _NavItem(icon: Icons.home_outlined, activeIcon: Icons.home, label: 'Home', path: '/'),
    _NavItem(icon: Icons.widgets_outlined, activeIcon: Icons.widgets, label: 'Components', path: '/components'),
    _NavItem(icon: Icons.bar_chart_outlined, activeIcon: Icons.bar_chart, label: 'Charts', path: '/charts'),
    _NavItem(icon: Icons.category_outlined, activeIcon: Icons.category, label: 'Shapes', path: '/shapes'),
    _NavItem(icon: Icons.settings_outlined, activeIcon: Icons.settings, label: 'Settings', path: '/settings'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final location = GoRouterState.of(context).uri.toString();

    int selectedIndex = 0;
    for (int i = 0; i < _navItems.length; i++) {
      if (i == 0) {
        if (location == '/') selectedIndex = 0;
      } else if (location.startsWith(_navItems[i].path)) {
        selectedIndex = i;
      }
    }

    return Scaffold(
      backgroundColor: t.background,
      body: child,
      bottomNavigationBar: _BkBottomNav(
        t: t,
        items: _navItems,
        selectedIndex: selectedIndex,
        onTap: (i) => context.go(_navItems[i].path),
      ),
    );
  }
}

class _BkBottomNav extends StatelessWidget {
  const _BkBottomNav({
    required this.t,
    required this.items,
    required this.selectedIndex,
    required this.onTap,
  });

  final BkTokens t;
  final List<_NavItem> items;
  final int selectedIndex;
  final ValueChanged<int> onTap;

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: t.background,
        border: Border(top: BorderSide(color: t.border, width: 3)),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(items.length, (i) {
              final item = items[i];
              final isSelected = i == selectedIndex;
              return Expanded(
                child: GestureDetector(
                  onTap: () => onTap(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 150),
                    decoration: BoxDecoration(
                      color: isSelected ? t.primary : Colors.transparent,
                      border: i < items.length - 1
                          ? Border(right: BorderSide(color: t.border, width: 1))
                          : null,
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Icon(
                          isSelected ? item.activeIcon : item.icon,
                          color: isSelected ? t.primaryForeground : t.mutedForeground,
                          size: 22,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          item.label.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 9,
                            fontWeight: FontWeight.w700,
                            letterSpacing: 0.5,
                            color: isSelected ? t.primaryForeground : t.mutedForeground,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavItem {
  const _NavItem({
    required this.icon,
    required this.activeIcon,
    required this.label,
    required this.path,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
}
