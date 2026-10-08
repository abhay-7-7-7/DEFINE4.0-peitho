import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_button.dart';
import '../../data/mock_data.dart';

// ─── Home Screen ─────────────────────────────────────────────────────────────

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const _HomeBody();
  }
}

class _HomeBody extends StatelessWidget {
  const _HomeBody();

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Scaffold(
      backgroundColor: t.background,
      body: CustomScrollView(
        slivers: [
          _BkSliverAppBar(),
          SliverToBoxAdapter(child: _HeroSection()),
          SliverToBoxAdapter(child: _MarqueeStrip()),
          SliverToBoxAdapter(child: _StatsRow()),
          SliverToBoxAdapter(child: _FeatureGrid()),
          SliverToBoxAdapter(child: _ShapesShowcase()),
          SliverToBoxAdapter(child: _CtaSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }
}

// ─── Sliver App Bar ──────────────────────────────────────────────────────────

class _BkSliverAppBar extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return SliverAppBar(
      backgroundColor: t.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      expandedHeight: 0,
      titleSpacing: 20,
      title: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: t.primary,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3), blurRadius: 0)],
            ),
            child: Center(
              child: Text(
                'BK',
                style: GoogleFonts.outfit(
                  fontSize: 14,
                  fontWeight: FontWeight.w900,
                  color: t.primaryForeground,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Text(
            'BOLDKIT',
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: t.foreground,
              letterSpacing: 2,
            ),
          ),
        ],
      ),
      actions: [
        _ThemeToggleButton(),
        const SizedBox(width: 16),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(1),
        child: Container(height: 3, color: t.border),
      ),
    );
  }
}

class _ThemeToggleButton extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return _PressableBox(
      onTap: () {
        // Theme toggle handled by provider upstream
      },
      child: Container(
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.border, width: t.borderWidth),
          boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3), blurRadius: 0)],
        ),
        child: Icon(t.isDark ? Icons.light_mode : Icons.dark_mode, size: 18, color: t.foreground),
      ),
    );
  }
}

// ─── Hero Section ────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 1280;
      final isTablet = constraints.maxWidth >= 768;
      final titleSize = isDesktop ? 72.0 : isTablet ? 52.0 : 36.0;
      final subtitleSize = isDesktop ? 20.0 : 16.0;
      final hPad = isDesktop ? 80.0 : isTablet ? 40.0 : 20.0;

      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 48),
        decoration: BoxDecoration(
          color: t.background,
          border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(flex: 3, child: _HeroText(titleSize: titleSize, subtitleSize: subtitleSize)),
                  const SizedBox(width: 48),
                  Expanded(flex: 2, child: _HeroSticker()),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroText(titleSize: titleSize, subtitleSize: subtitleSize),
                  const SizedBox(height: 32),
                  Center(child: _HeroSticker()),
                ],
              ),
      );
    });
  }
}

class _HeroText extends StatelessWidget {
  const _HeroText({required this.titleSize, required this.subtitleSize});
  final double titleSize;
  final double subtitleSize;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Badge
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
          decoration: BoxDecoration(
            color: t.accent,
            border: Border.all(color: t.border, width: t.borderWidth),
            boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3), blurRadius: 0)],
          ),
          child: Text(
            '✦ UI COMPONENT LIBRARY',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w800,
              color: t.accentForeground,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 24),
        // Title
        Text(
          'BUILD\nBRUTAL,\nBUILD BOLD',
          style: GoogleFonts.outfit(
            fontSize: titleSize,
            fontWeight: FontWeight.w900,
            color: t.foreground,
            letterSpacing: -1.5,
            height: 0.95,
          ),
        ),
        const SizedBox(height: 24),
        // Subtitle
        Text(
          'A neubrutalist Flutter component library with bold borders,\nhard shadows, and zero compromise on personality.',
          style: GoogleFonts.outfit(
            fontSize: subtitleSize,
            fontWeight: FontWeight.w500,
            color: t.mutedForeground,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 36),
        // CTA buttons
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            BkButton(
              label: 'BROWSE COMPONENTS',
              variant: BkButtonVariant.primary,
              size: BkButtonSize.lg,
              onPressed: () => context.go('/components'),
            ),
            BkButton(
              label: 'VIEW CHARTS',
              variant: BkButtonVariant.outline,
              size: BkButtonSize.lg,
              onPressed: () => context.go('/charts'),
            ),
          ],
        ),
      ],
    );
  }
}

class _HeroSticker extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Transform.rotate(
      angle: -0.08,
      child: Container(
        width: 280,
        height: 280,
        decoration: BoxDecoration(
          color: t.accent,
          border: Border.all(color: t.border, width: 3),
          boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(8, 8), blurRadius: 0)],
        ),
        child: Stack(
          children: [
            // Texture lines
            ...List.generate(10, (i) {
              return Positioned(
                top: (i * 28.0) + 10,
                left: 0,
                right: 0,
                child: Container(height: 1, color: t.accentForeground.withValues(alpha: 0.15)),
              );
            }),
            Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    '★',
                    style: TextStyle(fontSize: 48, color: t.accentForeground),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'NEUBRUTALISM',
                    style: GoogleFonts.outfit(
                      fontSize: 16,
                      fontWeight: FontWeight.w900,
                      color: t.accentForeground,
                      letterSpacing: 3,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'FOR FLUTTER',
                    style: GoogleFonts.outfit(
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: t.accentForeground,
                      letterSpacing: 2,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: t.primary,
                      border: Border.all(color: t.border, width: 2),
                    ),
                    child: Text(
                      '75+ COMPONENTS',
                      style: GoogleFonts.outfit(
                        fontSize: 11,
                        fontWeight: FontWeight.w800,
                        color: t.primaryForeground,
                        letterSpacing: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ─── Marquee Strip ───────────────────────────────────────────────────────────

class _MarqueeStrip extends StatefulWidget {
  @override
  State<_MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<_MarqueeStrip> with SingleTickerProviderStateMixin {
  late final ScrollController _ctrl;
  Timer? _timer;

  final List<String> _items = const [
    'BUTTON', '✦', 'CARD', '✦', 'BADGE', '✦', 'INPUT', '✦', 'CHECKBOX',
    '✦', 'SWITCH', '✦', 'SPINNER', '✦', 'ALERT', '✦', 'PROGRESS', '✦',
    'TABS', '✦', 'ACCORDION', '✦', 'DIALOG', '✦', 'TOAST', '✦', 'AVATAR',
    '✦', 'SLIDER', '✦', 'MARQUEE', '✦', 'SHAPES', '✦', 'CHARTS', '✦',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    WidgetsBinding.instance.addPostFrameCallback((_) => _startScroll());
  }

  void _startScroll() {
    if (!mounted) return;
    _timer = Timer.periodic(const Duration(milliseconds: 30), (_) {
      if (!mounted || !_ctrl.hasClients) return;
      final max = _ctrl.position.maxScrollExtent;
      final next = _ctrl.offset + 1.5;
      if (next >= max) {
        _ctrl.jumpTo(0);
      } else {
        _ctrl.jumpTo(next);
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final all = [..._items, ..._items, ..._items];
    return Container(
      height: 52,
      decoration: BoxDecoration(
        color: t.primary,
        border: Border.symmetric(
          horizontal: BorderSide(color: t.border, width: t.borderWidth),
        ),
      ),
      child: ListView.separated(
        controller: _ctrl,
        scrollDirection: Axis.horizontal,
        physics: const NeverScrollableScrollPhysics(),
        itemCount: all.length,
        separatorBuilder: (_, __) => const SizedBox(width: 24),
        itemBuilder: (_, i) => Center(
          child: Text(
            all[i],
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: t.primaryForeground,
              letterSpacing: 2,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Stats Row ───────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280 ? 80.0 : constraints.maxWidth >= 768 ? 40.0 : 20.0;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 40),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: LayoutBuilder(builder: (context, inner) {
          final cols = inner.maxWidth >= 900 ? 4 : (inner.maxWidth >= 500 ? 2 : 1);
          return GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: cols,
              mainAxisSpacing: 8,
              crossAxisSpacing: 8,
              childAspectRatio: cols == 4 ? 1.4 : (cols == 2 ? 1.6 : 2.2),
            ),
            itemCount: mockStats.length,
            itemBuilder: (_, i) => _StatItem(stat: mockStats[i], tokens: t),
          );
        }),
      );
    });
  }
}

class _StatItem extends StatelessWidget {
  const _StatItem({required this.stat, required this.tokens});
  final MockStat stat;
  final BkTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final colors = [t.primary, t.secondary, t.accent, t.neonPink];
    final idx = mockStats.indexOf(stat).clamp(0, 3);
    return Container(
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      margin: EdgeInsets.zero,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 4,
            height: 20,
            color: colors[idx],
          ),
          const SizedBox(height: 6),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: Text(
              '${stat.value}${stat.suffix}',
              style: GoogleFonts.outfit(
                fontSize: 32,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                height: 1,
              ),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            stat.label.toUpperCase(),
            style: GoogleFonts.outfit(
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: t.mutedForeground,
              letterSpacing: 1.5,
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid ────────────────────────────────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  static const List<_FeatureData> _features = [
    _FeatureData(
      title: 'BOLD BY DESIGN',
      description: 'Every component ships with 3px borders, hard shadows, and zero border-radius. No compromise.',
      accentColor: 0xFFEE7171,
      icon: '⬛',
    ),
    _FeatureData(
      title: 'DARK MODE',
      description: 'Full token-based dark mode support. Every color adapts seamlessly with BkTokens.',
      accentColor: 0xFF3DC9B3,
      icon: '◑',
    ),
    _FeatureData(
      title: 'PRESS ANIMATIONS',
      description: 'Brutalist push-down animations on every interactive element. Tactile. Physical.',
      accentColor: 0xFFFFD849,
      icon: '▼',
    ),
    _FeatureData(
      title: '75+ COMPONENTS',
      description: 'Buttons, cards, inputs, overlays, navigation, charts, shapes — production ready.',
      accentColor: 0xFFE44C8A,
      icon: '⊞',
    ),
    _FeatureData(
      title: 'RESPONSIVE',
      description: 'Phone, tablet, desktop layouts via LayoutBuilder. Every screen adapts perfectly.',
      accentColor: 0xFF7C3ADB,
      icon: '⊡',
    ),
    _FeatureData(
      title: 'THEME BUILDER',
      description: 'Generate custom color palettes live. Copy tokens directly into your project.',
      accentColor: 0xFF5EDBA0,
      icon: '✦',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280 ? 80.0 : constraints.maxWidth >= 768 ? 40.0 : 20.0;
      final cols = constraints.maxWidth >= 1280 ? 3 : constraints.maxWidth >= 768 ? 2 : 1;
      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 60, hPad, 60),
        decoration: BoxDecoration(
          color: t.muted.withValues(alpha: 0.3),
          border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'WHY BOLDKIT',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: t.mutedForeground,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'BUILT DIFFERENT.',
              style: GoogleFonts.outfit(
                fontSize: 40,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 32),
            GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: cols,
                mainAxisSpacing: 0,
                crossAxisSpacing: 0,
                childAspectRatio: cols == 1 ? 3.5 : 1.6,
              ),
              itemCount: _features.length,
              itemBuilder: (_, i) => _FeatureCard(data: _features[i], tokens: t),
            ),
          ],
        ),
      );
    });
  }
}

class _FeatureData {
  const _FeatureData({
    required this.title,
    required this.description,
    required this.accentColor,
    required this.icon,
  });
  final String title;
  final String description;
  final int accentColor;
  final String icon;
}

class _FeatureCard extends StatelessWidget {
  const _FeatureCard({required this.data, required this.tokens});
  final _FeatureData data;
  final BkTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final accent = Color(data.accentColor);
    return Container(
      margin: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: t.card,
        border: Border(
          left: BorderSide(color: accent, width: 4),
          top: BorderSide(color: t.border, width: t.borderWidth),
          right: BorderSide(color: t.border, width: t.borderWidth),
          bottom: BorderSide(color: t.border, width: t.borderWidth),
        ),
        boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(4, 4), blurRadius: 0)],
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            data.icon,
            style: TextStyle(fontSize: 28, color: accent),
          ),
          const SizedBox(height: 12),
          Text(
            data.title,
            style: GoogleFonts.outfit(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: t.foreground,
              letterSpacing: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            data.description,
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w500,
              color: t.mutedForeground,
              height: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

// ─── Shapes Showcase ─────────────────────────────────────────────────────────

class _ShapesShowcase extends StatelessWidget {
  static const List<_MiniShape> _shapes = [
    _MiniShape(label: 'CIRCLE', color: 0xFFEE7171, type: _ShapeType.circle),
    _MiniShape(label: 'SQUARE', color: 0xFF3DC9B3, type: _ShapeType.square),
    _MiniShape(label: 'TRIANGLE', color: 0xFFFFD849, type: _ShapeType.triangle),
    _MiniShape(label: 'HEXAGON', color: 0xFFE44C8A, type: _ShapeType.hexagon),
    _MiniShape(label: 'STAR', color: 0xFF7C3ADB, type: _ShapeType.star),
    _MiniShape(label: 'DIAMOND', color: 0xFF5EDBA0, type: _ShapeType.diamond),
    _MiniShape(label: 'CROSS', color: 0xFFFF6B35, type: _ShapeType.cross),
    _MiniShape(label: 'ARROW', color: 0xFF4ECDC4, type: _ShapeType.arrow),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280 ? 80.0 : constraints.maxWidth >= 768 ? 40.0 : 20.0;
      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 60, hPad, 60),
        decoration: BoxDecoration(
          border: Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SHAPE LIBRARY',
                  style: GoogleFonts.outfit(
                    fontSize: 32,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                    letterSpacing: -0.5,
                  ),
                ),
                BkButton(
                  label: 'EXPLORE',
                  variant: BkButtonVariant.outline,
                  size: BkButtonSize.sm,
                  onPressed: () => context.go('/shapes'),
                ),
              ],
            ),
            const SizedBox(height: 24),
            SizedBox(
              height: 120,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _shapes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 12),
                itemBuilder: (_, i) => _MiniShapeWidget(shape: _shapes[i], tokens: t),
              ),
            ),
          ],
        ),
      );
    });
  }
}

enum _ShapeType { circle, square, triangle, hexagon, star, diamond, cross, arrow }

class _MiniShape {
  const _MiniShape({required this.label, required this.color, required this.type});
  final String label;
  final int color;
  final _ShapeType type;
}

class _MiniShapeWidget extends StatelessWidget {
  const _MiniShapeWidget({required this.shape, required this.tokens});
  final _MiniShape shape;
  final BkTokens tokens;

  @override
  Widget build(BuildContext context) {
    final t = tokens;
    final color = Color(shape.color);
    return Container(
      width: 100,
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3), blurRadius: 0)],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            width: 56,
            height: 56,
            child: CustomPaint(painter: _SimpleShapePainter(shape.type, color)),
          ),
          const SizedBox(height: 6),
          Text(
            shape.label,
            style: GoogleFonts.outfit(
              fontSize: 9,
              fontWeight: FontWeight.w800,
              color: t.foreground,
              letterSpacing: 1.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _SimpleShapePainter extends CustomPainter {
  const _SimpleShapePainter(this.type, this.color);
  final _ShapeType type;
  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..color = color..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = Colors.black
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2;
    final cx = size.width / 2;
    final cy = size.height / 2;
    final r = size.width * 0.45;

    switch (type) {
      case _ShapeType.circle:
        canvas.drawCircle(Offset(cx, cy), r, paint);
        canvas.drawCircle(Offset(cx, cy), r, stroke);
      case _ShapeType.square:
        final rect = Rect.fromCenter(center: Offset(cx, cy), width: r * 1.8, height: r * 1.8);
        canvas.drawRect(rect, paint);
        canvas.drawRect(rect, stroke);
      case _ShapeType.triangle:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy + r * 0.7)
          ..lineTo(cx - r, cy + r * 0.7)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
      case _ShapeType.hexagon:
        final path = Path();
        for (var i = 0; i < 6; i++) {
          final angle = (i * 60 - 30) * 3.14159 / 180;
          final px = cx + r * (i == 0 ? 1 : 1) * _cos(angle);
          final py = cy + r * _sin(angle);
          i == 0 ? path.moveTo(px, py) : path.lineTo(px, py);
        }
        path.close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
      case _ShapeType.star:
        final path = _starPath(cx, cy, r, r * 0.4, 5);
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
      case _ShapeType.diamond:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r * 0.7, cy)
          ..lineTo(cx, cy + r)
          ..lineTo(cx - r * 0.7, cy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
      case _ShapeType.cross:
        final arm = r * 0.35;
        final path = Path()
          ..moveTo(cx - arm, cy - r)
          ..lineTo(cx + arm, cy - r)
          ..lineTo(cx + arm, cy - arm)
          ..lineTo(cx + r, cy - arm)
          ..lineTo(cx + r, cy + arm)
          ..lineTo(cx + arm, cy + arm)
          ..lineTo(cx + arm, cy + r)
          ..lineTo(cx - arm, cy + r)
          ..lineTo(cx - arm, cy + arm)
          ..lineTo(cx - r, cy + arm)
          ..lineTo(cx - r, cy - arm)
          ..lineTo(cx - arm, cy - arm)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
      case _ShapeType.arrow:
        final path = Path()
          ..moveTo(cx, cy - r)
          ..lineTo(cx + r, cy)
          ..lineTo(cx + r * 0.4, cy)
          ..lineTo(cx + r * 0.4, cy + r)
          ..lineTo(cx - r * 0.4, cy + r)
          ..lineTo(cx - r * 0.4, cy)
          ..lineTo(cx - r, cy)
          ..close();
        canvas.drawPath(path, paint);
        canvas.drawPath(path, stroke);
    }
  }

  double _cos(double a) => math.cos(a);
  double _sin(double a) => math.sin(a);

  Path _starPath(double cx, double cy, double outerR, double innerR, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = (i * 3.14159 / points) - 3.14159 / 2;
      final r2 = i.isEven ? outerR : innerR;
      final x = cx + r2 * _cos(angle);
      final y = cy + r2 * _sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _SimpleShapePainter old) => old.type != type || old.color != color;
}

// ─── CTA Section ─────────────────────────────────────────────────────────────

class _CtaSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280 ? 80.0 : constraints.maxWidth >= 768 ? 40.0 : 20.0;
      return Container(
        padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 72),
        decoration: BoxDecoration(
          color: t.primary,
          border: Border(top: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          children: [
            Text(
              'READY TO BUILD BOLD?',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 48,
                fontWeight: FontWeight.w900,
                color: t.primaryForeground,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              'Start building neubrutalist Flutter apps today.\nEverything you need. Zero configuration.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: t.primaryForeground.withValues(alpha: 0.8),
                height: 1.5,
              ),
            ),
            const SizedBox(height: 36),
            BkButton(
              label: 'GET STARTED FREE →',
              variant: BkButtonVariant.secondary,
              size: BkButtonSize.xl,
              onPressed: () => context.go('/components'),
            ),
          ],
        ),
      );
    });
  }
}

// ─── Pressable box helper ────────────────────────────────────────────────────

class _PressableBox extends StatefulWidget {
  const _PressableBox({required this.child, required this.onTap});
  final Widget child;
  final VoidCallback onTap;

  @override
  State<_PressableBox> createState() => _PressableBoxState();
}

class _PressableBoxState extends State<_PressableBox> {
  bool _pressed = false;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) {
        setState(() => _pressed = false);
        widget.onTap();
      },
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(_pressed ? 2 : 0, _pressed ? 2 : 0, 0),
        child: widget.child,
      ),
    );
  }
}
