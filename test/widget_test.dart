import 'package:calculator_app/main.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Future<void> key(WidgetTester tester, String value) async {
  final finder = find.byKey(ValueKey('key-$value'));
  await tester.ensureVisible(finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

String display(WidgetTester tester) =>
    tester.widget<Text>(find.byKey(const ValueKey('display'))).data!;
Future<void> sequence(WidgetTester tester, String keys) async {
  for (final value in keys.split(' ')) {
    await key(tester, value);
  }
}

void main() {
  testWidgets('theme switching during entry and result preserves calculation', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    await sequence(tester, '2 + 3');
    expect(display(tester), '3');
    await tester.tap(find.byKey(const ValueKey('theme')));
    await tester.pumpAndSettle();
    expect(
      tester.widget<MaterialApp>(find.byType(MaterialApp)).themeMode,
      ThemeMode.dark,
    );
    expect(display(tester), '3');
    await sequence(tester, '×');
    expect(display(tester), '5');
    await sequence(tester, '4 =');
    expect(display(tester), '20');
    await tester.tap(find.byKey(const ValueKey('theme')));
    await tester.pumpAndSettle();
    expect(display(tester), '20');
    await key(tester, '6');
    expect(display(tester), '6');
  });
  testWidgets('incomplete equals and error recovery visible in UI', (
    tester,
  ) async {
    await tester.pumpWidget(const CalculatorApp());
    await sequence(tester, '7 + =');
    expect(display(tester), '7');
    expect(find.text('7 + — enter a number'), findsOneWidget);
    await sequence(tester, '2 =');
    expect(display(tester), '9');
    await sequence(tester, 'AC 8 ÷ 0 =');
    expect(display(tester), 'Error');
    expect(find.textContaining('Cannot divide by zero'), findsOneWidget);
    await tester.tap(find.byKey(const ValueKey('theme')));
    await tester.pumpAndSettle();
    expect(display(tester), 'Error');
    await key(tester, '4');
    expect(display(tester), '4');
    await sequence(tester, '÷ 0 = AC');
    expect(display(tester), '0');
  });
  for (final scale in [1.0, 2.0, 3.0]) {
    testWidgets(
      '320px portrait with text scale $scale has usable unclipped keys',
      (tester) async {
        tester.view.physicalSize = const Size(320, 640);
        tester.view.devicePixelRatio = 1;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);
        tester.platformDispatcher.textScaleFactorTestValue = scale;
        addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
        await tester.pumpWidget(const CalculatorApp());
        await tester.pumpAndSettle();
        expect(
          MediaQuery.textScalerOf(
            tester.element(find.byKey(const ValueKey('display'))),
          ).scale(24),
          24 * scale,
        );
        for (final value in [
          '7',
          '8',
          '9',
          '×',
          '4',
          '5',
          '6',
          '−',
          '1',
          '2',
          '3',
          '+',
          '0',
          '=',
          'AC',
          '÷',
        ]) {
          final finder = find.byKey(ValueKey('key-$value'));
          await tester.ensureVisible(finder);
          await tester.pumpAndSettle();
          final size = tester.getSize(finder);
          expect(size.width, greaterThanOrEqualTo(48));
          expect(size.height, greaterThanOrEqualTo(48));
          expect(tester.takeException(), isNull);
          await tester.tap(finder);
          await tester.pumpAndSettle();
        }
        expect(tester.takeException(), isNull);
      },
    );
  }
  testWidgets('operator labels and committed-result live semantics', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(const CalculatorApp());
    for (final label in [
      'Add',
      'Subtract',
      'Multiply',
      'Divide',
      'Equals',
      'All clear',
      'Dark theme',
    ]) {
      expect(find.bySemanticsLabel(label), findsOneWidget);
    }
    await sequence(tester, '2 + 3 ×');
    expect(find.bySemanticsLabel('Display 5'), findsOneWidget);
    final announcement = tester.getSemantics(
      find.bySemanticsLabel('5. 5 × — enter a number'),
    );
    expect(announcement.getSemanticsData().flagsCollection.isLiveRegion, true);
    await sequence(tester, 'AC 8 ÷ 0 =');
    expect(
      find.bySemanticsLabel(RegExp('Cannot divide by zero')),
      findsWidgets,
    );
    handle.dispose();
  });
  testWidgets('light and dark text contrast and labeled tap targets', (
    tester,
  ) async {
    final handle = tester.ensureSemantics();

    await tester.pumpWidget(const CalculatorApp());
    for (var i = 0; i < 2; i++) {
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
      await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
      await sequence(tester, '8 ÷ 0 =');
      await expectLater(tester, meetsGuideline(textContrastGuideline));
      await key(tester, 'AC');
      await tester.tap(find.byKey(const ValueKey('theme')));
      await tester.pumpAndSettle();
    }
    handle.dispose();
  });
}
