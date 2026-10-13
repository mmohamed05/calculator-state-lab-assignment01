import 'package:calculator_app/calculator_model.dart';
import 'package:flutter_test/flutter_test.dart';

void tap(CalculatorModel m, String key) {
  switch (key) {
    case 'AC':
      m.clear();
    case '=':
      m.equals();
    case '+':
      m.chooseOperator(CalcOperator.add);
    case '−':
      m.chooseOperator(CalcOperator.subtract);
    case '×':
      m.chooseOperator(CalcOperator.multiply);
    case '÷':
      m.chooseOperator(CalcOperator.divide);
    default:
      m.digit(key);
  }
}

void trace(CalculatorModel m, String keys) {
  for (final key in keys.split(' ')) {
    tap(m, key);
  }
}

void main() {
  test('running total is left to right with intermediate displays', () {
    final m = CalculatorModel();
    final keys = ['2', '+', '3', '×', '4', '='];
    final expected = ['2', '2', '3', '5', '4', '20'];
    for (var i = 0; i < keys.length; i++) {
      tap(m, keys[i]);
      expect(
        m.displayText,
        expected[i],
        reason: 'after ${keys.take(i + 1).join(' ')}',
      );
    }
  });
  test('operator replacement uses the original accumulator', () {
    final m = CalculatorModel();
    trace(m, '9 + ×');
    expect(m.accumulator, 9);
    expect(m.pendingOperator, CalcOperator.multiply);
    trace(m, '2 =');
    expect(m.displayText, '18');
  });
  test('incomplete equals preserves pending operation and resumes', () {
    final m = CalculatorModel();
    trace(m, '7 + =');
    expect(m.displayText, '7');
    expect(m.pendingOperator, CalcOperator.add);
    expect(m.awaitingOperand, true);
    expect(m.error, isNull);
    trace(m, '2 =');
    expect(m.displayText, '9');
  });
  test('digit after equals starts fresh and repeated equals is inert', () {
    final m = CalculatorModel();
    trace(m, '2 + 3 = =');
    expect(m.displayText, '5');
    trace(m, '4');
    expect(m.displayText, '4');
    expect(m.accumulator, isNull);
    expect(m.resultCompleted, false);
    expect(m.pendingOperator, isNull);
  });
  test('all four operators chain with running totals', () {
    final m = CalculatorModel();
    trace(m, '1 2 + 6 −');
    expect(m.displayText, '18');
    trace(m, '3 ×');
    expect(m.displayText, '15');
    trace(m, '2 ÷');
    expect(m.displayText, '30');
    trace(m, '5 =');
    expect(m.displayText, '6');
  });
  test('multi digit and leading zero entry', () {
    final m = CalculatorModel();
    trace(m, '0 0 1 2 + 0 0 3 =');
    expect(m.displayText, '15');
  });
  test('fractional division and negative subtraction result', () {
    final m = CalculatorModel();
    trace(m, '7 ÷ 2 =');
    expect(m.displayText, '3.5');
    trace(m, 'AC 2 − 5 =');
    expect(m.displayText, '-3');
  });
  for (final setup in ['', '1 2', '8 +', '8 + 2', '8 + 2 =', '8 ÷ 0 =']) {
    test('AC clears every state field after [$setup]', () {
      final m = CalculatorModel();
      if (setup.isNotEmpty) trace(m, setup);
      m.clear();
      expect(m.displayText, '0');
      expect(m.accumulator, isNull);
      expect(m.currentOperand, '');
      expect(m.pendingOperator, isNull);
      expect(m.awaitingOperand, false);
      expect(m.resultCompleted, false);
      expect(m.error, isNull);
    });
  }
  test('AC stale accumulator after result', () {
    final m = CalculatorModel();
    trace(m, '8 + 2 = AC 3 + 4 =');
    expect(m.displayText, '7');
  });
  test('agent AC probes validate reset before operator or digit', () {
    for (final continuation in ['+ 5 =', '2 × 4 =']) {
      final m = CalculatorModel();
      trace(m, '5 + 3 =');
      expect(m.displayText, '8');
      m.equals();
      expect(m.displayText, '8');
      m.clear();
      expect(m.displayText, '0');
      expect(m.accumulator, isNull);
      expect(m.currentOperand, '');
      expect(m.pendingOperator, isNull);
      expect(m.awaitingOperand, false);
      expect(m.resultCompleted, false);
      expect(m.error, isNull);
      trace(m, continuation);
      expect(m.displayText, continuation.startsWith('+') ? '5' : '8');
    }
  });
  test('AC stale accumulator during chain', () {
    final m = CalculatorModel();
    trace(m, '8 + 2 × AC 4 + 1 =');
    expect(m.displayText, '5');
  });
  test('division by zero error ignores operators and recovers on digit', () {
    final m = CalculatorModel();
    trace(m, '8 ÷ 0 =');
    expect(m.error, contains('Cannot divide by zero'));
    expect(m.displayText, 'Error');
    trace(m, '+ =');
    expect(m.error, isNotNull);
    trace(m, '3 + 4 =');
    expect(m.displayText, '7');
    expect(m.error, isNull);
  });
  test('division by zero while chaining has the same recovery', () {
    final m = CalculatorModel();
    trace(m, '8 ÷ 0 ×');
    expect(m.error, isNotNull);
    trace(m, 'AC 2 + 2 =');
    expect(m.displayText, '4');
  });
  test('operator after result continues and initial operator uses zero', () {
    final m = CalculatorModel();
    trace(m, '+ 2 = × 3 =');
    expect(m.displayText, '6');
  });
  test('equals on standalone operand is ignored', () {
    final m = CalculatorModel();
    trace(m, '= 7 = 2');
    expect(m.displayText, '72');
  });
  test('input length error is explicit and recoverable', () {
    final m = CalculatorModel();
    for (var i = 0; i < 16; i++) {
      m.digit('9');
    }
    expect(m.error, contains('15 digits'));
    m.digit('2');
    expect(m.displayText, '2');
  });
  test('nonfinite result is guarded', () {
    final m = CalculatorModel();
    final large = List.filled(15, '9').join(' ');
    trace(m, '$large ×');
    for (var i = 0; i < 21 && m.error == null; i++) {
      trace(m, '$large ×');
    }
    expect(m.error, contains('out of range'));
    expect(m.accumulator, isNull);
    m.clear();
    expect(m.displayText, '0');
  });
  test('display rounding never replaces authoritative arithmetic', () {
    final m = CalculatorModel();
    trace(m, '1 ÷ 3 =');
    expect(m.displayText, '0.333333333333');
    trace(m, '× 3 =');
    expect(m.displayText, '1');
  });
}
