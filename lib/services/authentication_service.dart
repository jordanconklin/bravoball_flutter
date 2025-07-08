import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../config/app_config.dart';
import 'api_service.dart';
import 'user_manager_service.dart';

/// Authentication Service
/// Mirrors Swift AuthenticationService for managing authentication state
class AuthenticationService extends ChangeNotifier {
  static AuthenticationService? _instance;
  static AuthenticationService get shared => _instance ??= AuthenticationService._();
  
  AuthenticationService._();

  final ApiService _apiService = ApiService.shared;
  final UserManagerService _userManager = UserManagerService.instance;

  bool _isCheckingAuthentication = false;
  bool _isAuthenticated = false;
  bool _isCheckingAuth = true;

  // Getters
  bool get isCheckingAuthentication => _isCheckingAuthentication;
  bool get isAuthenticated => _isAuthenticated;
  bool get isCheckingAuth => _isCheckingAuth;

  /// Checks if user has valid stored credentials and validates them with the backend
  /// Mirrors Swift checkAuthenticationStatus
  Future<bool> checkAuthenticationStatus() async {
    if (kDebugMode) {
      print('🔍 AuthenticationService: Starting authentication check...');
    }

    _isCheckingAuthentication = true;
    notifyListeners();

    // Check if we have stored tokens
    if (!_userManager.hasValidToken || _userManager.email.isEmpty) {
      if (kDebugMode) {
        print('❌ AuthenticationService: No stored tokens found');
      }
      
      _isCheckingAuthentication = false;
      _isAuthenticated = false;
      notifyListeners();
      return false;
    }

    if (kDebugMode) {
      print('✅ AuthenticationService: Found stored tokens for user: ${_userManager.email}');
      print('🔑 AuthenticationService: Access token: ${_userManager.accessToken.substring(0, 20)}...');
    }

    // Validate token with backend by making a test authenticated request
    try {
      if (kDebugMode) {
        print('🌐 AuthenticationService: Validating token with backend...');
      }

      // Try to make an authenticated request to validate the token
      // We'll use a simple endpoint that requires authentication
      final response = await _apiService.get(
        '/api/drills/search',
        queryParameters: {'limit': '1'}, // Just get 1 drill to test auth
        requiresAuth: true,
      );

      final isValid = response.isSuccess;
      
      if (kDebugMode) {
        print('🌐 AuthenticationService: Backend response status: ${response.statusCode}');
      }

      _isCheckingAuthentication = false;
      _isAuthenticated = isValid;
      notifyListeners();

      if (isValid) {
        if (kDebugMode) {
          print('✅ AuthenticationService: Token validation successful');
        }
      } else {
        if (kDebugMode) {
          print('❌ AuthenticationService: Token validation failed');
        }
        // Clear invalid tokens
        await clearInvalidTokens();
      }

      return isValid;

    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthenticationService: Error validating token: $e');
      }
      
      // If validation fails, clear invalid tokens
      await clearInvalidTokens();

      _isCheckingAuthentication = false;
      _isAuthenticated = false;
      notifyListeners();

      return false;
    }
  }

  /// Update authentication status on app start (mirrors Swift updateAuthenticationStatus)
  Future<void> updateAuthenticationStatus() async {
    if (kDebugMode) {
      print('\n🔐 ===== STARTING AUTHENTICATION CHECK =====');
      print('📅 Timestamp: ${DateTime.now()}');
    }

    // Check if user has valid stored credentials
    final isAuthenticated = await checkAuthenticationStatus();

    // Add a minimum delay to show any loading animation
    await Future.delayed(const Duration(milliseconds: 800));

    if (isAuthenticated) {
      // User has valid tokens, authentication already handled in UserManager
      if (kDebugMode) {
        print('✅ Authentication check passed - user is logged in');
        print('📱 User: ${_userManager.email}');
      }
    } else {
      if (kDebugMode) {
        print('❌ Authentication check failed - user needs to login');
        print('📱 No valid tokens found or backend validation failed');
      }
    }

    // End loading state
    _isCheckingAuth = false;
    notifyListeners();
    
    if (kDebugMode) {
      print('🏁 Authentication check complete - isCheckingAuth: $_isCheckingAuth');
    }
  }

  /// Clear invalid tokens from storage (mirrors Swift clearInvalidTokens)
  Future<void> clearInvalidTokens() async {
    if (kDebugMode) {
      print('🗑️ AuthenticationService: Clearing invalid tokens');
    }

    try {
      final prefs = await SharedPreferences.getInstance();
      
      // Clear all auth-related data
      await prefs.remove('accessToken');
      await prefs.remove('refreshToken');
      await prefs.remove('userEmail');
      await prefs.remove('isLoggedIn');
      await prefs.remove('userHasAccountHistory');
      
      // Update user manager state
      await _userManager.logout();
      
      if (kDebugMode) {
        print('✅ AuthenticationService: Invalid tokens cleared');
      }
    } catch (e) {
      if (kDebugMode) {
        print('❌ AuthenticationService: Error clearing tokens: $e');
      }
    }
  }

  /// Initialize authentication service
  Future<void> initialize() async {
    if (kDebugMode) {
      print('🔐 AuthenticationService: Initializing...');
    }

    // Initialize user manager first
    await _userManager.initialize();
    
    // Check authentication status
    await updateAuthenticationStatus();
    
    if (kDebugMode) {
      print('✅ AuthenticationService: Initialized');
    }
  }

  /// Force refresh authentication state
  Future<void> refreshAuthenticationState() async {
    _isCheckingAuth = true;
    notifyListeners();
    
    await updateAuthenticationStatus();
  }

  /// Debug info
  String get debugInfo {
    return '''
Authentication Service Debug Info:
- IsCheckingAuth: $_isCheckingAuth
- IsCheckingAuthentication: $_isCheckingAuthentication  
- IsAuthenticated: $_isAuthenticated
- UserManager HasToken: ${_userManager.hasValidToken}
- UserManager IsLoggedIn: ${_userManager.isLoggedIn}
''';
  }
} 