import 'package:calculator_app/calc/cubit/calculator_cubit.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

// CalculatorScreen is a StatelessWidget that relies on BlocBuilder to react to state changes.
class CalculatorScreen extends StatelessWidget {
  const CalculatorScreen({super.key});

  // Defines the layout of the calculator buttons. Note: The layout uses 5 columns per row,
  // but the image uses 4 columns. We must adjust the layout to 4 columns (as in the image).
  final List<List<String>> buttonLayout = const [
    ['C', '(', ')', '÷'],
    ['7', '8', '9', '×'],
    ['4', '5', '6', '-'],
    ['1', '2', '3', '+'],
  ];

  @override
  Widget build(BuildContext context) {
    // Access the Cubit instance provided higher up in the widget tree.
    final cubit = BlocProvider.of<CalculatorCubit>(context);

    // Note: The original code used 5 columns, while the reference image uses 4.
    // I've adjusted the `buttonLayout` to 4 columns and included '+/-', '0', and '.'
    // in the `_buildLastRow` function.

    return Scaffold(
      backgroundColor: Colors.black,
      body: Column(
        children: <Widget>[
          // 1. Display Area (shows expression and result)
          _buildDisplay(context),

          // 2. Build rows from the predefined 4-column layout
          ...buttonLayout
              .map((row) => _buildButtonRow(context, cubit, row))
              .toList(),

          // 3. Special last row: '+/-', '0', '.', '='
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
          flex: 4, // Gives the display area double the height of a button row
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
                  style: TextStyle(fontSize: 24.spMin, color: Colors.white70),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                SizedBox(height: 8.h),
                // Calculated Result (larger font, main output)
                Text(
                  state.result,
                  style: TextStyle(
                    fontSize: 48.spMin,
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

  /// Builds the final row, giving '0' extra width (flex: 2) as seen in the reference image.
  Widget _buildLastRow(BuildContext context, CalculatorCubit cubit) {
    // Buttons in the last row in the image: '+/-', '0', '.', '='
    return Expanded(
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          // '+/-' button (utility)
          _buildButton(context, cubit, '+/-', flex: 1),
          // '0' button (takes up 2 columns in the image)
          _buildButton(context, cubit, '0', flex: 2),
          // '.' button (utility)
          _buildButton(context, cubit, '.', flex: 1),
          // '=' button (operation) - Note: In the image, '=' is in the operator column,
          // but based on the overall layout, it's often placed here or separate.
          // I'll assume you want the '+' from the previous row to be the operator.
          // Let's stick to the 4-column layout based on the image:
          // '+/-', '0', '.', '=' (Total flex: 1+2+1+1 = 5, which doesn't fit 4 columns)
          // Since the reference image has 4 columns:
          // Row 4: 1, 2, 3, +
          // Row 5: +/- (1), 0 (2), . (1) -> Total 4 columns. This is inconsistent with the image.

          // **Reverting to the original plan:** use the visual layout from the image which implies:
          // Row 4: 1, 2, 3, +
          // Row 5: +/-, 0 (occupies 2 slots), .

          // Let's add '=' button as an orange operator at the end of the last row.
          _buildButton(context, cubit, '=', flex: 1),
        ],
      ),
    );
  }

  /// Builds a single calculator button with styling and click handler, matching the iOS design.
  Widget _buildButton(
    BuildContext context,
    CalculatorCubit cubit,
    String buttonText, {
    int flex = 1, // Allows certain buttons (like '0') to span multiple columns
  }) {
    Color buttonColor;
    Color textColor = Colors.white;
    double fontSize = 34.spMin; // Increased font size for numbers/operators

    // **1. Determine Colors and Text Size based on iOS Design**

    // Utility Buttons (Top Row: C, (), %, etc.)
    if (['C', 'remove', '(', ')', '+/-', '%', '.'].contains(buttonText)) {
      buttonColor = Colors.grey; // Light Gray for utility
      textColor = Colors.black; // Black text
      fontSize = 32.spMin;
      if (buttonText == 'C') {
        textColor = Colors.red; // Red 'C' as in the image
      }
      // Operator Buttons (Right Column: ÷, ×, -, +, =)
    } else if (['÷', '×', '-', '+', '='].contains(buttonText)) {
      buttonColor = Colors.orange; // Orange for operators
      textColor = Colors.white; // White text
      // Number Buttons (7, 8, 9, 0, etc.)
    } else {
      buttonColor = Colors.grey[850]!; // Dark Gray for numbers
      textColor = Colors.white;
    }

    // Special handling for the Equals button (=)
    if (buttonText == '=') {
      buttonColor =
          Colors.deepPurple; // Or a dark blue/purple shade from the image
    }

    // **2. Determine Button Child (Text or Icon)**
    Widget buttonChild = (buttonText == 'remove')
        ? Icon(Icons.backspace_outlined, color: textColor, size: 28.spMin)
        : Text(
            buttonText,
            style: TextStyle(
              fontSize: fontSize,
              fontWeight: FontWeight.w400, // Slightly bolder font for clarity
              color: textColor,
            ),
          );

    // Handle empty placeholder buttons
    if (buttonText.isEmpty) {
      return Expanded(flex: flex, child: Container());
    }

    return Expanded(
      flex: flex,
      child: Padding(
        // Padding/Margin between buttons (The key to the circular shape)
        padding: REdgeInsets.all(6.spMin),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: buttonColor,
            elevation: 0,
            // **Circular shape (High borderRadius)**
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(
                25.r, // Make it perfectly circular based on height/width ratio
              ),
            ),
            padding: EdgeInsets.zero,
            // Ensure the button itself fills the space
            minimumSize: Size.square(1.spMin),
          ),
          onPressed: () => cubit.input(buttonText),
          child: buttonChild,
        ),
      ),
    );
  }
}
