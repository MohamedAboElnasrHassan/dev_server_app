// ignore_for_file: avoid_print, unused_import, unused_local_variable, unnecessary_null_comparison

import 'dart:io';
import 'dart:convert';
import 'package:yaml_edit/yaml_edit.dart';
import 'package:github/github.dart';
import 'package:path/path.dart' as path;
import 'github_utils.dart' as github_utils;
import 'github_repo.dart' as github_repo;
import 'interactive_menu.dart' as menu;

/// أداة تطوير متكاملة للمشروع
/// تجمع بين وظائف مزامنة الإعدادات، إصدار التحديثات، والنشر، وبناء التطبيق
void main(List<String> args) async {
  // تشغيل flutter analyze للتحقق من عدم وجود أخطاء
  final analyzeResult = await runFlutterAnalyze();
  if (!analyzeResult) {
    print('❌ Flutter analyze failed. Please fix the issues and try again.');
    return;
  }

  // مزامنة التكوين تلقائياً
  await syncConfig();

  if (args.isEmpty) {
    // إذا لم يتم تحديد أي أمر، اعرض القائمة التفاعلية
    await showInteractiveMenu();
    return;
  }

  final command = args[0];
  final restArgs = args.length > 1 ? args.sublist(1) : <String>[];

  switch (command) {
    case 'sync':
      await syncConfig();
      break;
    case 'build':
      if (restArgs.isEmpty) {
        print('❌ Missing platform argument');
        print('Usage: dart tools/dev_tools.dart build <platform>');
        print('Platforms: windows, macos, linux, all');
        return;
      }
      await buildApp(restArgs[0]);
      break;
    case 'release':
      if (restArgs.length < 2) {
        print('❌ Missing version or build number');
        print('Usage: dart tools/dev_tools.dart release <version> <build_number> [is_required]');
        print('Example: dart tools/dev_tools.dart release 1.0.1 2 true');
        return;
      }
      final version = restArgs[0];
      final buildNumber = restArgs[1];
      final isRequired = restArgs.length > 2 ? restArgs[2].toLowerCase() == 'true' : false;
      await createRelease(version, buildNumber, isRequired);

      // بناء التطبيق تلقائياً بعد إنشاء الإصدار
      final githubConfig = await github_utils.getGitHubConfig();
      if (githubConfig['auto_build'] == true) {
        await buildApp('all');
      }

      // نشر الإصدار تلقائياً بعد البناء
      if (githubConfig['auto_release'] == true) {
        await publishRelease(version, buildNumber, isRequired: isRequired);
      }
      break;
    case 'publish':
      if (restArgs.length < 2) {
        print('❌ Missing version or build number');
        print('Usage: dart tools/dev_tools.dart publish <version> <build_number> [is_required]');
        print('Example: dart tools/dev_tools.dart publish 1.0.1 2 true');
        return;
      }
      final version = restArgs[0];
      final buildNumber = restArgs[1];
      final isRequired = restArgs.length > 2 ? restArgs[2].toLowerCase() == 'true' : false;
      await publishRelease(version, buildNumber, isRequired: isRequired);
      break;
    case 'set-token':
      if (restArgs.isEmpty) {
        print('❌ Missing GitHub token');
        print('Usage: dart tools/dev_tools.dart set-token <github_token>');
        return;
      }
      await github_utils.setGitHubToken(restArgs[0]);
      break;
    case 'auto':
      // تنفيذ جميع الخطوات تلقائياً
      if (restArgs.length < 2) {
        print('❌ Missing version or build number');
        print('Usage: dart tools/dev_tools.dart auto <version> <build_number> [is_required]');
        print('Example: dart tools/dev_tools.dart auto 1.0.1 2 true');
        return;
      }
      final version = restArgs[0];
      final buildNumber = restArgs[1];
      final isRequired = restArgs.length > 2 ? restArgs[2].toLowerCase() == 'true' : false;

      // إنشاء الإصدار
      await createRelease(version, buildNumber, isRequired);

      // بناء التطبيق
      await buildApp('all');

      // نشر الإصدار
      await publishRelease(version, buildNumber, isRequired: isRequired);
      break;
    default:
      print('❌ Unknown command: $command');
      printUsage();
  }
}

/// عرض تعليمات الاستخدام
void printUsage() {
  print('=== 🛠️ Dev Server Tools ===');
  print('Usage: dart tools/dev_tools.dart <command> [arguments]');
  print('');
  print('Commands:');
  print('  sync                   Synchronize configuration files');
  print('  build <platform>       Build the app for the specified platform');
  print('                         Platforms: windows, macos, linux, all');
  print('  release <version> <build_number> [is_required]');
  print('                         Create a new release');
  print('  publish <version> <build_number> [is_required]');
  print('                         Publish a release to GitHub');
  print('  set-token <token>      Set GitHub token for publishing');
  print('');
  print('Examples:');
  print('  dart tools/dev_tools.dart sync');
  print('  dart tools/dev_tools.dart build windows');
  print('  dart tools/dev_tools.dart release 1.0.1 2 false');
  print('  dart tools/dev_tools.dart publish 1.0.1 2 true');
}

/// مزامنة ملفات التكوين
Future<void> syncConfig() async {
  print('\n=== 🔄 Auto-syncing configuration ===');

  try {
    // قراءة ملف التكوين
    final configFile = File('tools/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Configuration file not found: tools/app-config.json');
      return;
    }

    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());

    // تحديث ملف pubspec.yaml
    await updatePubspecYaml(config);

    print('✅ Configuration auto-synced successfully');
  } catch (e) {
    print('❌ Error during configuration sync: $e');
  }
}

/// تحديث ملف pubspec.yaml
Future<void> updatePubspecYaml(Map<String, dynamic> config) async {
  final pubspecFile = File('pubspec.yaml');
  if (!await pubspecFile.exists()) {
    print('❌ pubspec.yaml not found');
    return;
  }

  final pubspecContent = await pubspecFile.readAsString();
  final editor = YamlEditor(pubspecContent);

  // تحديث اسم التطبيق والوصف
  editor.update(['name'], config['app']['id']);
  editor.update(['description'], config['app']['description']);

  // تحديث رقم الإصدار
  final version = config['app']['version'];
  final buildNumber = config['update']['latest_build_number'];
  editor.update(['version'], '$version+$buildNumber');

  // حفظ التغييرات
  await pubspecFile.writeAsString(editor.toString());
}

/// إنشاء إصدار جديد
Future<void> createRelease(String version, String buildNumber, bool isRequired) async {
  print('\n=== 🚀 Creating Release v$version+$buildNumber ===');

  try {
    // قراءة ملف التكوين
    final configFile = File('tools/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Configuration file not found: tools/app-config.json');
      return;
    }

    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());

    // تحديث معلومات الإصدار
    config['app']['version'] = version;
    config['update']['latest_version'] = version;
    config['update']['latest_build_number'] = int.parse(buildNumber);
    config['update']['is_required'] = isRequired;

    // حفظ التغييرات
    await configFile.writeAsString(JsonEncoder.withIndent('  ').convert(config));

    // تحديث ملف pubspec.yaml
    await updatePubspecYaml(config);

    // إنشاء العلامة (tag) محلياً
    try {
      // التحقق من وجود العلامة محلياً
      final checkTagResult = await Process.run('git', ['tag', '-l', 'v$version']);
      final tagExists = checkTagResult.stdout.toString().trim().isNotEmpty;

      if (!tagExists) {
        // إنشاء العلامة محلياً
        final createTagResult = await Process.run('git', ['tag', 'v$version']);
        if (createTagResult.exitCode == 0) {
          print('✅ Created local tag v$version');

          // دفع العلامة إلى GitHub تلقائياً
          final githubConfig = await github_utils.getGitHubConfig();
          if (githubConfig['auto_push'] == true) {
            print('ℹ️ Pushing tag to GitHub...');
            final pushTagResult = await Process.run('git', ['push', 'origin', 'v$version']);
            if (pushTagResult.exitCode == 0) {
              print('✅ Pushed tag v$version to GitHub');
            } else {
              print('⚠️ Warning: Could not push tag to GitHub: ${pushTagResult.stderr}');
            }
          }
        } else {
          print('⚠️ Warning: Could not create local tag: ${createTagResult.stderr}');
        }
      } else {
        print('ℹ️ Local tag v$version already exists');
      }
    } catch (e) {
      print('⚠️ Warning: Error working with git tags: $e');
    }

    // التحقق من وجود المستودع وإنشائه إذا لم يكن موجوداً
    final repoInfo = await github_utils.getRepositoryInfo(config);
    if (repoInfo != null) {
      final githubConfig = await github_utils.getGitHubConfig();
      if (githubConfig['auto_create'] == true) {
        await github_repo.checkAndCreateRepository(repoInfo);
      }
    }

    print('✅ Release v$version+$buildNumber created successfully');

    // بناء التطبيق تلقائياً
    final githubConfig = await github_utils.getGitHubConfig();
    if (githubConfig['auto_build'] == true) {
      print('ℹ️ Auto-building app for all platforms...');
      await buildApp('all');
    } else {
      print('ℹ️ To build the app, run: dart tools/dev_tools.dart build all');
    }
  } catch (e) {
    print('❌ Error during release creation: $e');
  }
}

/// بناء التطبيق
Future<void> buildApp(String platform) async {
  print('\n=== 🔨 Building App ===');

  try {
    // مزامنة التكوين أولاً
    await syncConfig();

    // قراءة ملف التكوين
    final configFile = File('tools/app-config.json');
    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());

    // الحصول على معلومات الإصدار
    final version = config['app']['version'];
    final appNameFormatted = config['app']['id'];

    // بناء التطبيق للمنصة المحددة
    switch (platform.toLowerCase()) {
      case 'windows':
        await buildWindows(appNameFormatted, version);
        break;
      case 'macos':
        await buildMacOS(appNameFormatted, version);
        break;
      case 'linux':
        await buildLinux(appNameFormatted, version);
        break;
      case 'all':
        await buildWindows(appNameFormatted, version);
        await buildMacOS(appNameFormatted, version);
        await buildLinux(appNameFormatted, version);
        break;
      default:
        print('❌ Unknown platform: $platform');
        print('Supported platforms: windows, macos, linux, all');
        return;
    }

    print('\n=== ✅ Build Process Completed ===');
    print('Build files are available in: releases/v$version');
  } catch (e) {
    print('❌ Error during build: $e');
  }
}

/// بناء تطبيق Windows
Future<void> buildWindows(String appNameFormatted, String version) async {
  print('\n=== 🪟 Building for Windows ===');

  try {
    // قراءة إعدادات البناء من ملف التكوين
    final configFile = File('tools/app-config.json');
    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
    final windowsConfig = config['build']['windows'];
    // نستخدم مسارات ثابتة بدلاً من commonConfig

    // الحصول على مسارات المجلدات
    final outputDir = 'build/windows/x64/runner/Release';
    final releaseDir = 'releases/v$version';

    // تنفيذ أمر البناء
    print('Running: flutter build windows --release');

    bool buildSuccess = false;

    try {
      // تنفيذ أمر البناء
      // محاولة استخدام المسار الكامل لـ Flutter إذا لم يعمل الأمر العادي
      ProcessResult result;
      try {
        // محاولة استخدام الأمر العادي
        result = await Process.run('flutter', ['build', 'windows', '--release']);
      } catch (e) {
        // إذا فشل، حاول استخدام المسار الكامل
        print('⚠️ Flutter command not found in PATH. Trying with full path...');
        try {
          result = await Process.run('C:\\Users\\Mohamed\\dev\\flutter\\bin\\flutter.bat', ['build', 'windows', '--release']);
        } catch (e2) {
          throw Exception('Failed to run Flutter: $e2');
        }
      }

      if (result.exitCode == 0) {
        print('✅ Windows build completed successfully');
        buildSuccess = true;
      } else {
        print('❌ Error building for Windows:');
        print(result.stderr);
      }
    } catch (e) {
      print('❌ Error during Windows build: $e');
      print('⚠️ Make sure Flutter is installed and in your PATH');
    }

    // إذا فشل البناء، توقف عن العمل
    if (!buildSuccess) {
      print('❌ Build failed. Please make sure Flutter is installed and in your PATH.');
      print('❌ Stopping the build process.');
      return;
    }

    // إنشاء مجلد الإصدارات إذا لم يكن موجودًا
    await Directory(releaseDir).create(recursive: true);
    print('✅ Created release directory: $releaseDir');

    // نسخ مجلد التطبيق الكامل إلى مجلد الإصدارات
    final releaseFolder = Directory('build/windows/x64/runner/Release');
    final releaseFolderPath = '$releaseDir/app';
    final releaseFolderDir = Directory(releaseFolderPath);

    if (await releaseFolder.exists()) {
      // إنشاء مجلد التطبيق في مجلد الإصدارات
      if (await releaseFolderDir.exists()) {
        await releaseFolderDir.delete(recursive: true);
      }
      await releaseFolderDir.create(recursive: true);

      // نسخ جميع الملفات من مجلد الإصدار إلى مجلد التطبيق
      await _copyDirectory(releaseFolder.path, releaseFolderPath);

      // نسخ ملف EXE أيضًا بشكل منفصل للتوافق مع الإصدارات السابقة
      final exeFile = File('${releaseFolder.path}/$appNameFormatted.exe');
      if (await exeFile.exists()) {
        final newExePath = '$releaseDir/$appNameFormatted-v$version.exe';
        await exeFile.copy(newExePath);
        print('📦 EXE file copied to: $newExePath');
      }

      print('📦 Complete application folder copied to: $releaseFolderPath');
      print('ℹ️ This folder contains all required DLL files and dependencies');
    } else {
      print('⚠️ Release folder not found at: build/windows/x64/runner/Release');
    }

    // إنشاء ملف تثبيت مخصص
    final setupConfig = windowsConfig['setup'] as Map<String, dynamic>;
    final setupEnabled = setupConfig['enabled'] as bool? ?? true;

    if (setupEnabled) {
      print('\n=== 📌 Setup Installer Info ===');
      print('ℹ️ Setup installer will be created automatically by GitHub Actions when you push a tag.');
      print('ℹ️ To create a release, run: git tag v$version && git push origin v$version');
      print('ℹ️ The installer will be available in GitHub Releases after the workflow completes.');
    } else {
      print('\nℹ️ Setup installer creation is disabled in app-config.json');
    }
  } catch (e) {
    print('❌ Error during Windows build: $e');
  }
}

/// بناء تطبيق macOS
Future<void> buildMacOS(String appNameFormatted, String version) async {
  print('\n=== 🍎 Building for macOS ===');

  try {
    // قراءة إعدادات البناء من ملف التكوين
    final configFile = File('tools/app-config.json');
    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
    final macosConfig = config['build']['macos'];
    final commonConfig = config['build']['common'];

    // تنفيذ أمر البناء
    final buildCommand = replaceVariables(macosConfig['build_command'], config);
    print('Running: $buildCommand');

    try {
      final commandParts = buildCommand.split(' ');
      final result = await Process.run(commandParts[0], commandParts.sublist(1));

      if (result.exitCode == 0) {
        print('✅ macOS build completed successfully');
      } else {
        print('❌ Error building for macOS:');
        print(result.stderr);
        return;
      }
    } catch (e) {
      print('❌ Error during macOS build: $e');
      print('⚠️ Make sure Flutter is installed and in your PATH');
      return;
    }

    // الحصول على مسارات المجلدات
    final outputDir = replaceVariables(macosConfig['output_dir'], config);
    final releaseDir = replaceVariables(commonConfig['output_dir'], config);

    // إنشاء مجلد الإصدارات إذا لم يكن موجودًا
    final releaseDirObj = Directory(releaseDir);
    if (!await releaseDirObj.exists()) {
      await releaseDirObj.create(recursive: true);
    }

    print('⚠️ Note: macOS app packaging not implemented yet');
    print('📁 macOS app available at: $outputDir');
  } catch (e) {
    print('❌ Error during macOS build: $e');
  }
}

/// بناء تطبيق Linux
Future<void> buildLinux(String appNameFormatted, String version) async {
  print('\n=== 🐧 Building for Linux ===');

  try {
    // قراءة إعدادات البناء من ملف التكوين
    final configFile = File('tools/app-config.json');
    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
    final linuxConfig = config['build']['linux'];
    final commonConfig = config['build']['common'];

    // تنفيذ أمر البناء
    final buildCommand = replaceVariables(linuxConfig['build_command'], config);
    print('Running: $buildCommand');

    try {
      final commandParts = buildCommand.split(' ');
      final result = await Process.run(commandParts[0], commandParts.sublist(1));

      if (result.exitCode == 0) {
        print('✅ Linux build completed successfully');
      } else {
        print('❌ Error building for Linux:');
        print(result.stderr);
        return;
      }
    } catch (e) {
      print('❌ Error during Linux build: $e');
      print('⚠️ Make sure Flutter is installed and in your PATH');
      return;
    }

    // الحصول على مسارات المجلدات
    final outputDir = replaceVariables(linuxConfig['output_dir'], config);
    final releaseDir = replaceVariables(commonConfig['output_dir'], config);

    // إنشاء مجلد الإصدارات إذا لم يكن موجودًا
    final releaseDirObj = Directory(releaseDir);
    if (!await releaseDirObj.exists()) {
      await releaseDirObj.create(recursive: true);
    }

    print('⚠️ Note: Linux app packaging not implemented yet');
    print('📁 Linux app available at: $outputDir');
  } catch (e) {
    print('❌ Error during Linux build: $e');
  }
}

/// نسخ مجلد بشكل متكرر مع جميع الملفات والمجلدات الفرعية
Future<void> _copyDirectory(String source, String destination) async {
  final sourceDir = Directory(source);
  final destinationDir = Directory(destination);

  if (!await destinationDir.exists()) {
    await destinationDir.create(recursive: true);
  }

  await for (final entity in sourceDir.list(recursive: false)) {
    final entityPath = entity.path;
    final entityName = entityPath.split(Platform.pathSeparator).last;
    final newPath = '$destination${Platform.pathSeparator}$entityName';

    if (entity is File) {
      await entity.copy(newPath);
    } else if (entity is Directory) {
      await _copyDirectory(entityPath, newPath);
    }
  }
}

/// نشر إصدار جديد على GitHub
Future<void> publishRelease(String version, String buildNumber, {bool isRequired = false}) async {
  print('\n=== 🚀 Publishing Release v$version+$buildNumber ===');

  try {
    // قراءة إعدادات النشر من ملف التكوين
    final configFile = File('tools/app-config.json');
    final Map<String, dynamic> config = jsonDecode(await configFile.readAsString());
    final appConfig = config['app'];
    final updateConfig = config['update'];

    // التحقق من وجود ملفات الإصدار
    final releaseDir = 'releases/v$version';
    final releaseDirObj = Directory(releaseDir);

    if (!await releaseDirObj.exists()) {
      print('❌ Release directory not found: $releaseDir');
      print('ℹ️ Please build the app first using: dart tools/dev_tools.dart build all');
      return;
    }

    // التحقق من وجود ملفات الإصدار
    final appFiles = await github_utils.getFilesInDirectory(releaseDir);
    if (appFiles.isEmpty) {
      print('❌ No release files found in: $releaseDir');
      print('ℹ️ Please build the app first using: dart tools/dev_tools.dart build all');
      return;
    }

    print('💾 Found ${appFiles.length} files to publish:');
    for (final file in appFiles) {
      print('  - ${path.basename(file.path)}');
    }

    // الحصول على معلومات GitHub
    final githubToken = await github_utils.getGitHubToken();
    if (githubToken == null) {
      print('❌ GitHub token not found');
      print('ℹ️ Please set your GitHub token using: dart tools/dev_tools.dart set-token YOUR_TOKEN');
      return;
    }

    final repoInfo = await github_utils.getRepositoryInfo(config);
    if (repoInfo == null) {
      print('❌ Failed to get repository information');
      print('ℹ️ Please make sure you are in a git repository connected to GitHub');
      return;
    }

    // التحقق من وجود المستودع وإنشائه إذا لم يكن موجوداً
    final githubConfig = await github_utils.getGitHubConfig();
    if (githubConfig['auto_create'] == true) {
      final repoExists = await github_repo.checkAndCreateRepository(repoInfo);
      if (!repoExists) {
        print('❌ Repository does not exist and could not be created');
        print('ℹ️ Please create the repository manually or try again');
        return;
      }
    } else {
      // التحقق من وجود المستودع فقط
      try {
        final github = GitHub(auth: Authentication.withToken(githubToken));
        final slug = RepositorySlug(repoInfo['owner']!, repoInfo['name']!);
        await github.repositories.getRepository(slug);
      } catch (e) {
        print('❌ Repository does not exist: ${repoInfo['owner']}/${repoInfo['name']}');
        print('ℹ️ Please create the repository manually or enable auto_create in app-config.json');
        return;
      }
    }

    final github = GitHub(auth: Authentication.withToken(githubToken));
    final slug = RepositorySlug(repoInfo['owner']!, repoInfo['name']!);

    // التحقق من وجود الإصدار
    try {
      final existingRelease = await github.repositories.getReleaseByTagName(slug, 'v$version');
      if (existingRelease != null) {
        print('⚠️ Release v$version already exists');
        final confirm = await github_utils.confirmAction('Do you want to update the existing release?');
        if (!confirm) {
          print('❌ Release update cancelled');
          return;
        }

        // حذف الإصدار الموجود
        await github.repositories.deleteRelease(slug, existingRelease);
        print('✅ Deleted existing release v$version');
      }
    } catch (e) {
      // الإصدار غير موجود، نستمر
      print('ℹ️ Release v$version does not exist yet, creating new release');
    }

    // إنشاء العلامة (tag) إذا لم تكن موجودة
    try {
      // التحقق من وجود العلامة على GitHub
      try {
        await github.git.getReference(slug, 'tags/v$version');
        print('ℹ️ Tag v$version already exists on GitHub');
      } catch (e) {
        // العلامة غير موجودة على GitHub، إنشاؤها
        await github.git.createReference(slug, 'refs/tags/v$version', await github_utils.getHeadCommitSha());
        print('✅ Created tag v$version on GitHub');
      }
    } catch (e) {
      print('⚠️ Warning: Could not verify or create tag: $e');
      print('ℹ️ Continuing with release creation...');
    }

    // قراءة ملف CHANGELOG.md للحصول على ملاحظات الإصدار
    String releaseNotes = await github_utils.getReleaseNotesFromChangelog(version);

    // إنشاء الإصدار
    final createRelease = CreateRelease('v$version');
    createRelease.name = 'Version $version';
    createRelease.body = releaseNotes;

    final release = await github.repositories.createRelease(slug, createRelease);
    print('✅ Created release v$version');

    // رفع ملفات الإصدار
    for (final file in appFiles) {
      final fileName = path.basename(file.path);
      final contentType = github_utils.getContentType(fileName);

      try {
        // رفع الملف باستخدام الطريقة المناسبة للإصدار الحالي من الحزمة
        final bytes = await file.readAsBytes();
        final response = await github.request(
          'POST',
          '/repos/${repoInfo['owner']}/${repoInfo['name']}/releases/${release.id}/assets',
          headers: {
            'Content-Type': contentType,
            'Content-Length': bytes.length.toString(),
          },
          params: {'name': fileName},
          body: bytes,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('✅ Uploaded $fileName');
        } else {
          print('❌ Failed to upload $fileName: ${response.statusCode} ${response.body}');
        }
      } catch (e) {
        print('❌ Failed to upload $fileName: $e');
      }
    }

    // تحديث ملف التحديث
    await github_utils.updateUpdateConfig(version, buildNumber, isRequired, updateConfig, appConfig, config);

    print('\n✅ Release v$version published successfully!');
    print('🔗 Release URL: ${release.htmlUrl}');
  } catch (e) {
    print('❌ Error during release publishing: $e');
  }
}

/// استبدال المتغيرات في النص
String replaceVariables(String text, Map<String, dynamic> config) {
  final appConfig = config['app'];

  return text
      .replaceAll('{app.name}', appConfig['name'])
      .replaceAll('{app.id}', appConfig['id'])
      .replaceAll('{app.version}', appConfig['version'])
      .replaceAll('{app.author}', appConfig['author'])
      .replaceAll('{app.website}', appConfig['website']);
}

/// تشغيل flutter analyze للتحقق من عدم وجود أخطاء
Future<bool> runFlutterAnalyze() async {
  print('=== 🔍 Running Flutter Analyze ===');

  try {
    final result = await Process.run('flutter', ['analyze']);

    if (result.exitCode == 0) {
      print('✅ Flutter analyze completed successfully');
      return true;
    } else {
      print('⚠️ Flutter analyze found issues:');
      print(result.stdout);
      print(result.stderr);

      // سؤال المستخدم إذا كان يريد الاستمرار
      final shouldContinue = await github_utils.confirmAction('Continue despite analysis issues?');
      return shouldContinue;
    }
  } catch (e) {
    print('⚠️ Warning: Could not run Flutter analyze: $e');
    return true; // الاستمرار في حالة الخطأ
  }
}

/// عرض قائمة تفاعلية
Future<void> showInteractiveMenu() async {
  print('=== 🔧️ Dev Server Tools - Interactive Menu ===');
  print('');
  print('1. Sync configuration');
  print('2. Build app');
  print('3. Create new release');
  print('4. Publish release');
  print('5. Set GitHub token');
  print('6. Auto (create, build, publish)');
  print('0. Exit');
  print('');
  print('Enter your choice (0-6):');

  final choice = stdin.readLineSync()?.trim();

  switch (choice) {
    case '1':
      await syncConfig();
      break;
    case '2':
      print('\nSelect platform:');
      print('1. Windows');
      print('2. macOS');
      print('3. Linux');
      print('4. All');
      print('Enter platform (1-4):');

      final platformChoice = stdin.readLineSync()?.trim();
      String platform;

      switch (platformChoice) {
        case '1':
          platform = 'windows';
          break;
        case '2':
          platform = 'macos';
          break;
        case '3':
          platform = 'linux';
          break;
        case '4':
          platform = 'all';
          break;
        default:
          print('❌ Invalid choice');
          return;
      }

      await buildApp(platform);
      break;
    case '3':
      print('\nEnter version (e.g. 1.0.2):');
      final version = stdin.readLineSync()?.trim();

      print('Enter build number (e.g. 3):');
      final buildNumber = stdin.readLineSync()?.trim();

      print('Is this update required? (y/n):');
      final isRequiredInput = stdin.readLineSync()?.trim().toLowerCase();
      final isRequired = isRequiredInput == 'y' || isRequiredInput == 'yes';

      if (version != null && version.isNotEmpty && buildNumber != null && buildNumber.isNotEmpty) {
        await createRelease(version, buildNumber, isRequired);
      } else {
        print('❌ Invalid input');
      }
      break;
    case '4':
      print('\nEnter version (e.g. 1.0.2):');
      final version = stdin.readLineSync()?.trim();

      print('Enter build number (e.g. 3):');
      final buildNumber = stdin.readLineSync()?.trim();

      print('Is this update required? (y/n):');
      final isRequiredInput = stdin.readLineSync()?.trim().toLowerCase();
      final isRequired = isRequiredInput == 'y' || isRequiredInput == 'yes';

      if (version != null && version.isNotEmpty && buildNumber != null && buildNumber.isNotEmpty) {
        await publishRelease(version, buildNumber, isRequired: isRequired);
      } else {
        print('❌ Invalid input');
      }
      break;
    case '5':
      print('\nEnter GitHub token:');
      final token = stdin.readLineSync()?.trim();

      if (token != null && token.isNotEmpty) {
        await github_utils.setGitHubToken(token);
      } else {
        print('❌ Invalid token');
      }
      break;
    case '6':
      print('\nEnter version (e.g. 1.0.2):');
      final version = stdin.readLineSync()?.trim();

      print('Enter build number (e.g. 3):');
      final buildNumber = stdin.readLineSync()?.trim();

      print('Is this update required? (y/n):');
      final isRequiredInput = stdin.readLineSync()?.trim().toLowerCase();
      final isRequired = isRequiredInput == 'y' || isRequiredInput == 'yes';

      if (version != null && version.isNotEmpty && buildNumber != null && buildNumber.isNotEmpty) {
        // إنشاء الإصدار
        await createRelease(version, buildNumber, isRequired);

        // بناء التطبيق
        await buildApp('all');

        // نشر الإصدار
        await publishRelease(version, buildNumber, isRequired: isRequired);
      } else {
        print('❌ Invalid input');
      }
      break;
    case '0':
      print('Exiting...');
      break;
    default:
      print('❌ Invalid choice');
  }
}
