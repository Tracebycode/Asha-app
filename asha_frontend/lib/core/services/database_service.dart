// dart
// // lib/core/database_service.dart
//
// import 'package:postgres/postgres.dart';
//
// class DatabaseService {
//   late PostgreSQLConnection _connection;
//   bool _isConnected = false;
//
//   // --- CONFIGURE YOUR LOCAL DATABASE HERE ---
//   final String _host = 'localhost';
//   final int _port = 5432;
//   final String _dbName = 'ashaworker_db'; // The name of your local DB
//   final String _username = 'postgres';
//   final String _password = 'root'; // <-- IMPORTANT: CHANGE THIS
//
//   Future<void> connect() async {
//     if (_isConnected) return;
//     _connection = PostgreSQLConnection(
//       _host, _port, _dbName,
//       username: _username, password: _password,
//     );
//     await _connection.open();
//     _isConnected = true;
//     print("Database connection opened.");
//   }
//
//   Future<void> close() async {
//     if (!_isConnected || _connection.isClosed) return;
//     await _connection.close();
//     _isConnected = false;
//     print("Database connection closed.");
//   }
//
//   // --- Main Transaction to Save Family Head ---
//   Future<int> saveFamilyHead({
//     required Map<String, dynamic> headData,
//     required int ashaWorkerId, // This will come from your Auth logic later
//   }) async {
//     await connect(); // Ensure connection is open
//
//     // The 'postgres' package doesn't have a simple transaction block like some other libraries.
//     // For robustness in a real app, you would wrap this in a proper BEGIN/COMMIT/ROLLBACK structure.
//     // For now, we execute sequentially.
//
//     try {
//       // 1. Insert into 'family_heads'
//       final headResult = await _connection.query(
//         '''
//             INSERT INTO family_heads (user_id, name, mobile_number, address)
//             VALUES (@userId, @name, @mobile, @address) RETURNING id;
//             ''',
//         substitutionValues: {
//           'userId': ashaWorkerId,
//           'name': headData['name'],
//           'mobile': headData['mobileNumber'],
//           'address': headData['address'],
//         },
//       );
//       final newFamilyHeadId = headResult.first[0] as int;
//
//       // 2. Insert into 'family_members'
//       final memberResult = await _connection.query(
//         '''
//             INSERT INTO family_members (family_head_id, name, age, gender, aadhaar_number, is_head)
//             VALUES (@headId, @name, @age, @gender, @aadhaar, TRUE) RETURNING id;
//             ''',
//         substitutionValues: {
//           'headId': newFamilyHeadId,
//           'name': headData['name'],
//           'age': headData['age'],
//           'gender': headData['gender'],
//           'aadhaar': headData['aadhaarNumber'],
//         },
//       );
//       final newMemberId = memberResult.first[0] as int;
//
//       // 3. Insert into 'health_cases' if provided
//       if (headData['healthCase'] != null) {
//         final healthCase = headData['healthCase'];
//         final caseResult = await _connection.query(
//           '''
//               INSERT INTO health_cases (member_id, case_type, visit_date)
//               VALUES (@memberId, @caseType, @visitDate) RETURNING id;
//               ''',
//           substitutionValues: {
//             'memberId': newMemberId,
//             'caseType': healthCase['caseType'],
//             'visitDate': DateTime.parse(healthCase['visitDate']),
//           },
//         );
//         // We can use the newCaseId to save to specific screening tables if needed
//       }
//
//       // Return the ID of the new family, which is the anchor for all other members
//       return newFamilyHeadId;
//
//     } catch (e) {
//       print("DATABASE ERROR: Failed to save family head. $e");
//       // In a real app with transactions, you would issue a ROLLBACK command here.
//       rethrow; // Rethrow the error so the UI can handle it
//     }
//   }
// }
