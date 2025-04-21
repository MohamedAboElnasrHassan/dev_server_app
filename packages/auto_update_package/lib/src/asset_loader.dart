import 'dart:convert';
import 'package:flutter/services.dart';

/// دالة لتحميل ملف من الأصول
class AssetLoader {
  /// تحميل ملف JSON من الأصول
  static Future<Map<String, dynamic>> loadJsonAsset(String assetPath) async {
    try {
      // تحميل الملف كنص
      final jsonString = await rootBundle.loadString(assetPath);

      // تحويل النص إلى كائن JSON
      final jsonData = json.decode(jsonString) as Map<String, dynamic>;

      return jsonData;
    } catch (e) {
      throw Exception('Error loading asset: $assetPath - $e');
    }
  }
}
