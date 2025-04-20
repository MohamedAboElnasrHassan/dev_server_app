import 'package:flutter/material.dart';
import 'package:get/get.dart';

/// Diálogo personalizado
class CustomDialog extends StatelessWidget {
  final String title;
  final String message;
  final String confirmText;
  final String? cancelText;
  final VoidCallback? onConfirm;
  final VoidCallback? onCancel;
  final Widget? content;
  final bool barrierDismissible;

  const CustomDialog({
    super.key,
    required this.title,
    required this.message,
    this.confirmText = 'OK',
    this.cancelText,
    this.onConfirm,
    this.onCancel,
    this.content,
    this.barrierDismissible = true,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(title),
      content: content ?? Text(message),
      actions: [
        if (cancelText != null)
          TextButton(
            onPressed: onCancel ?? () => Get.back(result: false),
            child: Text(cancelText!),
          ),
        TextButton(
          onPressed: onConfirm ?? () => Get.back(result: true),
          child: Text(confirmText),
        ),
      ],
    );
  }

  /// Mostrar el diálogo
  static Future<bool?> show({
    required String title,
    required String message,
    String confirmText = 'OK',
    String? cancelText,
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
    Widget? content,
    bool barrierDismissible = true,
  }) {
    return Get.dialog<bool>(
      CustomDialog(
        title: title,
        message: message,
        confirmText: confirmText,
        cancelText: cancelText,
        onConfirm: onConfirm,
        onCancel: onCancel,
        content: content,
      ),
      barrierDismissible: barrierDismissible,
    );
  }
}
