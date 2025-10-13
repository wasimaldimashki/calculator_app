import 'package:calculator_app/calc/cubit/calculator_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// CalculatorScreen is a StatelessWidget that relies on BlocBuilder to react to state changes.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  // Defines the layout of the calculator buttons (excluding the final row for 0, ., =).
  final List<List<String>> buttonLayout = const [
    ['C', 'remove', '(', ')', '÷'],
    ['7', '8', '9', '×', '+/-'],
    ['4', '5', '6', '-', '%'],
    ['1', '2', '3', '+', '='],
  ];

  @override
  Widget build(BuildContext context) {
    // Access the Cubit instance provided higher up in the widget tree.
    final cubit = BlocProvider.of<CalculatorCubit>(context);

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          // 1. Display Area (shows expression and result)
          _buildDisplay(context),

          // 2. Build rows from the predefined buttonLayout list
          ...buttonLayout
              .map((row) => _buildButtonRow(context, cubit, row))
              .toList(),

          // 3. Special last row (for buttons that might need custom sizing like '0' and '=')
          _buildLastRow(context, cubit),
        ],
      ),
    );
  }

  /// Builds the top display area, which updates based on the CalculatorCubit state.
  Widget _buildDisplay(BuildContext context) {
    // BlocBuilder rebuilds only this widget when the CalculatorState changes.
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return Expanded(
          flex: 2, // Gives the display area double the height of a button row
          child: Container(
            alignment: Alignment.bottomRight,
            // Use ScreenUtil for responsive padding
            padding: EdgeInsets.symmetric(horizontal: 24.w, vertical: 12.h),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                // Current Expression (smaller font, displayed above the result)
                Text(
                  state.expression.isEmpty ? ' ' : state.expression,
                  style: TextStyle(fontSize: 24.sp, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                // Calculated Result (larger font, main output)
                Text(
                  state.result,
                  style: TextStyle(
                    fontSize: 48.sp,
                    fontWeight: FontWeight.w300,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  /// Builds a single row of buttons using a horizontal Row layout.
  Widget _buildButtonRow(
    BuildContext context,
    CalculatorCubit cubit,
    List<String> buttonTexts,
  ) {
    return Expanded(
      child: Row(
        crossAxisAlignment:
            CrossAxisAlignment.stretch, // Makes buttons fill height
        children: buttonTexts
            .map((text) => _buildButton(context, cubit, text))
            .toList(),
      ),
    );
  }

  /// Builds the final row, giving '0' extra width (flex: 2).
  Widget _buildLastRow(BuildContext context, CalculatorCubit cubit) {
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          _buildButton(context, cubit, '0', flex: 2), // '0' takes up 2 columns
          _buildButton(context, cubit, '.', flex: 1),
          _buildButton(context, cubit, '=', flex: 1),
        ],
      ),
    );
  }

  /// Builds a single calculator button with styling and click handler.
  Widget _buildButton(
    BuildContext context,
    CalculatorCubit cubit,
    String buttonText, {
    int flex = 1, // Allows certain buttons (like '0') to span multiple columns
  }) {
    Color buttonColor;
    const Color textColor = Colors.white;

    // Define color based on button function
    if (['÷', '×', '-', '+', '='].contains(buttonText)) {
      buttonColor = Colors.orange[800]!; // Operation buttons (Orange)
    } else if (['C', 'remove', '(', ')', '+/-', '%'].contains(buttonText)) {
      buttonColor = Colors.grey[700]!; // Utility buttons (Light Grey)
    } else {
      buttonColor = Colors.grey[900]!; // Number and decimal buttons (Dark Grey)
    }

    // Determine the button content (Text or Icon)
    Widget buttonChild = (buttonText == 'remove')
        ? const Icon(Icons.backspace_outlined, color: Colors.white, size: 24)
        : Text(
            buttonText,
            style: TextStyle(
              fontSize: 28.sp,
              fontWeight: FontWeight.normal,
              color: textColor,
            ),
          );

    // Handle empty placeholder buttons (if any are used in the layout)
    if (buttonText.isEmpty) {
      return Expanded(flex: flex, child: Container());
    }

    return Expanded(
      flex: flex,
      child: Padding(
        padding: EdgeInsets.all(4.sp),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            elevation: 0,
            // Circular shape for the buttons
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50.r),
            ),
            padding: EdgeInsets.zero,
          ),
          // Call the cubit's input function on press
          onPressed: () => cubit.input(buttonText),
          child: buttonChild,
        ),
      ),
    );
  }
}
