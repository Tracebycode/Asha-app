import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:asha_frontend/auth/services/secure_storage_service.dart';

class ApiService {
  final String _baseUrl = "https://asha-ehr-backend-9.onrender.com";
  final SecureStorageService _storage = SecureStorageService();

  // -------------------------------------------------------
  // JWT Headers
  // -------------------------------------------------------
  Future<Map<String, String>> _authHeaders() async {
    final token = await _storage.getToken();
    return {
      'Content-Type': 'application/json',
      'Authorization': 'Bearer $token',
    };
  }
  Future<http.Response> login(String username, String password) async {
    return await http.post(
      Uri.parse("$_baseUrl/auth/login"),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        "phone": username,
        "password": password,
      }),
    );
  }

  // -------------------------------------------------------
  // 1) CREATE FAMILY (correct)
  // -------------------------------------------------------
  Future<http.Response> createFamilyFromLocal(Map<String, dynamic> row) async {
    final headers = await _authHeaders();

    final body = {
      "area_id": row["area_id"],
      "address_line": row["address_line"],
      "landmark": row["landmark"]
    };

    return await http.post(
      Uri.parse("$_baseUrl/families/create"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // -------------------------------------------------------
  // 2) CREATE MEMBER (correct)
  // -------------------------------------------------------
  Future<http.Response> createMemberFromLocal(Map<String, dynamic> m) async {
    final headers = await _authHeaders();

    final body = {
      "family_id": m["family_client_id"], // SEND SERVER ID ✔

      "name": m["name"],
      "gender": m["gender"],
      "age": m["age"],
      "relation": m["relation"],
      "phone": m["phone"],
      "adhar_number": m["aadhaar"],
    };

    return await http.post(
      Uri.parse("$_baseUrl/families/add/members"),
      headers: headers,
      body: jsonEncode(body),
    );
  }

  // -------------------------------------------------------
  // 3) CREATE HEALTH RECORD (correct)
  // -------------------------------------------------------
  Future<http.Response> createHealthRecordFromLocal(
      Map<String, dynamic> row) async {

    final headers = await _authHeaders();

    final body = {
      "member_id": row["member_id"],          // SERVER MEMBER ID
      "task_id": row["task_id"],              // can be null
      "visit_type": row["visit_type"],
      "data_json": row["data_json"],          // must be Map
    };

    return await http.post(
      Uri.parse("$_baseUrl/health/add"),
      headers: headers,
      body: jsonEncode(body),
    );
  }
}
