import 'dart:convert';
import 'package:http/http.dart' as http;
import '../../auth/services/secure_storage_service.dart';

class ApiClient {
  final String baseUrl = "https://asha-ehr-backend-9.onrender.com";
  final SecureStorageService _storage = SecureStorageService();

  // ------------------------------------------------------
  // AUTH HEADERS
  // ------------------------------------------------------
  Future<Map<String, String>> _headers() async {
    final token = await _storage.getToken();

    if (token == null || token.isEmpty) {
      throw Exception("No token found — user must re-login");
    }

    return {
      "Content-Type": "application/json",
      "Authorization": "Bearer $token",
    };
  }

  // ------------------------------------------------------
  // RAW POST
  // ------------------------------------------------------
  Future<http.Response> _postRaw(String path, Map<String, dynamic> body) async {
    final headers = await _headers();

    return http
        .post(
      Uri.parse("$baseUrl$path"),
      headers: headers,
      body: jsonEncode(body),
    )
        .timeout(const Duration(seconds: 10));
  }

  // ------------------------------------------------------
  // JSON POST (decoded)
  // ------------------------------------------------------
  Future<Map<String, dynamic>> post(
      String path, Map<String, dynamic> body) async {
    final resp = await _postRaw(path, body);

    if (resp.statusCode >= 200 && resp.statusCode < 300) {
      return jsonDecode(resp.body);
    }

    throw Exception(
        "POST $path failed (${resp.statusCode}): ${resp.body}");
  }

  // ------------------------------------------------------
  // GET (decoded)
  // ------------------------------------------------------
  Future<dynamic> get(String path) async {
    final headers = await _headers();

    final response = await http
        .get(
      Uri.parse("$baseUrl$path"),
      headers: headers,
    )
        .timeout(const Duration(seconds: 10));

    if (response.statusCode >= 200 && response.statusCode < 300) {
      return jsonDecode(response.body);
    }

    throw Exception(
        "GET $path failed (${response.statusCode}): ${response.body}");
  }

  // ------------------------------------------------------
  // LOGIN (NO TOKEN REQUIRED)
  // ------------------------------------------------------
  Future<Map<String, dynamic>> login(String phone, String password) async {
    final response = await http
        .post(
      Uri.parse("$baseUrl/auth/login"),
      headers: {"Content-Type": "application/json"},
      body: jsonEncode({"phone": phone, "password": password}),
    )
        .timeout(const Duration(seconds: 10));

    return jsonDecode(response.body);
  }

  // ------------------------------------------------------
  // SYNC: FAMILY
  // ------------------------------------------------------
  Future<Map<String, dynamic>> createFamilyFromLocal(
      Map<String, dynamic> row) async {
    final resp = await _postRaw("/families/create", {
      "area_id": row["area_id"],
      "address_line": row["address_line"],
      "landmark": row["landmark"],
    });

    return jsonDecode(resp.body);
  }

  // ------------------------------------------------------
  // SYNC: MEMBER  (FULLY FIXED)
  // ------------------------------------------------------
  Future<Map<String, dynamic>> createMemberFromLocal(
      Map<String, dynamic> m) async {

    final resp = await _postRaw("/families/add/members", {
      // server family id — REQUIRED by backend
      "family_id": m["family_id"],

      "name": m["name"],
      "gender": m["gender"],
      "age": m["age"],
      "relation": m["relation"],
      "phone": m["phone"],

      // Aadhaar fallback FIX — this caused sync failure earlier
      "adhar_number": m["adhar_number"]
          ?? m["aadhaar_number"]
          ?? m["aadhaar"]
          ?? m["aadhar_number"],

      // optional fallback
      "dob": m["dob"] ?? m["date_of_birth"],
    });

    return jsonDecode(resp.body);
  }

  // ------------------------------------------------------
  // SYNC: HEALTH RECORD
  // ------------------------------------------------------
  Future<Map<String, dynamic>> createHealthRecordFromLocal(
      Map<String, dynamic> payload) async {
    final resp = await _postRaw("/health/add", payload);
    return jsonDecode(resp.body);
  }
  Future<List<dynamic>> getOnlineFamilies() async {
    final result = await get("/families/list");  // adjust to your real endpoint
    return result["families"];
  }

}
