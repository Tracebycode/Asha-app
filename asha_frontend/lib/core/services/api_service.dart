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

// 🔥 2: helper - GET auth header
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      if (token != null) 'Authorization': 'Bearer $token',
    };
  }

  // 🔥 3: FAMILY CREATE (for sync)
  Future<http.Response> createFamilyFromLocal(
      Map<String, dynamic> localRow) async {
    final url = Uri.parse('$_baseUrl/families/create');

    // ⚠️ IMPORTANT: Backend ko sirf zaroori fields bhejna
    final body = {
      "area_id": localRow["area_id"],            // JWT se bhi aa sakta hai
      "address_line": localRow["address_line"],
      "landmark": localRow["landmark"],
      "phone": localRow["phone"],
      // helpful hai agar server mapping store kare
      "client_id": localRow["client_id"],
      "device_created_at": localRow["device_created_at"],
      "device_updated_at": localRow["device_updated_at"],
    };

    final headers = await _authHeaders();

    return await http.post(
      url,
      headers: headers,
      body: jsonEncode(body),
    );
  }

  Future<http.Response> createMemberFromLocal(
      Map<String, dynamic> memberRow) async {
    final headers = await _authHeaders();

    final adhaarRaw = memberRow["aadhaar"]?.toString() ?? "";

    final body = {
      "family_id": memberRow["family_id"],      // 👈 server family_id
      "name": memberRow["name"],
      "age": memberRow["age"],
      "gender": memberRow["gender"],
      "relation": memberRow["relation"],
      "adhar_number": adhaarRaw,               // 👈 BACKEND FIELD NAME
      "phone": memberRow["phone"],

      // extra meta (backend ignore karega, but future me kaam aa sakta):
      "client_id": memberRow["client_id"],
      "device_created_at": memberRow["device_created_at"],
      "device_updated_at": memberRow["device_updated_at"],
    };

    return await http.post(
      Uri.parse("$_baseUrl/families/add/members"),
      headers: headers,
      body: jsonEncode(body),
    );
  }


}
