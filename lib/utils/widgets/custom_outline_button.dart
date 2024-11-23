import 'package:flutter/material.dart';

class CustomOutlinedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Color borderColor;
  final Color disabledBorderColor;
  final Color textColor;
  final Color disabledTextColor;
  final double borderWidth;
  final Color loadingIndicatorColor;
  final TextStyle? textStyle;

  const CustomOutlinedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.borderColor = Colors.blue,
    this.disabledBorderColor = Colors.grey,
    this.textColor = Colors.blue,
    this.disabledTextColor = Colors.grey,
    this.borderWidth = 2.0,
    this.loadingIndicatorColor = Colors.blue,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        side: BorderSide(
          color: isEnabled ? borderColor : disabledBorderColor,
          width: borderWidth,
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
      onPressed: isEnabled && !isLoading ? onPressed : null,
      child: isLoading
          ? CircularProgressIndicator(color: loadingIndicatorColor)
          : Text(
              text,
              style: textStyle ??
                  TextStyle(
                    color: isEnabled ? textColor : disabledTextColor,
                    fontWeight: FontWeight.bold,
                  ),
            ),
    );
  }
}

RadialGradient radialGradient = RadialGradient(
  center: const Alignment(
      0.002, 0.5), // 0.2% -> 0.002 (normalized), 0.5 stays the same
  radius: 1.0, // Covers farthest-corner
  colors: [
    Color.fromRGBO(68, 36, 164, 1), // rgba(68,36,164,1)
    Color.fromRGBO(84, 212, 228, 1), // rgba(84,212,228,1)
  ],
  stops: [0.037, 0.927], // 3.7% -> 0.037, 92.7% -> 0.927
);
