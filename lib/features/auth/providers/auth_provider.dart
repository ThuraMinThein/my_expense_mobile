import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/app_providers.dart';
import '../../expense/services/api_service.dart';
import '../services/auth_service.dart';

// State for authentication
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final String? token;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.token,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    String? token,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      token: token ?? this.token,
      errorMessage: errorMessage,
    );
  }
}

class AuthNotifier extends StateNotifier<AuthState> {
  final AuthService _googleAuthService;
  final ApiService _apiService;
  final SharedPreferences _prefs;

  AuthNotifier({
    required AuthService googleAuthService,
    required ApiService apiService,
    required SharedPreferences prefs,
  }) : _googleAuthService = googleAuthService,
       _apiService = apiService,
       _prefs = prefs,
       super(const AuthState()) {
    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    final token = _prefs.getString('auth_token');
    final userJson = _prefs.getString('user_data');

    if (token != null && token.isNotEmpty) {
      _apiService.setAuthToken(token);
      // Ideally verify token validity with backend here
      if (userJson != null) {
        // Parse user data - simplifying for now as we don't have a fromJson yet
        // In a real app, you'd parse the JSON or fetch profile
        state = state.copyWith(status: AuthStatus.authenticated);
      } else {
        state = state.copyWith(status: AuthStatus.authenticated);
      }
    } else {
      state = state.copyWith(status: AuthStatus.unauthenticated);
    }
  }

  Future<void> login(String userName, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _apiService.login(userName, password);
      final token = response['access_token'];

      if (token != null) {
        await _prefs.setString('auth_token', token);
        _apiService.setAuthToken(token);

        // Map response to UserData

        state = state.copyWith(status: AuthStatus.authenticated, token: token);
      } else {
        state = state.copyWith(
          status: AuthStatus.error,
          errorMessage: "Invalid response from server",
        );
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String userName, String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _apiService.register(userName, email, password);
      // Assuming register returns same as login or success message
      // If it auto-logins:
      final token = response['access_token'];

      if (token != null) {
        await _prefs.setString('auth_token', token);
        _apiService.setAuthToken(token);
        state = state.copyWith(status: AuthStatus.authenticated, token: token);
      } else {
        // If registration requires login afterwards
        state = state.copyWith(status: AuthStatus.unauthenticated);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> signInWithGoogle() async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      // 1. Sign in with Google Client
      final googleAuthData = await _googleAuthService.signInWithGoogle();
      final idToken = googleAuthData['idToken'];

      if (idToken == null) {
        throw 'Failed to get ID Token from Google';
      }

      // 2. Send ID Token to Backend
      final response = await _apiService.signInWithGoogle(idToken);
      final token = response['access_token'];
      if (token != null) {
        await _prefs.setString('auth_token', token);
        _apiService.setAuthToken(token);
        state = state.copyWith(status: AuthStatus.authenticated, token: token);
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> logout() async {
    await _googleAuthService.signOut();
    await _prefs.remove('auth_token');
    _apiService.clearAuthToken();
    state = state.copyWith(status: AuthStatus.unauthenticated, token: null);
  }
}

final authProvider = StateNotifierProvider<AuthNotifier, AuthState>((ref) {
  final googleAuthService = AuthService();
  final apiService = ref.watch(apiServiceProvider);
  // We need to ensure SharedPreferences is initialized.
  // Ideally, use a provider that returns Future<SharedPreferences> or initialized in main.
  // For now, assuming preferencesProvider provides an instance if we override it in main.dart
  final prefs = ref.watch(preferencesProvider);

  return AuthNotifier(
    googleAuthService: googleAuthService,
    apiService: apiService,
    prefs: prefs,
  );
});
