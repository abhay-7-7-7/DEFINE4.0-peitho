import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_motion.dart';
import '../theme/bk_tokens.dart';

class BkBreadcrumbItem {
  const BkBreadcrumbItem({
    required this.label,
    this.onTap,
    this.icon,
    this.isCurrent = false,
  });

  final String label;
  final VoidCallback? onTap;
  final IconData? icon;
  final bool isCurrent;
}

/// A neubrutalist breadcrumbs navigation strip.
class BkBreadcrumb extends StatelessWidget {
  const BkBreadcrumb({
    super.key,
    required this.items,
    this.separator = '/',
  });

  final List<BkBreadcrumbItem> items;
  final String separator;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: List.generate(items.length * 2 - 1, (index) {
          if (index.isOdd) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 8),
              child: Text(
                separator,
                style: GoogleFonts.dmMono(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: t.mutedForeground,
                ),
              ),
            );
          }

          final item = items[index ~/ 2];
          final isCurrent = item.isCurrent;

          Widget content = Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: isCurrent
                ? BoxDecoration(
                    color: t.primary,
                    border: Border.all(color: t.border, width: 2),
                    boxShadow: [
                      BoxShadow(
                        color: t.shadowColor,
                        offset: const Offset(2, 2),
                        blurRadius: 0,
                      ),
                    ],
                  )
                : null,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                if (item.icon != null) ...[
                  Icon(
                    item.icon,
                    size: 14,
                    color: isCurrent ? t.primaryForeground : t.foreground,
                  ),
                  const SizedBox(width: 4),
                ],
                Text(
                  item.label.toUpperCase(),
                  style: GoogleFonts.outfit(
                    fontSize: 12,
                    fontWeight: isCurrent ? FontWeight.w900 : FontWeight.w700,
                    color: isCurrent
                        ? t.primaryForeground
                        : (item.onTap != null
                            ? t.foreground
                            : t.mutedForeground),
                    letterSpacing: 0.5,
                  ),
                ),
              ],
            ),
          );

          if (item.onTap != null && !isCurrent) {
            return GestureDetector(
              onTap: () {
                BkMotion.hapticClick();
                item.onTap?.call();
              },
              child: content,
            );
          }

          return content;
        }),
      ),
    );
  }
}
