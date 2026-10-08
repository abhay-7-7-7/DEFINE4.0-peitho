import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  int _currentStep = 0;
  String _teamSize = '1-5';
  final Set<String> _useCases = {'Mobile App'};

  final _steps = const [
    BkStep(title: 'WELCOME', subtitle: 'Tell us who you are'),
    BkStep(title: 'TEAM', subtitle: 'How big is your crew'),
    BkStep(title: 'PURPOSE', subtitle: 'What are you building'),
    BkStep(title: 'READY', subtitle: 'All set up'),
  ];

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text('GETTING STARTED', style: GoogleFonts.outfit(fontWeight: FontWeight.w900)),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 540),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Stepper at top
              BkStepper(
                steps: _steps,
                currentStep: _currentStep,
                orientation: Axis.horizontal,
              ),
              const SizedBox(height: 32),

              // Step Card
              BkCard(
                child: Padding(
                  padding: const EdgeInsets.all(28),
                  child: _buildCurrentStep(t),
                ),
              ),
              const SizedBox(height: 24),

              // Actions
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (_currentStep > 0)
                    BkButton(
                      label: 'BACK',
                      variant: BkButtonVariant.outline,
                      size: BkButtonSize.defaultSize,
                      onPressed: () => setState(() => _currentStep--),
                    )
                  else
                    const SizedBox.shrink(),
                  BkButton(
                    label: _currentStep == _steps.length - 1 ? 'GO TO DASHBOARD' : 'CONTINUE',
                    variant: BkButtonVariant.primary,
                    size: BkButtonSize.defaultSize,
                    onPressed: () {
                      if (_currentStep < _steps.length - 1) {
                        setState(() => _currentStep++);
                      } else {
                        context.go('/');
                      }
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCurrentStep(BkTokens t) {
    switch (_currentStep) {
      case 0:
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WELCOME TO BOLDKIT', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Let\'s personalize your workspace experience.', style: GoogleFonts.outfit(color: t.mutedForeground)),
            const SizedBox(height: 24),
            const BkInput(
              label: 'YOUR NAME',
              hint: 'e.g. Satoshi Nakamoto',
            ),
          ],
        );
      case 1:
        final sizes = ['Just me (1)', '1-5 people', '6-20 people', '20+ people'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('SELECT TEAM SIZE', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('We calibrate resource allocations based on team size.', style: GoogleFonts.outfit(color: t.mutedForeground)),
            const SizedBox(height: 20),
            Column(
              children: sizes.map((s) {
                final isSelected = _teamSize == s;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10),
                  child: GestureDetector(
                    onTap: () => setState(() => _teamSize = s),
                    child: Container(
                      padding: const EdgeInsets.all(14),
                      decoration: BoxDecoration(
                        color: isSelected ? t.primary : t.card,
                        border: Border.all(color: t.border, width: t.borderWidth),
                        boxShadow: isSelected ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))] : null,
                      ),
                      child: Row(
                        children: [
                          Icon(
                            isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                            color: isSelected ? t.primaryForeground : t.foreground,
                          ),
                          const SizedBox(width: 12),
                          Text(
                            s.toUpperCase(),
                            style: GoogleFonts.outfit(
                              fontWeight: FontWeight.bold,
                              color: isSelected ? t.primaryForeground : t.foreground,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 2:
        final cases = ['Mobile App', 'Web Dashboard', 'Design System', 'Personal Portfolio'];
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('WHAT ARE YOU BUILDING?', style: GoogleFonts.outfit(fontSize: 20, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text('Choose all that apply.', style: GoogleFonts.outfit(color: t.mutedForeground)),
            const SizedBox(height: 20),
            Wrap(
              spacing: 10,
              runSpacing: 10,
              children: cases.map((c) {
                final isChecked = _useCases.contains(c);
                return GestureDetector(
                  onTap: () {
                    setState(() {
                      if (isChecked) {
                        _useCases.remove(c);
                      } else {
                        _useCases.add(c);
                      }
                    });
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    decoration: BoxDecoration(
                      color: isChecked ? t.secondary : t.card,
                      border: Border.all(color: t.border, width: t.borderWidth),
                      boxShadow: isChecked ? [BoxShadow(color: t.shadowColor, offset: const Offset(3, 3))] : null,
                    ),
                    child: Text(
                      c.toUpperCase(),
                      style: GoogleFonts.outfit(
                        fontWeight: FontWeight.w800,
                        color: isChecked ? t.secondaryForeground : t.foreground,
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
          ],
        );
      case 3:
      default:
        return Column(
          children: [
            Container(
              width: 72,
              height: 72,
              color: t.accent,
              child: Icon(Icons.celebration, size: 40, color: t.accentForeground),
            ),
            const SizedBox(height: 20),
            Text('YOU\'RE ALL SET!', style: GoogleFonts.outfit(fontSize: 24, fontWeight: FontWeight.w900)),
            const SizedBox(height: 8),
            Text(
              'Your brutalist design workspace is ready. Build something bold.',
              textAlign: TextAlign.center,
              style: GoogleFonts.outfit(fontSize: 14, color: t.mutedForeground),
            ),
          ],
        );
    }
  }
}
