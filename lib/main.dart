import 'dart:math' as math;

import 'package:flutter/material.dart';

import 'calculator_model.dart';

void main() => runApp(const CalculatorApp());

class CalculatorApp extends StatefulWidget {
  const CalculatorApp({super.key});
  @override
  State<CalculatorApp> createState() => _CalculatorAppState();
}

class _CalculatorAppState extends State<CalculatorApp> {
  final _calculator = CalculatorModel();
  bool _dark = false;
  // Only committed totals/errors are live announcements, not every digit.
  String _announcement = 'Calculator ready';

  void _press(String key) {
    setState(() {
      switch (key) {
        case 'AC':
          _calculator.clear();
        case '=':
          _calculator.equals();
        case '+':
          _calculator.chooseOperator(CalcOperator.add);
        case '−':
          _calculator.chooseOperator(CalcOperator.subtract);
        case '×':
          _calculator.chooseOperator(CalcOperator.multiply);
        case '÷':
          _calculator.chooseOperator(CalcOperator.divide);
        default:
          _calculator.digit(key);
      }
      if (!RegExp(r'^\d$').hasMatch(key) || _calculator.error != null) {
        _announcement =
            _calculator.error ??
            '${_calculator.displayText}. ${_calculator.contextText}';
      }
    });
  }

  @override
  Widget build(BuildContext context) => MaterialApp(
    debugShowCheckedModeBanner: false,
    title: 'Calculator State Lab',
    theme: _theme(Brightness.light),
    darkTheme: _theme(Brightness.dark),
    themeMode: _dark ? ThemeMode.dark : ThemeMode.light,
    themeAnimationDuration: const Duration(milliseconds: 300),
    home: Builder(
      builder: (context) {
        final colors = Theme.of(context).colorScheme;
        return Scaffold(
          body: SafeArea(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 520),
                child: LayoutBuilder(
                  builder: (context, constraints) {
                    final scale =
                        MediaQuery.textScalerOf(context).scale(24) / 24;
                    final keyHeight = math.max(64.0, 28 * scale + 28);
                    return SingleChildScrollView(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Row(
                            children: [
                              const Expanded(
                                child: Text(
                                  'Calculator',
                                  style: TextStyle(
                                    fontSize: 26,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                              ),
                              Semantics(
                                label: 'Dark theme',
                                child: Switch(
                                  key: const ValueKey('theme'),
                                  value: _dark,
                                  onChanged: (value) =>
                                      setState(() => _dark = value),
                                ),
                              ),
                            ],
                          ),
                          const Text(
                            'Left-to-right • State Lab',
                            style: TextStyle(fontSize: 14),
                          ),
                          const SizedBox(height: 24),
                          Container(
                            padding: const EdgeInsets.all(20),
                            decoration: BoxDecoration(
                              color: _calculator.error == null
                                  ? colors.surfaceContainerHighest
                                  : colors.errorContainer,
                              borderRadius: BorderRadius.circular(24),
                            ),
                            child: DefaultTextStyle(
                              style: TextStyle(
                                color: _calculator.error == null
                                    ? colors.onSurface
                                    : colors.onErrorContainer,
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.end,
                                children: [
                                  Text(
                                    _calculator.contextText,
                                    key: const ValueKey('context'),
                                    style: const TextStyle(fontSize: 16),
                                  ),
                                  const SizedBox(height: 12),
                                  Semantics(
                                    label: 'Display ${_calculator.displayText}',
                                    excludeSemantics: true,
                                    child: SingleChildScrollView(
                                      scrollDirection: Axis.horizontal,
                                      reverse: true,
                                      child: Text(
                                        _calculator.displayText,
                                        key: const ValueKey('display'),
                                        style: const TextStyle(
                                          fontSize: 48,
                                          fontWeight: FontWeight.w600,
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          Semantics(
                            liveRegion: true,
                            label: _announcement,
                            child: const SizedBox(height: 16),
                          ),
                          _row(['AC', '÷'], keyHeight, colors),
                          _row(['7', '8', '9', '×'], keyHeight, colors),
                          _row(['4', '5', '6', '−'], keyHeight, colors),
                          _row(['1', '2', '3', '+'], keyHeight, colors),
                          _row(['0', '='], keyHeight, colors),
                        ],
                      ),
                    );
                  },
                ),
              ),
            ),
          ),
        );
      },
    ),
  );

  Widget _row(List<String> keys, double height, ColorScheme colors) => Padding(
    padding: const EdgeInsets.only(bottom: 10),
    child: Row(
      children: [
        for (var i = 0; i < keys.length; i++) ...[
          if (i > 0) const SizedBox(width: 10),
          Expanded(
            child: SizedBox(
              height: height,
              child: FilledButton(
                key: ValueKey('key-${keys[i]}'),
                style: FilledButton.styleFrom(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  backgroundColor: keys[i] == '='
                      ? colors.primary
                      : colors.surfaceContainerHighest,
                  foregroundColor: keys[i] == '='
                      ? colors.onPrimary
                      : colors.onSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(18),
                  ),
                  // Button animation is not a selected enhanced feature.
                  splashFactory: NoSplash.splashFactory,
                  animationDuration: Duration.zero,
                  overlayColor: Colors.transparent,
                ),
                onPressed: () => _press(keys[i]),
                child: Text(
                  keys[i],
                  semanticsLabel: _label(keys[i]),
                  style: const TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ),
          ),
        ],
      ],
    ),
  );

  String _label(String key) => switch (key) {
    'AC' => 'All clear',
    '=' => 'Equals',
    '+' => 'Add',
    '−' => 'Subtract',
    '×' => 'Multiply',
    '÷' => 'Divide',
    _ => key,
  };

  ThemeData _theme(Brightness brightness) => ThemeData(
    useMaterial3: true,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xff315e51),
      brightness: brightness,
    ),
  );
}
