import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/bk_motion.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../../data/mock_data.dart';
import '../settings/theme_provider.dart';

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
    final t = context.bk;
    return Scaffold(
      backgroundColor: t.background,
      body: CustomScrollView(
        slivers: [
          _BkSliverAppBar(),
          SliverToBoxAdapter(child: _HeroSection()),
          SliverToBoxAdapter(child: _MarqueeStrip()),
          SliverToBoxAdapter(child: _StatsRow()),
          SliverToBoxAdapter(child: _FeatureGrid()),
          SliverToBoxAdapter(child: _PlaygroundSection()),
          SliverToBoxAdapter(child: _ShapesShowcase()),
          SliverToBoxAdapter(child: _CtaSection()),
          const SliverToBoxAdapter(child: SizedBox(height: 60)),
        ],
      ),
    );
  }
}

// ─── Sliver App Bar ──────────────────────────────────────────────────────────

class _BkSliverAppBar extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final t = context.bk;
    return SliverAppBar(
      backgroundColor: t.background,
      surfaceTintColor: Colors.transparent,
      elevation: 0,
      pinned: true,
      titleSpacing: 16,
      title: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 36,
            height: 36,
            decoration: BoxDecoration(
              color: t.primary,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(
                    color: t.shadowColor,
                    offset: const Offset(3, 3),
                    blurRadius: 0)
              ],
            ),
            child: Center(
              child: Text(
                'BK',
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: t.primaryForeground,
                  letterSpacing: 1,
                ),
              ),
            ),
          ),
          const SizedBox(width: 10),
          Flexible(
            child: Text(
              'BOLDKIT',
              style: GoogleFonts.outfit(
                fontSize: 15,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: 2,
              ),
              overflow: TextOverflow.ellipsis,
            ),
          ),
        ],
      ),
      actions: [
        IconButton(
          icon: Icon(Icons.search, color: t.foreground),
          tooltip: 'Quick Search (⌘K)',
          onPressed: () => showBkCommandPalette(context),
        ),
        _ThemeToggleButton(),
        const SizedBox(width: 12),
      ],
      bottom: PreferredSize(
        preferredSize: const Size.fromHeight(3),
        child: Container(height: 3, color: t.border),
      ),
    );
  }
}

class _ThemeToggleButton extends ConsumerStatefulWidget {
  @override
  ConsumerState<_ThemeToggleButton> createState() => _ThemeToggleButtonState();
}

class _ThemeToggleButtonState extends ConsumerState<_ThemeToggleButton>
    with SingleTickerProviderStateMixin {
  late final AnimationController _iconAnim;
  bool _pressed = false;

  @override
  void initState() {
    super.initState();
    _iconAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _iconAnim.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    final themeMode = ref.watch(themeModeProvider);
    final notifier = ref.read(themeModeProvider.notifier);

    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    if (effectiveDark) {
      _iconAnim.forward();
    } else {
      _iconAnim.reverse();
    }

    return GestureDetector(
      onTap: () {
        BkMotion.hapticClick();
        notifier.toggle();
      },
      onTapDown: (_) => setState(() => _pressed = true),
      onTapUp: (_) => setState(() => _pressed = false),
      onTapCancel: () => setState(() => _pressed = false),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 80),
        transform: Matrix4.translationValues(
          _pressed ? 2 : 0,
          _pressed ? 2 : 0,
          0,
        ),
        width: 40,
        height: 40,
        decoration: BoxDecoration(
          color: t.card,
          border: Border.all(color: t.border, width: t.borderWidth),
          boxShadow: _pressed
              ? const []
              : [
                  BoxShadow(
                      color: t.shadowColor,
                      offset: const Offset(3, 3),
                      blurRadius: 0)
                ],
        ),
        child: Center(
          child: AnimatedSwitcher(
            duration: const Duration(milliseconds: 250),
            transitionBuilder: (child, anim) => ScaleTransition(
              scale: anim,
              child: RotationTransition(
                turns: Tween(begin: -0.25, end: 0.0).animate(anim),
                child: child,
              ),
            ),
            child: Icon(
              effectiveDark ? Icons.light_mode : Icons.dark_mode,
              key: ValueKey(effectiveDark),
              size: 18,
              color: t.foreground,
            ),
          ),
        ),
      ),
    );
  }
}

// ─── Hero Section ─────────────────────────────────────────────────────────────

class _HeroSection extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    return LayoutBuilder(builder: (context, constraints) {
      final isDesktop = constraints.maxWidth >= 1280;
      final isTablet = constraints.maxWidth >= 768;
      final titleSize = (isDesktop
              ? 64.0
              : isTablet
                  ? 48.0
                  : 32.0)
          .clamp(28.0, 72.0);
      final subtitleSize = isDesktop ? 18.0 : 15.0;
      final hPad = isDesktop
          ? 80.0
          : isTablet
              ? 40.0
              : 20.0;

      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 40, hPad, 40),
        decoration: BoxDecoration(
          color: t.background,
          border:
              Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: isDesktop
            ? Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                      flex: 3,
                      child: _HeroText(
                          titleSize: titleSize, subtitleSize: subtitleSize)),
                  const SizedBox(width: 48),
                  Expanded(flex: 2, child: _InteractiveHeroVisual()),
                ],
              )
            : Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _HeroText(titleSize: titleSize, subtitleSize: subtitleSize),
                  const SizedBox(height: 32),
                  Center(child: _InteractiveHeroVisual()),
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
    final t = context.bk;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
          decoration: BoxDecoration(
            color: t.accent,
            border: Border.all(color: t.border, width: t.borderWidth),
            boxShadow: [
              BoxShadow(
                  color: t.shadowColor,
                  offset: const Offset(3, 3),
                  blurRadius: 0)
            ],
          ),
          child: Text(
            '✦ NEUBRUTALISM UI KIT',
            style: GoogleFonts.outfit(
              fontSize: 11,
              fontWeight: FontWeight.w900,
              color: t.accentForeground,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 16),
        _AnimatedHeroHeadline(titleSize: titleSize, t: t),
        const SizedBox(height: 16),
        Text(
          'Production-quality Flutter components built with thick 3px borders, hard shadows, zero border-radius, and bold typography. Zero fluff.',
          style: GoogleFonts.outfit(
            fontSize: subtitleSize,
            color: t.mutedForeground,
            height: 1.5,
          ),
        ),
        const SizedBox(height: 28),
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            BkButton(
              label: 'EXPLORE COMPONENTS',
              variant: BkButtonVariant.primary,
              size: BkButtonSize.lg,
              onPressed: () => context.go('/components'),
            ),
            BkButton(
              label: 'THEME BUILDER',
              variant: BkButtonVariant.outline,
              size: BkButtonSize.lg,
              onPressed: () => context.go('/theme-builder'),
            ),
          ],
        ),
      ],
    );
  }
}

class _AnimatedHeroHeadline extends StatefulWidget {
  const _AnimatedHeroHeadline({required this.titleSize, required this.t});
  final double titleSize;
  final BkTokens t;

  @override
  State<_AnimatedHeroHeadline> createState() => _AnimatedHeroHeadlineState();
}

class _AnimatedHeroHeadlineState extends State<_AnimatedHeroHeadline>
    with SingleTickerProviderStateMixin {
  static const _words = ['BRUTAL,', 'BOLD.', 'DIFFERENT.', 'FAST.', 'YOURS.'];
  late final AnimationController _ctrl;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = widget.t;
    return AnimatedBuilder(
      animation: _ctrl,
      builder: (context, _) {
        final totalWords = _words.length;
        final cycleProgress = (_ctrl.value * totalWords) % 1.0;
        final wordIndex = (_ctrl.value * totalWords).floor() % totalWords;
        final currentWord = _words[wordIndex];

        String displayWord;
        bool cursorBlink = false;
        if (cycleProgress < 0.55) {
          final charCount = ((cycleProgress / 0.55) * currentWord.length)
              .clamp(0, currentWord.length)
              .round();
          displayWord = currentWord.substring(0, charCount);
        } else if (cycleProgress < 0.80) {
          displayWord = currentWord;
          cursorBlink = (cycleProgress * 20).floor() % 2 == 0;
        } else {
          final remaining =
              (((1.0 - cycleProgress) / 0.20) * currentWord.length)
                  .clamp(0, currentWord.length)
                  .round();
          displayWord = currentWord.substring(0, remaining);
        }

        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              'BUILD',
              style: GoogleFonts.outfit(
                fontSize: widget.titleSize,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: -1.5,
                height: 1.0,
              ),
            ),
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Flexible(
                  child: Text(
                    displayWord,
                    style: GoogleFonts.outfit(
                      fontSize: widget.titleSize,
                      fontWeight: FontWeight.w900,
                      color: t.primary,
                      letterSpacing: -1.5,
                      height: 1.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                ),
                Opacity(
                  opacity: cursorBlink ? 0.0 : 1.0,
                  child: Container(
                    width: widget.titleSize * 0.08,
                    height: widget.titleSize * 0.85,
                    color: t.primary,
                    margin: const EdgeInsets.only(left: 2),
                  ),
                ),
              ],
            ),
          ],
        );
      },
    );
  }
}

/// Interactive Hero Centerpiece reacting to drag/touch with rotating math curve & floating drift shapes.
class _InteractiveHeroVisual extends StatefulWidget {
  @override
  State<_InteractiveHeroVisual> createState() => _InteractiveHeroVisualState();
}

class _InteractiveHeroVisualState extends State<_InteractiveHeroVisual>
    with SingleTickerProviderStateMixin {
  Offset _dragOffset = Offset.zero;
  late final AnimationController _rotationCtrl;

  @override
  void initState() {
    super.initState();
    _rotationCtrl = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 14),
    )..repeat();
  }

  @override
  void dispose() {
    _rotationCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bk;

    return LayoutBuilder(builder: (ctx, c) {
      final size = c.maxWidth.clamp(200.0, 300.0);

      return GestureDetector(
        onPanUpdate: (d) {
          setState(() {
            _dragOffset = Offset(
              (_dragOffset.dx + d.delta.dx * 0.25).clamp(-20.0, 20.0),
              (_dragOffset.dy + d.delta.dy * 0.25).clamp(-20.0, 20.0),
            );
          });
        },
        onPanEnd: (_) {
          setState(() => _dragOffset = Offset.zero);
        },
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          curve: Curves.easeOutCubic,
          transform:
              Matrix4.translationValues(_dragOffset.dx, _dragOffset.dy, 0),
          child: Transform.rotate(
            angle: -0.05,
            child: Container(
              width: size,
              height: size,
              decoration: BoxDecoration(
                color: t.accent,
                border: Border.all(color: t.border, width: 3),
                boxShadow: [
                  BoxShadow(
                      color: t.shadowColor,
                      offset: const Offset(8, 8),
                      blurRadius: 0)
                ],
              ),
              child: Stack(
                children: [
                  // Lined paper styling
                  ...List.generate(10, (i) {
                    return Positioned(
                      top: (i * 28.0) + 10,
                      left: 0,
                      right: 0,
                      child: Container(
                          height: 1,
                          color: t.accentForeground.withValues(alpha: 0.15)),
                    );
                  }),
                  // Live Animated Math Curve in center
                  Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        SizedBox(
                          width: size * 0.45,
                          height: size * 0.45,
                          child: BkMathCurveLoader(
                            curve: BkMathCurveType.rose,
                            headColor: t.accentForeground,
                            size: size * 0.45,
                          ),
                        ),
                        const SizedBox(height: 10),
                        Text(
                          'NEUBRUTALISM',
                          style: GoogleFonts.outfit(
                            fontSize: size * 0.058,
                            fontWeight: FontWeight.w900,
                            color: t.accentForeground,
                            letterSpacing: 3,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'DRAG TO INTERACT',
                          style: GoogleFonts.dmMono(
                            fontSize: size * 0.038,
                            fontWeight: FontWeight.bold,
                            color: t.accentForeground.withValues(alpha: 0.7),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      );
    });
  }
}

// ─── Marquee Strip ────────────────────────────────────────────────────────────

class _MarqueeStrip extends StatefulWidget {
  @override
  State<_MarqueeStrip> createState() => _MarqueeStripState();
}

class _MarqueeStripState extends State<_MarqueeStrip>
    with SingleTickerProviderStateMixin {
  late final ScrollController _ctrl;
  late final AnimationController _anim;

  final List<String> _items = const [
    'BUTTON',
    '✦',
    'CARD',
    '✦',
    'BADGE',
    '✦',
    'INPUT',
    '✦',
    'CHECKBOX',
    '✦',
    'SWITCH',
    '✦',
    'SPINNER',
    '✦',
    'ALERT',
    '✦',
    'PROGRESS',
    '✦',
    'TABS',
    '✦',
    'ACCORDION',
    '✦',
    'DIALOG',
    '✦',
    'TOAST',
    '✦',
    'AVATAR',
    '✦',
    'SLIDER',
    '✦',
    'MARQUEE',
    '✦',
    'SHAPES',
    '✦',
    'CHARTS',
    '✦',
  ];

  @override
  void initState() {
    super.initState();
    _ctrl = ScrollController();
    _anim =
        AnimationController(vsync: this, duration: const Duration(seconds: 25))
          ..addListener(() {
            if (_ctrl.hasClients) {
              final max = _ctrl.position.maxScrollExtent;
              if (max > 0) {
                _ctrl.jumpTo(_anim.value * max);
              }
            }
          })
          ..repeat();
  }

  @override
  void dispose() {
    _anim.dispose();
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    final all = [..._items, ..._items, ..._items];

    return GestureDetector(
      onTapDown: (_) => _anim.stop(),
      onTapUp: (_) => _anim.repeat(),
      onTapCancel: () => _anim.repeat(),
      child: Container(
        height: 48,
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
          padding: const EdgeInsets.symmetric(horizontal: 16),
          itemCount: all.length,
          separatorBuilder: (_, __) => const SizedBox(width: 20),
          itemBuilder: (_, i) {
            final item = all[i];
            return Center(
              child: Text(
                item,
                style: GoogleFonts.outfit(
                  fontSize: 13,
                  fontWeight: FontWeight.w900,
                  color: t.primaryForeground,
                  letterSpacing: item == '✦' ? 0 : 2,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ─── Stats Row ────────────────────────────────────────────────────────────────

class _StatsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280
          ? 80.0
          : constraints.maxWidth >= 768
              ? 40.0
              : 20.0;
      final cols = constraints.maxWidth >= 900
          ? 4
          : (constraints.maxWidth >= 500 ? 2 : 2);
      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 32, hPad, 32),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: GridView.builder(
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: cols,
            mainAxisSpacing: 8,
            crossAxisSpacing: 8,
            mainAxisExtent: 130,
          ),
          itemCount: mockStats.length,
          itemBuilder: (_, i) => _StatItem(stat: mockStats[i], tokens: t),
        ),
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

    // Extract numerical target
    double target = 0;
    if (stat.value == '75+') {
      target = 75;
    } else if (stat.value == '2.8') {
      target = 2.8;
    } else if (stat.value == '12') {
      target = 12;
    } else if (stat.value == '48') {
      target = 48;
    }

    return Container(
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [
          BoxShadow(
              color: t.shadowColor, offset: const Offset(4, 4), blurRadius: 0)
        ],
      ),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(width: 4, height: 14, color: colors[idx]),
          const SizedBox(height: 4),
          FittedBox(
            fit: BoxFit.scaleDown,
            alignment: Alignment.centerLeft,
            child: TweenAnimationBuilder<double>(
              tween: Tween(begin: 0.0, end: target),
              duration: BkMotion.counter,
              curve: BkMotion.revealCurve,
              builder: (context, val, _) {
                String strVal;
                if (stat.value == '75+') {
                  strVal = '${val.toInt()}+';
                } else if (stat.value == '2.8') {
                  strVal = val.toStringAsFixed(1);
                } else {
                  strVal = val.toInt().toString();
                }

                return Text(
                  '$strVal${stat.suffix}',
                  style: GoogleFonts.outfit(
                    fontSize: 28,
                    fontWeight: FontWeight.w900,
                    color: t.foreground,
                    height: 1,
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 4),
          Flexible(
            child: Text(
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
          ),
        ],
      ),
    );
  }
}

// ─── Feature Grid with Tap to Expand / Flip ───────────────────────────────────

class _FeatureGrid extends StatelessWidget {
  static const List<_FeatureData> _features = [
    _FeatureData(
      title: 'BOLD BY DESIGN',
      description:
          'Every component ships with 3px borders, hard shadows, and zero border-radius. No compromise.',
      detailedInfo:
          'Pure neubrutalist visual hierarchy that stands out from typical generic designs.',
      accentColor: 0xFFEE7171,
      icon: '⬛',
    ),
    _FeatureData(
      title: 'DARK MODE',
      description:
          'Full token-based dark mode. Every color adapts with BkTokens.',
      detailedInfo:
          'Single source of truth with zero startup theme flash and instant repainting.',
      accentColor: 0xFF3DC9B3,
      icon: '◑',
    ),
    _FeatureData(
      title: 'PRESS ANIMATIONS',
      description:
          'Brutalist push-down animations on every interactive element. Tactile. Physical.',
      detailedInfo:
          'Elements shift 2px down-right into their hard shadow with zero blur on tap.',
      accentColor: 0xFFFFD849,
      icon: '▼',
    ),
    _FeatureData(
      title: '75+ COMPONENTS',
      description:
          'Buttons, cards, inputs, overlays, navigation, charts, shapes — production ready.',
      detailedInfo:
          'Complete suite matching the original BoldKit library specification 1-to-1.',
      accentColor: 0xFFE44C8A,
      icon: '⊞',
    ),
    _FeatureData(
      title: 'RESPONSIVE',
      description:
          'Phone, tablet, desktop layouts via LayoutBuilder. Every screen adapts.',
      detailedInfo:
          'Zero layout overflow errors across viewports from 320px to 1280px+.',
      accentColor: 0xFF7C3ADB,
      icon: '⊡',
    ),
    _FeatureData(
      title: 'THEME BUILDER',
      description:
          'Generate custom color palettes live. Copy tokens into your project.',
      detailedInfo:
          'Tweak border width, shadow offsets, and colors with instant whole-app reload.',
      accentColor: 0xFF5EDBA0,
      icon: '✦',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280
          ? 80.0
          : constraints.maxWidth >= 768
              ? 40.0
              : 20.0;
      final cols = constraints.maxWidth >= 1280
          ? 3
          : constraints.maxWidth >= 600
              ? 2
              : 1;

      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 48),
        decoration: BoxDecoration(
          color: t.muted.withValues(alpha: 0.3),
          border:
              Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
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
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            ..._buildRows(cols, t),
          ],
        ),
      );
    });
  }

  List<Widget> _buildRows(int cols, BkTokens t) {
    final rows = <Widget>[];
    for (int start = 0; start < _features.length; start += cols) {
      final rowFeatures = _features.sublist(
        start,
        (start + cols).clamp(0, _features.length),
      );
      rows.add(
        Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: rowFeatures.asMap().entries.map((entry) {
                final i = entry.key;
                return Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        right: i < rowFeatures.length - 1 ? 12 : 0),
                    child: _InteractiveFeatureCard(
                      data: entry.value,
                      tokens: t,
                    ),
                  ),
                );
              }).toList(),
            ),
          ),
        ),
      );
    }
    return rows;
  }
}

class _FeatureData {
  const _FeatureData({
    required this.title,
    required this.description,
    required this.detailedInfo,
    required this.accentColor,
    required this.icon,
  });
  final String title;
  final String description;
  final String detailedInfo;
  final int accentColor;
  final String icon;
}

class _InteractiveFeatureCard extends StatefulWidget {
  const _InteractiveFeatureCard({
    required this.data,
    required this.tokens,
  });

  final _FeatureData data;
  final BkTokens tokens;

  @override
  State<_InteractiveFeatureCard> createState() =>
      _InteractiveFeatureCardState();
}

class _InteractiveFeatureCardState extends State<_InteractiveFeatureCard> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    final t = widget.tokens;
    final accent = Color(widget.data.accentColor);

    return BkCard(
      interactive: true,
      onTap: () {
        BkMotion.hapticClick();
        setState(() => _expanded = !_expanded);
      },
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                width: 36,
                height: 36,
                decoration: BoxDecoration(
                  color: accent,
                  border: Border.all(color: t.border, width: 2),
                ),
                child: Center(
                  child: Text(
                    widget.data.icon,
                    style: TextStyle(fontSize: 16, color: t.border),
                  ),
                ),
              ),
              Icon(
                _expanded ? Icons.expand_less : Icons.expand_more,
                size: 20,
                color: t.mutedForeground,
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            widget.data.title,
            style: GoogleFonts.outfit(
              fontSize: 16,
              fontWeight: FontWeight.w900,
              color: t.foreground,
              letterSpacing: 0.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            widget.data.description,
            style: GoogleFonts.outfit(
              fontSize: 13,
              color: t.mutedForeground,
              height: 1.4,
            ),
          ),
          if (_expanded) ...[
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: accent.withValues(alpha: 0.15),
                border: Border(left: BorderSide(color: accent, width: 3)),
              ),
              child: Text(
                widget.data.detailedInfo,
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: t.foreground,
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

// ─── Interactive Playground Section ───────────────────────────────────────────

class _PlaygroundSection extends ConsumerStatefulWidget {
  @override
  ConsumerState<_PlaygroundSection> createState() => _PlaygroundSectionState();
}

class _PlaygroundSectionState extends ConsumerState<_PlaygroundSection> {
  BkButtonVariant _selectedVariant = BkButtonVariant.primary;
  BkButtonSize _selectedSize = BkButtonSize.md;
  double _sliderValue = 65.0;
  bool _switchValue = true;
  double _ratingValue = 4.0;

  @override
  Widget build(BuildContext context) {
    final t = context.bk;

    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280
          ? 80.0
          : constraints.maxWidth >= 768
              ? 40.0
              : 20.0;

      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 48),
        decoration: BoxDecoration(
          color: t.background,
          border:
              Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'LIVE PLAYGROUND',
              style: GoogleFonts.outfit(
                fontSize: 11,
                fontWeight: FontWeight.w800,
                color: t.mutedForeground,
                letterSpacing: 3,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'TRY IT RIGHT HERE.',
              style: GoogleFonts.outfit(
                fontSize: 36,
                fontWeight: FontWeight.w900,
                color: t.foreground,
                letterSpacing: -1,
              ),
            ),
            const SizedBox(height: 24),
            // Theme Quick Swapper Bar
            BkCard(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'QUICK THEME PRESET SWAPPER',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.foreground),
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      _presetChip(
                          'coral', 'CORAL RED', const Color(0xFFEE7171)),
                      _presetChip('teal', 'TEAL MINT', const Color(0xFF3DC9B3)),
                      _presetChip(
                          'yellow', 'YELLOW ACCENT', const Color(0xFFFFD849)),
                      _presetChip(
                          'purple', 'NEON PURPLE', const Color(0xFFA855F7)),
                      _presetChip(
                          'cyber', 'CYBERPUNK', const Color(0xFFFF007A)),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            // Interactive Controls Demo
            BkCard(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'BUTTON VARIANT & SIZE PICKER',
                    style: GoogleFonts.outfit(
                        fontSize: 12,
                        fontWeight: FontWeight.w900,
                        color: t.foreground),
                  ),
                  const SizedBox(height: 14),
                  // Live target button
                  Center(
                    child: BkButton(
                      label: 'TAP THIS BUTTON',
                      variant: _selectedVariant,
                      size: _selectedSize,
                      onPressed: () {
                        BkToastManager.show(context,
                            message: 'Pressed with tactile push!');
                      },
                    ),
                  ),
                  const SizedBox(height: 20),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('VARIANT:',
                          style: GoogleFonts.dmMono(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      ...[
                        BkButtonVariant.primary,
                        BkButtonVariant.secondary,
                        BkButtonVariant.accent,
                        BkButtonVariant.outline,
                        BkButtonVariant.destructive
                      ].map((v) {
                        return ChoiceChip(
                          label: Text(v.name.toUpperCase()),
                          selected: _selectedVariant == v,
                          onSelected: (_) =>
                              setState(() => _selectedVariant = v),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text('SIZE:',
                          style: GoogleFonts.dmMono(
                              fontSize: 11, fontWeight: FontWeight.bold)),
                      ...[BkButtonSize.sm, BkButtonSize.md, BkButtonSize.lg]
                          .map((s) {
                        return ChoiceChip(
                          label: Text(s.name.toUpperCase()),
                          selected: _selectedSize == s,
                          onSelected: (_) => setState(() => _selectedSize = s),
                        );
                      }),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Divider(height: 1, color: t.border),
                  const SizedBox(height: 16),
                  // Slider + Switch + Rating Row
                  BkSlider(
                    label: 'INTERACTIVE BRUTALIST SLIDER',
                    value: _sliderValue,
                    onChanged: (val) => setState(() => _sliderValue = val),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('NOTIFICATIONS TOGGLE',
                          style: GoogleFonts.outfit(
                              fontSize: 12, fontWeight: FontWeight.w900)),
                      BkSwitch(
                        value: _switchValue,
                        onChanged: (v) => setState(() => _switchValue = v),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('RATING DEMO',
                          style: GoogleFonts.outfit(
                              fontSize: 12, fontWeight: FontWeight.w900)),
                      BkRating(
                        rating: _ratingValue,
                        onChanged: (r) => setState(() => _ratingValue = r),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      );
    });
  }

  Widget _presetChip(String presetId, String label, Color color) {
    return GestureDetector(
      onTap: () {
        BkMotion.hapticClick();
        ref.read(customThemeTokensProvider.notifier).setPreset(presetId);
        BkToastManager.show(context,
            message: 'Rethemed to $label!', variant: BkToastVariant.info);
      },
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
        decoration: BoxDecoration(
          color: color,
          border: Border.all(color: Colors.black, width: 2),
          boxShadow: const [
            BoxShadow(color: Colors.black, offset: Offset(2, 2))
          ],
        ),
        child: Text(
          label,
          style: GoogleFonts.dmMono(
              fontSize: 10, fontWeight: FontWeight.w900, color: Colors.black),
        ),
      ),
    );
  }
}

// ─── Shapes Showcase ──────────────────────────────────────────────────────────

class _ShapesShowcase extends StatelessWidget {
  static const _shapes = [
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
    final t = context.bk;
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280
          ? 80.0
          : constraints.maxWidth >= 768
              ? 40.0
              : 20.0;
      return Container(
        padding: EdgeInsets.fromLTRB(hPad, 48, hPad, 48),
        decoration: BoxDecoration(
          border:
              Border(bottom: BorderSide(color: t.border, width: t.borderWidth)),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Flexible(
                  child: Text(
                    'SHAPE LIBRARY',
                    style: GoogleFonts.outfit(
                      fontSize: 28,
                      fontWeight: FontWeight.w900,
                      color: t.foreground,
                      letterSpacing: -0.5,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 12),
                BkButton(
                  label: 'EXPLORE',
                  variant: BkButtonVariant.outline,
                  size: BkButtonSize.sm,
                  onPressed: () => context.go('/shapes'),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              height: 110,
              child: ListView.separated(
                scrollDirection: Axis.horizontal,
                itemCount: _shapes.length,
                separatorBuilder: (_, __) => const SizedBox(width: 10),
                itemBuilder: (_, i) =>
                    _MiniShapeWidget(shape: _shapes[i], tokens: t),
              ),
            ),
          ],
        ),
      );
    });
  }
}

enum _ShapeType {
  circle,
  square,
  triangle,
  hexagon,
  star,
  diamond,
  cross,
  arrow
}

class _MiniShape {
  const _MiniShape(
      {required this.label, required this.color, required this.type});
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
      width: 90,
      decoration: BoxDecoration(
        color: t.card,
        border: Border.all(color: t.border, width: t.borderWidth),
        boxShadow: [
          BoxShadow(
              color: t.shadowColor, offset: const Offset(3, 3), blurRadius: 0)
        ],
      ),
      padding: const EdgeInsets.all(8),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          SizedBox(
            width: 50,
            height: 50,
            child: CustomPaint(
              painter: _SimpleShapePainter(shape.type, color, t.border),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            shape.label,
            style: GoogleFonts.outfit(
              fontSize: 8,
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
  const _SimpleShapePainter(this.type, this.color, this.strokeColor);
  final _ShapeType type;
  final Color color;
  final Color strokeColor;

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..style = PaintingStyle.fill;
    final stroke = Paint()
      ..color = strokeColor
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
        final rect = Rect.fromCenter(
            center: Offset(cx, cy), width: r * 1.8, height: r * 1.8);
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
          final angle = (i * 60 - 30) * math.pi / 180;
          final px = cx + r * math.cos(angle);
          final py = cy + r * math.sin(angle);
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

  Path _starPath(
      double cx, double cy, double outerR, double innerR, int points) {
    final path = Path();
    for (var i = 0; i < points * 2; i++) {
      final angle = (i * math.pi / points) - math.pi / 2;
      final r2 = i.isEven ? outerR : innerR;
      final x = cx + r2 * math.cos(angle);
      final y = cy + r2 * math.sin(angle);
      i == 0 ? path.moveTo(x, y) : path.lineTo(x, y);
    }
    return path..close();
  }

  @override
  bool shouldRepaint(covariant _SimpleShapePainter old) =>
      old.type != type || old.color != color || old.strokeColor != strokeColor;
}

// ─── CTA Section with Working Newsletter & Confetti Burst ─────────────────────

class _CtaSection extends StatefulWidget {
  @override
  State<_CtaSection> createState() => _CtaSectionState();
}

class _CtaSectionState extends State<_CtaSection>
    with SingleTickerProviderStateMixin {
  final TextEditingController _emailController = TextEditingController();
  bool _isLoading = false;
  bool _showConfetti = false;
  late final AnimationController _confettiAnim;

  @override
  void initState() {
    super.initState();
    _confettiAnim = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1500),
    );
  }

  @override
  void dispose() {
    _emailController.dispose();
    _confettiAnim.dispose();
    super.dispose();
  }

  void _subscribe() async {
    final email = _emailController.text.trim();
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+$');

    if (!emailRegex.hasMatch(email)) {
      BkMotion.hapticMedium();
      BkToastManager.show(context,
          message: 'PLEASE ENTER A VALID EMAIL',
          variant: BkToastVariant.destructive);
      return;
    }

    setState(() => _isLoading = true);
    BkMotion.hapticClick();

    await Future.delayed(const Duration(milliseconds: 600));
    if (!mounted) return;

    setState(() {
      _isLoading = false;
      _showConfetti = true;
    });

    _confettiAnim.forward(from: 0.0);
    BkMotion.hapticLight();
    BkToastManager.show(
      context,
      message: 'WELCOME TO BOLDKIT! CONFIRMATION SENT.',
      variant: BkToastVariant.success,
    );
    _emailController.clear();
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bk;
    return LayoutBuilder(builder: (context, constraints) {
      final hPad = constraints.maxWidth >= 1280
          ? 80.0
          : constraints.maxWidth >= 768
              ? 40.0
              : 20.0;
      final titleSize = constraints.maxWidth >= 768 ? 48.0 : 32.0;

      return Stack(
        children: [
          Container(
            padding: EdgeInsets.symmetric(horizontal: hPad, vertical: 60),
            decoration: BoxDecoration(
              color: t.primary,
              border: Border(
                  top: BorderSide(color: t.border, width: t.borderWidth)),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'READY TO BUILD BOLD?',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: titleSize,
                    fontWeight: FontWeight.w900,
                    color: t.primaryForeground,
                    letterSpacing: -1,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 16),
                Text(
                  'Get updates, new components, and design tips directly in your inbox.',
                  textAlign: TextAlign.center,
                  style: GoogleFonts.outfit(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: t.primaryForeground.withValues(alpha: 0.85),
                    height: 1.5,
                  ),
                  softWrap: true,
                ),
                const SizedBox(height: 28),
                ConstrainedBox(
                  constraints: const BoxConstraints(maxWidth: 440),
                  child: Row(
                    children: [
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: t.card,
                            border: Border.all(
                                color: t.border, width: t.borderWidth),
                            boxShadow: [
                              BoxShadow(
                                  color: t.shadowColor,
                                  offset: const Offset(3, 3),
                                  blurRadius: 0),
                            ],
                          ),
                          child: TextField(
                            controller: _emailController,
                            style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.bold,
                                color: t.foreground),
                            decoration: InputDecoration(
                              hintText: 'ENTER YOUR EMAIL...',
                              hintStyle: GoogleFonts.outfit(
                                  fontSize: 12, color: t.mutedForeground),
                              border: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 14, vertical: 12),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      BkButton(
                        label: 'JOIN',
                        variant: BkButtonVariant.secondary,
                        size: BkButtonSize.defaultSize,
                        isLoading: _isLoading,
                        onPressed: _subscribe,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                BkButton(
                  label: 'BROWSE COMPONENT CATALOG →',
                  variant: BkButtonVariant.outline,
                  size: BkButtonSize.lg,
                  onPressed: () => context.go('/components'),
                ),
              ],
            ),
          ),
          if (_showConfetti)
            Positioned.fill(
              child: IgnorePointer(
                child: AnimatedBuilder(
                  animation: _confettiAnim,
                  builder: (context, _) => CustomPaint(
                    painter: _ConfettiPainter(_confettiAnim.value),
                  ),
                ),
              ),
            ),
        ],
      );
    });
  }
}

class _ConfettiPainter extends CustomPainter {
  _ConfettiPainter(this.progress);
  final double progress;

  static final _particles = List.generate(40, (i) {
    final rand = math.Random(i);
    return _Particle(
      angle: rand.nextDouble() * 2 * math.pi,
      speed: 100 + rand.nextDouble() * 200,
      color: [
        const Color(0xFFEE7171),
        const Color(0xFF3DC9B3),
        const Color(0xFFFFD849),
        const Color(0xFFA855F7),
        Colors.white
      ][i % 5],
      size: 6.0 + rand.nextDouble() * 8.0,
    );
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (progress <= 0 || progress >= 1) return;
    final center = Offset(size.width / 2, size.height / 2);

    for (final p in _particles) {
      final distance = p.speed * progress;
      final x = center.dx + distance * math.cos(p.angle);
      final y = center.dy +
          distance * math.sin(p.angle) +
          (progress * progress * 80); // gravity
      final opacity = (1.0 - progress).clamp(0.0, 1.0);

      final paint = Paint()
        ..color = p.color.withValues(alpha: opacity)
        ..style = PaintingStyle.fill;
      final borderPaint = Paint()
        ..color = Colors.black.withValues(alpha: opacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = 1.5;

      final rect =
          Rect.fromCenter(center: Offset(x, y), width: p.size, height: p.size);
      canvas.drawRect(rect, paint);
      canvas.drawRect(rect, borderPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _ConfettiPainter oldDelegate) => true;
}

class _Particle {
  const _Particle({
    required this.angle,
    required this.speed,
    required this.color,
    required this.size,
  });
  final double angle;
  final double speed;
  final Color color;
  final double size;
}
