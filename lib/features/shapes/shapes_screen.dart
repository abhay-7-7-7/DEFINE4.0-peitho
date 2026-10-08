import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';

class ShapesScreen extends StatefulWidget {
  const ShapesScreen({super.key});

  @override
  State<ShapesScreen> createState() => _ShapesScreenState();
}

class _ShapesScreenState extends State<ShapesScreen> {
  String _selectedCategory = 'All';

  final _categories = [
    'All',
    'Geometric',
    'Organic',
    'Celestial',
    'Mathematical',
    'Mechanical'
  ];

  final _shapes = const [
    // Geometric
    _ShapeItem('Triangle', BkShapeType.triangle, 'Geometric'),
    _ShapeItem('Diamond', BkShapeType.diamond, 'Geometric'),
    _ShapeItem('Pentagon', BkShapeType.pentagon, 'Geometric'),
    _ShapeItem('Hexagon', BkShapeType.hexagon, 'Geometric'),
    _ShapeItem('Octagon', BkShapeType.octagon, 'Geometric'),
    _ShapeItem('Cross', BkShapeType.cross, 'Geometric'),
    _ShapeItem('Arrow', BkShapeType.arrow, 'Geometric'),
    _ShapeItem('Chevron', BkShapeType.chevron, 'Geometric'),
    // Organic
    _ShapeItem('Blob', BkShapeType.blob, 'Organic'),
    _ShapeItem('Cloud', BkShapeType.cloud, 'Organic'),
    _ShapeItem('Splash', BkShapeType.splash, 'Organic'),
    _ShapeItem('Leaf', BkShapeType.leaf, 'Organic'),
    _ShapeItem('Flower', BkShapeType.flower, 'Organic'),
    _ShapeItem('Heart', BkShapeType.heart, 'Organic'),
    _ShapeItem('Star', BkShapeType.star, 'Organic'),
    _ShapeItem('Sharp Star', BkShapeType.starSharp, 'Organic'),
    // Celestial
    _ShapeItem('Moon', BkShapeType.moon, 'Celestial'),
    _ShapeItem('Sun', BkShapeType.sun, 'Celestial'),
    _ShapeItem('Lightning', BkShapeType.lightning, 'Celestial'),
    _ShapeItem('Rocket', BkShapeType.rocket, 'Celestial'),
    _ShapeItem('Planet', BkShapeType.planet, 'Celestial'),
    _ShapeItem('Cosmic Ring', BkShapeType.cosmicRing, 'Celestial'),
    // Mathematical
    _ShapeItem('Infinity', BkShapeType.infinity, 'Mathematical'),
    _ShapeItem('Spiral', BkShapeType.spiral, 'Mathematical'),
    _ShapeItem('Fractal', BkShapeType.fractal, 'Mathematical'),
    _ShapeItem('Mobius', BkShapeType.mobius, 'Mathematical'),
    _ShapeItem('Wave', BkShapeType.wave, 'Mathematical'),
    // Mechanical
    _ShapeItem('Gear', BkShapeType.gear, 'Mechanical'),
    _ShapeItem('Cog', BkShapeType.cog, 'Mechanical'),
    _ShapeItem('Circuit', BkShapeType.circuit, 'Mechanical'),
    _ShapeItem('Target', BkShapeType.target, 'Mechanical'),
    _ShapeItem('Shield', BkShapeType.shield, 'Mechanical'),
    _ShapeItem('Bracket', BkShapeType.bracket, 'Mechanical'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    final filtered = _shapes.where((s) {
      return _selectedCategory == 'All' || s.category == _selectedCategory;
    }).toList();

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'SHAPES',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: t.foreground,
          ),
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 12),
            child: BkButton(
              label: 'BUILDER',
              variant: BkButtonVariant.primary,
              size: BkButtonSize.sm,
              onPressed: () => context.go('/shapes/builder'),
            ),
          ),
        ],
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: CustomScrollView(
        slivers: [
          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categories.map((cat) {
                    final isSelected = _selectedCategory == cat;
                    return Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: GestureDetector(
                        onTap: () => setState(() => _selectedCategory = cat),
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                              horizontal: 14, vertical: 8),
                          decoration: BoxDecoration(
                            color: isSelected ? t.primary : t.card,
                            border: Border.all(
                                color: t.border, width: t.borderWidth),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                        color: t.shadowColor,
                                        offset: const Offset(3, 3))
                                  ]
                                : null,
                          ),
                          child: Text(
                            cat.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontSize: 12,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 0.5,
                              color: isSelected
                                  ? t.primaryForeground
                                  : t.foreground,
                            ),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            sliver: SliverGrid(
              gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
                maxCrossAxisExtent: 180,
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
              ),
              delegate: SliverChildBuilderDelegate(
                (context, index) {
                  final s = filtered[index];
                  return GestureDetector(
                    onTap: () => _showShapeModal(context, s, t),
                    child: BkCard(
                      interactive: true,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Expanded(
                            child: Center(
                              child: BkShape(
                                shape: s.shape,
                                size: 64,
                                color: t.primary,
                              ),
                            ),
                          ),
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(vertical: 8),
                            color: t.muted.withValues(alpha: 0.3),
                            child: Text(
                              s.name.toUpperCase(),
                              textAlign: TextAlign.center,
                              style: GoogleFonts.outfit(
                                fontSize: 11,
                                fontWeight: FontWeight.w900,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
                childCount: filtered.length,
              ),
            ),
          ),
          const SliverToBoxAdapter(child: SizedBox(height: 40)),
        ],
      ),
    );
  }

  void _showShapeModal(BuildContext context, _ShapeItem shape, BkTokens t) {
    showBkBottomSheet(
      context: context,
      title: shape.name,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.background,
              border: Border.all(color: t.border, width: 2),
            ),
            child: Center(
              child: BkShape(
                shape: shape.shape,
                size: 120,
                color: t.primary,
                animation: BkShapeAnimation.spin,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            'CATEGORY: ${shape.category.toUpperCase()}',
            style:
                GoogleFonts.dmMono(fontWeight: FontWeight.bold, fontSize: 12),
          ),
          const SizedBox(height: 16),
          BkButton(
            label: 'OPEN IN SHAPE BUILDER',
            variant: BkButtonVariant.primary,
            size: BkButtonSize.defaultSize,
            onPressed: () {
              Navigator.of(context).pop();
              context.go('/shapes/builder');
            },
          ),
        ],
      ),
    );
  }
}

class _ShapeItem {
  const _ShapeItem(this.name, this.shape, this.category);
  final String name;
  final BkShapeType shape;
  final String category;
}
