import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_widgets.dart';

class OtpScreen extends StatefulWidget {
  const OtpScreen({super.key});

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  int _secondsRemaining = 60;
  Timer? _timer;
  String _otp = '';

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  void _startTimer() {
    _secondsRemaining = 60;
    _timer?.cancel();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsRemaining > 0) {
        setState(() => _secondsRemaining--);
      } else {
        _timer?.cancel();
      }
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        title: Text(
          'VERIFICATION',
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
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'ENTER OTP CODE',
                      style: GoogleFonts.outfit(
                        fontSize: 24,
                        fontWeight: FontWeight.w900,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'We sent a 6-digit verification code to al***@example.com.',
                      style: GoogleFonts.outfit(
                          fontSize: 14, color: t.mutedForeground),
                    ),
                    const SizedBox(height: 28),
                    // OTP Box Row
                    Center(
                      child: FittedBox(
                        fit: BoxFit.scaleDown,
                        child: BkOtpInput(
                          onChanged: (code) => setState(() => _otp = code),
                          onCompleted: (code) {
                            setState(() => _otp = code);
                            BkToastManager.show(context,
                                message: 'Code Verified!',
                                variant: BkToastVariant.success);
                            final router = GoRouter.of(context);
                            Future.delayed(const Duration(milliseconds: 600),
                                () {
                              if (mounted) router.go('/');
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(height: 28),
                    BkButton(
                      label: 'VERIFY CODE',
                      variant: BkButtonVariant.primary,
                      size: BkButtonSize.lg,
                      onPressed: _otp.length == 6
                          ? () {
                              BkToastManager.show(context,
                                  message: 'Verified Successfully!',
                                  variant: BkToastVariant.success);
                              context.go('/');
                            }
                          : null,
                    ),
                    const SizedBox(height: 20),
                    Center(
                      child: _secondsRemaining > 0
                          ? Text(
                              'Resend code in ${_secondsRemaining}s',
                              style: GoogleFonts.dmMono(
                                fontSize: 13,
                                color: t.mutedForeground,
                              ),
                            )
                          : GestureDetector(
                              onTap: _startTimer,
                              child: Text(
                                'RESEND CODE',
                                style: GoogleFonts.outfit(
                                  fontSize: 12,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0.5,
                                  color: t.primary,
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
