import 'package:flutter/material.dart';
import 'update_manager.dart';

/// صفحة التحديث
class UpdateView extends StatefulWidget {
  final UpdateManager updateManager;
  final VoidCallback? onSkip;
  final VoidCallback? onInstallComplete;

  const UpdateView({
    Key? key,
    required this.updateManager,
    this.onSkip,
    this.onInstallComplete,
  }) : super(key: key);

  @override
  State<UpdateView> createState() => _UpdateViewState();
}

class _UpdateViewState extends State<UpdateView> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadedFilePath;
  String _statusMessage = '';

  @override
  void initState() {
    super.initState();
    widget.updateManager.isDownloading.addListener(_onDownloadStatusChanged);
    widget.updateManager.downloadProgress.addListener(_onProgressChanged);
  }

  @override
  void dispose() {
    widget.updateManager.isDownloading.removeListener(_onDownloadStatusChanged);
    widget.updateManager.downloadProgress.removeListener(_onProgressChanged);
    super.dispose();
  }

  void _onDownloadStatusChanged() {
    setState(() {
      _isDownloading = widget.updateManager.isDownloading.value;
    });
  }

  void _onProgressChanged() {
    setState(() {
      _downloadProgress = widget.updateManager.downloadProgress.value;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentVersion = widget.updateManager.currentVersion.value;
    final latestVersion = widget.updateManager.latestVersion.value;

    if (latestVersion == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('التحديثات')),
        body: const Center(child: Text('لا توجد معلومات عن التحديث')),
      );
    }

    final isRequired = latestVersion.required;
    // final changeLog = latestVersion.changeLog ?? 'تحديث جديد متاح';

    return Scaffold(
      appBar: AppBar(title: const Text('تحديث جديد متاح')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // أيقونة التحديث
            const Icon(Icons.system_update, size: 80, color: Colors.blue),
            const SizedBox(height: 24),

            // عنوان التحديث
            Text(
              'إصدار جديد متاح',
              style: Theme.of(context).textTheme.headlineMedium,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 16),

            // معلومات الإصدار
            Text(
              'الإصدار الحالي: $currentVersion\nالإصدار الجديد: ${latestVersion.version}',
              style: Theme.of(context).textTheme.bodyLarge,
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),

            // ملاحظات الإصدار
            if (latestVersion.changeLog != null)
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'ما الجديد',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 8),
                      Text(
                        latestVersion.changeLog!,
                        style: Theme.of(context).textTheme.bodyMedium,
                      ),
                    ],
                  ),
                ),
              ),
            const SizedBox(height: 24),

            // شريط التقدم
            if (_isDownloading)
              Column(
                children: [
                  LinearProgressIndicator(value: _downloadProgress),
                  const SizedBox(height: 8),
                  Text(
                    '${(_downloadProgress * 100).toStringAsFixed(0)}%',
                    textAlign: TextAlign.center,
                  ),
                ],
              ),

            if (_statusMessage.isNotEmpty)
              Padding(
                padding: const EdgeInsets.only(top: 8.0, bottom: 8.0),
                child: Text(
                  _statusMessage,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    color:
                        _statusMessage.contains('خطأ')
                            ? Colors.red
                            : Colors.green,
                  ),
                ),
              ),

            const SizedBox(height: 24),

            // أزرار الإجراءات
            if (_isDownloading)
              ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(backgroundColor: Colors.grey),
                child: const Text('إلغاء'),
              )
            else
              Column(
                children: [
                  if (_downloadedFilePath != null)
                    ElevatedButton.icon(
                      icon: const Icon(Icons.install_desktop),
                      label: const Text('تثبيت التحديث'),
                      onPressed: _installUpdate,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.green,
                      ),
                    )
                  else
                    ElevatedButton.icon(
                      icon: const Icon(Icons.download),
                      label: const Text('تنزيل وتثبيت'),
                      onPressed: _downloadUpdate,
                    ),
                  const SizedBox(height: 12),
                  if (!isRequired)
                    TextButton(
                      onPressed: () {
                        widget.updateManager.skipVersion();
                        if (widget.onSkip != null) {
                          widget.onSkip!();
                        }
                        Navigator.of(context).pop();
                      },
                      child: const Text('تخطي هذا الإصدار'),
                    ),
                  const SizedBox(height: 12),
                  if (latestVersion.notesUrl != null)
                    TextButton(
                      onPressed: () => widget.updateManager.openReleaseNotes(),
                      child: const Text('عرض ملاحظات الإصدار'),
                    ),
                ],
              ),
          ],
        ),
      ),
    );
  }

  /// تنزيل التحديث
  Future<void> _downloadUpdate() async {
    setState(() {
      _isDownloading = true;
      _statusMessage = '';
    });

    try {
      final filePath = await widget.updateManager.downloadUpdate();

      setState(() {
        _isDownloading = false;
        _downloadedFilePath = filePath;
        _statusMessage =
            filePath != null
                ? 'تم التنزيل بنجاح'
                : 'فشل التنزيل، يرجى المحاولة مرة أخرى';
      });
    } catch (e) {
      setState(() {
        _isDownloading = false;
        _statusMessage = 'حدث خطأ أثناء التنزيل: $e';
      });
    }
  }

  /// تثبيت التحديث
  Future<void> _installUpdate() async {
    if (_downloadedFilePath == null) return;

    setState(() {
      _statusMessage = 'جاري التثبيت...';
    });

    try {
      final success = await widget.updateManager.installUpdate(
        _downloadedFilePath!,
      );

      setState(() {
        _statusMessage =
            success
                ? 'تم بدء التثبيت'
                : 'فشل بدء التثبيت، يرجى المحاولة مرة أخرى';
      });

      if (success) {
        if (widget.onInstallComplete != null) {
          widget.onInstallComplete!();
        }
        Future.delayed(const Duration(seconds: 2), () {
          Navigator.of(context).pop(true);
        });
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ أثناء التثبيت: $e';
      });
    }
  }
}
