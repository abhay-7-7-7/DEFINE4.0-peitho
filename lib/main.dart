// BoldKit Flutter — Design system ported from BoldKit by Aniruddha Agarwal
// Original: https://github.com/ANIBIT14/boldkit (MIT License)
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'core/router.dart';
import 'core/theme/bk_theme.dart';
import 'features/settings/theme_provider.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ProviderScope(child: BoldKitApp()));
}

class BoldKitApp extends ConsumerWidget {
  const BoldKitApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeProvider);
    final router = ref.watch(routerProvider);

    return MaterialApp.router(
      title: 'BoldKit',
      debugShowCheckedModeBanner: false,
      themeMode: themeMode,
      theme: BkTheme.light(),
      darkTheme: BkTheme.dark(),
      routerConfig: router,
    );
  }
}
