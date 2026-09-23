import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/auth_user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal() {
    restoreSession();
  }

  static const String _prefKeySessionUser = 'auth_session_user';
  static const String _prefKeySessionRole = 'auth_session_role';
  static const String _prefKeySessionLive = 'auth_session_live';

  final ApiService _apiService = ApiService();

  AuthUser? _currentUser;
  bool _isLiveBackend = false;
  String? _lastError;
  String? _statusMessage;
  bool _isLoading = false;
  bool _hasRestoredSession = false;

  AuthUser? get currentUser => _currentUser;
  UserRole get role => _currentUser?.role ?? UserRole.guest;
  bool get isAuthenticated => _currentUser != null && _currentUser!.role != UserRole.guest;
  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;
  bool get isLiveBackend => _isLiveBackend;
  String? get lastError => _lastError;
  String? get statusMessage => _statusMessage;
  bool get isLoading => _isLoading;
  bool get hasRestoredSession => _hasRestoredSession;

  bool get _isTestEnv => !kIsWeb && Platform.environment.containsKey('FLUTTER_TEST');

  Future<void> _saveSession() async {
    if (_isTestEnv) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      if (_currentUser != null) {
        await prefs.setString(_prefKeySessionUser, jsonEncode(_currentUser!.toJson()));
        await prefs.setString(_prefKeySessionRole, _currentUser!.role.name);
        await prefs.setBool(_prefKeySessionLive, _isLiveBackend);
      }
    } catch (e) {
      debugPrint('Failed to save auth session: $e');
    }
  }

  Future<void> _clearSession() async {
    if (_isTestEnv) return;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove(_prefKeySessionUser);
      await prefs.remove(_prefKeySessionRole);
      await prefs.remove(_prefKeySessionLive);
    } catch (e) {
      debugPrint('Failed to clear auth session: $e');
    }
  }

  /// Restores session on app startup so user stays logged in
  Future<bool> restoreSession() async {
    if (_isTestEnv) {
      _hasRestoredSession = true;
      return false;
    }
    try {
      final prefs = await SharedPreferences.getInstance();
      final userJsonStr = prefs.getString(_prefKeySessionUser);
      final roleStr = prefs.getString(_prefKeySessionRole);
      final isLive = prefs.getBool(_prefKeySessionLive) ?? false;

      if (userJsonStr != null && userJsonStr.isNotEmpty) {
        final Map<String, dynamic> userMap = jsonDecode(userJsonStr);
        final role = roleStr == 'admin'
            ? UserRole.admin
            : (roleStr == 'member' ? UserRole.member : UserRole.guest);

        if (role != UserRole.guest) {
          _currentUser = AuthUser.fromJson(userMap, role);
          _isLiveBackend = isLive;
          _statusMessage = 'Welcome back, ${_currentUser!.name}';
          _hasRestoredSession = true;
          notifyListeners();
          return true;
        }
      }
    } catch (e) {
      debugPrint('Error restoring auth session: $e');
    }
    _hasRestoredSession = true;
    return false;
  }

  /// Attempt Login with live backend first, with offline demo fallback
  Future<bool> login({
    required String username,
    required String password,
    UserRole? role,
  }) async {
    _isLoading = true;
    _lastError = null;
    _statusMessage = null;
    notifyListeners();

    final roleStr = role == null
        ? null
        : (role == UserRole.admin ? 'admin' : 'member');
    final result = await _apiService.login(
      username: username,
      password: password,
      role: roleStr,
    );

    _isLoading = false;

    if (result.isSuccess && result.data != null) {
      final data = result.data as Map<String, dynamic>;
      final userData = data['user'] as Map<String, dynamic>? ?? {};
      final token = data['token']?.toString();

      // Resolve role from server response or fallback to role hint
      final serverRoleStr = (data['role'] ?? userData['role'] ?? '').toString().toLowerCase();
      final resolvedRole = serverRoleStr == 'admin'
          ? UserRole.admin
          : (serverRoleStr == 'member' ? UserRole.member : (role ?? UserRole.member));

      _currentUser = AuthUser.fromJson({
        ...userData,
        'token': token,
      }, resolvedRole);
      _isLiveBackend = true;
      _statusMessage = 'Connected to Live Backend API';
      _saveSession();
      notifyListeners();
      return true;
    }

    // If backend was reachable but rejected credentials:
    if (!result.isOffline) {
      _lastError = result.message ?? 'Invalid username or password.';
      notifyListeners();
      return false;
    }

    // If backend was offline, allow local test fallback ONLY in debug mode or test environment
    final isDebugOrTest = kDebugMode || (!kIsWeb && Platform.environment.containsKey('FLUTTER_TEST'));
    if (isDebugOrTest) {
      final cleanUser = username.trim().toLowerCase();
      final cleanPass = password.trim();

      // Check admin credentials
      if ((role == null || role == UserRole.admin) && (cleanUser == 'admin' && cleanPass == 'admin123')) {
        _currentUser = const AuthUser(
          id: '1',
          username: 'admin',
          name: 'System Administrator',
          email: 'admin@sfofindia.com',
          role: UserRole.admin,
          status: 'Active',
        );
        _isLiveBackend = false;
        _statusMessage = 'Authenticated via Offline Demo Mode (Backend not running)';
        _saveSession();
        notifyListeners();
        return true;
      }

      // Check member credentials
      if ((role == null || role == UserRole.member) &&
          ((cleanUser == 'mbr0001' || cleanUser == 'member' || cleanUser.startsWith('sfof')) &&
              cleanPass == 'member123')) {
        _currentUser = const AuthUser(
          id: '1',
          username: 'MBR0001',
          name: 'Vikramaditya Singh',
          email: 'vikram.singh@sfofindia.org',
          role: UserRole.member,
          memberUserId: 'MBR0001',
          phone: '+91 98765 43210',
          status: 'Active',
        );
        _isLiveBackend = false;
        _statusMessage = 'Authenticated via Offline Demo Mode (Backend not running)';
        _saveSession();
        notifyListeners();
        return true;
      }
    }

    _lastError = result.message ?? 'Authentication failed. Please check your credentials.';
    notifyListeners();
    return false;
  }

  /// Request password recovery for Email or Member ID
  Future<ApiResult> forgotPassword(String identifier) async {
    return await _apiService.forgotPassword(identifier: identifier);
  }

  /// Update current user data in session
  void updateCurrentUser(Map<String, dynamic> updatedData) {
    if (_currentUser != null) {
      _currentUser = _currentUser!.copyWith(
        name: updatedData['name'] ?? _currentUser!.name,
        phone: updatedData['mobile'] ?? updatedData['phone'] ?? _currentUser!.phone,
        email: updatedData['email'] ?? _currentUser!.email,
        status: updatedData['status'] ?? _currentUser!.status,
      );
      _saveSession();
      notifyListeners();
    }
  }

  /// Completes password reset and logs the user in with their active session
  void completePasswordResetLogin({
    required Map<String, dynamic> data,
    required UserRole role,
  }) {
    final userData = data['user'] as Map<String, dynamic>? ?? {};
    final token = data['token']?.toString();

    _currentUser = AuthUser.fromJson({
      ...userData,
      'token': token,
    }, role);
    _isLiveBackend = true;
    _statusMessage = 'Password updated successfully! Welcome back.';
    _lastError = null;
    _saveSession();
    notifyListeners();
  }

  /// Sets an offline authenticated session (for testing/demo fallback)
  void setOfflineSession(AuthUser user) {
    _currentUser = user;
    _isLiveBackend = false;
    _statusMessage = 'Authenticated via Offline Demo';
    _lastError = null;
    _saveSession();
    notifyListeners();
  }

  /// Logout
  Future<void> logout() async {
    _currentUser = null;
    _isLiveBackend = false;
    _lastError = null;
    _statusMessage = null;
    await _clearSession();
    notifyListeners();
  }
}
