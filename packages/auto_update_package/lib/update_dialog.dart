import 'package:flutter/material.dart';
import 'update_service.dart';

/// حوار التحديث
class UpdateDialog extends StatefulWidget {
  final UpdateInfo updateInfo;
  final UpdateService updateService;
  
  const UpdateDialog({
    Key? key,
    required this.updateInfo,
    required this.updateService,
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
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text('تحديث جديد متاح'),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('الإصدار الحالي: ${widget.updateInfo.currentVersion}'),
          Text('الإصدار الجديد: ${widget.updateInfo.latestVersion}'),
          SizedBox(height: 8),
          Text(widget.updateInfo.releaseNotes),
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
        if (!widget.updateInfo.isRequired)
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
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
      final filePath = await widget.updateService.downloadUpdate(widget.updateInfo);
      
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
      final success = await widget.updateService.installUpdate(_downloadedFilePath!);
      
      setState(() {
        _statusMessage = success
            ? 'تم بدء التثبيت'
            : 'فشل بدء التثبيت، يرجى المحاولة مرة أخرى';
      });
      
      if (success) {
        Navigator.of(context).pop(true);
      }
    } catch (e) {
      setState(() {
        _statusMessage = 'حدث خطأ أثناء التثبيت: $e';
      });
    }
  }
}
