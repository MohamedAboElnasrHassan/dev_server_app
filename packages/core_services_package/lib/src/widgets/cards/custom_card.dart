import 'package:flutter/material.dart';

class CustomCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final double borderRadius;
  final double? elevation;
  final Color? backgroundColor;
  final VoidCallback? onTap;
  final bool hasShadow;
  final Border? border;

  const CustomCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
    this.margin = const EdgeInsets.all(0),
    this.borderRadius = 12,
    this.elevation,
    this.backgroundColor,
    this.onTap,
    this.hasShadow = true,
    this.border,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final cardColor =
        backgroundColor ??
        (isDarkMode ? Theme.of(context).cardColor : Colors.white);

    final cardElevation = elevation ?? (hasShadow ? 2.0 : 0.0);

    if (onTap != null) {
      return Padding(
        padding: margin,
        child: Material(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(borderRadius),
          elevation: cardElevation,
          child: InkWell(
            onTap: onTap,
            borderRadius: BorderRadius.circular(borderRadius),
            child: Ink(
              decoration: BoxDecoration(
                color: cardColor,
                borderRadius: BorderRadius.circular(borderRadius),
                border: border,
              ),
              child: Padding(padding: padding, child: child),
            ),
          ),
        ),
      );
    }

    return Padding(
      padding: margin,
      child: Material(
        color: cardColor,
        borderRadius: BorderRadius.circular(borderRadius),
        elevation: cardElevation,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(borderRadius),
            border: border,
          ),
          padding: padding,
          child: child,
        ),
      ),
    );
  }
}
