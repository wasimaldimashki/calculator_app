part of 'calculator_cubit.dart';

@immutable
class CalculatorState {
  final String expression;
  final String result;

  const CalculatorState({required this.expression, required this.result});

  factory CalculatorState.initial() =>
      const CalculatorState(expression: '', result: '0');

  CalculatorState copyWith({String? expression, String? result}) {
    return CalculatorState(
      expression: expression ?? this.expression,
      result: result ?? this.result,
    );
  }
}
