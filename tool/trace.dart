import 'dart:convert';
import 'dart:io';

import 'package:calculator_app/calculator_model.dart';

void main() {
  final cases = [
    '5 + + 3 =',
    '5 + 3 = =',
    '5 + 3 AC',
    '5 + 3 = AC + 5 =',
    '5 + 3 = AC 2 × 4 =',
    '2 + 3 × 4 =',
    '9 + × 2 =',
    '7 + = 2 =',
    '2 + 3 = = 4',
    '1 2 + 6 − 3 × 2 ÷ 5 =',
    '0 0 1 2 + 0 0 3 =',
    '7 ÷ 2 =',
    '8 + 2 = AC 3 + 4 =',
    '8 + 2 × AC 4 + 1 =',
    '8 ÷ 0 = 3 + 4 =',
    '8 ÷ 0 = AC',
    '1 2 + 3 × 4 =',
  ];
  final output = <Map<String, dynamic>>[];
  for (final sequence in cases) {
    final m = CalculatorModel();
    final states = <Map<String, dynamic>>[];
    for (final key in sequence.split(' ')) {
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
      states.add({
        'key': key,
        'display': m.displayText,
        'accumulator': m.accumulator,
        'operand': m.currentOperand,
        'pending': m.pendingOperator?.symbol,
        'awaiting': m.awaitingOperand,
        'result': m.resultCompleted,
        'error': m.error,
      });
    }
    output.add({'sequence': sequence, 'states': states});
  }
  stdout.writeln(const JsonEncoder.withIndent('  ').convert(output));
}
