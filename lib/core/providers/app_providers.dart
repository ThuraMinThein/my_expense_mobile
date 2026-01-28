import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../features/expense/services/api_service.dart';

final preferencesProvider = Provider<SharedPreferences>((ref) {
  throw UnimplementedError('SharedPreferencesProvider must be overridden');
});

final currencyProvider = StateProvider<String>((ref) {
  return 'MMK';
});

final themeProvider = StateProvider<bool>((ref) {
  return false; // false for light, true for dark
});

class UserData {
  final String id;
  final String name;
  final String email;
  final String? photoUrl;

  const UserData({
    required this.id,
    required this.name,
    required this.email,
    this.photoUrl,
  });

  UserData copyWith({
    String? id,
    String? name,
    String? email,
    String? photoUrl,
  }) {
    return UserData(
      id: id ?? this.id,
      name: name ?? this.name,
      email: email ?? this.email,
      photoUrl: photoUrl ?? this.photoUrl,
    );
  }

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'].toString(),
      name: json['name'] ?? '',
      email: json['email'] ?? '',
    );
  }
}

final apiServiceProvider = Provider<ApiService>((ref) {
  return ApiService();
});
