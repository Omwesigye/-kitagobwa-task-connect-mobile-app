import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    this.onTap,
    this.color,     // optional, can fallback to theme
    this.textColor, // optional, can fallback to theme
  });

  final String buttonText;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final bgColor = color ?? (theme.brightness == Brightness.dark ? Colors.white10 : Colors.white);
    final fgColor = textColor ?? (theme.brightness == Brightness.dark ? Colors.white : Colors.black);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(30.0),
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: const BorderRadius.only(topLeft: Radius.circular(50)),
        ),
        child: Text(
          buttonText,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontSize: 20.0,
            fontWeight: FontWeight.bold,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}
