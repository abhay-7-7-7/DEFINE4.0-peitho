import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/bk_tokens.dart';
import '../../../core/widgets/bk_alert.dart';
import '../../../core/widgets/bk_button.dart';
import '../../../core/widgets/bk_card.dart';
import '../../../core/widgets/bk_input.dart';
import 'auth_controller.dart';
import 'auth_state.dart';

class SellerRegisterScreen extends ConsumerStatefulWidget {
  const SellerRegisterScreen({super.key});

  @override
  ConsumerState<SellerRegisterScreen> createState() => _SellerRegisterScreenState();
}

class _SellerRegisterScreenState extends ConsumerState<SellerRegisterScreen> {
  final _fullNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  final _formKey = GlobalKey<FormState>();

  @override
  void dispose() {
    _fullNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Passwords do not match')),
      );
      return;
    }

    final success = await ref.read(authControllerProvider.notifier).register(
          _fullNameController.text,
          _emailController.text,
          _passwordController.text,
        );

    if (success && mounted) {
      context.go('/seller/dashboard');
    }
  }

  @override
  Widget build(BuildContext context) {
    final t = BkTokens.of(context);
    final authState = ref.watch(authControllerProvider);

    return Scaffold(
      backgroundColor: t.background,
      appBar: AppBar(
        backgroundColor: t.background,
        elevation: 0,
        title: Text(
          'REGISTER SELLER',
          style: TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w900,
            color: t.foreground,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: t.foreground),
          onPressed: () => context.pop(),
        ),
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20.0),
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 420),
              child: Form(
                key: _formKey,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    BkCard(
                      backgroundColor: t.card,
                      child: Padding(
                        padding: const EdgeInsets.all(20.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            Text(
                              'CREATE SELLER ACCOUNT',
                              style: TextStyle(
                                fontFamily: 'Outfit',
                                fontSize: 18,
                                fontWeight: FontWeight.w900,
                                color: t.foreground,
                              ),
                            ),
                            const SizedBox(height: 6),
                            Text(
                              'Unlock automated negotiation, product profit floors, and live meeting assist.',
                              style: TextStyle(
                                fontSize: 13,
                                color: t.mutedForeground,
                              ),
                            ),
                            const SizedBox(height: 16),

                            if (authState.errorMessage != null) ...[
                              BkAlert(
                                title: 'Registration Error',
                                description: authState.errorMessage!,
                                variant: BkAlertVariant.destructive,
                              ),
                              const SizedBox(height: 16),
                            ],

                            BkInput(
                              label: 'Full Name',
                              controller: _fullNameController,
                              hint: 'Alex Vance',
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Full name is required';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            BkInput(
                              label: 'Email Address',
                              controller: _emailController,
                              hint: 'seller@store.com',
                              keyboardType: TextInputType.emailAddress,
                              validator: (val) {
                                if (val == null || val.trim().isEmpty) {
                                  return 'Email is required';
                                }
                                if (!val.contains('@')) return 'Enter valid email';
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            BkInput(
                              label: 'Password (min 8 chars, 1 uppercase, 1 digit)',
                              controller: _passwordController,
                              hint: '••••••••',
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.length < 8) {
                                  return 'Must be at least 8 characters';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 14),

                            BkInput(
                              label: 'Confirm Password',
                              controller: _confirmPasswordController,
                              hint: '••••••••',
                              obscureText: true,
                              validator: (val) {
                                if (val == null || val.isEmpty) {
                                  return 'Please confirm password';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 20),

                            BkButton(
                              label: 'CREATE ACCOUNT',
                              isLoading: authState.status == AuthStatus.loading,
                              variant: BkButtonVariant.primary,
                              onPressed: _submit,
                            ),
                            const SizedBox(height: 12),

                            BkButton(
                              label: 'ALREADY HAVE AN ACCOUNT? SIGN IN',
                              variant: BkButtonVariant.ghost,
                              onPressed: () => context.pop(),
                            ),
                          ],
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
