import 'package:flutter/foundation.dart';

class Environment {
  static bool get isDebug => kDebugMode;
  static bool get isRelease => kReleaseMode;
  static bool get isProfile => kProfileMode;

  static String get environmentName {
    if (kDebugMode) return 'Development';
    if (kReleaseMode) return 'Production';
    if (kProfileMode) return 'Profile';
    return 'Unknown';
  }

  // Network settings based on environment
  static Duration get connectTimeout {
    switch (environmentName) {
      case 'Development':
        return const Duration(seconds: 10);
      case 'Production':
        return const Duration(seconds: 15);
      default:
        return const Duration(seconds: 10);
    }
  }

  static Duration get receiveTimeout {
    switch (environmentName) {
      case 'Development':
        return const Duration(seconds: 10);
      case 'Production':
        return const Duration(seconds: 15);
      default:
        return const Duration(seconds: 10);
    }
  }

  // Retry settings
  static int get maxRetries => kDebugMode ? 1 : 3;

  // Logging settings
  static bool get enableLogging => kDebugMode;
  static bool get enableDetailedErrors => kDebugMode;

  // API URL resolution strategy
  static String resolveApiUrl(List<String> possibleUrls) {
    if (kDebugMode) {
      // In debug, always use the first (development) URL
      return possibleUrls.first;
    } else {
      // In production, you could implement smarter logic here
      // For now, return the first production URL
      return possibleUrls.firstWhere(
        (url) => url.startsWith('https'),
        orElse: () => possibleUrls.first,
      );
    }
  }
}
