import 'package:flutter/foundation.dart';

class ApiConstants {
  static String get baseUrl {
    if (kDebugMode) {
      // Development environment
      return _getDevelopmentBaseUrl();
    } else {
      // Production environment
      return _getProductionBaseUrl();
    }
  }

  static const String apiPrefix = '';

  static String _getDevelopmentBaseUrl() {
    // Use 10.0.2.2 for Android emulator to access host localhost
    // Use localhost for iOS simulator
    // Use your machine's IP for real device
    return 'http://10.0.2.2:3333';
  }

  static String _getProductionBaseUrl() {
    // Production API URL - replace with your actual production backend URL
    // You can also use environment variables or different strategies:
    // 1. Fixed production URL:
    return 'https://api.myexpense.app'; // Update this with your production URL

    // 2. Alternative: Try common production URLs as fallback
    // return _tryProductionUrls();

    // 3. Alternative: Use environment variable (requires flutter_dotenv package)
    // return dotenv.env['API_BASE_URL'] ?? 'https://api.myexpense.app';
  }

  static List<String> get productionUrlFallbacks => [
    'https://api.myexpense.app',
    'https://myexpense-api.herokuapp.com',
    'https://api.myexpense.herokuapp.com',
    'https://my-expense-api.onrender.com',
  ];

  // Auth Endpoints
  static const String login = '/auth/login';
  static const String register = '/auth/register';
  static const String googleAuth = '/auth/google';
  static const String logout = '/auth/logout';
  static const String refreshToken = '/auth/refresh';

  // Expense Endpoints
  static const String expenses = '/expenses';
  static const String dailyUsage = '/expenses/daily';
  static const String weeklyUsage = '/expenses/weekly';
  static const String monthlyUsage = '/expenses/monthly';

  // Analytics
  static const String analytics = '/analytics';
}
