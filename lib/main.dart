// BoldKit Flutter — Design system ported from BoldKit by Aniruddha Agarwal
// Original: https://github.com/ANIBIT14/boldkit (MIT License)
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/localization/app_localizations.dart';
import 'core/router.dart';
import 'core/theme/bk_theme.dart';
import 'core/theme/bk_tokens.dart';
import 'features/settings/theme_provider.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Load persisted theme BEFORE runApp to eliminate the startup flash.
  final initialTheme = await loadPersistedThemeMode();

  runApp(
    ProviderScope(
      overrides: [
        // Pre-seed the provider with the already-loaded value.
        themeModeProvider.overrideWith(
          (ref) => ThemeModeNotifier(initialTheme),
        ),
      ],
      child: const BoldKitApp(),
    ),
  );
}

class BoldKitApp extends ConsumerWidget {
  const BoldKitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    // Derive the effective brightness for SystemUiOverlayStyle.
    final platformBrightness = MediaQuery.platformBrightnessOf(context);
    final effectiveDark = themeMode == ThemeMode.dark ||
        (themeMode == ThemeMode.system &&
            platformBrightness == Brightness.dark);

    // Keep status-bar and nav-bar icons in sync with the theme.
    final overlayStyle = effectiveDark
        ? SystemUiOverlayStyle.light.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: BkTokens.dark.background,
            systemNavigationBarIconBrightness: Brightness.light,
          )
        : SystemUiOverlayStyle.dark.copyWith(
            statusBarColor: Colors.transparent,
            systemNavigationBarColor: BkTokens.light.background,
            systemNavigationBarIconBrightness: Brightness.dark,
          );

    final customTokens = ref.watch(customThemeTokensProvider);
    final lightTokens = customTokens.isCustomized
        ? customTokens.applyTo(BkTokens.light)
        : BkTokens.light;
    final darkTokens = customTokens.isCustomized
        ? customTokens.applyTo(BkTokens.dark)
        : BkTokens.dark;

    final appLocale = ref.watch(appLocaleProvider);

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: overlayStyle,
      child: MaterialApp.router(
        title: 'TradeMind',
        debugShowCheckedModeBanner: false,
        themeMode: themeMode,
        theme: BkTheme.light(lightTokens),
        darkTheme: BkTheme.dark(darkTokens),
        locale: Locale(appLocale.localeCode),
        supportedLocales: supportedLanguages.map((l) => Locale(l.code)).toList(),
        routerConfig: router,
      ),
    );
  }
}
