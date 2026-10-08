import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boldkit_flutter/core/theme/bk_theme.dart';
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
  const sizes = [
    Size(360, 800),  // mobile
    Size(768, 1024), // tablet
    Size(1280, 800), // desktop
  ];

  final screens = <String, Widget Function()>{
    'HomeScreen': () => const HomeScreen(),
    'ComponentsScreen': () => const ComponentsScreen(),
    'ComponentDetailScreen': () => const ComponentDetailScreen(componentId: 'button'),
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

  for (final size in sizes) {
    for (final isDark in [false, true]) {
      final modeName = isDark ? 'Dark' : 'Light';
      final sizeName = '${size.width.toInt()}x${size.height.toInt()}';

      testWidgets('Renders all screens at $sizeName in $modeName mode without overflow', (tester) async {
        tester.view.physicalSize = size;
        tester.view.devicePixelRatio = 1.0;
        addTearDown(() {
          tester.view.resetPhysicalSize();
          tester.view.resetDevicePixelRatio();
        });

        final theme = isDark ? BkTheme.dark() : BkTheme.light();

        for (final entry in screens.entries) {
          await tester.pumpWidget(
            ProviderScope(
              child: MaterialApp(
                theme: theme,
                home: Material(child: entry.value()),
              ),
            ),
          );
          await tester.pump(const Duration(milliseconds: 100));

          expect(tester.takeException(), isNull, reason: '${entry.key} had an exception at $sizeName in $modeName');
        }
      });
    }
  }
}
