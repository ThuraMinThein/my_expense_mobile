import 'package:dio/dio.dart';
import '../../../core/constants/api_constants.dart';
import '../../../core/utils/environment.dart';

class ApiService {
  final Dio _dio;

  ApiService() : _dio = Dio() {
    _dio.options = BaseOptions(
      baseUrl: ApiConstants.baseUrl,
      connectTimeout: Environment.connectTimeout,
      receiveTimeout: Environment.receiveTimeout,
      sendTimeout: Environment.receiveTimeout,
      headers: {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        'User-Agent': 'MyExpense/1.0.0',
      },
    );

    // Add logging interceptor for debugging
    if (Environment.enableLogging) {
      _dio.interceptors.add(
        LogInterceptor(
          requestBody: true,
          responseBody: true,
          requestHeader: true,
          responseHeader: false,
        ),
      );
    }
  }

  // Auth endpoints
  Future<Map<String, dynamic>> login(String email, String password) async {
    try {
      final response = await _dio.post(
        '/auth/login',
        data: {'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> signInWithGoogle(String idToken) async {
    try {
      final response = await _dio.post(
        '/auth/google/token',
        data: {'id_token': idToken},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> register(
    String name,
    String email,
    String password,
  ) async {
    try {
      final response = await _dio.post(
        '/auth/register',
        data: {'name': name, 'email': email, 'password': password},
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Expense endpoints
  Future<List<Map<String, dynamic>>> getExpenses({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (period != null) queryParams['period'] = period;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _dio.get(
        '/expenses',
        queryParameters: queryParams,
      );
      return List<Map<String, dynamic>>.from(response.data['expenses']);
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> createExpense(
    Map<String, dynamic> expenseData,
  ) async {
    try {
      final response = await _dio.post('/expenses', data: expenseData);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<Map<String, dynamic>> updateExpense(
    String id,
    Map<String, dynamic> expenseData,
  ) async {
    try {
      final response = await _dio.put('/expenses/$id', data: expenseData);
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  Future<void> deleteExpense(String id) async {
    try {
      await _dio.delete('/expenses/$id');
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  // Analytics endpoints
  Future<Map<String, dynamic>> getAnalytics({
    String? period,
    DateTime? startDate,
    DateTime? endDate,
  }) async {
    try {
      final Map<String, dynamic> queryParams = {};
      if (period != null) queryParams['period'] = period;
      if (startDate != null)
        queryParams['startDate'] = startDate.toIso8601String();
      if (endDate != null) queryParams['endDate'] = endDate.toIso8601String();

      final response = await _dio.get(
        '/analytics',
        queryParameters: queryParams,
      );
      return response.data;
    } on DioException catch (e) {
      throw _handleDioError(e);
    }
  }

  String _handleDioError(DioException e) {
    switch (e.type) {
      case DioExceptionType.connectionTimeout:
        return Environment.enableDetailedErrors
            ? 'Connection timeout. Please check your internet connection.'
            : 'Unable to connect to server. Please try again.';
      case DioExceptionType.sendTimeout:
        return 'Request timeout. Please try again.';
      case DioExceptionType.receiveTimeout:
        return 'Response timeout. Please try again.';
      case DioExceptionType.badResponse:
        return _handleBadResponse(e);
      case DioExceptionType.cancel:
        return 'Request was cancelled.';
      case DioExceptionType.connectionError:
        return Environment.enableDetailedErrors
            ? 'No internet connection. Please check your network.'
            : 'Network error. Please check your internet connection and try again.';
      case DioExceptionType.unknown:
      default:
        return Environment.enableDetailedErrors
            ? 'An unexpected error occurred: ${e.message}'
            : 'Something went wrong. Please try again later.';
    }
  }

  String _handleBadResponse(DioException e) {
    final statusCode = e.response?.statusCode;
    final data = e.response?.data;

    // Try to extract custom error message from response
    if (data is Map<String, dynamic>) {
      if (data['message'] != null) {
        return data['message'].toString();
      }
      if (data['error'] != null) {
        return data['error'].toString();
      }
    }

    // Fallback to status code based messages
    switch (statusCode) {
      case 400:
        return 'Bad request. Please check your input.';
      case 401:
        return 'Authentication required. Please log in again.';
      case 403:
        return 'Access denied. You do not have permission.';
      case 404:
        return Environment.enableDetailedErrors
            ? 'Endpoint not found: ${e.requestOptions.uri}'
            : 'Resource not found.';
      case 429:
        return 'Too many requests. Please try again later.';
      case 500:
        return 'Server error. Please try again later.';
      case 502:
      case 503:
      case 504:
        return 'Service unavailable. Please try again later.';
      default:
        return Environment.enableDetailedErrors
            ? 'Server error occurred: $statusCode'
            : 'Server error occurred. Please try again.';
    }
  }

  void setAuthToken(String token) {
    _dio.options.headers['Authorization'] = 'Bearer $token';
  }

  void clearAuthToken() {
    _dio.options.headers.remove('Authorization');
  }

  // Method to update base URL dynamically (useful for fallback URLs)
  void updateBaseUrl(String newBaseUrl) {
    _dio.options.baseUrl = newBaseUrl + ApiConstants.apiPrefix;
  }

  // Method to test API connectivity
  Future<bool> testConnectivity() async {
    try {
      final response = await _dio.get('/health');
      return response.statusCode == 200;
    } catch (e) {
      if (Environment.enableLogging) {
        print('Connectivity test failed: $e');
      }
      return false;
    }
  }

  // Method to try different production URLs as fallback
  Future<bool> tryFallbackUrls() async {
    if (Environment.isDebug) return true; // Skip in debug mode

    for (final url in ApiConstants.productionUrlFallbacks) {
      try {
        final originalBaseUrl = _dio.options.baseUrl;
        updateBaseUrl(url);

        if (await testConnectivity()) {
          return true;
        }

        // Restore original if this failed
        _dio.options.baseUrl = originalBaseUrl;
      } catch (e) {
        // Continue to next URL
        continue;
      }
    }
    return false;
  }
}
