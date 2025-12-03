import 'dart:convert';

Map<String, dynamic> parseJwt(String token) {
  final parts = token.split('.');
  if (parts.length != 3) {
    throw Exception('invalid token');
  }

  final payload = parts[1];
  final normalized = base64.normalize(payload);
  final decoded = utf8.decode(base64Url.decode(normalized));

  return json.decode(decoded);
}
