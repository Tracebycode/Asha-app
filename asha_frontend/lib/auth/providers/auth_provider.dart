import 'package:flutter/material.dart';
import 'package:asha_frontend/auth/services/secure_storage_service.dart';

/// Manages the authentication state of the application.
///
/// It holds the authentication token and notifies listeners when the
/// authentication state changes (e.g., user logs in or logs out).
class AuthProvider extends ChangeNotifier {
  String? _token;
  final SecureStorageService _storageService = SecureStorageService();
  bool _isLoading = true; // To track if we are still loading the token from storage

  /// The authentication token. Null if the user is not authenticated.
  String? get token => _token;

  /// A boolean to quickly check if the user is authenticated.
  bool get isAuthenticated => _token != null;

  /// A boolean to check if the provider is still loading the initial token.
  bool get isLoading => _isLoading;

  AuthProvider() {
    // When the app starts, immediately try to load the token from storage.
    _loadTokenFromStorage();
  }

  /// Attempts to load the JWT from secure storage upon app startup.
  Future<void> _loadTokenFromStorage() async {
    _token = await _storageService.getToken();
    _isLoading = false; // Finished loading
    notifyListeners(); // Notify widgets that loading is complete and they can now check the token.
  }

  /// To be called when the user successfully logs in.
  /// It saves the token to secure storage and updates the state.
  Future<void> login(String token) async {
    await _storageService.saveToken(token);
    _token = token;
    notifyListeners(); // Notify all listening widgets that the user is now logged in.
  }

  /// To be called when the user logs out or the session expires.
  /// It deletes the token from storage and clears the state.
  Future<void> logout() async {
    await _storageService.deleteToken();
    _token = null;
    notifyListeners(); // Notify all listening widgets that the user has logged out.
  }
}
