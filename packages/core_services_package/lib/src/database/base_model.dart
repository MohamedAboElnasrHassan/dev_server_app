/// نموذج قاعدة للكيانات
abstract class BaseModel {
  /// تحويل النموذج إلى Map
  Map<String, dynamic> toMap();

  /// تحويل النموذج إلى JSON
  Map<String, dynamic> toJson() => toMap();

  /// نسخ النموذج مع تحديث بعض الحقول
  BaseModel copyWith();
}
