import 'package:flutter/material.dart';
class CustomElevatedButton extends StatelessWidget {
  final String text;
  final VoidCallback? onPressed;
  final bool isLoading;
  final bool isEnabled;
  final Gradient? gradient;
  final Color? backgroundColor;
  final Color? disabledColor;
  final Color textColor;
  final Color loadingIndicatorColor;
  final TextStyle? textStyle;

  const CustomElevatedButton({
    super.key,
    required this.text,
    this.onPressed,
    this.isLoading = false,
    this.isEnabled = true,
    this.gradient,
    this.backgroundColor,
    this.disabledColor = Colors.grey,
    this.textColor = Colors.white,
    this.loadingIndicatorColor = Colors.white,
    this.textStyle,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: isEnabled ? gradient : null,
        color: (gradient == null ? backgroundColor : null),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          padding: const EdgeInsets.all(10),
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: isEnabled && !isLoading ? onPressed : null,
        child: isLoading
            ? CircularProgressIndicator(color: loadingIndicatorColor)
            : Text(
                text,
                style: textStyle ??
                    TextStyle(color: textColor, fontWeight: FontWeight.bold),
              ),
      ),
    );
  }
}
