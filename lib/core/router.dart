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

// TradeMind Feature Screens
import '../features/seller/auth/auth_controller.dart';
import '../features/seller/auth/seller_login_screen.dart';
import '../features/seller/auth/seller_register_screen.dart';
import '../features/seller/seller_shell.dart';
import '../features/seller/products/product_form_screen.dart';
import '../features/seller/products/product_stats_screen.dart';
import '../features/seller/products/product_models.dart';
import '../features/seller/meetings/meeting_models.dart';
import '../features/seller/live_chat/seller_live_chat_screen.dart';
import '../features/seller/analytics/analytics_screen.dart';
import '../features/seller/api_keys/api_keys_screen.dart';
import '../features/seller/email_settings/email_settings_screen.dart';
import '../features/seller/voice/voice_call_screen.dart';
import '../features/seller/callbacks/callbacks_screen.dart';
import '../features/buyer/buyer_join_screen.dart';
import '../features/buyer/buyer_chat_screen.dart';

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
  final authState = ref.watch(authControllerProvider);

  return GoRouter(
    initialLocation: '/seller/dashboard',
    errorBuilder: (context, state) => const Error404Screen(),
    redirect: (context, state) {
      final loc = state.matchedLocation;
      final isBuyerRoute = loc.startsWith('/join') || loc.startsWith('/buyer');
      if (isBuyerRoute) return null;

      final isAuthRoute = loc == '/seller/login' || loc == '/seller/register';
      final isSellerRoute = loc.startsWith('/seller');

      if (isSellerRoute && !authState.isAuthenticated && !isAuthRoute) {
        return '/seller/login';
      }
      if (authState.isAuthenticated && isAuthRoute) {
        return '/seller/dashboard';
      }
      return null;
    },
    routes: [
      // TradeMind Seller Routes
      GoRoute(
        path: '/seller/login',
        name: 'seller-login',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerLoginScreen(),
        ),
      ),
      GoRoute(
        path: '/seller/register',
        name: 'seller-register',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerRegisterScreen(),
        ),
      ),
      GoRoute(
        path: '/seller',
        redirect: (_, __) => '/seller/dashboard',
      ),
      GoRoute(
        path: '/seller/dashboard',
        name: 'seller-dashboard',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerShell(initialIndex: 0),
        ),
      ),
      GoRoute(
        path: '/seller/products',
        name: 'seller-products',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerShell(initialIndex: 1),
        ),
      ),
      GoRoute(
        path: '/seller/meetings',
        name: 'seller-meetings',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerShell(initialIndex: 2),
        ),
      ),
      GoRoute(
        path: '/seller/bot',
        name: 'seller-bot',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerShell(initialIndex: 3),
        ),
      ),
      GoRoute(
        path: '/seller/settings',
        name: 'seller-settings',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const SellerShell(initialIndex: 4),
        ),
      ),
      GoRoute(
        path: '/seller/products/new',
        name: 'seller-product-new',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const ProductFormScreen(),
        ),
      ),
      GoRoute(
        path: '/seller/products/edit',
        name: 'seller-product-edit',
        pageBuilder: (context, state) {
          final extraProduct = state.extra as Product?;
          return _buildBrutalistPage(
            context: context,
            state: state,
            child: ProductFormScreen(productToEdit: extraProduct),
          );
        },
      ),
      GoRoute(
        path: '/seller/products/stats/:id',
        name: 'seller-product-stats',
        pageBuilder: (context, state) {
          final prod = state.extra as Product? ??
              Product(
                id: int.tryParse(state.pathParameters['id'] ?? '0') ?? 0,
                userId: 0,
                name: 'Product #${state.pathParameters['id']}',
                basePrice: 0,
                costPrice: 0,
                minAcceptablePrice: 0,
                createdAt: '',
              );
          return _buildBrutalistPage(
            context: context,
            state: state,
            child: ProductStatsScreen(product: prod),
          );
        },
      ),
      GoRoute(
        path: '/seller/live-chat/:sessionId',
        name: 'seller-live-chat',
        pageBuilder: (context, state) {
          final sId = state.pathParameters['sessionId'] ?? '';
          final sess = state.extra as LiveMeetingSession? ??
              LiveMeetingSession(
                sessionId: sId,
                productName: 'Negotiation Room',
                basePrice: 0.0,
                costPrice: 0.0,
                minFloor: 0.0,
                mode: 'MAX_PROFIT',
                maxRounds: 10,
                quantity: 1,
                buyerLink: '',
                localIp: '127.0.0.1',
              );
          return _buildBrutalistPage(
            context: context,
            state: state,
            child: SellerLiveChatScreen(session: sess),
          );
        },
      ),
      GoRoute(
        path: '/seller/analytics',
        name: 'seller-analytics',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const AnalyticsScreen(),
        ),
      ),
      GoRoute(
        path: '/seller/api-keys',
        name: 'seller-api-keys',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const ApiKeysScreen(),
        ),
      ),
      GoRoute(
        path: '/seller/email-settings',
        name: 'seller-email-settings',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const EmailSettingsScreen(),
        ),
      ),
      GoRoute(
        path: '/seller/voice',
        name: 'seller-voice',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const VoiceCallScreen(),
        ),
      ),
      GoRoute(
        path: '/seller/callbacks',
        name: 'seller-callbacks',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const CallbacksScreen(),
        ),
      ),

      // Buyer Public Routes
      GoRoute(
        path: '/join',
        name: 'buyer-join',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: const BuyerJoinScreen(),
        ),
      ),
      GoRoute(
        path: '/join/:token',
        name: 'buyer-join-token',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: BuyerJoinScreen(
            initialToken: state.pathParameters['token'],
          ),
        ),
      ),
      GoRoute(
        path: '/buyer/join',
        redirect: (_, __) => '/join',
      ),
      GoRoute(
        path: '/buyer/:token',
        name: 'buyer-room',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: BuyerChatScreen(
            sessionId: state.pathParameters['token'] ?? '',
            buyerName: state.uri.queryParameters['name'] ?? 'Buyer',
          ),
        ),
      ),
      GoRoute(
        path: '/buyer-chat/:token',
        name: 'buyer-chat-room',
        pageBuilder: (context, state) => _buildBrutalistPage(
          context: context,
          state: state,
          child: BuyerChatScreen(
            sessionId: state.pathParameters['token'] ?? '',
            buyerName: state.uri.queryParameters['name'] ?? 'Buyer',
          ),
        ),
      ),

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
