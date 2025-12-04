class FamilyIdMapping {
  static Map<String, String> map = {};

  static Future<void> saveMapping(String clientId, String serverId) async {
    map[clientId] = serverId;
  }

  static Future<String?> getServerId(String clientId) async {
    return map[clientId];
  }
}
