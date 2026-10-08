import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkCommandItem {
  const BkCommandItem({
    required this.title,
    this.subtitle,
    required this.category,
    this.icon,
    this.route,
    this.onSelected,
  });

  final String title;
  final String? subtitle;
  final String category;
  final IconData? icon;
  final String? route;
  final VoidCallback? onSelected;
}

Future<void> showBkCommandPalette(BuildContext context) {
  BkMotion.hapticClick();
  return showDialog(
    context: context,
    barrierColor: Colors.black54,
    builder: (context) => const BkCommandPalette(),
  );
}

/// Neubrutalist Command Palette modal with keyboard-style search and quick navigation.
class BkCommandPalette extends StatefulWidget {
  const BkCommandPalette({super.key});

  @override
  State<BkCommandPalette> createState() => _BkCommandPaletteState();
}

class _BkCommandPaletteState extends State<BkCommandPalette> {
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  static const _commands = [
    // Pages
    BkCommandItem(
        title: 'Home Screen', category: 'Pages', icon: Icons.home, route: '/'),
    BkCommandItem(
        title: 'Components Catalog',
        category: 'Pages',
        icon: Icons.widgets,
        route: '/components'),
    BkCommandItem(
        title: 'Interactive Charts',
        category: 'Pages',
        icon: Icons.bar_chart,
        route: '/charts'),
    BkCommandItem(
        title: 'Shapes Gallery',
        category: 'Pages',
        icon: Icons.category,
        route: '/shapes'),
    BkCommandItem(
        title: 'Shape Builder Studio',
        category: 'Pages',
        icon: Icons.tune,
        route: '/shapes/builder'),
    BkCommandItem(
        title: 'ASCII & Shaders Studio',
        category: 'Pages',
        icon: Icons.terminal,
        route: '/ascii'),
    BkCommandItem(
        title: 'Theme Builder',
        category: 'Pages',
        icon: Icons.palette,
        route: '/theme-builder'),
    BkCommandItem(
        title: 'Settings & About',
        category: 'Pages',
        icon: Icons.settings,
        route: '/settings'),
    // Blocks
    BkCommandItem(
        title: 'Auth Login',
        category: 'Blocks',
        icon: Icons.lock,
        route: '/blocks/login'),
    BkCommandItem(
        title: 'Auth Sign Up',
        category: 'Blocks',
        icon: Icons.person_add,
        route: '/blocks/signup'),
    BkCommandItem(
        title: 'Auth OTP Verification',
        category: 'Blocks',
        icon: Icons.pin,
        route: '/blocks/otp'),
    BkCommandItem(
        title: 'Onboarding Flow',
        category: 'Blocks',
        icon: Icons.flag,
        route: '/blocks/onboarding'),
    BkCommandItem(
        title: 'Invoice Generator',
        category: 'Blocks',
        icon: Icons.receipt,
        route: '/blocks/invoice'),
    BkCommandItem(
        title: 'Pricing Tiers',
        category: 'Blocks',
        icon: Icons.sell,
        route: '/blocks/pricing'),
    BkCommandItem(
        title: 'Testimonials Carousel',
        category: 'Blocks',
        icon: Icons.format_quote,
        route: '/blocks/testimonials'),
    BkCommandItem(
        title: 'Team Directory',
        category: 'Blocks',
        icon: Icons.group,
        route: '/blocks/team'),
    BkCommandItem(
        title: 'FAQ Accordion',
        category: 'Blocks',
        icon: Icons.help_outline,
        route: '/blocks/faq'),
    BkCommandItem(
        title: 'Contact Form',
        category: 'Blocks',
        icon: Icons.mail_outline,
        route: '/blocks/contact'),
    BkCommandItem(
        title: 'Account Settings',
        category: 'Blocks',
        icon: Icons.manage_accounts,
        route: '/blocks/settings'),
    BkCommandItem(
        title: '404 Not Found Page',
        category: 'Blocks',
        icon: Icons.error_outline,
        route: '/blocks/404'),
    BkCommandItem(
        title: '500 Server Error Page',
        category: 'Blocks',
        icon: Icons.warning_amber,
        route: '/blocks/500'),
    BkCommandItem(
        title: 'Maintenance Status Page',
        category: 'Blocks',
        icon: Icons.build,
        route: '/blocks/maintenance'),
  ];

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final filtered = _commands.where((c) {
      if (_query.isEmpty) return true;
      final q = _query.toLowerCase();
      return c.title.toLowerCase().contains(q) ||
          c.category.toLowerCase().contains(q) ||
          (c.subtitle?.toLowerCase().contains(q) ?? false);
    }).toList();

    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      insetPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540, maxHeight: 520),
          child: Container(
            decoration: BoxDecoration(
              color: t.background,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(t.shadowOffset + 2, t.shadowOffset + 2),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Search Input Header
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                  decoration: BoxDecoration(
                    color: t.card,
                    border: Border(
                        bottom:
                            BorderSide(color: t.border, width: t.borderWidth)),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.search, size: 22, color: t.foreground),
                      const SizedBox(width: 12),
                      Expanded(
                        child: TextField(
                          controller: _searchController,
                          autofocus: true,
                          style: GoogleFonts.outfit(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,
                            color: t.foreground,
                          ),
                          decoration: InputDecoration(
                            hintText: 'TYPE A COMMAND OR SCREEN...',
                            hintStyle: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.mutedForeground,
                            ),
                            border: InputBorder.none,
                            enabledBorder: InputBorder.none,
                            focusedBorder: InputBorder.none,
                            isDense: true,
                            contentPadding: EdgeInsets.zero,
                          ),
                          onChanged: (text) => setState(() => _query = text),
                        ),
                      ),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 6, vertical: 2),
                        decoration: BoxDecoration(
                          color: t.muted,
                          border: Border.all(color: t.border, width: 1.5),
                        ),
                        child: Text(
                          'ESC',
                          style: GoogleFonts.dmMono(
                            fontSize: 10,
                            fontWeight: FontWeight.bold,
                            color: t.foreground,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                // Results List
                Expanded(
                  child: filtered.isEmpty
                      ? Center(
                          child: Text(
                            'NO MATCHING COMMANDS FOUND',
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: t.mutedForeground,
                            ),
                          ),
                        )
                      : ListView.separated(
                          itemCount: filtered.length,
                          separatorBuilder: (_, __) => Divider(
                              height: 1,
                              color: t.border.withValues(alpha: 0.2)),
                          itemBuilder: (context, i) {
                            final cmd = filtered[i];
                            return Material(
                              color: Colors.transparent,
                              child: ListTile(
                                leading: cmd.icon != null
                                    ? Icon(cmd.icon,
                                        size: 20, color: t.foreground)
                                    : null,
                                title: Text(
                                  cmd.title.toUpperCase(),
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w800,
                                    color: t.foreground,
                                  ),
                                ),
                                trailing: Container(
                                  padding: const EdgeInsets.symmetric(
                                      horizontal: 6, vertical: 2),
                                  decoration: BoxDecoration(
                                    color: t.muted,
                                    border:
                                        Border.all(color: t.border, width: 1),
                                  ),
                                  child: Text(
                                    cmd.category.toUpperCase(),
                                    style: GoogleFonts.dmMono(
                                      fontSize: 9,
                                      fontWeight: FontWeight.bold,
                                      color: t.mutedForeground,
                                    ),
                                  ),
                                ),
                                onTap: () {
                                  BkMotion.hapticClick();
                                  Navigator.of(context).pop();
                                  if (cmd.route != null) {
                                    context.go(cmd.route!);
                                  } else {
                                    cmd.onSelected?.call();
                                  }
                                },
                              ),
                            );
                          },
                        ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
