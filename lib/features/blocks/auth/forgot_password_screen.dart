import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _emailController = TextEditingController();
  bool _submitted = false;

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  void _handleSubmit() {
    if (_emailController.text.isNotEmpty) {
      setState(() => _submitted = true);
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'RECOVERY',
          style: GoogleFonts.outfit(
              fontWeight: FontWeight.w900, letterSpacing: 1.0),
        ),
        backgroundColor: t.background,
        elevation: 0,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 420),
            child: BkCard(
              child: Padding(
                padding: const EdgeInsets.all(28),
                child: _submitted
                    ? Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: 64,
                            height: 64,
                            color: t.success,
                            child: Icon(Icons.check,
                                size: 36, color: t.successForeground),
                          ),
                          const SizedBox(height: 20),
                          Text(
                            'LINK SENT',
                            style: GoogleFonts.outfit(
                              fontSize: 22,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Text(
                            'We sent a password reset link to ${_emailController.text}. Please check your inbox.',
                            textAlign: TextAlign.center,
                            style: GoogleFonts.outfit(
                                fontSize: 14, color: t.mutedForeground),
                          ),
                          const SizedBox(height: 24),
                          BkButton(
                            label: 'BACK TO SIGN IN',
                            variant: BkButtonVariant.primary,
                            size: BkButtonSize.defaultSize,
                            onPressed: () => context.go('/blocks/login'),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            'RESET PASSWORD',
                            style: GoogleFonts.outfit(
                              fontSize: 24,
                              fontWeight: FontWeight.w900,
                              letterSpacing: 1.0,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Enter your email and we will send you a link to reset your account password.',
                            style: GoogleFonts.outfit(
                                fontSize: 14, color: t.mutedForeground),
                          ),
                          const SizedBox(height: 24),
                          BkInput(
                            controller: _emailController,
                            label: 'EMAIL',
                            hint: 'alex@example.com',
                            keyboardType: TextInputType.emailAddress,
                            prefix:
                                Icon(Icons.mail_outline, color: t.foreground),
                          ),
                          const SizedBox(height: 24),
                          BkButton(
                            label: 'SEND RESET LINK',
                            variant: BkButtonVariant.primary,
                            size: BkButtonSize.lg,
                            onPressed: _handleSubmit,
                          ),
                          const SizedBox(height: 16),
                          Center(
                            child: GestureDetector(
                              onTap: () => context.go('/blocks/login'),
                              child: Text(
                                'BACK TO SIGN IN',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: t.foreground,
                                  decoration: TextDecoration.underline,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
