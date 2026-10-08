import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:boldkit_flutter/core/theme/bk_theme.dart';
import 'package:boldkit_flutter/core/widgets/bk_button.dart';
import 'package:boldkit_flutter/core/widgets/bk_input.dart';
import 'package:boldkit_flutter/core/widgets/bk_badge.dart';

void main() {
  testWidgets('BkButton renders with label and handles tap', (WidgetTester tester) async {
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

  testWidgets('BkInput renders label and accepts text', (WidgetTester tester) async {
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

  testWidgets('BkBadge renders with variant colors', (WidgetTester tester) async {
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
}
