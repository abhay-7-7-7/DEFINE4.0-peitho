import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:boldkit_flutter/core/theme/bk_theme.dart';
import 'package:boldkit_flutter/core/widgets/bk_button.dart';
import 'package:boldkit_flutter/core/widgets/bk_switch.dart';
import 'package:boldkit_flutter/core/widgets/bk_toast.dart';
import 'package:boldkit_flutter/features/home/home_screen.dart';
import 'package:boldkit_flutter/features/components/components_screen.dart';
import 'package:boldkit_flutter/features/components/component_detail_screen.dart';
import 'package:boldkit_flutter/features/charts/charts_screen.dart';
import 'package:boldkit_flutter/features/shapes/shapes_screen.dart';
import 'package:boldkit_flutter/features/shapes/shape_builder_screen.dart';
import 'package:boldkit_flutter/features/ascii_effects/ascii_effects_screen.dart';
import 'package:boldkit_flutter/features/theme_builder/theme_builder_screen.dart';
import 'package:boldkit_flutter/features/settings/settings_about_screen.dart';
import 'package:boldkit_flutter/features/blocks/auth/login_screen.dart';
import 'package:boldkit_flutter/features/blocks/auth/signup_screen.dart';
import 'package:boldkit_flutter/features/blocks/auth/forgot_password_screen.dart';
import 'package:boldkit_flutter/features/blocks/auth/otp_screen.dart';
import 'package:boldkit_flutter/features/blocks/marketing/pricing_screen.dart';
import 'package:boldkit_flutter/features/blocks/marketing/testimonials_screen.dart';
import 'package:boldkit_flutter/features/blocks/marketing/team_screen.dart';
import 'package:boldkit_flutter/features/blocks/marketing/faq_screen.dart';
import 'package:boldkit_flutter/features/blocks/marketing/contact_screen.dart';
import 'package:boldkit_flutter/features/blocks/invoice/invoice_screen.dart';
import 'package:boldkit_flutter/features/blocks/onboarding/onboarding_screen.dart';
import 'package:boldkit_flutter/features/blocks/settings/settings_screen.dart';
import 'package:boldkit_flutter/features/blocks/error/error_404_screen.dart';
import 'package:boldkit_flutter/features/blocks/error/error_500_screen.dart';
import 'package:boldkit_flutter/features/blocks/error/maintenance_screen.dart';

void main() {
  const testSizes = [
    Size(320, 640), // small phone
    Size(360, 800), // user phone (CPH2767)
    Size(412, 915), // standard modern phone
    Size(768, 1024), // tablet
    Size(1280, 800), // desktop
  ];

  final screens = <String, Widget Function()>{
    'HomeScreen': () => const HomeScreen(),
    'ComponentsScreen': () => const ComponentsScreen(),
    'ComponentDetailScreen': () =>
        const ComponentDetailScreen(componentId: 'button'),
    'ChartsScreen': () => const ChartsScreen(),
    'ShapesScreen': () => const ShapesScreen(),
    'ShapeBuilderScreen': () => const ShapeBuilderScreen(),
    'AsciiEffectsScreen': () => const AsciiEffectsScreen(),
    'ThemeBuilderScreen': () => const ThemeBuilderScreen(),
    'SettingsAboutScreen': () => const SettingsAboutScreen(),
    'LoginScreen': () => const LoginScreen(),
    'SignUpScreen': () => const SignUpScreen(),
    'ForgotPasswordScreen': () => const ForgotPasswordScreen(),
    'OtpScreen': () => const OtpScreen(),
    'PricingScreen': () => const PricingScreen(),
    'TestimonialsScreen': () => const TestimonialsScreen(),
    'TeamScreen': () => const TeamScreen(),
    'FaqScreen': () => const FaqScreen(),
    'ContactScreen': () => const ContactScreen(),
    'InvoiceScreen': () => const InvoiceScreen(),
    'OnboardingScreen': () => const OnboardingScreen(),
    'BlocksSettingsScreen': () => const BlocksSettingsScreen(),
    'Error404Screen': () => const Error404Screen(),
    'Error500Screen': () => const Error500Screen(),
    'MaintenanceScreen': () => const MaintenanceScreen(),
  };

  for (final size in testSizes) {
    for (final isDark in [false, true]) {
      for (final textScale in [1.0, 1.3]) {
        final modeName = isDark ? 'Dark' : 'Light';
        final sizeName = '${size.width.toInt()}x${size.height.toInt()}';
        final scaleName = 'scale_${textScale}x';

        testWidgets(
            'Verify $sizeName $modeName $scaleName all screens without overflow or errors',
            (tester) async {
          tester.view.physicalSize = size;
          tester.view.devicePixelRatio = 1.0;
          addTearDown(() {
            tester.view.resetPhysicalSize();
            tester.view.resetDevicePixelRatio();
          });

          final theme = isDark ? BkTheme.dark() : BkTheme.light();

          for (final entry in screens.entries) {
            final router = GoRouter(
              initialLocation: '/',
              routes: [
                GoRoute(
                  path: '/',
                  builder: (context, state) => MediaQuery(
                    data: MediaQueryData(
                      size: size,
                      textScaler: TextScaler.linear(textScale),
                    ),
                    child: Material(child: entry.value()),
                  ),
                ),
                GoRoute(
                    path: '/components',
                    builder: (c, s) => const SizedBox(),
                    routes: [
                      GoRoute(path: ':id', builder: (c, s) => const SizedBox()),
                    ]),
                GoRoute(path: '/charts', builder: (c, s) => const SizedBox()),
                GoRoute(path: '/shapes', builder: (c, s) => const SizedBox()),
                GoRoute(path: '/settings', builder: (c, s) => const SizedBox()),
              ],
            );

            await tester.pumpWidget(
              ProviderScope(
                child: MaterialApp.router(
                  theme: theme,
                  routerConfig: router,
                ),
              ),
            );

            // Initial frame render
            await tester.pump(const Duration(milliseconds: 50));
            expect(
              tester.takeException(),
              isNull,
              reason:
                  '${entry.key} had exception at $sizeName $modeName $scaleName on initial render',
            );

            // Test interaction: scroll down if scrollable
            final scrollableFinder = find.byType(Scrollable);
            if (scrollableFinder.evaluate().isNotEmpty) {
              await tester.drag(scrollableFinder.first, const Offset(0, -300));
              await tester.pump(const Duration(milliseconds: 50));
              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${entry.key} had exception after scroll at $sizeName $modeName $scaleName',
              );
            }

            // Test interaction: tap switch if present
            final switchFinder = find.byType(BkSwitch);
            if (switchFinder.evaluate().isNotEmpty) {
              await tester.tap(switchFinder.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 50));
              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${entry.key} had exception after switch tap at $sizeName $modeName $scaleName',
              );
            }

            // Test interaction: tap button if present
            final buttonFinder = find.byType(BkButton);
            if (buttonFinder.evaluate().isNotEmpty) {
              await tester.tap(buttonFinder.first, warnIfMissed: false);
              await tester.pump(const Duration(milliseconds: 50));
              BkToastManager.dismiss();
              expect(
                tester.takeException(),
                isNull,
                reason:
                    '${entry.key} had exception after button tap at $sizeName $modeName $scaleName',
              );
            }
          }
          BkToastManager.dismiss();
        });
      }
    }
  }
}
