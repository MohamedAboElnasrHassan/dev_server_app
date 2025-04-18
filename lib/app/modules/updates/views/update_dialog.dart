import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/update_controller.dart';

/// حوار التحديث
class UpdateDialog extends StatelessWidget {
  final UpdateController controller;
  final bool required;

  const UpdateDialog({
    super.key,
    required this.controller,
    this.required = false,
  });

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('update_available'.tr),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(required ? 'update_required_message'.tr : 'update_available_message'.tr),
          const SizedBox(height: 8),
          Text(
            '${'current_version'.tr}: ${controller.currentVersion.value}\n${'latest_version'.tr}: ${controller.updateManager.latestVersion.value?.version ?? ''}',
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
        ],
      ),
      actions: [
        if (!required)
          TextButton(
            onPressed: () {
              if (!required) {
                controller.skipVersion();
              } else {
                Get.back();
              }
            },
            child: Text('skip'.tr),
          ),
        TextButton(
          onPressed: () => Get.back(),
          child: Text('later'.tr),
        ),
        ElevatedButton(
          onPressed: () {
            Get.back();
            Get.toNamed('/update');
          },
          child: Text('update_now'.tr),
        ),
      ],
    );
  }

  /// عرض حوار التحديث
  static void show({bool required = false}) {
    // التحقق من وجود المتحكم
    if (!Get.isRegistered<UpdateController>()) {
      Get.lazyPut(() => UpdateController());
    }

    final controller = Get.find<UpdateController>();

    Get.dialog(
      UpdateDialog(
        controller: controller,
        required: required,
      ),
      barrierDismissible: !required,
    );
  }
}
