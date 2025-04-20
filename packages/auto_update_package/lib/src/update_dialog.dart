import 'package:flutter/material.dart';
import 'update_manager.dart';
import 'version_model.dart';

/// حوار التحديث
class UpdateDialog extends StatefulWidget {
  final UpdateManager updateManager;
  final VersionInfo updateInfo;
  final VoidCallback? onSkip;
  final VoidCallback? onInstallComplete;
  
  const UpdateDialog({
    Key? key,
    required this.updateManager,
    required this.updateInfo,
    this.onSkip,
    this.onInstallComplete,
  }) : super(key: key);
  
  @override
  State<UpdateDialog> createState() => _UpdateDialogState();
}

class _UpdateDialogState extends State<UpdateDialog> {
  bool _isDownloading = false;
  double _downloadProgress = 0.0;
  String? _downloadedFilePath;
  String _statusMessage = '';
  
  @override
  void initState() {
    super.initState();
    
    // Listen to download progress
    widget.updateManager.downloadProgress.addListener(_onDownloadProgressChanged);
    widget.updateManager.isDownloading.addListener(_onDownloadStatusChanged);
  }
  
  @override
  void dispose() {
    widget.updateManager.downloadProgress.removeListener(_onDownloadProgressChanged);
    widget.updateManager.isDownloading.removeListener(_onDownloadStatusChanged);
    super.dispose();
  }
  
  void _onDownloadProgressChanged() {
    setState(() {
      _downloadProgress = widget.updateManager.downloadProgress.value;
    });
  }
  
  void _onDownloadStatusChanged() {
    setState(() {
      _isDownloading = widget.updateManager.isDownloading.value;
    });
  }
  
  @override
  Widget build(BuildContext context) {
    final currentVersion = widget.updateManager.currentVersion.value;
    final latestVersion = widget.updateInfo.version;
    final isRequired = widget.updateInfo.required;
    final changeLog = widget.updateInfo.changeLog ?? 'تحديث جديد متاح';
    
    return AlertDialog(
      title: Text('تحديث جديد متاح'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإصدار الحالي: $currentVersion'),
          Text('الإصدار الجديد: $latestVersion'),
          SizedBox(height: 8),
          Text(changeLog),
          SizedBox(height: 16),
          if (_isDownloading && _downloadedFilePath == null)
            Column(
              children: [
                LinearProgressIndicator(value: _downloadProgress),
                SizedBox(height: 8),
                Text('جاري التنزيل... ${(_downloadProgress * 100).toStringAsFixed(0)}%'),
              ],
            ),
          if (_statusMessage.isNotEmpty)
            Padding(
              padding: const EdgeInsets.only(top: 8.0),
              child: Text(_statusMessage),
            ),
        ],
      ),
      actions: [
        if (!isRequired)
          TextButton(
            onPressed: () {
              widget.updateManager.skipVersion();
              if (widget.onSkip != null) {
                widget.onSkip!();
              }
              Navigator.of(context).pop();
            },
            child: Text('تخطي'),
          ),
        if (_downloadedFilePath != null)
          ElevatedButton(
            onPressed: _installUpdate,
            child: Text('تثبيت'),
          )
        else if (!_isDownloading)
          ElevatedButton(
            onPressed: _downloadUpdate,
            child: Text('تنزيل'),
          ),
      ],
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
        _statusMessage = filePath != null
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
      final success = await widget.updateManager.installUpdate(_downloadedFilePath!);
      
      setState(() {
        _statusMessage = success
            ? 'تم بدء التثبيت'
            : 'فشل بدء التثبيت، يرجى المحاولة مرة أخرى';
      });
      
      if (success) {
        if (widget.onInstallComplete != null) {
          widget.onInstallComplete!();
        }
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ أثناء التثبيت: $e';
      });
    }
  }
}
