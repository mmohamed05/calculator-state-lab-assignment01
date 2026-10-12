/// A left-to-right calculator. The display is derived, never independently set.
enum CalcOperator {
  add('+', 'Add'),
  subtract('−', 'Subtract'),
  multiply('×', 'Multiply'),
  divide('÷', 'Divide');

  const CalcOperator(this.symbol, this.label);
  final String symbol;
  final String label;
}

class CalculatorModel {
  double? _accumulator;
  String _currentOperand = '';
  CalcOperator? _pendingOperator;
  bool _awaitingOperand = false;
  bool _resultCompleted = false;
  String? _error;

  double? get accumulator => _accumulator;
  String get currentOperand => _currentOperand;
  CalcOperator? get pendingOperator => _pendingOperator;
  bool get awaitingOperand => _awaitingOperand;
  bool get resultCompleted => _resultCompleted;
  String? get error => _error;

  String get displayText {
    if (_error != null) return 'Error';
    if (_currentOperand.isNotEmpty) return _currentOperand;
    return formatNumber(_accumulator ?? 0);
  }

  String get contextText {
    if (_error != null) return _error!;
    if (_pendingOperator != null) {
      final prefix =
          '${formatNumber(_accumulator!)} ${_pendingOperator!.symbol}';
      return _awaitingOperand ? '$prefix — enter a number' : prefix;
    }
    return _resultCompleted ? 'Result' : 'Enter a number';
  }

  /// Twelve significant display digits; arithmetic retains the full double.
  static String formatNumber(double value) {
    if (value == 0) return '0';
    final parts = value.toStringAsPrecision(12).split('e');
    var mantissa = parts.first;
    if (mantissa.contains('.')) {
      mantissa = mantissa.replaceFirst(RegExp(r'0+$'), '');
      mantissa = mantissa.replaceFirst(RegExp(r'\.$'), '');
    }
    return parts.length == 1 ? mantissa : '${mantissa}e${parts.last}';
  }

  void digit(String digit) {
    if (!RegExp(r'^\d$').hasMatch(digit)) {
      throw ArgumentError.value(digit, 'digit', 'Expected one digit');
    }
    if (_error != null || _resultCompleted) clear();
    if (_awaitingOperand) {
      _currentOperand = '';
      _awaitingOperand = false;
    }
    final next = _currentOperand == '0' ? digit : '$_currentOperand$digit';
    // Explicit error rather than silently dropping input or losing integer precision.
    if (next.length > 15) {
      _fail('Use at most 15 digits. Enter a digit or tap AC to restart.');
      return;
    }
    _currentOperand = next;
  }

  void chooseOperator(CalcOperator operator) {
    if (_error != null) return;
    if (_pendingOperator != null && !_awaitingOperand) {
      if (!_applyPending()) return;
    } else if (_pendingOperator == null) {
      _accumulator = _currentOperand.isNotEmpty
          ? double.parse(_currentOperand)
          : (_accumulator ?? 0);
    }
    _pendingOperator = operator;
    _currentOperand = '';
    _awaitingOperand = true;
    _resultCompleted = false;
  }

  void equals() {
    // Incomplete and repeated equals preserve all calculation state.
    if (_error != null || _pendingOperator == null || _awaitingOperand) return;
    if (!_applyPending()) return;
    _pendingOperator = null;
    _currentOperand = '';
    _awaitingOperand = false;
    _resultCompleted = true;
  }

  bool _applyPending() {
    final right = double.parse(_currentOperand);
    if (_pendingOperator == CalcOperator.divide && right == 0) {
      _fail('Cannot divide by zero. Enter a digit or tap AC to restart.');
      return false;
    }
    final left = _accumulator!;
    final result = switch (_pendingOperator!) {
      CalcOperator.add => left + right,
      CalcOperator.subtract => left - right,
      CalcOperator.multiply => left * right,
      CalcOperator.divide => left / right,
    };
    if (!result.isFinite) {
      _fail('Result is out of range. Enter a digit or tap AC to restart.');
      return false;
    }
    _accumulator = result;
    return true;
  }

  void _fail(String message) {
    clear();
    _error = message;
  }

  void clear() {
    _accumulator = null;
    _currentOperand = '';
    _pendingOperator = null;
    _awaitingOperand = false;
    _resultCompleted = false;
    _error = null;
  }
}
