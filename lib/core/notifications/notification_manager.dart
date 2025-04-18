import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../base/app_base.dart';

/// مدير الإشعارات
class NotificationManager extends BaseService {
  final notifications = <AppNotification>[].obs;
  final unreadCount = 0.obs;

  Future<NotificationManager> init() async {
    await initService();
    // يمكن تحميل الإشعارات من التخزين المحلي هنا
    return this;
  }

  /// إضافة إشعار جديد
  void addNotification(AppNotification notification) {
    notifications.insert(0, notification);
    if (!notification.isRead) {
      unreadCount.value++;
    }

    // عرض إشعار منبثق إذا كان الإشعار مهمًا
    if (notification.isImportant) {
      Get.snackbar(
        notification.title,
        notification.message,
        duration: const Duration(seconds: 5),
        backgroundColor: notification.color.withAlpha(204), // 0.8 opacity
        colorText: Colors.white,
        mainButton: TextButton(
          onPressed: () {
            markAsRead(notification.id);
            Get.back();
            if (notification.action != null) {
              notification.action!();
            }
          },
          child: const Text('عرض', style: TextStyle(color: Colors.white)),
        ),
      );
    }
  }

  /// تحديد إشعار كمقروء
  void markAsRead(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = notifications[index];
      if (!notification.isRead) {
        notification.isRead = true;
        notifications[index] = notification;
        unreadCount.value--;
        notifications.refresh();
      }
    }
  }

  /// تحديد جميع الإشعارات كمقروءة
  void markAllAsRead() {
    for (var i = 0; i < notifications.length; i++) {
      if (!notifications[i].isRead) {
        final notification = notifications[i];
        notification.isRead = true;
        notifications[i] = notification;
      }
    }
    unreadCount.value = 0;
    notifications.refresh();
  }

  /// إزالة إشعار
  void removeNotification(String id) {
    final index = notifications.indexWhere((n) => n.id == id);
    if (index != -1) {
      final notification = notifications[index];
      if (!notification.isRead) {
        unreadCount.value--;
      }
      notifications.removeAt(index);
    }
  }

  /// مسح جميع الإشعارات
  void clearAll() {
    notifications.clear();
    unreadCount.value = 0;
  }
}

/// نموذج الإشعار
class AppNotification {
  final String id;
  final String title;
  final String message;
  final DateTime time;
  final Color color;
  final IconData icon;
  final Function? action;
  final bool isImportant;
  bool isRead;

  AppNotification({
    required this.id,
    required this.title,
    required this.message,
    required this.time,
    this.color = Colors.blue,
    this.icon = Icons.notifications,
    this.action,
    this.isImportant = false,
    this.isRead = false,
  });

  /// إنشاء إشعار من JSON
  factory AppNotification.fromJson(Map<String, dynamic> json) {
    return AppNotification(
      id: json['id'],
      title: json['title'],
      message: json['message'],
      time: DateTime.parse(json['time']),
      color: Color(json['color']),
      icon: IconData(json['icon'], fontFamily: 'MaterialIcons'),
      isImportant: json['isImportant'] ?? false,
      isRead: json['isRead'] ?? false,
    );
  }

  /// تحويل الإشعار إلى JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'message': message,
      'time': time.toIso8601String(),
      'color': color.toARGB32(), // Convert to int safely
      'icon': icon.codePoint,
      'isImportant': isImportant,
      'isRead': isRead,
    };
  }
}
