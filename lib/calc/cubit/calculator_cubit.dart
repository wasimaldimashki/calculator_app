import 'package:bloc/bloc.dart';
import 'package:meta/meta.dart';
import "package:function_tree/function_tree.dart";

part 'calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  // Initialize the state with empty expression and result '0'.
  CalculatorCubit() : super(CalculatorState.initial());

  /// Handles all button presses and routes them to the appropriate function.
  void input(String buttonText) {
    String currentExpression = state.expression;

    // --- Special Buttons Handling ---

    // Clear button
    if (buttonText == 'C') {
      clear();
      return;
    }

    // Backspace/Remove last character button
    if (buttonText == 'remove') {
      backspace();
      return;
    }

    // Toggle sign button
    if (buttonText == '+/-') {
      toggleSign();
      return;
    }

    // Calculate/Equals button
    if (buttonText == '=') {
      calculate();
      return;
    }

    // --- Normal Input Handling (Numbers, Operators, Parentheses) ---

    // Replace UI symbols (×, ÷) with Dart-compatible symbols (*, /)
    String charForCalc = buttonText.replaceAll('×', '*').replaceAll('÷', '/');

    // Simple logic to prevent common errors (e.g., repeating operators)
    if (currentExpression.isNotEmpty &&
        ['*', '/', '+', '-'].contains(charForCalc)) {
      String lastChar = currentExpression.substring(
        currentExpression.length - 1,
      );
      if (['*', '/', '+', '-'].contains(lastChar)) {
        // Replace the last operator instead of appending a new one
        currentExpression = currentExpression.substring(
          0,
          currentExpression.length - 1,
        );
      }
    }

    // Build the new full expression string
    String newExpression = currentExpression + charForCalc;

    // Update the state
    emit(
      state.copyWith(
        expression: newExpression,
        // Display the full expression as the user types
        result: newExpression.isEmpty ? '0' : newExpression,
      ),
    );
  }

  /// Clears the entire expression and resets the state.
  void clear() {
    emit(CalculatorState.initial());
  }

  /// Removes the last character from the expression (Backspace).
  void backspace() {
    String exp = state.expression;
    if (exp.isNotEmpty) {
      String newExp = exp.substring(0, exp.length - 1);
      emit(
        state.copyWith(
          expression: newExp,
          result: newExp.isEmpty ? '0' : newExp,
        ),
      );
    } else {
      emit(CalculatorState.initial());
    }
  }

  /// Toggles the sign of the entire current expression by wrapping it in '(-...)'
  void toggleSign() {
    String exp = state.expression;

    // If the expression is already wrapped in negative parentheses, remove them
    if (exp.startsWith('(-') && exp.endsWith(')')) {
      exp = exp.substring(2, exp.length - 1);
    } else {
      // Wrap the current expression in negative parentheses
      exp = '(-$exp)';
    }

    emit(state.copyWith(expression: exp, result: exp));
  }

  /// Calculates the final result of the expression string using `function_tree`.
  void calculate() {
    String finalExpression = state.expression;

    // Prevent calculation if the expression is empty
    if (finalExpression.isEmpty) {
      emit(state.copyWith(result: '0', expression: ''));
      return;
    }

    // Optional: Remove trailing open parentheses to prevent crash on incomplete input
    while (finalExpression.endsWith('(')) {
      finalExpression = finalExpression.substring(
        0,
        finalExpression.length - 1,
      );
    }

    try {
      // 💡 Key step: Use the .interpret() extension method from function_tree
      // to evaluate the full string expression, including parentheses and operator precedence.
      num result = finalExpression.interpret();

      // Output formatting (removes .0, handles long decimals)
      String evaluatedResult = _formatResult(result);

      emit(
        state.copyWith(
          result: evaluatedResult,
          // Set the result as the new expression for subsequent operations
          expression: evaluatedResult,
        ),
      );
    } catch (e) {
      // Handle parsing errors or division by zero
      emit(state.copyWith(result: 'Error', expression: ''));
    }
  }

  /// Helper function to format the calculation result.
  String _formatResult(dynamic result) {
    if (result.isInfinite || result.isNaN) {
      return 'Error';
    }

    // Check if the number is an integer to display without trailing '.0'
    if (result == result.roundToDouble()) {
      return result.toInt().toString();
    }

    // Rounding and trimming unnecessary zeros for decimal numbers
    return result.toStringAsFixed(8).replaceAll(RegExp(r'\.?0+$'), '');
  }
}
