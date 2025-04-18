// ignore_for_file: avoid_print

import 'dart:io';
import 'package:github/github.dart';
import 'github_utils.dart' as github_utils;

/// إنشاء مستودع جديد على GitHub
Future<bool> createRepository(String owner, String name) async {
  try {
    final token = await github_utils.getGitHubToken();
    if (token == null) {
      print('❌ GitHub token not found');
      print('ℹ️ Please set your GitHub token using: dart tools/dev_tools.dart set-token YOUR_TOKEN');
      return false;
    }

    final github = GitHub(auth: Authentication.withToken(token));

    print('ℹ️ Creating repository: $owner/$name');

    try {
      // محاولة إنشاء المستودع في حساب المستخدم
      final repository = await github.repositories.createRepository(
        CreateRepository(name)
          ..description = 'Dev Server App with auto-update support'
          ..private = false
          ..hasIssues = true
          ..hasWiki = true
          ..autoInit = true,
      );

      print('✅ Repository created successfully: ${repository.htmlUrl}');
      return true;
    } catch (e) {
      // إذا فشل إنشاء المستودع في حساب المستخدم، حاول إنشاءه في منظمة
      try {
        // إنشاء المستودع في منظمة
        final createRepo = CreateRepository(name)
          ..description = 'Dev Server App with auto-update support'
          ..private = false
          ..hasIssues = true
          ..hasWiki = true
          ..autoInit = true;

        // استخدام طريقة مختلفة لإنشاء المستودع في منظمة
        final response = await github.request(
          'POST',
          '/orgs/$owner/repos',
          body: createRepo.toJson(),
        );

        if (response.statusCode >= 200 && response.statusCode < 300) {
          final repository = Repository.fromJson(response.body as Map<String, dynamic>);
          print('✅ Repository created successfully in organization: ${repository.htmlUrl}');
          return true;
        } else {
          print('❌ Failed to create repository in organization: ${response.statusCode} ${response.body}');
          return false;
        }
      } catch (e2) {
        print('❌ Failed to create repository: $e2');
        return false;
      }
    }
  } catch (e) {
    print('❌ Error creating repository: $e');
    return false;
  }
}

/// تهيئة المستودع المحلي وربطه بالمستودع البعيد
Future<bool> initializeLocalRepository(String owner, String name) async {
  try {
    // التحقق مما إذا كان المجلد الحالي مستودع Git
    final isGitRepo = await Process.run('git', ['rev-parse', '--is-inside-work-tree']);

    if (isGitRepo.exitCode != 0) {
      // إنشاء مستودع Git جديد
      print('ℹ️ Initializing Git repository...');
      final initResult = await Process.run('git', ['init']);
      if (initResult.exitCode != 0) {
        print('❌ Failed to initialize Git repository: ${initResult.stderr}');
        return false;
      }
    }

    // إضافة المستودع البعيد
    print('ℹ️ Adding remote repository...');
    final remoteUrl = 'https://github.com/$owner/$name.git';

    // التحقق من وجود remote origin
    final checkRemoteResult = await Process.run('git', ['remote']);
    final remotes = checkRemoteResult.stdout.toString().trim().split('\n');

    if (remotes.contains('origin')) {
      // تحديث المستودع البعيد الموجود
      final setUrlResult = await Process.run('git', ['remote', 'set-url', 'origin', remoteUrl]);
      if (setUrlResult.exitCode != 0) {
        print('❌ Failed to update remote URL: ${setUrlResult.stderr}');
        return false;
      }
    } else {
      // إضافة مستودع بعيد جديد
      final addRemoteResult = await Process.run('git', ['remote', 'add', 'origin', remoteUrl]);
      if (addRemoteResult.exitCode != 0) {
        print('❌ Failed to add remote: ${addRemoteResult.stderr}');
        return false;
      }
    }

    print('✅ Repository initialized and connected to GitHub');

    // سؤال المستخدم إذا كان يريد إضافة ودفع الملفات
    final shouldPush = await github_utils.confirmAction('Do you want to add and push all files to the repository?');
    if (shouldPush) {
      // إضافة جميع الملفات
      print('ℹ️ Adding all files...');
      final addResult = await Process.run('git', ['add', '.']);
      if (addResult.exitCode != 0) {
        print('❌ Failed to add files: ${addResult.stderr}');
        return false;
      }

      // إنشاء commit
      print('ℹ️ Creating commit...');
      final commitResult = await Process.run('git', ['commit', '-m', 'Initial commit']);
      if (commitResult.exitCode != 0) {
        print('❌ Failed to create commit: ${commitResult.stderr}');
        return false;
      }

      // دفع التغييرات
      print('ℹ️ Pushing to GitHub...');
      final pushResult = await Process.run('git', ['push', '-u', 'origin', 'main']);
      if (pushResult.exitCode != 0) {
        // محاولة دفع إلى master إذا فشل الدفع إلى main
        final pushMasterResult = await Process.run('git', ['push', '-u', 'origin', 'master']);
        if (pushMasterResult.exitCode != 0) {
          print('❌ Failed to push to GitHub: ${pushResult.stderr}');
          print('ℹ️ You may need to push manually using: git push -u origin main');
          return false;
        }
      }

      print('✅ All files pushed to GitHub successfully');
    }

    return true;
  } catch (e) {
    print('❌ Error initializing repository: $e');
    return false;
  }
}

/// التحقق من وجود المستودع وإنشاءه إذا لم يكن موجوداً
Future<bool> checkAndCreateRepository(Map<String, String> repoInfo) async {
  try {
    final token = await github_utils.getGitHubToken();
    if (token == null) {
      print('❌ GitHub token not found');
      return false;
    }

    final github = GitHub(auth: Authentication.withToken(token));
    final owner = repoInfo['owner']!;
    final name = repoInfo['name']!;
    final slug = RepositorySlug(owner, name);

    try {
      // محاولة الحصول على المستودع للتحقق من وجوده
      await github.repositories.getRepository(slug);
      print('✅ Repository exists: $owner/$name');
      return true;
    } catch (e) {
      // المستودع غير موجود، سؤال المستخدم إذا كان يريد إنشاءه
      print('ℹ️ Repository does not exist: $owner/$name');
      final shouldCreate = await github_utils.confirmAction('Do you want to create the repository automatically?');

      if (shouldCreate) {
        final success = await createRepository(owner, name);
        if (success) {
          // ربط المستودع المحلي بالمستودع البعيد
          await initializeLocalRepository(owner, name);
          return true;
        }
      }

      return false;
    }
  } catch (e) {
    print('❌ Error checking repository: $e');
    return false;
  }
}
