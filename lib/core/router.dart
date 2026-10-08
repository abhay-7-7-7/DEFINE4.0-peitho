import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'theme/bk_motion.dart';
import '../features/home/home_screen.dart';
import '../features/components/components_screen.dart';
import '../features/components/component_detail_screen.dart';
import '../features/charts/charts_screen.dart';
import '../features/shapes/shapes_screen.dart';
import '../features/shapes/shape_builder_screen.dart';
import '../features/ascii_effects/ascii_effects_screen.dart';
import '../features/theme_builder/theme_builder_screen.dart';
import '../features/blocks/auth/login_screen.dart';
import '../features/blocks/auth/signup_screen.dart';
import '../features/blocks/auth/forgot_password_screen.dart';
import '../features/blocks/auth/otp_screen.dart';
import '../features/blocks/error/error_404_screen.dart';
import '../features/blocks/error/error_500_screen.dart';
import '../features/blocks/error/maintenance_screen.dart';
import '../features/blocks/marketing/testimonials_screen.dart';
import '../features/blocks/marketing/pricing_screen.dart';
import '../features/blocks/marketing/team_screen.dart';
import '../features/blocks/marketing/faq_screen.dart';
import '../features/blocks/marketing/contact_screen.dart';
import '../features/blocks/settings/settings_screen.dart';
import '../features/blocks/onboarding/onboarding_screen.dart';
import '../features/blocks/invoice/invoice_screen.dart';
import '../features/settings/settings_about_screen.dart';
import 'shell_scaffold.dart';

/// Reusable brutalist page transition (slide with hard settle and fade).
CustomTransitionPage<void> _buildBrutalistPage({
  required BuildContext context,
  required GoRouterState state,
  required Widget child,
}) {
  return CustomTransitionPage<void>(
    key: state.pageKey,
    child: child,
    transitionDuration: BkMotion.pageTransition,
    transitionsBuilder: (context, animation, secondaryAnimation, child) {
      if (!BkMotion.shouldAnimate(context)) return child;
      final slide = Tween<Offset>(
        begin: const Offset(0.04, 0.0),
        end: Offset.zero,
      ).animate(CurvedAnimation(parent: animation, curve: BkMotion.pressCurve));
      final fade = CurvedAnimation(parent: animation, curve: Curves.easeIn);

      return SlideTransition(
        position: slide,
        child: FadeTransition(
          opacity: fade,
          child: child,
        ),
      );
    },
  );
}

final routerProvider = Provider<GoRouter>((ref) {
  return GoRouter(
    initialLocation: '/',
    errorBuilder: (context, state) => const Error404Screen(),
    routes: [
      // Shell with bottom nav
      ShellRoute(
        builder: (context, state, child) => ShellScaffold(child: child),
        routes: [
          GoRoute(
            path: '/',
            name: 'home',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const HomeScreen(),
            ),
          ),
          GoRoute(
            path: '/components',
            name: 'components',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const ComponentsScreen(),
            ),
            routes: [
              GoRoute(
                path: ':id',
                name: 'component-detail',
                pageBuilder: (context, state) => _buildBrutalistPage(
                  context: context,
                  state: state,
                  child: ComponentDetailScreen(
                    componentId: state.pathParameters['id'] ?? '',
                  ),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/charts',
            name: 'charts',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const ChartsScreen(),
            ),
          ),
          GoRoute(
            path: '/shapes',
            name: 'shapes',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const ShapesScreen(),
            ),
            routes: [
              GoRoute(
                path: 'builder',
                name: 'shape-builder',
                pageBuilder: (context, state) => _buildBrutalistPage(
                  context: context,
                  state: state,
                  child: const ShapeBuilderScreen(),
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/ascii',
            name: 'ascii-effects',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const AsciiEffectsScreen(),
            ),
          ),
          GoRoute(
            path: '/theme-builder',
            name: 'theme-builder',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const ThemeBuilderScreen(),
            ),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            pageBuilder: (context, state) => _buildBrutalistPage(
              context: context,
              state: state,
              child: const SettingsAboutScreen(),
            ),
          ),
        ],
      ),
      // Blocks — pushed on top of shell, no bottom nav
      GoRoute(
        path: '/blocks/login',
        name: 'login',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const LoginScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/signup',
        name: 'signup',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SignUpScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/forgot-password',
        name: 'forgot-password',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const ForgotPasswordScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/otp',
        name: 'otp',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const OtpScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/404',
        name: 'error-404',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const Error404Screen(),
        ),
      ),
      GoRoute(
        path: '/blocks/500',
        name: 'error-500',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const Error500Screen(),
        ),
      ),
      GoRoute(
        path: '/blocks/maintenance',
        name: 'maintenance',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const MaintenanceScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/testimonials',
        name: 'testimonials',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const TestimonialsScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/pricing',
        name: 'pricing',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const PricingScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/team',
        name: 'team',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const TeamScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/faq',
        name: 'faq',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const FaqScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/contact',
        name: 'contact',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const ContactScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/settings',
        name: 'block-settings',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const BlocksSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/onboarding',
        name: 'onboarding',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: '/blocks/invoice',
        name: 'invoice',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const InvoiceScreen(),
        ),
      ),
    ],
  );
});
