import 'package:get/get.dart';

/// مدير النماذج المخصص للتعامل مع النماذج بشكل أكثر تنظيمًا
class FormManager {
  final Map<String, Rx<FormField>> _fields = {};
  final isValid = false.obs;
  final isDirty = false.obs;

  /// تسجيل حقل جديد في النموذج
  void registerField(
    String name, {
    dynamic initialValue,
    List<FormValidator>? validators,
  }) {
    _fields[name] =
        FormField(
          name: name,
          value: initialValue,
          validators: validators ?? [],
        ).obs;
    _validateForm();
  }

  /// تعيين قيمة لحقل
  void setValue(String name, dynamic value) {
    if (_fields.containsKey(name)) {
      final field = _fields[name]!.value;
      field.value = value;
      field.isDirty = true;
      field.validate();
      _fields[name]!.refresh();

      isDirty.value = true;
      _validateForm();
    }
  }

  /// الحصول على قيمة حقل
  dynamic getValue(String name) {
    return _fields[name]?.value.value;
  }

  /// الحصول على خطأ حقل
  String? getError(String name) {
    return _fields[name]?.value.error;
  }

  /// التحقق من صحة حقل
  bool isFieldValid(String name) {
    return _fields[name]?.value.isValid ?? false;
  }

  /// التحقق من صحة النموذج بالكامل
  void _validateForm() {
    isValid.value = _fields.values.every((field) => field.value.isValid);
  }

  /// الحصول على جميع قيم النموذج
  Map<String, dynamic> getValues() {
    final result = <String, dynamic>{};
    for (final entry in _fields.entries) {
      result[entry.key] = entry.value.value.value;
    }
    return result;
  }

  /// إعادة تعيين النموذج
  void reset() {
    for (final field in _fields.values) {
      field.value.reset();
      field.refresh();
    }
    isDirty.value = false;
    _validateForm();
  }

  /// التحقق من صحة النموذج بالكامل
  bool validate() {
    for (final field in _fields.values) {
      field.value.validate();
      field.refresh();
    }
    _validateForm();
    return isValid.value;
  }
}

/// حقل النموذج
class FormField {
  final String name;
  dynamic value;
  final List<FormValidator> validators;
  String? error;
  bool isDirty = false;
  bool isValid = true;

  FormField({required this.name, this.value, required this.validators});

  /// التحقق من صحة الحقل
  void validate() {
    error = null;

    for (final validator in validators) {
      final result = validator(value);
      if (result != null) {
        error = result;
        isValid = false;
        return;
      }
    }

    isValid = true;
  }

  /// إعادة تعيين الحقل
  void reset() {
    error = null;
    isDirty = false;
    isValid = true;
  }
}

/// نوع دالة التحقق من صحة الحقل
typedef FormValidator = String? Function(dynamic value);

/// مكتبة من دوال التحقق الشائعة
class Validators {
  /// التحقق من أن القيمة غير فارغة
  static FormValidator required(String message) {
    return (value) {
      if (value == null || (value is String && value.isEmpty)) {
        return message;
      }
      return null;
    };
  }

  /// التحقق من أن القيمة بريد إلكتروني صحيح
  static FormValidator email(String message) {
    return (value) {
      if (value == null || value is! String || !GetUtils.isEmail(value)) {
        return message;
      }
      return null;
    };
  }

  /// التحقق من أن القيمة رقم هاتف صحيح
  static FormValidator phone(String message) {
    return (value) {
      if (value == null || value is! String || !GetUtils.isPhoneNumber(value)) {
        return message;
      }
      return null;
    };
  }

  /// التحقق من أن القيمة URL صحيح
  static FormValidator url(String message) {
    return (value) {
      if (value == null || value is! String || !GetUtils.isURL(value)) {
        return message;
      }
      return null;
    };
  }

  /// التحقق من أن القيمة لا تقل عن الحد الأدنى
  static FormValidator minLength(int min, String message) {
    return (value) {
      if (value == null || value is! String || value.length < min) {
        return message;
      }
      return null;
    };
  }

  /// التحقق من أن القيمة لا تزيد عن الحد الأقصى
  static FormValidator maxLength(int max, String message) {
    return (value) {
      if (value == null || value is! String || value.length > max) {
        return message;
      }
      return null;
    };
  }

  /// التحقق من أن القيمة تطابق نمط معين
  static FormValidator pattern(RegExp pattern, String message) {
    return (value) {
      if (value == null || value is! String || !pattern.hasMatch(value)) {
        return message;
      }
      return null;
    };
  }
}
