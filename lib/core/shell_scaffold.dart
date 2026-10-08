import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'theme/bk_motion.dart';
import 'theme/bk_tokens.dart';
import 'widgets/bk_command_palette.dart';

/// Shell scaffold — wraps main sections with an animated brutalist bottom navigation bar.
class ShellScaffold extends StatefulWidget {
  const ShellScaffold({super.key, required this.child});

  final Widget child;

  @override
  State<ShellScaffold> createState() => _ShellScaffoldState();
}

class _ShellScaffoldState extends State<ShellScaffold>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pulseController;
  late final Animation<double> _pulseAnimation;

  static const _navItems = [
    _NavItem(
        icon: Icons.home_outlined,
        activeIcon: Icons.home,
        label: 'Home',
        path: '/'),
    _NavItem(
        icon: Icons.widgets_outlined,
        activeIcon: Icons.widgets,
        label: 'Components',
        path: '/components',
        hasBadge: true),
    _NavItem(
        icon: Icons.bar_chart_outlined,
        activeIcon: Icons.bar_chart,
        label: 'Charts',
        path: '/charts'),
    _NavItem(
        icon: Icons.category_outlined,
        activeIcon: Icons.category,
        label: 'Shapes',
        path: '/shapes'),
    _NavItem(
        icon: Icons.settings_outlined,
        activeIcon: Icons.settings,
        label: 'Settings',
        path: '/settings'),
  ];

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: BkMotion.badgePulse,
    )..repeat(reverse: true);

    _pulseAnimation = Tween<double>(begin: 0.92, end: 1.08).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  void _onNavTap(BuildContext context, int index, int selectedIndex) {
    BkMotion.hapticClick();
    if (index == selectedIndex) {
      // Tap active tab -> scroll to top
      final controller = PrimaryScrollController.maybeOf(context);
      if (controller != null && controller.hasClients) {
        controller.animateTo(
          0.0,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeOutCubic,
        );
      }
    } else {
      context.go(_navItems[index].path);
    }
  }

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

    return PopScope(
      canPop: location == '/',
      onPopInvokedWithResult: (didPop, result) {
        if (!didPop) {
          context.go('/');
        }
      },
      child: Scaffold(
        backgroundColor: t.background,
        body: widget.child,
        floatingActionButton: FloatingActionButton.small(
          heroTag: 'command_palette_fab',
          backgroundColor: t.accent,
          foregroundColor: t.accentForeground,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.zero,
            side: BorderSide(color: t.border, width: 2.5),
          ),
          onPressed: () => showBkCommandPalette(context),
          tooltip: 'Quick Commands (⌘K)',
          child: const Icon(Icons.search, size: 20),
        ),
        bottomNavigationBar: _BkBottomNav(
          t: t,
          items: _navItems,
          selectedIndex: selectedIndex,
          pulseAnimation: _pulseAnimation,
          onTap: (i) => _onNavTap(context, i, selectedIndex),
        ),
      ),
    );
  }
}

class _BkBottomNav extends StatelessWidget {
  const _BkBottomNav({
    required this.t,
    required this.items,
    required this.selectedIndex,
    required this.pulseAnimation,
    required this.onTap,
  });

  final BkTokens t;
  final List<_NavItem> items;
  final int selectedIndex;
  final Animation<double> pulseAnimation;
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
                    duration: const Duration(milliseconds: 140),
                    curve: Curves.easeOut,
                    decoration: BoxDecoration(
                      color: isSelected ? t.primary : Colors.transparent,
                      border: i < items.length - 1
                          ? Border(right: BorderSide(color: t.border, width: 1))
                          : null,
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      clipBehavior: Clip.none,
                      children: [
                        Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSelected ? item.activeIcon : item.icon,
                              color: isSelected
                                  ? t.primaryForeground
                                  : t.mutedForeground,
                              size: 22,
                            ),
                            const SizedBox(height: 2),
                            FittedBox(
                              fit: BoxFit.scaleDown,
                              child: Text(
                                item.label.toUpperCase(),
                                style: GoogleFonts.outfit(
                                  fontSize: 9,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0.3,
                                  color: isSelected
                                      ? t.primaryForeground
                                      : t.mutedForeground,
                                ),
                              ),
                            ),
                          ],
                        ),
                        if (item.hasBadge && !isSelected)
                          Positioned(
                            top: 8,
                            right: 8,
                            child: ScaleTransition(
                              scale: pulseAnimation,
                              child: Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 4, vertical: 1),
                                decoration: BoxDecoration(
                                  color: t.accent,
                                  border:
                                      Border.all(color: t.border, width: 1.5),
                                ),
                                child: Text(
                                  '75+',
                                  style: GoogleFonts.dmMono(
                                    fontSize: 8,
                                    fontWeight: FontWeight.w900,
                                    color: t.accentForeground,
                                  ),
                                ),
                              ),
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
    this.hasBadge = false,
  });

  final IconData icon;
  final IconData activeIcon;
  final String label;
  final String path;
  final bool hasBadge;
}
