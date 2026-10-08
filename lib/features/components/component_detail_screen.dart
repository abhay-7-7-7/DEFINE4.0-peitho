import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../core/theme/bk_motion.dart';
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
  int _selectedTab = 0; // 0: Preview, 1: Variants, 2: Code
  bool _canvasDark = false;
  bool _copied = false;

  // Live configurable control state
  String _customLabel = 'CLICK ME';
  BkButtonVariant _btnVariant = BkButtonVariant.primary;
  BkButtonSize _btnSize = BkButtonSize.md;
  bool _btnLoading = false;
  bool _btnDisabled = false;
  bool _switchVal = true;
  bool _checkboxVal = true;
  double _sliderVal = 50.0;
  double _ratingVal = 4.0;
  String _selectVal = 'OPTION 1';
  List<String> _tags = ['FLUTTER', 'DART', 'NEUBRUTALISM'];
  int _stepperStep = 1;

  void _resetControls() {
    BkMotion.hapticClick();
    setState(() {
      _customLabel = 'CLICK ME';
      _btnVariant = BkButtonVariant.primary;
      _btnSize = BkButtonSize.md;
      _btnLoading = false;
      _btnDisabled = false;
      _switchVal = true;
      _checkboxVal = true;
      _sliderVal = 50.0;
      _ratingVal = 4.0;
      _selectVal = 'OPTION 1';
      _tags = ['FLUTTER', 'DART', 'NEUBRUTALISM'];
      _stepperStep = 1;
    });
    BkToastManager.show(context, message: 'Controls reset to default');
  }

  void _copyCode(String code) {
    BkMotion.hapticClick();
    Clipboard.setData(ClipboardData(text: code));
    setState(() => _copied = true);
    BkToastManager.show(context,
        message: 'Copied Dart code to clipboard! 📋',
        variant: BkToastVariant.success);
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) setState(() => _copied = false);
    });
  }

  @override
  Widget build(BuildContext context) {
    final t = context.bk;
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

    final demoTokens = _canvasDark ? BkTokens.dark : BkTokens.light;

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
        actions: [
          IconButton(
            icon: Icon(_canvasDark ? Icons.light_mode : Icons.dark_mode,
                color: t.foreground),
            tooltip: 'Toggle Demo Canvas Theme',
            onPressed: () {
              BkMotion.hapticClick();
              setState(() => _canvasDark = !_canvasDark);
            },
          ),
          IconButton(
            icon: Icon(Icons.refresh, color: t.foreground),
            tooltip: 'Reset Controls',
            onPressed: _resetControls,
          ),
          const SizedBox(width: 8),
        ],
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
            // Header Hero Banner
            Hero(
              tag: 'component-${comp.id}',
              child: Material(
                color: Colors.transparent,
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: t.card,
                    border: Border.all(color: t.border, width: t.borderWidth),
                    boxShadow: [
                      BoxShadow(
                          color: t.shadowColor,
                          offset: Offset(t.shadowOffset, t.shadowOffset),
                          blurRadius: 0),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              comp.name.toUpperCase(),
                              style: GoogleFonts.outfit(
                                  fontSize: 20, fontWeight: FontWeight.w900),
                            ),
                          ),
                          BkBadge(
                              label: comp.category,
                              variant: BkBadgeVariant.primary),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Text(
                        comp.description,
                        style: GoogleFonts.outfit(
                            fontSize: 14, color: t.mutedForeground),
                      ),
                      const SizedBox(height: 12),
                      Wrap(
                        spacing: 6,
                        runSpacing: 6,
                        children: comp.tags
                            .map((tag) => BkBadge(
                                label: tag, variant: BkBadgeVariant.outline))
                            .toList(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Segmented Tabs: PREVIEW / VARIANTS / CODE
            Row(
              children: [
                _tabButton(0, 'PREVIEW'),
                const SizedBox(width: 8),
                _tabButton(1, 'VARIANTS'),
                const SizedBox(width: 8),
                _tabButton(2, 'DART CODE'),
              ],
            ),
            const SizedBox(height: 16),
            // Tab Contents
            if (_selectedTab == 0) ...[
              // Live Demo Canvas with Canvas-specific theme
              Container(
                width: double.infinity,
                constraints: const BoxConstraints(minHeight: 220),
                padding: const EdgeInsets.all(24),
                decoration: BoxDecoration(
                  color: demoTokens.background,
                  border: Border.all(
                      color: demoTokens.border, width: demoTokens.borderWidth),
                  boxShadow: [
                    BoxShadow(
                      color: demoTokens.shadowColor,
                      offset: Offset(
                          demoTokens.shadowOffset, demoTokens.shadowOffset),
                      blurRadius: 0,
                    ),
                  ],
                ),
                child: Center(
                  child: _buildComponentDemo(comp.id, demoTokens),
                ),
              ),
              const SizedBox(height: 20),
              // Live Controls Panel
              _buildLiveControls(comp.id, t),
            ] else if (_selectedTab == 1) ...[
              _buildVariantsPanel(comp.id, t),
            ] else ...[
              // Code Tab
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(
                        'USAGE SNIPPET',
                        style: GoogleFonts.outfit(
                            fontSize: 12,
                            fontWeight: FontWeight.w900,
                            color: t.mutedForeground),
                      ),
                      BkButton(
                        label: _copied ? 'COPIED!' : 'COPY CODE',
                        variant: _copied
                            ? BkButtonVariant.secondary
                            : BkButtonVariant.outline,
                        size: BkButtonSize.sm,
                        leading:
                            Icon(_copied ? Icons.check : Icons.copy, size: 14),
                        onPressed: () => _copyCode(_getDartCode(comp.id)),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Container(
                    width: double.infinity,
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: t.foreground,
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: [
                        BoxShadow(
                            color: t.shadowColor,
                            offset: const Offset(4, 4),
                            blurRadius: 0),
                      ],
                    ),
                    child: SelectableText(
                      _getDartCode(comp.id),
                      style: GoogleFonts.dmMono(
                        fontSize: 12,
                        color: t.background,
                        height: 1.5,
                      ),
                    ),
                  ),
                ],
              ),
            ],
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _tabButton(int index, String title) {
    final isSelected = _selectedTab == index;
    final t = context.bk;

    return Expanded(
      child: GestureDetector(
        onTap: () {
          BkMotion.hapticClick();
          setState(() => _selectedTab = index);
        },
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: isSelected ? t.primary : t.card,
            border: Border.all(color: t.border, width: t.borderWidth),
            boxShadow: isSelected
                ? [
                    BoxShadow(
                        color: t.shadowColor,
                        offset: const Offset(3, 3),
                        blurRadius: 0)
                  ]
                : null,
          ),
          child: Center(
            child: Text(
              title,
              style: GoogleFonts.outfit(
                fontSize: 12,
                fontWeight: FontWeight.w900,
                letterSpacing: 0.5,
                color: isSelected ? t.primaryForeground : t.foreground,
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildLiveControls(String id, BkTokens t) {
    return BkCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'LIVE DEMO CONTROLS',
            style: GoogleFonts.outfit(
                fontSize: 12, fontWeight: FontWeight.w900, letterSpacing: 0.5),
          ),
          const SizedBox(height: 14),
          if (id == 'button') ...[
            TextField(
              decoration: const InputDecoration(
                  labelText: 'BUTTON LABEL', isDense: true),
              controller: TextEditingController(text: _customLabel)
                ..selection =
                    TextSelection.collapsed(offset: _customLabel.length),
              onChanged: (val) => setState(() => _customLabel = val),
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: BkSelect<BkButtonVariant>(
                    label: 'VARIANT',
                    value: _btnVariant,
                    items: BkButtonVariant.values
                        .map((v) => BkSelectItem(value: v, label: v.name))
                        .toList(),
                    onChanged: (v) => setState(() => _btnVariant = v),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: BkSelect<BkButtonSize>(
                    label: 'SIZE',
                    value: _btnSize,
                    items: BkButtonSize.values
                        .map((s) => BkSelectItem(value: s, label: s.name))
                        .toList(),
                    onChanged: (s) => setState(() => _btnSize = s),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text('LOADING STATE',
                        style: GoogleFonts.outfit(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                BkSwitch(
                    value: _btnLoading,
                    onChanged: (v) => setState(() => _btnLoading = v)),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text('DISABLED STATE',
                        style: GoogleFonts.outfit(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                BkSwitch(
                    value: _btnDisabled,
                    onChanged: (v) => setState(() => _btnDisabled = v)),
              ],
            ),
          ] else if (id == 'slider') ...[
            BkSlider(
              label: 'SLIDER VALUE',
              value: _sliderVal,
              min: 0,
              max: 100,
              onChanged: (v) => setState(() => _sliderVal = v),
            ),
          ] else if (id == 'rating') ...[
            BkSlider(
              label: 'RATING VALUE',
              value: _ratingVal,
              min: 0,
              max: 5,
              divisions: 5,
              onChanged: (v) => setState(() => _ratingVal = v),
            ),
          ] else ...[
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                    child: Text('TOGGLE STATE',
                        style: GoogleFonts.outfit(
                            fontSize: 12, fontWeight: FontWeight.bold))),
                const SizedBox(width: 8),
                BkSwitch(
                    value: _switchVal,
                    onChanged: (v) => setState(() => _switchVal = v)),
              ],
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildVariantsPanel(String id, BkTokens t) {
    if (id == 'button') {
      return Column(
        children: BkButtonVariant.values.map((v) {
          return Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    v.name.toUpperCase(),
                    style: GoogleFonts.dmMono(
                        fontSize: 12, fontWeight: FontWeight.bold),
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                const SizedBox(width: 8),
                BkButton(
                    label: v.name.toUpperCase(),
                    variant: v,
                    size: BkButtonSize.sm,
                    onPressed: () {}),
              ],
            ),
          );
        }).toList(),
      );
    } else if (id == 'badge') {
      return Wrap(
        spacing: 8,
        runSpacing: 8,
        children: BkBadgeVariant.values
            .map((v) => BkBadge(label: v.name.toUpperCase(), variant: v))
            .toList(),
      );
    }
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24),
        child: Text('All standard variants are shown in Preview tab',
            style: GoogleFonts.outfit(color: t.mutedForeground)),
      ),
    );
  }

  Widget _buildComponentDemo(String id, BkTokens t) {
    switch (id) {
      case 'button':
        return BkButton(
          label: _customLabel.toUpperCase(),
          variant: _btnVariant,
          size: _btnSize,
          isLoading: _btnLoading,
          enabled: !_btnDisabled,
          onPressed: () {
            BkToastManager.show(context,
                message: 'Pressed ${_btnVariant.name} button!');
          },
        );
      case 'card':
        return BkCard(
          interactive: true,
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text('NEUBRUTALIST CARD',
                  style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
              const SizedBox(height: 6),
              Text(
                  'Interactive tactile push card with 3px border and 4px offset shadow.',
                  style: GoogleFonts.outfit(
                      fontSize: 12, color: t.mutedForeground)),
            ],
          ),
        );
      case 'slider':
        return SizedBox(
          width: 280,
          child: BkSlider(
            value: _sliderVal,
            onChanged: (v) => setState(() => _sliderVal = v),
          ),
        );
      case 'rating':
        return BkRating(
          rating: _ratingVal,
          onChanged: (v) => setState(() => _ratingVal = v),
        );
      case 'select':
        return SizedBox(
          width: 260,
          child: BkSelect<String>(
            items: const [
              BkSelectItem(value: 'OPTION 1', label: 'Option 1'),
              BkSelectItem(value: 'OPTION 2', label: 'Option 2'),
              BkSelectItem(value: 'OPTION 3', label: 'Option 3'),
            ],
            value: _selectVal,
            onChanged: (v) => setState(() => _selectVal = v),
          ),
        );
      case 'tag-input':
        return SizedBox(
          width: 300,
          child: BkTagInput(
            tags: _tags,
            onChanged: (v) => setState(() => _tags = v),
          ),
        );
      case 'combobox':
        return SizedBox(
          width: 280,
          child: BkCombobox<String>(
            items: const [
              BkComboboxItem(value: 'FLUTTER', label: 'Flutter'),
              BkComboboxItem(value: 'REACT', label: 'React'),
              BkComboboxItem(value: 'VUE', label: 'Vue'),
              BkComboboxItem(value: 'SVELTE', label: 'Svelte'),
            ],
            onSelected: (v) =>
                BkToastManager.show(context, message: 'Selected $v'),
          ),
        );
      case 'switch':
        return BkSwitch(
          value: _switchVal,
          onChanged: (v) => setState(() => _switchVal = v),
        );
      case 'checkbox':
        return BkCheckbox(
          value: _checkboxVal,
          onChanged: (v) => setState(() => _checkboxVal = v ?? false),
          label: 'I ACCEPT THE TERMS',
        );
      case 'radio':
        return BkRadioGroup<String>(
          options: const [
            BkRadioOption(value: '1', label: 'Standard Tier'),
            BkRadioOption(value: '2', label: 'Professional Tier'),
          ],
          selectedValue: '1',
          onChanged: (_) {},
        );
      case 'stepper':
        return BkStepper(
          currentStep: _stepperStep,
          onStepTapped: (s) => setState(() => _stepperStep = s),
          steps: const [
            BkStep(title: 'Plan'),
            BkStep(title: 'Details'),
            BkStep(title: 'Confirm'),
          ],
        );
      case 'collapsible':
        return const SizedBox(
          width: 300,
          child: BkCollapsible(
            title: 'EXPANDABLE CONTENT',
            child: Text(
                'This content smoothly expands and collapses with 3px brutalist borders.'),
          ),
        );
      case 'timeline':
        return const SizedBox(
          width: 300,
          child: BkTimeline(
            items: [
              BkTimelineItem(
                  title: 'CREATED', timestamp: '10:00 AM', isCompleted: true),
              BkTimelineItem(
                  title: 'REVIEWED', timestamp: '11:30 AM', isCompleted: true),
              BkTimelineItem(
                  title: 'DEPLOYED', timestamp: '01:00 PM', isCompleted: false),
            ],
          ),
        );
      case 'tree-view':
        return SizedBox(
          width: 280,
          child: BkTreeView(
            nodes: [
              BkTreeNode(
                label: 'src',
                isExpanded: true,
                children: [
                  BkTreeNode(label: 'components'),
                  BkTreeNode(label: 'main.dart'),
                ],
              ),
            ],
          ),
        );
      case 'data-table':
        return SizedBox(
          width: 340,
          child: BkDataTable<String>(
            columns: [
              BkDataColumn(
                  label: 'Name',
                  cellBuilder: (s) => Text(s,
                      style: GoogleFonts.outfit(fontWeight: FontWeight.bold))),
              BkDataColumn(
                  label: 'Status',
                  cellBuilder: (_) => const BkBadge(
                      label: 'ACTIVE', variant: BkBadgeVariant.success)),
            ],
            data: const ['Alpha', 'Beta', 'Gamma'],
          ),
        );
      default:
        return BkButton(
          label: 'BOLDKIT PREVIEW',
          variant: BkButtonVariant.primary,
          onPressed: () {},
        );
    }
  }

  String _getDartCode(String id) {
    switch (id) {
      case 'button':
        return 'BkButton(\n  label: "$_customLabel",\n  variant: BkButtonVariant.${_btnVariant.name},\n  size: BkButtonSize.${_btnSize.name},\n  onPressed: () => doSomething(),\n)';
      case 'card':
        return 'BkCard(\n  interactive: true,\n  padding: const EdgeInsets.all(16),\n  child: Text("Brutalist Card"),\n)';
      case 'slider':
        return 'BkSlider(\n  value: $_sliderVal,\n  min: 0,\n  max: 100,\n  onChanged: (val) => setState(() => val),\n)';
      case 'select':
        return 'BkSelect<String>(\n  items: items,\n  value: selectedValue,\n  onChanged: (val) => setState(() => val),\n)';
      default:
        return 'BkButton(\n  label: "${id.toUpperCase()}",\n  onPressed: () {},\n)';
    }
  }
}
