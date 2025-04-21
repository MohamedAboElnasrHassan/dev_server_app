import 'package:flutter/material.dart';
import 'package:auto_update_package/auto_update_package.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SettingsPage extends StatefulWidget {
  final UpdateManager updateManager;

  const SettingsPage({super.key, required this.updateManager});

  @override
  State<SettingsPage> createState() => _SettingsPageState();
}

class _SettingsPageState extends State<SettingsPage> {
  bool _autoCheckUpdates = true;
  String _configUrl = '';
  final TextEditingController _configUrlController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadSettings();
  }

  Future<void> _loadSettings() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      _autoCheckUpdates = prefs.getBool('auto_check_updates') ?? true;
      _configUrl =
          prefs.getString('config_url') ??
          'https://raw.githubusercontent.com/MohamedAboElnasrHassan/dev_server/main/app-config.json';
      _configUrlController.text = _configUrl;
    });
  }

  Future<void> _saveSettings() async {
    final scaffoldMessenger = ScaffoldMessenger.of(context);
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('auto_check_updates', _autoCheckUpdates);
    await prefs.setString('config_url', _configUrl);

    if (mounted) {
      scaffoldMessenger.showSnackBar(
        const SnackBar(content: Text('تم حفظ الإعدادات')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('الإعدادات')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // قسم التحديثات
            const Text(
              'إعدادات التحديث',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            SwitchListTile(
              title: const Text('التحقق التلقائي من التحديثات'),
              subtitle: const Text('التحقق من وجود تحديثات عند بدء التطبيق'),
              value: _autoCheckUpdates,
              onChanged: (value) {
                setState(() {
                  _autoCheckUpdates = value;
                });
              },
            ),
            const SizedBox(height: 16),

            // قسم عنوان التكوين
            const Text(
              'عنوان ملف التكوين',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: _configUrlController,
              decoration: const InputDecoration(
                labelText: 'عنوان ملف التكوين',
                border: OutlineInputBorder(),
              ),
              onChanged: (value) {
                _configUrl = value;
              },
            ),
            const SizedBox(height: 16),

            // قسم معلومات الإصدار
            const Text(
              'معلومات الإصدار',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ValueListenableBuilder<String>(
              valueListenable: widget.updateManager.currentVersion,
              builder: (context, version, child) {
                return Text('الإصدار الحالي: $version');
              },
            ),
            const SizedBox(height: 16),

            // زر حفظ الإعدادات
            Center(
              child: ElevatedButton(
                onPressed: _saveSettings,
                child: const Text('حفظ الإعدادات'),
              ),
            ),

            // زر التحقق من التحديثات
            const SizedBox(height: 8),
            Center(
              child: ElevatedButton(
                onPressed: () async {
                  final scaffoldMessenger = ScaffoldMessenger.of(context);
                  final hasUpdate = await widget.updateManager.checkForUpdates(
                    force: true,
                  );
                  if (!hasUpdate && mounted) {
                    scaffoldMessenger.showSnackBar(
                      const SnackBar(content: Text('لا توجد تحديثات جديدة')),
                    );
                  }
                },
                child: const Text('التحقق من وجود تحديثات'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  void dispose() {
    _configUrlController.dispose();
    super.dispose();
  }
}
