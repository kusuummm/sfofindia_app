import 'package:flutter/foundation.dart';
import '../models/auth_user_model.dart';
import 'api_service.dart';

class AuthService extends ChangeNotifier {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  final ApiService _apiService = ApiService();

  AuthUser? _currentUser;
  bool _isLiveBackend = false;
  String? _lastError;
  String? _statusMessage;
  bool _isLoading = false;

  AuthUser? get currentUser => _currentUser;
  UserRole get role => _currentUser?.role ?? UserRole.guest;
  bool get isAuthenticated => _currentUser != null && _currentUser!.role != UserRole.guest;
  bool get isAdmin => role == UserRole.admin;
  bool get isMember => role == UserRole.member;
  bool get isLiveBackend => _isLiveBackend;
  String? get lastError => _lastError;
  String? get statusMessage => _statusMessage;
  bool get isLoading => _isLoading;

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
      notifyListeners();
      return true;
    }

    // If backend was reachable but rejected credentials:
    if (!result.isOffline) {
      _lastError = result.message ?? 'Invalid username or password.';
      notifyListeners();
      return false;
    }

    // If backend was offline, check if matching demo credentials for smooth offline development & testing
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
        email: 'vikram.singh@example.com',
        role: UserRole.member,
        memberUserId: 'MBR0001',
        phone: '+91 98765 43210',
        status: 'Active',
      );
      _isLiveBackend = false;
      _statusMessage = 'Authenticated via Offline Demo Mode (Backend not running)';
      notifyListeners();
      return true;
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
    notifyListeners();
  }

  /// Sets an offline authenticated session (for testing/demo fallback)
  void setOfflineSession(AuthUser user) {
    _currentUser = user;
    _isLiveBackend = false;
    _statusMessage = 'Authenticated via Offline Demo';
    _lastError = null;
    notifyListeners();
  }

  /// Logout
  void logout() {
    _currentUser = null;
    _isLiveBackend = false;
    _lastError = null;
    _statusMessage = null;
    notifyListeners();
  }
}
