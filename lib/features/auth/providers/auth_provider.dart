import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/providers/app_providers.dart';
import '../../expense/services/api_service.dart';
import '../services/auth_service.dart';

// State for authentication
enum AuthStatus { initial, authenticated, unauthenticated, loading, error }

class AuthState {
  final AuthStatus status;
  final UserData? user;
  final String? errorMessage;

  const AuthState({
    this.status = AuthStatus.initial,
    this.user,
    this.errorMessage,
  });

  AuthState copyWith({
    AuthStatus? status,
    UserData? user,
    String? errorMessage,
  }) {
    return AuthState(
      status: status ?? this.status,
      user: user ?? this.user,
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
  })  : _googleAuthService = googleAuthService,
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

  Future<void> login(String email, String password) async {
    state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _apiService.login(email, password);
      final token = response['token'];
      final userData = response['user'];

      if (token != null) {
        await _prefs.setString('auth_token', token);
        _apiService.setAuthToken(token);
        
        // Map response to UserData
        final user = UserData(
            id: userData['id'].toString(),
            name: userData['name'],
            email: userData['email'],
            photoUrl: userData['picture']
        );

        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
      } else {
         state = state.copyWith(status: AuthStatus.error, errorMessage: "Invalid response from server");
      }
    } catch (e) {
      state = state.copyWith(
        status: AuthStatus.error,
        errorMessage: e.toString(),
      );
    }
  }

  Future<void> register(String name, String email, String password) async {
     state = state.copyWith(status: AuthStatus.loading);
    try {
      final response = await _apiService.register(name, email, password);
      // Assuming register returns same as login or success message
      // If it auto-logins:
       final token = response['token'];
      final userData = response['user'];

      if (token != null) {
        await _prefs.setString('auth_token', token);
        _apiService.setAuthToken(token);
         final user = UserData(
            id: userData['id'].toString(),
            name: userData['name'],
            email: userData['email'],
            photoUrl: userData['picture']
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
          user: user,
        );
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
       final token = response['token'];
      final userData = response['user'];

       if (token != null) {
        await _prefs.setString('auth_token', token);
        _apiService.setAuthToken(token);
         final user = UserData(
            id: userData['id'].toString(),
            name: userData['name'],
            email: userData['email'],
            photoUrl: userData['picture']
        );
        state = state.copyWith(
          status: AuthStatus.authenticated,
           user: user,
        );
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
    await _prefs.remove('user_data');
    _apiService.clearAuthToken();
    state = state.copyWith(status: AuthStatus.unauthenticated, user: null);
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
