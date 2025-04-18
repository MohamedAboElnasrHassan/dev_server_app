import 'dart:async';
import 'package:get/get.dart';
import '../base/app_base.dart';
import '../logging/logger.dart';
import '../storage/storage_manager.dart';

/// حالة الاستجابة
enum ResponseStatus {
  success,
  error,
  loading,
  networkError,
  timeoutError,
  serverError,
  authError,
  validationError,
}

/// نموذج الاستجابة
class ApiResponse<T> {
  final T? data;
  final String? message;
  final ResponseStatus status;
  final int? statusCode;
  final Map<String, dynamic>? errors;

  ApiResponse({
    this.data,
    this.message,
    required this.status,
    this.statusCode,
    this.errors,
  });

  bool get isSuccess => status == ResponseStatus.success;
  bool get isError => status != ResponseStatus.success;
  bool get isLoading => status == ResponseStatus.loading;
  bool get isNetworkError => status == ResponseStatus.networkError;
  bool get isTimeoutError => status == ResponseStatus.timeoutError;
  bool get isServerError => status == ResponseStatus.serverError;
  bool get isAuthError => status == ResponseStatus.authError;
  bool get isValidationError => status == ResponseStatus.validationError;

  /// إنشاء استجابة نجاح
  static ApiResponse<T> success<T>(T data, {String? message, int? statusCode}) {
    return ApiResponse<T>(
      data: data,
      message: message,
      status: ResponseStatus.success,
      statusCode: statusCode,
    );
  }

  /// إنشاء استجابة خطأ
  static ApiResponse<T> error<T>(String message, {
    ResponseStatus status = ResponseStatus.error,
    int? statusCode,
    Map<String, dynamic>? errors,
  }) {
    return ApiResponse<T>(
      message: message,
      status: status,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// إنشاء استجابة تحميل
  static ApiResponse<T> loading<T>() {
    return ApiResponse<T>(
      status: ResponseStatus.loading,
    );
  }
}

/// مدير الشبكة
class ApiManager extends BaseService {
  final Logger _logger = Get.find<Logger>();
  late GetConnect _connect;
  final String baseUrl;
  final Map<String, String> defaultHeaders;
  final Duration timeout;

  ApiManager({
    required this.baseUrl,
    this.defaultHeaders = const {},
    this.timeout = const Duration(seconds: 30),
  });

  Future<ApiManager> init() async {
    await initService();

    _connect = GetConnect(
      timeout: timeout,
      userAgent: 'MyApp/1.0',
    );

    _connect.baseUrl = baseUrl;

    // إضافة معدل الطلبات
    _connect.httpClient.addRequestModifier<dynamic>((request) {
      // إضافة الرؤوس الافتراضية
      defaultHeaders.forEach((key, value) {
        request.headers[key] = value;
      });

      // إضافة رأس المصادقة إذا كان متاحًا
      final storageManager = Get.find<StorageManager>();
      // استخدام الدالة الغير متزامنة للحصول على الرمز المميز
      storageManager.read<String>('auth_token').then((token) {
        if (token != null && token.isNotEmpty) {
          request.headers['Authorization'] = 'Bearer $token';
        }
      });

      _logger.info('API Request: ${request.method} ${request.url}');
      return request;
    });

    // إضافة معدل الاستجابات
    _connect.httpClient.addResponseModifier<dynamic>((request, response) {
      final statusCode = response.statusCode;
      final url = request.url.toString();

      if (statusCode != null && statusCode >= 200 && statusCode < 300) {
        _logger.info('API Response: $statusCode - $url');
      } else {
        _logger.error(
          'API Error: $statusCode - $url',
          tag: 'API',
          error: response.bodyString,
        );
      }

      return response;
    });

    return this;
  }

  /// إرسال طلب GET
  Future<ApiResponse<T>> get<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await _connect.get(
        path,
        query: query,
        headers: headers,
        decoder: decoder,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// إرسال طلب POST
  Future<ApiResponse<T>> post<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await _connect.post(
        path,
        body,
        query: query,
        headers: headers,
        decoder: decoder,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// إرسال طلب PUT
  Future<ApiResponse<T>> put<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await _connect.put(
        path,
        body,
        query: query,
        headers: headers,
        decoder: decoder,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// إرسال طلب DELETE
  Future<ApiResponse<T>> delete<T>(
    String path, {
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await _connect.delete(
        path,
        query: query,
        headers: headers,
        decoder: decoder,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// إرسال طلب PATCH
  Future<ApiResponse<T>> patch<T>(
    String path, {
    dynamic body,
    Map<String, dynamic>? query,
    Map<String, String>? headers,
    T Function(dynamic)? decoder,
  }) async {
    try {
      final response = await _connect.patch(
        path,
        body,
        query: query,
        headers: headers,
        decoder: decoder,
      );

      return _handleResponse<T>(response);
    } catch (e) {
      return _handleError<T>(e);
    }
  }

  /// إنشاء اتصال WebSocket
  GetSocket socket(String path) {
    return _connect.socket(path);
  }

  /// معالجة الاستجابة
  ApiResponse<T> _handleResponse<T>(Response response) {
    final statusCode = response.statusCode;

    if (statusCode == null || statusCode < 200 || statusCode >= 300) {
      return _handleErrorResponse<T>(response);
    }

    return ApiResponse.success<T>(
      response.body,
      message: response.statusText,
      statusCode: statusCode,
    );
  }

  /// معالجة استجابة الخطأ
  ApiResponse<T> _handleErrorResponse<T>(Response response) {
    final statusCode = response.statusCode;
    final message = response.statusText ?? 'حدث خطأ غير معروف';

    ResponseStatus status;

    if (statusCode == null) {
      status = ResponseStatus.networkError;
    } else if (statusCode == 401 || statusCode == 403) {
      status = ResponseStatus.authError;
    } else if (statusCode == 422) {
      status = ResponseStatus.validationError;
    } else if (statusCode >= 500) {
      status = ResponseStatus.serverError;
    } else {
      status = ResponseStatus.error;
    }

    Map<String, dynamic>? errors;
    if (response.body is Map) {
      errors = response.body['errors'];
    }

    return ApiResponse.error<T>(
      message,
      status: status,
      statusCode: statusCode,
      errors: errors,
    );
  }

  /// معالجة الخطأ
  ApiResponse<T> _handleError<T>(Object e) {
    if (e is TimeoutException) {
      return ApiResponse.error<T>(
        'انتهت مهلة الاتصال',
        status: ResponseStatus.timeoutError,
      );
    }

    return ApiResponse.error<T>(
      e.toString(),
      status: ResponseStatus.networkError,
    );
  }
}
