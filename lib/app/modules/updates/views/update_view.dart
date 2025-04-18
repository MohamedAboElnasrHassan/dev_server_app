import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../../core/widgets/buttons/custom_button.dart';
import '../controllers/update_controller.dart';

class UpdateView extends GetView<UpdateController> {
  const UpdateView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('update_available'.tr),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // أيقونة التحديث
            const Icon(
              Icons.system_update,
              size: 80,
              color: Colors.blue,
            ),
            const SizedBox(height: 24),

            // عنوان التحديث
            Text(
              'new_version_available'.tr,
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // معلومات الإصدار
            Obx(() => Text(
              '${'current_version'.tr}: ${controller.currentVersion.value}\n${'latest_version'.tr}: ${controller.updateManager.latestVersion.value?.version ?? ''}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            )),
            const SizedBox(height: 24),

            // ملاحظات الإصدار
            if (controller.updateManager.latestVersion.value?.changeLog != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'whats_new'.tr,
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        controller.updateManager.latestVersion.value!.changeLog!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // شريط التقدم
            Obx(() {
              if (controller.isDownloading.value) {
                return Column(
                  children: [
                    LinearProgressIndicator(
                      value: controller.downloadProgress.value,
                    ),
                    const SizedBox(height: 8),
                    Text(
                      '${(controller.downloadProgress.value * 100).toStringAsFixed(0)}%',
                      textAlign: TextAlign.center,
                    ),
                  ],
                );
              }
              return const SizedBox.shrink();
            }),
            const SizedBox(height: 24),

            // أزرار الإجراءات
            Obx(() {
              if (controller.isDownloading.value) {
                return CustomButton(
                  text: 'cancel'.tr,
                  onPressed: () => Get.back(),
                  type: ButtonType.secondary,
                );
              }

              return Column(
                children: [
                  CustomButton(
                    text: 'download_and_install'.tr,
                    onPressed: controller.downloadAndInstallUpdate,
                    icon: Icons.download,
                    isFullWidth: true,
                  ),
                  const SizedBox(height: 12),
                  if (!controller.updateRequired.value)
                    CustomButton(
                      text: 'skip_this_version'.tr,
                      onPressed: controller.skipVersion,
                      type: ButtonType.secondary,
                      isFullWidth: true,
                    ),
                  const SizedBox(height: 12),
                  CustomButton(
                    text: 'view_release_notes'.tr,
                    onPressed: controller.openReleaseNotes,
                    type: ButtonType.text,
                    isFullWidth: true,
                  ),
                ],
              );
            }),
          ],
        ),
      ),
    );
  }
}
