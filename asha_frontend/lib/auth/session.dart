class Session {
  static final Session instance = Session._internal();

  Session._internal();

  String? userId;          // sub
  String? name;
  String? phone;
  String? role;

  String? phcId;
  String? areaId;
  String? areaName;

  String? ashaWorkerId;
  String? anmWorkerId;

  // Checks if session is fully loaded
  bool get isLoggedIn {
    return userId != null && role == "asha";
  }

  void clear() {
    userId = null;
    name = null;
    phone = null;
    role = null;
    phcId = null;
    areaId = null;
    areaName = null;
    ashaWorkerId = null;
    anmWorkerId = null;
  }
  void setUserFromJwt(Map<String, dynamic> data) {
    userId = data["sub"];
    phcId = data["phc_id"];

    final area = data["area"];
    if (area != null) {
      areaId = area["id"];
      areaName = area["name"];
    } else {
      print("WARNING: area missing in JWT payload.");
      areaId = null;
      areaName = null;
    }

    ashaWorkerId = data["asha_worker_id"];
    anmWorkerId = data["anm_worker_id"];
  }


}

