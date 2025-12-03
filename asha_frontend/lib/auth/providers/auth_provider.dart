import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:asha_frontend/auth/services/secure_storage_service.dart';
import 'package:asha_frontend/auth/jwt_helper.dart';
import 'package:asha_frontend/auth/session.dart';

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
    final storedToken = await _storageService.getToken();

    if (storedToken == null) {
      print("No token found in secure storage");
      _isLoading = false;
      notifyListeners();
      return;
    }

    _token = storedToken;

    try {
      final parts = storedToken.split('.');
      if (parts.length != 3) throw Exception("Invalid JWT format");

      final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
      final data = jsonDecode(payload);

      try {
        Session.instance.setUserFromJwt(data);
      } catch (e) {
        print("Session parse error: $e");
      }

    } catch (e) {
      print("JWT decode error: $e");
      // token corrupt → logout
      await logout();
    }

    _isLoading = false;
    notifyListeners();
  }


  /// To be called when the user successfully logs in.
  /// It saves the token to secure storage and updates the state.
  Future<void> login(String token) async {
    // 1. Save token securely
    await _storageService.saveToken(token);

    // 2. Set internal state
    _token = token;

    // 3. Decode token → fill Session data
    final claims = parseJwt(token);
    final s = Session.instance;

    s.userId = claims["sub"];
    s.name = claims["name"];
    s.phone = claims["phone"];
    s.role = claims["role"];

    s.phcId = claims["phc_id"];
    final area = claims["area"];
    if (area != null) {
      s.areaId = area["id"];
      s.areaName = area["name"];
    } else {
      print("WARNING: area object missing in JWT");
      s.areaId = null;
      s.areaName = null;
    }


    s.ashaWorkerId = claims["asha_worker_id"];
    s.anmWorkerId = claims["anm_worker_id"];

    // 4. Notify listeners
    notifyListeners();
  }

  /// To be called when the user logs out or the session expires.
  /// It deletes the token from storage and clears the state.
  Future<void> logout() async {
    await _storageService.deleteToken();
    _token = null;
    notifyListeners(); // Notify all listening widgets that the user has logged out.
  }
}
