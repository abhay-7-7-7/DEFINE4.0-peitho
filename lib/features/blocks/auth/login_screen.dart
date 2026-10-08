import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_shadow.dart';

/// Brutalist login screen block.
class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key, this.onSignIn, this.onSignUp, this.onForgotPassword, this.onGoogle, this.onGitHub});

  final VoidCallback? onSignIn;
  final VoidCallback? onSignUp;
  final VoidCallback? onForgotPassword;
  final VoidCallback? onGoogle;
  final VoidCallback? onGitHub;

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _isLoading = false;

  @override
  void dispose() {
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    super.dispose();
  }

  String? _validateEmail(String? v) {
    if (v == null || v.trim().isEmpty) return 'Email is required';
    final emailReg = RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$');
    if (!emailReg.hasMatch(v.trim())) return 'Enter a valid email address';
    return null;
  }

  String? _validatePassword(String? v) {
    if (v == null || v.isEmpty) return 'Password is required';
    if (v.length < 8) return 'Password must be at least 8 characters';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'SIGNING IN...',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: BkTokens.of(context).primary,
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onSignIn?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          'BOLDKIT',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 20,
            color: t.foreground,
            letterSpacing: 2,
          ),
        ),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(3),
          child: Container(height: 3, color: t.border),
        ),
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 400),
            child: BkShadow(
              backgroundColor: t.card,
              child: Padding(
                padding: const EdgeInsets.all(32),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        'SIGN IN',
                        style: GoogleFonts.outfit(
                          fontSize: 36,
                          fontWeight: FontWeight.w900,
                          color: t.foreground,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Welcome back to BoldKit',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: t.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _BkLabel(text: 'EMAIL', t: t),
                      const SizedBox(height: 6),
                      _BkTextFormField(
                        controller: _emailCtrl,
                        t: t,
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      _BkLabel(text: 'PASSWORD', t: t),
                      const SizedBox(height: 6),
                      _BkTextFormField(
                        controller: _passwordCtrl,
                        t: t,
                        hintText: '••••••••',
                        obscureText: _obscurePassword,
                        validator: _validatePassword,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscurePassword = !_obscurePassword),
                          child: Icon(
                            _obscurePassword ? Icons.visibility_off : Icons.visibility,
                            color: t.mutedForeground,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      Align(
                        alignment: Alignment.centerRight,
                        child: GestureDetector(
                          onTap: widget.onForgotPassword,
                          child: Text(
                            'Forgot password?',
                            style: GoogleFonts.outfit(
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: t.primary,
                              decoration: TextDecoration.underline,
                              decorationColor: t.primary,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: BkButton(
                          label: _isLoading ? 'SIGNING IN...' : 'SIGN IN',
                          isLoading: _isLoading,
                          size: BkButtonSize.lg,
                          onPressed: _submit,
                        ),
                      ),
                      const SizedBox(height: 24),
                      _OrDivider(t: t),
                      const SizedBox(height: 24),
                      SizedBox(
                        height: 52,
                        child: BkButton(
                          label: 'CONTINUE WITH GOOGLE',
                          variant: BkButtonVariant.outline,
                          size: BkButtonSize.lg,
                          leading: const Icon(Icons.g_mobiledata, size: 22),
                          onPressed: widget.onGoogle,
                        ),
                      ),
                      const SizedBox(height: 12),
                      SizedBox(
                        height: 52,
                        child: BkButton(
                          label: 'CONTINUE WITH GITHUB',
                          variant: BkButtonVariant.outline,
                          size: BkButtonSize.lg,
                          leading: const Icon(Icons.code, size: 22),
                          onPressed: widget.onGitHub,
                        ),
                      ),
                      const SizedBox(height: 24),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            "Don't have an account? ",
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: t.mutedForeground,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onSignUp,
                            child: Text(
                              'SIGN UP',
                              style: GoogleFonts.outfit(
                                fontSize: 14,
                                fontWeight: FontWeight.w800,
                                color: t.foreground,
                                decoration: TextDecoration.underline,
                                decorationColor: t.foreground,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Shared brutalist field helpers ───────────────────────────────────────────

class _BkLabel extends StatelessWidget {
  const _BkLabel({required this.text, required this.t});
  final String text;
  final BkTokens t;
  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: GoogleFonts.outfit(
        fontSize: 12,
        fontWeight: FontWeight.w800,
        color: t.foreground,
        letterSpacing: 1.5,
      ),
    );
  }
}

class _BkTextFormField extends StatelessWidget {
  const _BkTextFormField({
    required this.controller,
    required this.t,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
  });

  final TextEditingController controller;
  final BkTokens t;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      controller: controller,
      obscureText: obscureText,
      keyboardType: keyboardType,
      maxLines: 1,
      validator: validator,
      style: GoogleFonts.outfit(
        fontSize: 15,
        fontWeight: FontWeight.w500,
        color: t.foreground,
      ),
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: GoogleFonts.outfit(
          fontSize: 15,
          color: t.mutedForeground,
        ),
        filled: true,
        fillColor: t.background,
        suffixIcon: suffixIcon,
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.border, width: 3),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.foreground, width: 3),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.destructive, width: 3),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.zero,
          borderSide: BorderSide(color: t.destructive, width: 3),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
        errorStyle: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: t.destructive,
        ),
      ),
    );
  }
}

class _OrDivider extends StatelessWidget {
  const _OrDivider({required this.t});
  final BkTokens t;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(child: Container(height: 3, color: t.border)),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 12),
          child: Text(
            'OR',
            style: GoogleFonts.outfit(
              fontSize: 13,
              fontWeight: FontWeight.w800,
              color: t.mutedForeground,
              letterSpacing: 1.5,
            ),
          ),
        ),
        Expanded(child: Container(height: 3, color: t.border)),
      ],
    );
  }
}
