import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:boldkit_flutter/core/theme/bk_theme.dart';
import 'package:boldkit_flutter/core/widgets/bk_button.dart';
import 'package:boldkit_flutter/core/widgets/bk_input.dart';
import 'package:boldkit_flutter/core/widgets/bk_badge.dart';
import 'package:boldkit_flutter/core/widgets/bk_select.dart';
import 'package:boldkit_flutter/core/widgets/bk_slider.dart';
import 'package:boldkit_flutter/core/widgets/bk_rating.dart';
import 'package:boldkit_flutter/core/widgets/bk_data_table.dart';
import 'package:boldkit_flutter/core/widgets/bk_command_palette.dart';
import 'package:boldkit_flutter/features/home/home_screen.dart';
import 'package:boldkit_flutter/features/settings/theme_provider.dart';

void main() {
  testWidgets('BkButton renders with label and handles tap',
      (WidgetTester tester) async {
    bool tapped = false;

    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: Scaffold(
          body: BkButton(
            label: 'TEST BUTTON',
            variant: BkButtonVariant.primary,
            onPressed: () {
              tapped = true;
            },
          ),
        ),
      ),
    );

    expect(find.text('TEST BUTTON'), findsOneWidget);

    await tester.tap(find.text('TEST BUTTON'));
    await tester.pumpAndSettle();

    expect(tapped, isTrue);
  });

  testWidgets('BkInput renders label and accepts text',
      (WidgetTester tester) async {
    final controller = TextEditingController();

    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: Scaffold(
          body: BkInput(
            controller: controller,
            label: 'USERNAME',
            hint: 'Enter your username',
          ),
        ),
      ),
    );

    expect(find.text('USERNAME'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'bold_user');
    expect(controller.text, equals('bold_user'));
  });

  testWidgets('BkBadge renders with variant colors',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: const Scaffold(
          body: BkBadge(
            label: 'NEW',
            variant: BkBadgeVariant.accent,
          ),
        ),
      ),
    );

    expect(find.text('NEW'), findsOneWidget);
  });

  testWidgets('BkSelect renders value and opens options',
      (WidgetTester tester) async {
    String selected = 'opt1';
    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return BkSelect<String>(
                label: 'CHOOSE OPTION',
                value: selected,
                items: const [
                  BkSelectItem(value: 'opt1', label: 'Option 1'),
                  BkSelectItem(value: 'opt2', label: 'Option 2'),
                ],
                onChanged: (v) {
                  setState(() => selected = v);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('OPTION 1'), findsOneWidget);
    await tester.tap(find.text('OPTION 1'));
    await tester.pumpAndSettle();

    expect(find.text('OPTION 2'), findsOneWidget);
    await tester.tap(find.text('OPTION 2'));
    await tester.pumpAndSettle();

    expect(selected, equals('opt2'));
  });

  testWidgets('BkSlider renders label and responds to changes',
      (WidgetTester tester) async {
    double sliderVal = 50.0;
    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return BkSlider(
                label: 'VOLUME',
                value: sliderVal,
                min: 0,
                max: 100,
                onChanged: (v) {
                  setState(() => sliderVal = v);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('VOLUME'), findsOneWidget);
    expect(find.text('50.0'), findsOneWidget);
  });

  testWidgets('BkRating renders stars and handles tap',
      (WidgetTester tester) async {
    double currentRating = 3.0;
    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return BkRating(
                rating: currentRating,
                onChanged: (v) {
                  setState(() => currentRating = v);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('3.0 / 5.0'), findsOneWidget);
    expect(find.byIcon(Icons.star), findsNWidgets(5));

    // Tap on the 5th star
    await tester.tap(find.byIcon(Icons.star).at(4));
    await tester.pumpAndSettle();

    expect(currentRating, equals(5.0));
  });

  testWidgets('BkDataTable renders columns, data, and handles selection',
      (WidgetTester tester) async {
    final sampleData = ['Row Alpha', 'Row Beta', 'Row Gamma'];
    Set<String> selected = {};

    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: Scaffold(
          body: StatefulBuilder(
            builder: (context, setState) {
              return BkDataTable<String>(
                columns: [
                  BkDataColumn<String>(
                    label: 'NAME',
                    cellBuilder: (item) => Text(item),
                  ),
                ],
                data: sampleData,
                selectable: true,
                selectedItems: selected,
                onSelectionChanged: (set) {
                  setState(() => selected = set);
                },
              );
            },
          ),
        ),
      ),
    );

    expect(find.text('NAME'), findsOneWidget);
    expect(find.text('Row Alpha'), findsOneWidget);
    expect(find.text('Row Beta'), findsOneWidget);
    expect(find.text('Row Gamma'), findsOneWidget);
  });

  testWidgets('BkCommandPalette renders and filters commands',
      (WidgetTester tester) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: BkTheme.light(),
        home: const Scaffold(
          body: BkCommandPalette(),
        ),
      ),
    );

    expect(find.byType(TextField), findsOneWidget);
    expect(find.text('HOME SCREEN'), findsOneWidget);

    await tester.enterText(find.byType(TextField), 'Theme');
    await tester.pumpAndSettle();

    expect(find.text('THEME BUILDER'), findsOneWidget);
    expect(find.text('HOME SCREEN'), findsNothing);
  });

  testWidgets(
      'Theme toggle button changes Theme.of(context).brightness and persists',
      (WidgetTester tester) async {
    SharedPreferences.setMockInitialValues({'bk_theme_mode': 'light'});

    final container = ProviderContainer(
      overrides: [
        themeModeProvider
            .overrideWith((ref) => ThemeModeNotifier(ThemeMode.light)),
      ],
    );

    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: Consumer(
          builder: (context, ref, _) {
            final mode = ref.watch(themeModeProvider);
            return MaterialApp(
              theme: BkTheme.light(),
              darkTheme: BkTheme.dark(),
              themeMode: mode,
              home: const HomeScreen(),
            );
          },
        ),
      ),
    );

    await tester.pump();

    // Verify initial theme is light
    BuildContext homeContext = tester.element(find.byType(HomeScreen));
    expect(Theme.of(homeContext).brightness, equals(Brightness.light));

    // Tap the theme toggle button in the app bar
    final toggleFinder = find.byIcon(Icons.dark_mode);
    expect(toggleFinder, findsOneWidget);
    await tester.tap(toggleFinder);
    await tester.pump();
    await tester.pump(const Duration(milliseconds: 300));

    expect(container.read(themeModeProvider), equals(ThemeMode.dark));

    // Verify theme changed to dark
    homeContext = tester.element(find.byType(HomeScreen));
    expect(Theme.of(homeContext).brightness, equals(Brightness.dark));

    // Verify that the choice survives a rebuild / is persisted
    final prefs = await SharedPreferences.getInstance();
    expect(prefs.getString('bk_theme_mode'), equals('dark'));
  });
}
