import 'package:flutter/material.dart';

class WelcomeButton extends StatelessWidget {
  const WelcomeButton({
    super.key,
    required this.buttonText,
    this.onTap,
    this.color,
    this.textColor,
  });

  final String buttonText;
  final VoidCallback? onTap;
  final Color? color;
  final Color? textColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    final bgColor =
        color ??
        (theme.brightness == Brightness.dark ? Colors.white10 : Colors.white);
    final fgColor =
        textColor ??
        (theme.brightness == Brightness.dark ? Colors.white : Colors.black);

    return GestureDetector(
      onTap: onTap,
      child: Container(
        height: 52, // << Medium button height
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: bgColor,
          borderRadius: BorderRadius.circular(30), // << Fully rounded (pill)
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 6,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Text(
          buttonText,
          style: TextStyle(
            fontSize: 17,
            fontWeight: FontWeight.w600,
            color: fgColor,
          ),
        ),
      ),
    );
  }
}
