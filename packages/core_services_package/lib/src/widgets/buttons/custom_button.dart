import 'package:flutter/material.dart';
import '../../values/app_colors.dart';

enum ButtonType { primary, secondary, text }

class CustomButton extends StatelessWidget {
  final String text;
  final VoidCallback onPressed;
  final ButtonType type;
  final bool isLoading;
  final bool isFullWidth;
  final IconData? icon;
  final double? width;
  final double height;
  final double borderRadius;

  const CustomButton({
    super.key,
    required this.text,
    required this.onPressed,
    this.type = ButtonType.primary,
    this.isLoading = false,
    this.isFullWidth = false,
    this.icon,
    this.width,
    this.height = 48,
    this.borderRadius = 8,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;

    // Define colors based on theme and button type
    final Color backgroundColor;
    final Color textColor;
    final Color borderColor;

    switch (type) {
      case ButtonType.primary:
        backgroundColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
        textColor = Colors.white;
        borderColor = backgroundColor;
        break;
      case ButtonType.secondary:
        backgroundColor = Colors.transparent;
        textColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
        borderColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
        break;
      case ButtonType.text:
        backgroundColor = Colors.transparent;
        textColor = isDarkMode ? AppColors.darkPrimary : AppColors.lightPrimary;
        borderColor = Colors.transparent;
        break;
    }

    // Create button content
    Widget buttonContent;
    if (isLoading) {
      buttonContent = SizedBox(
        height: 24,
        width: 24,
        child: CircularProgressIndicator(
          strokeWidth: 2,
          valueColor: AlwaysStoppedAnimation<Color>(textColor),
        ),
      );
    } else if (icon != null) {
      buttonContent = Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, color: textColor, size: 20),
          const SizedBox(width: 8),
          Text(
            text,
            style: TextStyle(
              color: textColor,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      );
    } else {
      buttonContent = Text(
        text,
        style: TextStyle(
          color: textColor,
          fontWeight: FontWeight.bold,
          fontSize: 16,
        ),
      );
    }

    // Create button container
    return Container(
      width: isFullWidth ? double.infinity : width,
      height: height,
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(borderRadius),
        border: Border.all(
          color: borderColor,
          width: type == ButtonType.secondary ? 2 : 0,
        ),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isLoading ? null : onPressed,
          borderRadius: BorderRadius.circular(borderRadius),
          child: Center(child: buttonContent),
        ),
      ),
    );
  }
}
