import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_tokens.dart';
import '../../core/widgets/bk_widgets.dart';
import '../../data/mock_data.dart';

class ComponentDetailScreen extends StatefulWidget {
  const ComponentDetailScreen({super.key, required this.componentId});

  final String componentId;

  @override
  State<ComponentDetailScreen> createState() => _ComponentDetailScreenState();
}

class _ComponentDetailScreenState extends State<ComponentDetailScreen> {
  bool _switchVal = true;
  bool _checkboxVal = true;
  double _sliderVal = 40.0;
  bool _showCode = false;

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final comp = mockComponents.firstWhere(
      (c) => c.id == widget.componentId,
      orElse: () => MockComponentInfo(
        id: widget.componentId,
        name: widget.componentId.toUpperCase(),
        description: 'Neubrutalism UI component demonstration.',
        category: 'Core',
        tags: ['widget', 'brutalist'],
      ),
    );

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          comp.name.toUpperCase(),
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            letterSpacing: 1.0,
            color: t.foreground,
          ),
        ),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header info
            Text(
              comp.description,
              style: GoogleFonts.outfit(fontSize: 15, color: t.mutedForeground),
            ),
            const SizedBox(height: 12),
            Wrap(
              spacing: 8,
              children: comp.tags.map((tag) => BkBadge(label: tag, variant: BkBadgeVariant.outline)).toList(),
            ),
          const SizedBox(height: 24),

          // Live Demo Card
          Text(
            'INTERACTIVE PREVIEW',
            style: GoogleFonts.outfit(
              fontSize: 12,
              fontWeight: FontWeight.w900,
              letterSpacing: 1.0,
              color: t.mutedForeground,
            ),
          ),
          const SizedBox(height: 8),
          Container(
            width: double.infinity,
            constraints: const BoxConstraints(minHeight: 220),
            padding: const EdgeInsets.all(24),
            decoration: BoxDecoration(
              color: t.card,
              border: Border.all(color: t.border, width: t.borderWidth),
              boxShadow: [
                BoxShadow(
                  color: t.shadowColor,
                  offset: Offset(t.shadowOffset, t.shadowOffset),
                  blurRadius: 0,
                ),
              ],
            ),
            child: Center(
              child: _buildComponentDemo(comp.id, t),
            ),
          ),
          const SizedBox(height: 24),

          // Code snippet toggle
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'DART CODE',
                style: GoogleFonts.outfit(
                  fontSize: 12,
                  fontWeight: FontWeight.w900,
                  letterSpacing: 1.0,
                  color: t.mutedForeground,
                ),
              ),
              GestureDetector(
                onTap: () => setState(() => _showCode = !_showCode),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  decoration: BoxDecoration(
                    color: _showCode ? t.primary : t.card,
                    border: Border.all(color: t.border, width: 2),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.code, size: 14, color: _showCode ? t.primaryForeground : t.foreground),
                      const SizedBox(width: 4),
                      Text(
                        _showCode ? 'HIDE' : 'VIEW',
                        style: GoogleFonts.outfit(
                          fontSize: 11,
                          fontWeight: FontWeight.bold,
                          color: _showCode ? t.primaryForeground : t.foreground,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
          if (_showCode) ...[
            const SizedBox(height: 8),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: t.foreground,
                border: Border.all(color: t.border, width: t.borderWidth),
                boxShadow: [
                  BoxShadow(
                    color: t.shadowColor,
                    offset: Offset(t.shadowOffset * 0.75, t.shadowOffset * 0.75),
                    blurRadius: 0,
                  ),
                ],
              ),
              child: Text(
                _getDartCode(comp.id),
                style: GoogleFonts.dmMono(
                  fontSize: 12,
                  color: t.background,
                  height: 1.5,
                ),
              ),
            ),
          ],
          const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildComponentDemo(String id, BkTokens t) {
    switch (id) {
      case 'button':
        const variants = BkButtonVariant.values;
        return Column(
          children: [
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: variants.map((v) {
                return BkButton(
                  label: v.name.toUpperCase(),
                  variant: v,
                  onPressed: () {},
                );
              }).toList(),
            ),
          ],
        );
      case 'switch':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BkSwitch(
              value: _switchVal,
              onChanged: (v) => setState(() => _switchVal = v),
            ),
            const SizedBox(width: 16),
            Text(
              _switchVal ? 'ON' : 'OFF',
              style: GoogleFonts.outfit(fontWeight: FontWeight.w900, fontSize: 16),
            ),
          ],
        );
      case 'checkbox':
        return Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            BkCheckbox(
              value: _checkboxVal,
              onChanged: (v) => setState(() => _checkboxVal = v ?? false),
            ),
            const SizedBox(width: 12),
            Text(
              'ACCEPT TERMS',
              style: GoogleFonts.outfit(fontWeight: FontWeight.bold),
            ),
          ],
        );
      case 'badge':
        return Wrap(
          spacing: 8,
          runSpacing: 8,
          children: BkBadgeVariant.values.map((v) {
            return BkBadge(label: v.name.toUpperCase(), variant: v);
          }).toList(),
        );
      case 'spinner':
        return Wrap(
          spacing: 24,
          runSpacing: 24,
          alignment: WrapAlignment.center,
          children: BkSpinnerVariant.values.map((v) {
            return Column(
              children: [
                BkSpinner(variant: v, size: 36),
                const SizedBox(height: 8),
                Text(v.name.toUpperCase(), style: GoogleFonts.dmMono(fontSize: 10)),
              ],
            );
          }).toList(),
        );
      case 'alert':
        return Column(
          children: BkAlertVariant.values.map((v) {
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: BkAlert(
                title: '${v.name.toUpperCase()} ALERT',
                description: 'This is a sample ${v.name} notification banner.',
                variant: v,
              ),
            );
          }).toList(),
        );
      case 'progress':
        return Column(
          children: [
            BkProgress(value: _sliderVal / 100),
            const SizedBox(height: 16),
            Slider(
              value: _sliderVal,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _sliderVal = v),
            ),
            Text('${_sliderVal.round()}% PROGRESS', style: GoogleFonts.dmMono(fontSize: 12)),
          ],
        );
      case 'stat-card':
        return const BkStatCard(
          title: 'Total Revenue',
          value: '\$45,280',
          change: '+14.2%',
          trend: BkTrend.up,
          colorScheme: 'primary',
          progressValue: 0.72,
        );
      case 'sticker':
        return const Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            BkSticker(child: Text('NEW FEATURE')),
            BkStamp(text: 'APPROVED'),
          ],
        );
      case 'input':
        return const SizedBox(
          width: 300,
          child: BkInput(
            label: 'EMAIL ADDRESS',
            hint: 'alex@example.com',
            prefix: Icon(Icons.email_outlined),
          ),
        );
      default:
        return Column(
          children: [
            Text(
              id.toUpperCase(),
              style: GoogleFonts.outfit(fontSize: 22, fontWeight: FontWeight.w900),
            ),
            const SizedBox(height: 8),
            Text(
              'Interactive component demo preview',
              style: GoogleFonts.outfit(color: t.mutedForeground),
            ),
          ],
        );
    }
  }

  String _getDartCode(String id) {
    switch (id) {
      case 'button':
        return '''BkButton(
  label: 'SUBMIT',
  variant: BkButtonVariant.primary,
  size: BkButtonSize.defaultSize,
  onPressed: () => print('Pressed!'),
)''';
      case 'switch':
        return '''BkSwitch(
  value: isEnabled,
  onChanged: (val) => setState(() => isEnabled = val),
)''';
      case 'badge':
        return '''BkBadge(
  text: 'PRO',
  variant: BkBadgeVariant.accent,
)''';
      case 'alert':
        return '''BkAlert(
  title: 'WARNING',
  description: 'Your subscription expires soon.',
  variant: BkAlertVariant.warning,
)''';
      default:
        return '// Import BoldKit widgets\nimport "package:boldkit_flutter/core/widgets/bk_widgets.dart";\n\n// Usage:\nBk${id[0].toUpperCase()}${id.substring(1)}()';
    }
  }
}
