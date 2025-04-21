import 'dart:io';
import 'dart:convert';
import 'package:github/github.dart';
import 'package:yaml_edit/yaml_edit.dart';

/// الدالة الرئيسية
void main(List<String> args) async {
  if (args.isEmpty) {
    printUsage();
    return;
  }

  final command = args[0];
  final restArgs = args.length > 1 ? args.sublist(1) : [];

  switch (command) {
    case 'create':
      await createRepository();
      break;
    case 'sync':
      await syncConfig();
      break;
    case 'version':
      await getVersion();
      break;
    case 'bump':
      await bumpVersion();
      break;
    case 'publish':
      if (restArgs.length < 2) {
        print('❌ Missing version or build number');
        print(
          'Usage: dart github_tools.dart publish <version> <build_number> [is_required]',
        );
        return;
      }
      final version = restArgs[0];
      final buildNumber = restArgs[1];
      final isRequired =
          restArgs.length > 2 ? restArgs[2].toLowerCase() == 'true' : false;
      await publishRelease(version, buildNumber, isRequired: isRequired);
      break;
    case 'auto':
      if (restArgs.length < 2) {
        print('❌ Missing version or build number');
        print(
          'Usage: dart github_tools.dart auto <version> <build_number> [is_required]',
        );
        return;
      }
      final version = restArgs[0];
      final buildNumber = restArgs[1];
      final isRequired =
          restArgs.length > 2 ? restArgs[2].toLowerCase() == 'true' : false;

      // تنفيذ جميع الخطوات تلقائياً
      await createRepository();
      await syncConfig();
      await buildApp('all');
      await createRelease(version, buildNumber, isRequired);
      await publishRelease(version, buildNumber, isRequired: isRequired);
      break;
    default:
      print('❌ Unknown command: $command');
      printUsage();
  }
}

/// عرض طريقة الاستخدام
void printUsage() {
  print('Usage: dart github_tools.dart <command> [arguments]');
  print('');
  print('Commands:');
  print('  create                Create GitHub repository');
  print('  sync                  Sync configuration');
  print('  version               Get current version');
  print('  bump                  Bump version');
  print('  publish <version> <build_number> [is_required]');
  print('                         Publish a release to GitHub');
  print('  auto <version> <build_number> [is_required]');
  print(
    '                         Automatically create, build and publish a release',
  );
  print('');
  print('Examples:');
  print('  dart github_tools.dart create');
  print('  dart github_tools.dart version');
  print('  dart github_tools.dart publish 1.0.2 3 false');
}

/// إنشاء مستودع GitHub
Future<void> createRepository() async {
  try {
    print('=== 🚀 Creating GitHub Repository ===');

    // قراءة ملف التكوين
    final configFile = File('lib/config/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Config file not found: ${configFile.path}');
      return;
    }

    final config = json.decode(await configFile.readAsString());
    final repoInfo = config['repository'];
    final githubConfig = config['github'];

    // التحقق من وجود توكن GitHub
    final token = githubConfig['token'];
    if (token == null || token.isEmpty) {
      print('❌ GitHub token not found in config file');
      print('Please add your GitHub token to lib/config/app-config.json');
      return;
    }

    // إنشاء عميل GitHub
    final github = GitHub(auth: Authentication.withToken(token));

    // التحقق من وجود المستودع
    try {
      final repo = await github.repositories.getRepository(
        RepositorySlug(repoInfo['owner'], repoInfo['name']),
      );

      print('✅ Repository already exists: ${repo.htmlUrl}');
      return;
    } catch (e) {
      // المستودع غير موجود، سنقوم بإنشائه
    }

    // إنشاء المستودع
    final createRepo = await github.repositories.createRepository(
      CreateRepository(
        repoInfo['name'],
        description: 'Dev Server application with auto-update support',
        private: true, // مستودع خاص
        hasIssues: true,
        hasWiki: true,
        autoInit: true,
      ),
    );

    print('✅ Repository created: ${createRepo.htmlUrl}');

    // إنشاء فرع main إذا لم يكن موجوداً
    try {
      await github.git.getReference(
        RepositorySlug(repoInfo['owner'], repoInfo['name']),
        'heads/main',
      );
      print('✅ Branch main already exists');
    } catch (e) {
      try {
        // الحصول على الـ SHA للـ master
        final masterRef = await github.git.getReference(
          RepositorySlug(repoInfo['owner'], repoInfo['name']),
          'heads/master',
        );

        // إنشاء فرع main
        await github.git.createReference(
          RepositorySlug(repoInfo['owner'], repoInfo['name']),
          'refs/heads/main',
          masterRef.object?.sha ?? '',
        );

        print('✅ Created main branch from master');
      } catch (e) {
        print('⚠️ Could not create main branch: $e');
      }
    }
  } catch (e) {
    print('❌ Error creating repository: $e');
  }
}

/// مزامنة ملف التكوين
Future<void> syncConfig() async {
  try {
    print('=== 🔄 Syncing Configuration ===');

    // قراءة ملف التكوين
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final configFile = File('${scriptDir.path}/lib/config/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Config file not found: ${configFile.path}');
      return;
    }

    final config = json.decode(await configFile.readAsString());

    // تحديث ملف pubspec.yaml
    final pubspecFile = File('../../apps/dev_server_app/pubspec.yaml');
    if (await pubspecFile.exists()) {
      final pubspecContent = await pubspecFile.readAsString();
      final pubspecEditor = YamlEditor(pubspecContent);

      // تحديث الإصدار
      final appVersion = config['app']['version'];
      final buildNumber = config['app']['build_number'];
      pubspecEditor.update(['version'], '$appVersion+$buildNumber');

      // حفظ التغييرات
      await pubspecFile.writeAsString(pubspecEditor.toString());
      print('✅ Updated pubspec.yaml with version $appVersion+$buildNumber');
    } else {
      print('❌ pubspec.yaml not found: ${pubspecFile.path}');
    }

    print('✅ Configuration synced successfully');
  } catch (e) {
    print('❌ Error syncing configuration: $e');
  }
}

/// بناء التطبيق
Future<void> buildApp(String platform) async {
  try {
    print('=== 🔨 Building App for $platform ===');

    if (platform == 'all' || platform == 'windows') {
      print('🏗️ Building for Windows...');
      final result = await Process.run('flutter', [
        'build',
        'windows',
        '--release',
      ], workingDirectory: '../../apps/dev_server_app');

      if (result.exitCode == 0) {
        print('✅ Windows build completed');
      } else {
        print('❌ Windows build failed: ${result.stderr}');
      }
    }

    if (platform == 'all' || platform == 'macos') {
      print('🏗️ Building for macOS...');
      final result = await Process.run('flutter', [
        'build',
        'macos',
        '--release',
      ], workingDirectory: '../../apps/dev_server_app');

      if (result.exitCode == 0) {
        print('✅ macOS build completed');
      } else {
        print('❌ macOS build failed: ${result.stderr}');
      }
    }

    if (platform == 'all' || platform == 'linux') {
      print('🏗️ Building for Linux...');
      final result = await Process.run('flutter', [
        'build',
        'linux',
        '--release',
      ], workingDirectory: '../../apps/dev_server_app');

      if (result.exitCode == 0) {
        print('✅ Linux build completed');
      } else {
        print('❌ Linux build failed: ${result.stderr}');
      }
    }

    print('✅ Build process completed');
  } catch (e) {
    print('❌ Error building app: $e');
  }
}

/// إنشاء إصدار جديد
Future<void> createRelease(
  String version,
  String buildNumber,
  bool isRequired,
) async {
  try {
    print('=== 🏷️ Creating Release v$version ===');

    // قراءة ملف التكوين
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final configFile = File('${scriptDir.path}/lib/config/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Config file not found: ${configFile.path}');
      return;
    }

    final configContent = await configFile.readAsString();
    final config = json.decode(configContent);

    // تحديث الإصدار في ملف التكوين
    config['app']['version'] = version;
    config['app']['build_number'] = int.parse(buildNumber);
    config['update']['latest_version'] = version;
    config['update']['latest_build_number'] = int.parse(buildNumber);
    config['update']['is_required'] = isRequired;

    // حفظ التغييرات
    final jsonString = JsonEncoder.withIndent('  ').convert(config);
    await configFile.writeAsString(jsonString);

    // تحديث ملف pubspec.yaml
    await syncConfig();

    print('✅ Release v$version created successfully');
  } catch (e) {
    print('❌ Error creating release: $e');
  }
}

/// الحصول على الإصدار الحالي
Future<void> getVersion() async {
  try {
    print('=== 🔍 Getting Current Version ===');

    // قراءة ملف التكوين
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final configFile = File('${scriptDir.path}/lib/config/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Config file not found: ${configFile.path}');
      return;
    }

    final config = json.decode(await configFile.readAsString());
    final appConfig = config['app'];
    final updateConfig = config['update'];

    final version = appConfig['version'];
    final buildNumber = appConfig['build_number'];
    final latestVersion = updateConfig['latest_version'];
    final latestBuildNumber = updateConfig['latest_build_number'];

    print('💾 App version: $version (build $buildNumber)');
    print('💾 Latest version: $latestVersion (build $latestBuildNumber)');

    // التحقق من وجود تحديث
    if (version != latestVersion || buildNumber != latestBuildNumber) {
      print('⚠️ Version mismatch between app and update config!');
      print(
        'ℹ️ Consider running `dart github_tools.dart sync` to sync versions.',
      );
    }
  } catch (e) {
    print('❌ Error getting version: $e');
  }
}

/// زيادة رقم الإصدار
Future<void> bumpVersion() async {
  try {
    print('=== 🔎 Bumping Version ===');

    // قراءة ملف التكوين
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final configFile = File('${scriptDir.path}/lib/config/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Config file not found: ${configFile.path}');
      return;
    }

    final configContent = await configFile.readAsString();
    final config = json.decode(configContent);

    // الحصول على الإصدار الحالي
    final currentVersion = config['app']['version'];
    final currentBuildNumber = config['app']['build_number'];

    print('💾 Current version: $currentVersion (build $currentBuildNumber)');

    // تحليل الإصدار الحالي
    final versionParts = currentVersion.split('.');
    if (versionParts.length != 3) {
      print('❌ Invalid version format: $currentVersion');
      print('ℹ️ Version should be in format: major.minor.patch');
      return;
    }

    final major = int.parse(versionParts[0]);
    final minor = int.parse(versionParts[1]);
    final patch = int.parse(versionParts[2]);

    // زيادة رقم الإصدار
    final newPatch = patch + 1;
    final newVersion = '$major.$minor.$newPatch';
    final newBuildNumber = currentBuildNumber + 1;

    // تحديث الإصدار في ملف التكوين
    config['app']['version'] = newVersion;
    config['app']['build_number'] = newBuildNumber;
    config['update']['latest_version'] = newVersion;
    config['update']['latest_build_number'] = newBuildNumber;

    // حفظ التغييرات
    final jsonString = JsonEncoder.withIndent('  ').convert(config);
    await configFile.writeAsString(jsonString);

    print('✅ Version bumped to: $newVersion (build $newBuildNumber)');

    // تحديث ملف pubspec.yaml
    await syncConfig();
  } catch (e) {
    print('❌ Error bumping version: $e');
  }
}

/// نشر الإصدار على GitHub
Future<void> publishRelease(
  String version,
  String buildNumber, {
  bool isRequired = false,
}) async {
  try {
    print('=== 📤 Publishing Release v$version to GitHub ===');

    // قراءة ملف التكوين
    final scriptDir = File(Platform.script.toFilePath()).parent.parent;
    final configFile = File('${scriptDir.path}/lib/config/app-config.json');
    if (!await configFile.exists()) {
      print('❌ Config file not found: ${configFile.path}');
      return;
    }

    print('📄 Reading config file: ${configFile.path}');
    final configContent = await configFile.readAsString();
    print('📄 Config file content length: ${configContent.length} bytes');

    Map<String, dynamic> config;
    Map<String, dynamic> repoInfo;
    Map<String, dynamic> githubConfig;
    Map<String, dynamic> updateConfig;
    // Map<String, dynamic> appConfig;

    try {
      config = json.decode(configContent);
      print('📄 Config parsed successfully');

      repoInfo = config['repository'];
      print('📄 Repository info: ${repoInfo['owner']}/${repoInfo['name']}');

      githubConfig = config['github'];
      print('📄 GitHub token length: ${githubConfig['token']?.length ?? 0}');

      updateConfig = config['update'];
      // appConfig = config['app'];
    } catch (e) {
      print('❌ Error parsing config file: $e');
      return;
    }

    // التحقق من وجود توكن GitHub
    final token = githubConfig['token'];
    if (token == null || token.isEmpty) {
      print('❌ GitHub token not found in config file');
      print('Please add your GitHub token to lib/config/app-config.json');
      return;
    }

    // إنشاء عميل GitHub
    final github = GitHub(auth: Authentication.withToken(token));

    // إنشاء الإصدار أو تحديثه إذا كان موجوداً
    Release release;
    try {
      // محاولة إنشاء إصدار جديد
      release = await github.repositories.createRelease(
        RepositorySlug(repoInfo['owner'], repoInfo['name']),
        CreateRelease('v$version')
          ..name = 'v$version'
          ..body = updateConfig['change_log'] ?? 'Release v$version',
      );
      print('✅ GitHub release created: ${release.htmlUrl}');
    } catch (e) {
      if (e.toString().contains('already_exists')) {
        // الإصدار موجود بالفعل، الحصول عليه
        print('ℹ️ Release already exists, getting it...');
        final releases =
            await github.repositories
                .listReleases(
                  RepositorySlug(repoInfo['owner'], repoInfo['name']),
                )
                .toList();

        release = releases.firstWhere(
          (r) => r.tagName == 'v$version',
          orElse: () => throw Exception('Release v$version not found'),
        );
        print('✅ Found existing release: ${release.htmlUrl}');
      } else {
        // خطأ آخر
        rethrow;
      }
    }

    // رفع الملفات المبنية
    print('📤 Uploading build files to GitHub release...');
    final platformsToUpload = ['windows', 'macos', 'linux'];
    final fileExtensions = {
      'windows': '-setup.exe',
      'macos': '.dmg',
      'linux': '.AppImage',
    };

    final platformEmojis = {
      'windows': '💻', // 💻
      'macos': '🍏', // 🍏
      'linux': '🐧', // 🐧
    };

    // رفع ملف التثبيت من مجلد installer
    final installerFileName = 'dev_server-v$version-setup.exe';

    // التحقق من وجود ملف التثبيت في مجلد app_build أولاً
    final newInstallerPath = '../../app_build/installer/$installerFileName';
    final legacyInstallerPath = '../../apps/dev_server_app/build/installer/$installerFileName';

    final newInstallerFile = File(newInstallerPath);
    final legacyInstallerFile = File(legacyInstallerPath);

    File installerFile;
    String installerPath;

    if (await newInstallerFile.exists()) {
      installerFile = newInstallerFile;
      installerPath = newInstallerPath;
      print('🔍 Found installer file in app_build directory: $newInstallerPath');
    } else {
      installerFile = legacyInstallerFile;
      installerPath = legacyInstallerPath;
      print('🔍 Looking for installer file in legacy directory: $legacyInstallerPath');
    }

    try {
      // التحقق من وجود ملف التثبيت
      if (await installerFile.exists()) {
        final fileSize = await installerFile.length();
        print('💾 Uploading installer: $installerFileName ($fileSize bytes)');

        // رفع الملف
        final bytes = await installerFile.readAsBytes();
        final response = await github.request(
          'POST',
          '/repos/${repoInfo['owner']}/${repoInfo['name']}/releases/${release.id}/assets',
          headers: {
            'Content-Type': 'application/octet-stream',
            'Content-Length': bytes.length.toString(),
          },
          params: {'name': installerFileName},
          body: bytes,
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          print('✅ Uploaded installer successfully');
        } else {
          print(
            '❌ Failed to upload installer: ${response.statusCode} ${response.body}',
          );
        }
      } else {
        print('ℹ️ Installer file not found: $installerPath');
        print(
          'ℹ️ You can create it with: dart melos_runner.dart run create:installer',
        );
      }
    } catch (e) {
      print('❌ Failed to upload installer: $e');
    }

    // رفع ملفات المنصات
    for (final platform in platformsToUpload) {
      final fileName = 'dev-server-v$version${fileExtensions[platform]}';
      final contentType = 'application/octet-stream';

      // تحديد مسار الملف
      String filePath;
      if (platform == 'windows') {
        filePath =
            '../../apps/dev_server_app/build/windows/runner/Release/$fileName';
      } else if (platform == 'macos') {
        filePath =
            '../../apps/dev_server_app/build/macos/Build/Products/Release/$fileName';
      } else if (platform == 'linux') {
        filePath =
            '../../apps/dev_server_app/build/linux/x64/release/bundle/$fileName';
      } else {
        continue;
      }

      final file = File(filePath);

      try {
        // التحقق من وجود الملف
        if (await file.exists()) {
          final fileSize = await file.length();
          print(
            '${platformEmojis[platform] ?? '📤'} Uploading $fileName ($fileSize bytes)',
          );

          // رفع الملف
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
            print(
              '❌ Failed to upload $fileName: ${response.statusCode} ${response.body}',
            );
          }
        } else {
          print('❌ File not found: ${file.path}');
        }
      } catch (e) {
        print('❌ Failed to upload $fileName: $e');
      }
    }

    // رفع ملف التكوين أيضاً
    print('📝 Uploading configuration file...');
    try {
      final appConfigFile = configFile;
      if (await appConfigFile.exists()) {
        final configBytes = await appConfigFile.readAsBytes();
        final configResponse = await github.request(
          'POST',
          '/repos/${repoInfo['owner']}/${repoInfo['name']}/releases/${release.id}/assets',
          headers: {
            'Content-Type': 'application/json',
            'Content-Length': configBytes.length.toString(),
          },
          params: {'name': 'app-config.json'},
          body: configBytes,
        );

        if (configResponse.statusCode >= 200 &&
            configResponse.statusCode < 300) {
          print('✅ Uploaded app-config.json');
        } else {
          print(
            '❌ Failed to upload app-config.json: ${configResponse.statusCode} ${configResponse.body}',
          );
        }
      }
    } catch (e) {
      print('❌ Failed to upload app-config.json: $e');
    }

    print('\n✅ Release v$version published successfully!');
    print('🔗 Release URL: ${release.htmlUrl}');
  } catch (e) {
    print('❌ Error during release publishing: $e');
  }
}
