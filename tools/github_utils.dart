// ignore_for_file: avoid_print, unused_import

import 'dart:io';
import 'dart:convert';
import 'package:github/github.dart';
import 'package:path/path.dart' as path;
import 'github_repo.dart' as github_repo;

/// الحصول على قائمة الملفات في مجلد
Future<List<File>> getFilesInDirectory(String directory) async {
  final dir = Directory(directory);
  if (!await dir.exists()) return [];

  final files = <File>[];
  await for (final entity in dir.list(recursive: true)) {
    if (entity is File) {
      // تجاهل الملفات المؤقتة وملفات النسخ الاحتياطي
      if (!entity.path.endsWith('.tmp') && !entity.path.endsWith('.bak')) {
        // فقط ملفات التثبيت والتنفيذ والأرشيف
        if (entity.path.endsWith('.exe') || entity.path.endsWith('.dmg') ||
            entity.path.endsWith('.AppImage') || entity.path.endsWith('.zip') ||
            entity.path.endsWith('-setup.exe')) {
          files.add(entity);
        }
      }
    }
  }
  return files;
}

/// الحصول على توكن GitHub
Future<String?> getGitHubToken() async {
  try {
    // محاولة قراءة التوكن من ملف التكوين
    final configFile = File('tools/app-config.json');
    if (await configFile.exists()) {
      final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
      if (config.containsKey('github') && config['github'] is Map) {
        final githubConfig = config['github'] as Map<String, dynamic>;
        if (githubConfig.containsKey('token') && githubConfig['token'].toString().isNotEmpty) {
          return githubConfig['token'].toString();
        }
      }
    }

    // محاولة قراءة التوكن من ملف مخفي
    final tokenFile = File('.github_token');
    if (await tokenFile.exists()) {
      final token = (await tokenFile.readAsString()).trim();
      // حفظ التوكن في ملف التكوين
      await saveTokenToConfig(token);
      return token;
    }

    // محاولة قراءة التوكن من متغيرات البيئة
    final envToken = Platform.environment['GITHUB_TOKEN'];
    if (envToken != null && envToken.isNotEmpty) {
      // حفظ التوكن في ملف التكوين
      await saveTokenToConfig(envToken);
      return envToken;
    }

    // طلب التوكن من المستخدم
    print('ℹ️ GitHub token not found');
    print('ℹ️ Please enter your GitHub token:');
    final token = stdin.readLineSync()?.trim();
    if (token != null && token.isNotEmpty) {
      // حفظ التوكن في ملف التكوين
      await saveTokenToConfig(token);
      return token;
    }
  } catch (e) {
    print('❌ Error getting GitHub token: $e');
  }

  return null;
}

/// حفظ التوكن في ملف التكوين
Future<void> saveTokenToConfig(String token) async {
  try {
    final configFile = File('tools/app-config.json');
    if (await configFile.exists()) {
      final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());

      if (!config.containsKey('github')) {
        config['github'] = {};
      }

      config['github']['token'] = token;

      await configFile.writeAsString(JsonEncoder.withIndent('  ').convert(config));
      print('✅ GitHub token saved to config file');
    }
  } catch (e) {
    print('❌ Error saving token to config: $e');
  }
}

/// الحصول على معلومات المستودع
/// يعيد قاموس يحتوي على اسم المالك واسم المستودع
Future<Map<String, String>?> getRepositoryInfo(Map<String, dynamic> config) async {
  try {
    final updateConfig = config['update'] as Map<String, dynamic>;

    if (updateConfig.containsKey('repository')) {
      final repoUrl = updateConfig['repository'] as String;
      final match = RegExp(r'github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?$').firstMatch(repoUrl);
      if (match != null) {
        return {
          'owner': match.group(1)!,
          'name': match.group(2)!,
        };
      }
    }

    // محاولة الحصول على معلومات المستودع من Git
    final result = await Process.run('git', ['config', '--get', 'remote.origin.url']);
    if (result.exitCode == 0 && result.stdout.toString().trim().isNotEmpty) {
      final repoUrl = result.stdout.toString().trim();
      final match = RegExp(r'github\.com[/:]([^/]+)/([^/]+?)(?:\.git)?$').firstMatch(repoUrl);
      if (match != null) {
        return {
          'owner': match.group(1)!,
          'name': match.group(2)!,
        };
      }
    }

    // طلب معلومات المستودع من المستخدم
    print('ℹ️ Repository information not found');
    print('ℹ️ Please enter the repository owner (username or organization):');
    final owner = stdin.readLineSync()?.trim();
    print('ℹ️ Please enter the repository name:');
    final name = stdin.readLineSync()?.trim();

    if (owner != null && owner.isNotEmpty && name != null && name.isNotEmpty) {
      return {
        'owner': owner,
        'name': name,
      };
    }
  } catch (e) {
    print('❌ Error getting repository information: $e');
  }

  return null;
}

/// الحصول على SHA لآخر commit
Future<String> getHeadCommitSha() async {
  final result = await Process.run('git', ['rev-parse', 'HEAD']);
  if (result.exitCode == 0) {
    return result.stdout.toString().trim();
  }
  throw Exception('Failed to get HEAD commit SHA');
}

/// الحصول على ملاحظات الإصدار من ملف CHANGELOG.md
Future<String> getReleaseNotesFromChangelog(String version) async {
  try {
    final changelogFile = File('CHANGELOG.md');
    if (!await changelogFile.exists()) {
      return 'Release v$version';
    }

    final content = await changelogFile.readAsString();
    final versionHeader = '## $version';
    final nextVersionHeader = '## ';

    final versionIndex = content.indexOf(versionHeader);
    if (versionIndex == -1) {
      return 'Release v$version';
    }

    final startIndex = versionIndex + versionHeader.length;
    final nextVersionIndex = content.indexOf(nextVersionHeader, startIndex);

    final endIndex = nextVersionIndex == -1 ? content.length : nextVersionIndex;
    return content.substring(startIndex, endIndex).trim();
  } catch (e) {
    print('⚠️ Error reading CHANGELOG.md: $e');
    return 'Release v$version';
  }
}

/// تحديث ملف التحديث
Future<void> updateUpdateConfig(String version, String buildNumber, bool isRequired,
    Map<String, dynamic> updateConfig, Map<String, dynamic> appConfig, Map<String, dynamic> config) async {
  try {
    final configFile = File('tools/app-config.json');

    // تحديث معلومات الإصدار
    config['update']['latest_version'] = version;
    config['update']['latest_build_number'] = int.parse(buildNumber);
    config['update']['is_required'] = isRequired;

    // تحديث روابط التحميل
    final repoInfo = await getRepositoryInfo(config);
    if (repoInfo != null) {
      final baseUrl = 'https://github.com/${repoInfo['owner']}/${repoInfo['name']}/releases/download/v$version';

      config['update']['windows']['download_url'] = '$baseUrl/dev_server-v$version-setup.exe';
      config['update']['macos']['download_url'] = '$baseUrl/dev_server-v$version.dmg';
      config['update']['linux']['download_url'] = '$baseUrl/dev_server-v$version.AppImage';
    }

    // حفظ التغييرات
    await configFile.writeAsString(JsonEncoder.withIndent('  ').convert(config));
    print('✅ Updated update configuration in app-config.json');
  } catch (e) {
    print('❌ Error updating update configuration: $e');
  }
}

/// الحصول على نوع المحتوى بناءً على امتداد الملف
String getContentType(String fileName) {
  final ext = path.extension(fileName).toLowerCase();
  switch (ext) {
    case '.exe':
      return 'application/vnd.microsoft.portable-executable';
    case '.dmg':
      return 'application/x-apple-diskimage';
    case '.appimage':
      return 'application/x-executable';
    case '.zip':
      return 'application/zip';
    default:
      return 'application/octet-stream';
  }
}

/// تأكيد الإجراء من المستخدم
Future<bool> confirmAction(String message) async {
  print('$message (y/n)');
  final response = stdin.readLineSync()?.trim().toLowerCase();
  return response == 'y' || response == 'yes';
}

/// إعداد توكن GitHub
Future<void> setGitHubToken(String token) async {
  await saveTokenToConfig(token);
  print('✅ GitHub token saved successfully');
}

/// الحصول على إعدادات GitHub
Future<Map<String, dynamic>> getGitHubConfig() async {
  try {
    final configFile = File('tools/app-config.json');
    if (await configFile.exists()) {
      final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
      if (config.containsKey('github') && config['github'] is Map) {
        return config['github'] as Map<String, dynamic>;
      }
    }
  } catch (e) {
    print('❌ Error reading GitHub config: $e');
  }

  // إعدادات افتراضية
  return {
    'token': '',
    'auto_create': true,
    'auto_push': true,
    'auto_release': true,
    'auto_tag': true
  };
}
