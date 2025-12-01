import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asha_frontend/auth/services/secure_storage_service.dart';

class ApiService {
  final String _baseUrl = "https://asha-ehr-backend-9.onrender.com";
  final SecureStorageService _storage = SecureStorageService();

  // --- Authentication ---

  Future<http.Response> login(String mobile, String password) async {
    final response = await http.post(
      Uri.parse('$_baseUrl/auth/login'),
      headers: {'Content-Type': 'application/json'},
      // CORRECTED: Use the actual mobile and password variables
      body: jsonEncode({
        'phone': mobile,
        'password': password,
      }),
    );
    return response;
  }

  // --- Authenticated GET Request ---

  Future<http.Response> get(String endpoint, {Function? onAuthError}) async {
    final token = await _storage.getToken();

    final response = await http.get(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401 && onAuthError != null) {
      onAuthError();
    }

    return response;
  }

  // --- START: ADD NEW AUTHENTICATED METHODS ---

  // --- Authenticated POST Request ---
  // Use this for creating new data (e.g., adding a family)
  Future<http.Response> post(String endpoint, Map<String, dynamic> body, {Function? onAuthError}) async {
    final token = await _storage.getToken();

    final response = await http.post(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && onAuthError != null) {
      onAuthError();
    }

    return response;
  }

  // --- Authenticated PUT Request ---
  // Use this for updating existing data
  Future<http.Response> put(String endpoint, Map<String, dynamic> body, {Function? onAuthError}) async {
    final token = await _storage.getToken();

    final response = await http.put(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(body),
    );

    if (response.statusCode == 401 && onAuthError != null) {
      onAuthError();
    }

    return response;
  }

  // --- Authenticated DELETE Request ---
  // Use this for deleting data
  Future<http.Response> delete(String endpoint, {Function? onAuthError}) async {
    final token = await _storage.getToken();

    final response = await http.delete(
      Uri.parse('$_baseUrl/$endpoint'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 401 && onAuthError != null) {
      onAuthError();
    }

    return response;
  }
// --- END: ADD NEW AUTHENTICATED METHODS ---
}
