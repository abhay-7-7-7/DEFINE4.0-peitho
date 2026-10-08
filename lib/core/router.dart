import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
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
            builder: (context, state) => const HomeScreen(),
          ),
          GoRoute(
            path: '/components',
            name: 'components',
            builder: (context, state) => const ComponentsScreen(),
            routes: [
              GoRoute(
                path: ':id',
                name: 'component-detail',
                builder: (context, state) => ComponentDetailScreen(
                  componentId: state.pathParameters['id'] ?? '',
                ),
              ),
            ],
          ),
          GoRoute(
            path: '/charts',
            name: 'charts',
            builder: (context, state) => const ChartsScreen(),
          ),
          GoRoute(
            path: '/shapes',
            name: 'shapes',
            builder: (context, state) => const ShapesScreen(),
            routes: [
              GoRoute(
                path: 'builder',
                name: 'shape-builder',
                builder: (context, state) => const ShapeBuilderScreen(),
              ),
            ],
          ),
          GoRoute(
            path: '/ascii',
            name: 'ascii-effects',
            builder: (context, state) => const AsciiEffectsScreen(),
          ),
          GoRoute(
            path: '/theme-builder',
            name: 'theme-builder',
            builder: (context, state) => const ThemeBuilderScreen(),
          ),
          GoRoute(
            path: '/settings',
            name: 'settings',
            builder: (context, state) => const SettingsAboutScreen(),
          ),
        ],
      ),
      // Blocks — pushed on top of shell, no bottom nav
      GoRoute(
        path: '/blocks/login',
        name: 'login',
        builder: (context, state) => const LoginScreen(),
      ),
      GoRoute(
        path: '/blocks/signup',
        name: 'signup',
        builder: (context, state) => const SignUpScreen(),
      ),
      GoRoute(
        path: '/blocks/forgot-password',
        name: 'forgot-password',
        builder: (context, state) => const ForgotPasswordScreen(),
      ),
      GoRoute(
        path: '/blocks/otp',
        name: 'otp',
        builder: (context, state) => const OtpScreen(),
      ),
      GoRoute(
        path: '/blocks/404',
        name: 'error-404',
        builder: (context, state) => const Error404Screen(),
      ),
      GoRoute(
        path: '/blocks/500',
        name: 'error-500',
        builder: (context, state) => const Error500Screen(),
      ),
      GoRoute(
        path: '/blocks/maintenance',
        name: 'maintenance',
        builder: (context, state) => const MaintenanceScreen(),
      ),
      GoRoute(
        path: '/blocks/testimonials',
        name: 'testimonials',
        builder: (context, state) => const TestimonialsScreen(),
      ),
      GoRoute(
        path: '/blocks/pricing',
        name: 'pricing',
        builder: (context, state) => const PricingScreen(),
      ),
      GoRoute(
        path: '/blocks/team',
        name: 'team',
        builder: (context, state) => const TeamScreen(),
      ),
      GoRoute(
        path: '/blocks/faq',
        name: 'faq',
        builder: (context, state) => const FaqScreen(),
      ),
      GoRoute(
        path: '/blocks/contact',
        name: 'contact',
        builder: (context, state) => const ContactScreen(),
      ),
      GoRoute(
        path: '/blocks/settings',
        name: 'block-settings',
        builder: (context, state) => const BlocksSettingsScreen(),
      ),
      GoRoute(
        path: '/blocks/onboarding',
        name: 'onboarding',
        builder: (context, state) => const OnboardingScreen(),
      ),
      GoRoute(
        path: '/blocks/invoice',
        name: 'invoice',
        builder: (context, state) => const InvoiceScreen(),
      ),
    ],
  );
});
