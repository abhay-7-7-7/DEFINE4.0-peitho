import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_shadow.dart';

/// Brutalist sign-up block screen.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key, this.onCreateAccount, this.onBackToLogin});

  final VoidCallback? onCreateAccount;
  final VoidCallback? onBackToLogin;

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

typedef SignupScreen = SignUpScreen;

class _SignUpScreenState extends State<SignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passwordCtrl = TextEditingController();
  final _confirmCtrl = TextEditingController();
  bool _obscurePassword = true;
  bool _obscureConfirm = true;
  bool _agreedToTerms = false;
  bool _isLoading = false;

  @override
  void dispose() {
    _nameCtrl.dispose();
    _emailCtrl.dispose();
    _passwordCtrl.dispose();
    _confirmCtrl.dispose();
    super.dispose();
  }

  String? _validateName(String? v) {
    if (v == null || v.trim().isEmpty) return 'Full name is required';
    if (v.trim().length < 2) return 'Name must be at least 2 characters';
    return null;
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

  String? _validateConfirm(String? v) {
    if (v == null || v.isEmpty) return 'Please confirm your password';
    if (v != _passwordCtrl.text) return 'Passwords do not match';
    return null;
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (!_agreedToTerms) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(
            'Please agree to the Terms of Service.',
            style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
          ),
          backgroundColor: BkTokens.of(context).destructive,
          behavior: SnackBarBehavior.floating,
        ),
      );
      return;
    }
    setState(() => _isLoading = true);
    await Future.delayed(const Duration(seconds: 1));
    setState(() => _isLoading = false);
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          'ACCOUNT CREATED!',
          style: GoogleFonts.outfit(fontWeight: FontWeight.w700),
        ),
        backgroundColor: BkTokens.of(context).success,
        behavior: SnackBarBehavior.floating,
      ),
    );
    widget.onCreateAccount?.call();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.foreground),
          onPressed: widget.onBackToLogin,
        ),
        title: Text(
          'CREATE ACCOUNT',
          style: GoogleFonts.outfit(
            fontWeight: FontWeight.w900,
            fontSize: 18,
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
                        'JOIN BOLDKIT',
                        style: GoogleFonts.outfit(
                          fontSize: 32,
                          fontWeight: FontWeight.w900,
                          color: t.foreground,
                          letterSpacing: 2,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        'Create your account in seconds',
                        style: GoogleFonts.outfit(
                          fontSize: 15,
                          fontWeight: FontWeight.w500,
                          color: t.mutedForeground,
                        ),
                      ),
                      const SizedBox(height: 28),
                      _BkLabel(text: 'FULL NAME', t: t),
                      const SizedBox(height: 6),
                      _BkField(
                        controller: _nameCtrl,
                        t: t,
                        hintText: 'Jane Doe',
                        validator: _validateName,
                        textCapitalization: TextCapitalization.words,
                      ),
                      const SizedBox(height: 16),
                      _BkLabel(text: 'EMAIL', t: t),
                      const SizedBox(height: 6),
                      _BkField(
                        controller: _emailCtrl,
                        t: t,
                        hintText: 'you@example.com',
                        keyboardType: TextInputType.emailAddress,
                        validator: _validateEmail,
                      ),
                      const SizedBox(height: 16),
                      _BkLabel(text: 'PASSWORD', t: t),
                      const SizedBox(height: 6),
                      _BkField(
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
                      const SizedBox(height: 16),
                      _BkLabel(text: 'CONFIRM PASSWORD', t: t),
                      const SizedBox(height: 6),
                      _BkField(
                        controller: _confirmCtrl,
                        t: t,
                        hintText: '••••••••',
                        obscureText: _obscureConfirm,
                        validator: _validateConfirm,
                        suffixIcon: GestureDetector(
                          onTap: () => setState(() => _obscureConfirm = !_obscureConfirm),
                          child: Icon(
                            _obscureConfirm ? Icons.visibility_off : Icons.visibility,
                            color: t.mutedForeground,
                            size: 20,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      GestureDetector(
                        onTap: () => setState(() => _agreedToTerms = !_agreedToTerms),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              width: 22,
                              height: 22,
                              decoration: BoxDecoration(
                                color: _agreedToTerms ? t.primary : t.background,
                                border: Border.all(color: t.border, width: 3),
                              ),
                              child: _agreedToTerms
                                  ? Icon(Icons.check, size: 14, color: t.primaryForeground)
                                  : null,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text.rich(
                                TextSpan(
                                  text: 'I agree to the ',
                                  style: GoogleFonts.outfit(
                                    fontSize: 13,
                                    color: t.mutedForeground,
                                  ),
                                  children: [
                                    TextSpan(
                                      text: 'Terms of Service',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: t.foreground,
                                        decoration: TextDecoration.underline,
                                        decorationColor: t.foreground,
                                      ),
                                    ),
                                    TextSpan(
                                      text: ' and ',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        color: t.mutedForeground,
                                      ),
                                    ),
                                    TextSpan(
                                      text: 'Privacy Policy',
                                      style: GoogleFonts.outfit(
                                        fontSize: 13,
                                        fontWeight: FontWeight.w700,
                                        color: t.foreground,
                                        decoration: TextDecoration.underline,
                                        decorationColor: t.foreground,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 28),
                      SizedBox(
                        height: 52,
                        child: BkButton(
                          label: _isLoading ? 'CREATING ACCOUNT...' : 'CREATE ACCOUNT',
                          isLoading: _isLoading,
                          size: BkButtonSize.lg,
                          onPressed: _submit,
                        ),
                      ),
                      const SizedBox(height: 20),
                      Wrap(
                        alignment: WrapAlignment.center,
                        crossAxisAlignment: WrapCrossAlignment.center,
                        children: [
                          Text(
                            'Already have an account? ',
                            style: GoogleFonts.outfit(
                              fontSize: 14,
                              color: t.mutedForeground,
                            ),
                          ),
                          GestureDetector(
                            onTap: widget.onBackToLogin,
                            child: Text(
                              'SIGN IN',
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

// ── Shared helpers ────────────────────────────────────────────────────────────

class _BkLabel extends StatelessWidget {
  const _BkLabel({required this.text, required this.t});
  final String text;
  final BkTokens t;
  @override
  Widget build(BuildContext context) => Text(
        text,
        style: GoogleFonts.outfit(
          fontSize: 12,
          fontWeight: FontWeight.w800,
          color: t.foreground,
          letterSpacing: 1.5,
        ),
      );
}

class _BkField extends StatelessWidget {
  const _BkField({
    required this.controller,
    required this.t,
    required this.hintText,
    this.obscureText = false,
    this.keyboardType,
    this.validator,
    this.suffixIcon,
    this.textCapitalization = TextCapitalization.none,
  });

  final TextEditingController controller;
  final BkTokens t;
  final String hintText;
  final bool obscureText;
  final TextInputType? keyboardType;
  final FormFieldValidator<String>? validator;
  final Widget? suffixIcon;
  final TextCapitalization textCapitalization;

  @override
  Widget build(BuildContext context) => TextFormField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textCapitalization: textCapitalization,
        validator: validator,
        style: GoogleFonts.outfit(fontSize: 15, fontWeight: FontWeight.w500, color: t.foreground),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: GoogleFonts.outfit(fontSize: 15, color: t.mutedForeground),
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
          errorStyle: GoogleFonts.outfit(fontSize: 12, fontWeight: FontWeight.w600, color: t.destructive),
        ),
      );
}
