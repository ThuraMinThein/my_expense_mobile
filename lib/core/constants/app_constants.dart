import 'package:flutter/material.dart';

class AppConstants {
  static const String appName = 'My Expense';
  static const String appVersion = '1.0.0';

  static const List<String> expenseCategories = [
    'Food',
    'Transport',
    'Shopping',
    'Entertainment',
    'Health',
    'Education',
    'Other',
    'Bills',
  ];

  static const List<String> currencies = [
    'USD',
    'EUR',
    'GBP',
    'JPY',
    'CNY',
    'INR',
    'AUD',
    'CAD',
    'MMK',
  ];

  static const String defaultCurrency = 'USD';

  static const String dateFormat = 'MMM dd, yyyy';
  static const String timeFormat = 'hh:mm a';
  static const String dateTimeFormat = 'MMM dd, yyyy hh:mm a';

  static const EdgeInsets defaultPadding = EdgeInsets.all(16.0);
  static const EdgeInsets smallPadding = EdgeInsets.all(8.0);
  static const EdgeInsets largePadding = EdgeInsets.all(24.0);

  static const double borderRadius = 12.0;
  static const double largeBorderRadius = 16.0;
  static const double smallBorderRadius = 8.0;

  static const double cardElevation = 2.0;
  static const double largeCardElevation = 4.0;

  static const Duration defaultAnimationDuration = Duration(milliseconds: 300);
  static const Duration fastAnimationDuration = Duration(milliseconds: 150);
  static const Duration slowAnimationDuration = Duration(milliseconds: 500);
}

enum ExpenseCategory {
  food('Food'),
  transport('Transport'),
  shopping('Shopping'),
  entertainment('Entertainment'),
  health('Health'),
  education('Education'),
  other('Other'),
  bills('Bills');

  const ExpenseCategory(this.name);
  final String name;
}

enum PeriodFilter {
  daily('Daily'),
  weekly('Weekly'),
  monthly('Monthly');

  const PeriodFilter(this.label);
  final String label;
}
