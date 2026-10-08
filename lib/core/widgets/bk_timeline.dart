import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../theme/bk_tokens.dart';

class BkTimelineItem {
  const BkTimelineItem({
    required this.title,
    this.description,
    this.timestamp,
    this.icon,
    this.nodeColor,
    this.isCompleted = false,
  });

  final String title;
  final String? description;
  final String? timestamp;
  final IconData? icon;
  final Color? nodeColor;
  final bool isCompleted;
}

/// A neubrutalist timeline component with connecting 3px solid rules and brutalist nodes.
class BkTimeline extends StatelessWidget {
  const BkTimeline({
    super.key,
    required this.items,
  });

  final List<BkTimelineItem> items;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Column(
      children: List.generate(items.length, (index) {
        final item = items[index];
        final isLast = index == items.length - 1;
        final nodeBg =
            item.nodeColor ?? (item.isCompleted ? t.primary : t.card);

        return IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Left track & node
              SizedBox(
                width: 44,
                child: Column(
                  children: [
                    // Node
                    Container(
                      width: 32,
                      height: 32,
                      decoration: BoxDecoration(
                        color: nodeBg,
                        border:
                            Border.all(color: t.border, width: t.borderWidth),
                        boxShadow: [
                          BoxShadow(
                            color: t.shadowColor,
                            offset:
                                Offset(t.shadowOffset - 1, t.shadowOffset - 1),
                            blurRadius: 0,
                          ),
                        ],
                      ),
                      child: Center(
                        child: item.icon != null
                            ? Icon(item.icon,
                                size: 16,
                                color: item.isCompleted
                                    ? t.primaryForeground
                                    : t.foreground)
                            : Text(
                                '${index + 1}',
                                style: GoogleFonts.dmMono(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  color: item.isCompleted
                                      ? t.primaryForeground
                                      : t.foreground,
                                ),
                              ),
                      ),
                    ),
                    // Line
                    if (!isLast)
                      Expanded(
                        child: Container(
                          width: t.borderWidth,
                          color: t.border,
                        ),
                      ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Content card
              Expanded(
                child: Padding(
                  padding: EdgeInsets.only(bottom: isLast ? 0 : 24),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: t.card,
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: [
                        BoxShadow(
                          color: t.shadowColor,
                          offset:
                              Offset(t.shadowOffset - 1, t.shadowOffset - 1),
                          blurRadius: 0,
                        ),
                      ],
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        if (item.timestamp != null) ...[
                          Text(
                            item.timestamp!.toUpperCase(),
                            style: GoogleFonts.dmMono(
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                              color: t.mutedForeground,
                            ),
                          ),
                          const SizedBox(height: 4),
                        ],
                        Text(
                          item.title.toUpperCase(),
                          style: GoogleFonts.outfit(
                            fontSize: 14,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 0.3,
                            color: t.foreground,
                          ),
                        ),
                        if (item.description != null) ...[
                          const SizedBox(height: 4),
                          Text(
                            item.description!,
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              color: t.mutedForeground,
                              height: 1.4,
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
