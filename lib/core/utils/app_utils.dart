import 'package:intl/intl.dart';

class AppUtils {
  static String formatAmount(double amount, {String currency = 'USD'}) {
    final format = NumberFormat.currency(
      symbol: _getCurrencySymbol(currency),
      decimalDigits: 2,
    );
    return format.format(amount);
  }

  static String formatDateTime(
    DateTime dateTime, {
    String format = 'MMM dd, yyyy',
  }) {
    return DateFormat(format).format(dateTime);
  }

  static String formatDate(DateTime dateTime) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final expenseDate = DateTime(dateTime.year, dateTime.month, dateTime.day);

    final difference = expenseDate.difference(today).inDays;

    if (difference == 0) {
      return 'Today';
    } else if (difference == -1) {
      return 'Yesterday';
    } else if (difference > -7) {
      return DateFormat('EEEE').format(dateTime); // Day name
    } else {
      return AppUtils.formatDateTime(dateTime, format: 'MMM dd, yyyy');
    }
  }

  static String _getCurrencySymbol(String currency) {
    switch (currency) {
      case 'USD':
        return '\$';
      case 'EUR':
        return '€';
      case 'GBP':
        return '£';
      case 'JPY':
        return '¥';
      case 'CNY':
        return '¥';
      case 'INR':
        return '₹';
      case 'AUD':
        return '\$';
      case 'CAD':
        return '\$';
      default:
        return '\$';
    }
  }

  static DateTime getStartOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day);
  }

  static DateTime getEndOfDay(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, dateTime.day, 23, 59, 59);
  }

  static DateTime getStartOfWeek(DateTime dateTime) {
    final date = dateTime;
    final weekDay = date.weekday;
    final startOfWeek = date.subtract(Duration(days: weekDay - 1));
    return getStartOfDay(startOfWeek);
  }

  static DateTime getEndOfWeek(DateTime dateTime) {
    final date = dateTime;
    final weekDay = date.weekday;
    final endOfWeek = date.add(Duration(days: 7 - weekDay));
    return getEndOfDay(endOfWeek);
  }

  static DateTime getStartOfMonth(DateTime dateTime) {
    return DateTime(dateTime.year, dateTime.month, 1);
  }

  static DateTime getEndOfMonth(DateTime dateTime) {
    final nextMonth = DateTime(dateTime.year, dateTime.month + 1, 1);
    return nextMonth.subtract(const Duration(days: 1));
  }

  static String getInitials(String name) {
    if (name.isEmpty) return '';
    final parts = name.trim().split(' ');
    if (parts.length >= 2) {
      return parts[0][0].toUpperCase() + parts[1][0].toUpperCase();
    }
    return name[0].toUpperCase();
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  static String getErrorMessage(String error) {
    switch (error.toLowerCase()) {
      case 'user-not-found':
        return 'User not found. Please check your email.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'This email is already registered. Please use a different email.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Invalid email address. Please check and try again.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      default:
        return 'An error occurred. Please try again.';
    }
  }
}
