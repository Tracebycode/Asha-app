import 'package:flutter/material.dart';
import 'package:asha_frontend/features/family/ui/widgets/common_form_widgets.dart';
import 'package:asha_frontend/features/family/ui/add_member_page.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/auth/session.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/repositories/members_repository.dart';

import 'package:uuid/uuid.dart';
import 'dart:convert';




class _MemberSummary {
  final String clientId;       // 👈 NEW FIELD
  String name;
  int age;
  String? gender;
  String? relation;
  String? aadhaar;
  String? phone;
  List<String> healthCases;
  Map<String, dynamic> healthDetails;

  _MemberSummary({
    required this.clientId,    // 👈 NEW REQUIRED ARG
    required this.name,
    required this.age,
    this.gender,
    this.relation,
    this.aadhaar,
    this.phone,
    this.healthCases = const [],
    this.healthDetails = const {},
  });
}


class AddFamilyPage extends StatefulWidget {
  const AddFamilyPage({super.key});

  @override
  State<AddFamilyPage> createState() => _AddFamilyPageState();
}

class _AddFamilyPageState extends State<AddFamilyPage> {
  final _formKey = GlobalKey<FormState>();

  final _addressController = TextEditingController();
  final _landmarkController = TextEditingController();
  final _mobileController = TextEditingController();

  final List<_MemberSummary> _members = [];
  final FamiliesDao _familiesDao = FamiliesDao();
  String? _familyClientId;        // after Save Basics
  bool _basicsSaved = false;      // block final save until ready



  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onSaveFamilyBasics() async {
    if (_formKey.currentState?.validate() != true) return;

    // Create family id if first time
    _familyClientId ??= "fam_${const Uuid().v4()}";

    final familyData = {
      "client_id": _familyClientId,
      "address_line": _addressController.text.trim(),
      "landmark": _landmarkController.text.trim(),
      "phone": _mobileController.text.trim(),
      "phc_id": Session.instance.phcId,
      "area_id": Session.instance.areaId,
      "asha_worker_id": Session.instance.ashaWorkerId,
      "device_created_at": DateTime.now().toIso8601String(),
      "device_updated_at": DateTime.now().toIso8601String(),
      "is_dirty": 1,
      "dirty_operation": "insert",
      "local_updated_at": DateTime.now().toIso8601String(),
    };

    await _familiesDao.insertFamily(familyData);

    _basicsSaved = true;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Family basics saved. Now add members")),
    );

    setState(() {});
  }


  Future<void> _onFinalSaveFamily() async {
    if (!_basicsSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Save family basics first")),
      );
      return;
    }

    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Add at least one member")),
      );
      return;
    }

    final membersRepo = MembersRepository(MembersDao());

    for (final m in _members) {
      // Save each member
      await membersRepo.createMember(
        familyClientId: _familyClientId!,
        member: {
          "name": m.name,
          "age": m.age,
          "gender": m.gender,
          "relation": m.relation,
          "aadhaar": m.aadhaar,
          "phone": m.phone,
        },
      );

      // Save health cases for each member (local)
      for (final hc in m.healthCases) {
        final recordId = "hr_${const Uuid().v4()}";

        await  HealthRecordsDao().insertRecord(
          {
            "id": recordId,
            "member_client_id": m.clientId,
            "visit_type": hc,
            "data_json": jsonEncode(m.healthDetails[hc] ?? {}),
            "is_dirty": 1,
            "dirty_operation": "insert",
            "device_created_at": DateTime.now().toIso8601String(),
            "device_updated_at": DateTime.now().toIso8601String(),
            "local_updated_at": DateTime.now().toIso8601String(),
          },
        );
      }
    }

    print("🎉 FINAL FAMILY + MEMBERS + HEALTH SAVED TO LOCAL DB");

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Family saved successfully")),
    );

    Navigator.pop(context);
  }





  // ADD MEMBER
  Future<void> _onAddMemberPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMemberPage()),
    );

    if (result != null) {
      final memberClientId = "mem_${const Uuid().v4()}";  // 👈 NEW ID

      setState(() {
        _members.add(
          _MemberSummary(
            clientId: memberClientId,
            name: result["name"],
            age: result["age"],
            gender: result["gender"],
            relation: result["relation"],
            aadhaar: result["aadhaar"],
            phone: result["phone"],
            healthCases: List<String>.from(result["healthCases"]),
            healthDetails: result["healthDetails"] ?? {},
          ),
        );
      });
    }
  }


  // EDIT MEMBER
  Future<void> _onEditMemberPressed(int index) async {
    final m = _members[index];

    final updated = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemberPage(
          existingMember: {
            "name": m.name,
            "age": m.age,
            "gender": m.gender,
            "relation": m.relation,
            "aadhaar": m.aadhaar,
            "phone": m.phone,
            "healthCases": m.healthCases,
            "healthDetails": m.healthDetails,
          },
        ),
      ),
    );

    if (updated != null) {
      setState(() {
        _members[index] = _MemberSummary(
          clientId: m.clientId,   // 👈 SAME ID PRESERVED
          name: updated["name"],
          age: updated["age"],
          gender: updated["gender"],
          relation: updated["relation"],
          aadhaar: updated["aadhaar"],
          phone: updated["phone"],
          healthCases: List<String>.from(updated["healthCases"]),
          healthDetails: updated["healthDetails"] ?? {},
        );
      });
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add New Family'),
        backgroundColor: const Color(0xFF2A5A9E),
        foregroundColor: Colors.white,
      ),

      backgroundColor: Colors.grey[200],

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              const SectionTitle(title: "Family Basic Details"),
              const SizedBox(height: 16),

              AppTextField(label: "Address", controller: _addressController),
              const SizedBox(height: 16),

              AppTextField(label: "Landmark", controller: _landmarkController),
              const SizedBox(height: 16),

              AppTextField(
                label: "Mobile Number",
                controller: _mobileController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 28),

              const SectionTitle(title: "Family Members"),
              const SizedBox(height: 12),

              _members.isEmpty
                  ? Container(
                width: double.infinity,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: Colors.grey.shade300),
                ),
                child: const Text(
                  "No members added yet.\nTap \"Add Member\" to begin.",
                  style: TextStyle(color: Colors.grey),
                ),
              )
                  : Column(
                children: List.generate(_members.length, (index) {
                  final m = _members[index];

                  return Card(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        child: Text(m.name.isNotEmpty ? m.name[0] : "?"),
                      ),
                      title: Text(m.name),
                      subtitle: Text(
                        "Age: ${m.age} | ${m.relation ?? ''}",
                      ),
                      onTap: () => _onEditMemberPressed(index),
                    ),
                  );
                }),
              ),

              const SizedBox(height: 120),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            ElevatedButton(
              onPressed: _onSaveFamilyBasics,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Save Family Basics",
                style: TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),

            OutlinedButton.icon(
              onPressed: _basicsSaved ? _onAddMemberPressed : null,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text("Add Member"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            ElevatedButton(
              onPressed: _onFinalSaveFamily,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: const Text(
                "Save Entire Family",
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),

    );
  }
}
