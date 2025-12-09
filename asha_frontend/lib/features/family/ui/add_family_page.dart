import 'package:flutter/material.dart';
import 'package:asha_frontend/localization/app_localization.dart';
import 'package:asha_frontend/features/family/ui/widgets/common_form_widgets.dart';
import 'package:asha_frontend/features/family/ui/add_member_page.dart';
import 'package:asha_frontend/data/local/dao/families_dao.dart';
import 'package:asha_frontend/data/local/dao/health_records_dao.dart';
import 'package:asha_frontend/auth/session.dart';
import 'package:asha_frontend/data/local/dao/members_dao.dart';
import 'package:asha_frontend/data/repositories/members_repository.dart';
import 'package:asha_frontend/data/repositories/health_records_repository.dart';
import 'package:uuid/uuid.dart';
import 'dart:convert';

class _MemberSummary {
  String name;
  int age;
  String? gender;
  String? relation;
  String? aadhaar;
  String? phone;
  List<String> healthCases;
  Map<String, dynamic> healthDetails;

  _MemberSummary({
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
  final Map<String, dynamic>? existingFamily;

  const AddFamilyPage({super.key, this.existingFamily});

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

  String? _familyClientId;
  bool _basicsSaved = false;
  bool _isEditMode = false;

  @override
  void initState() {
    super.initState();

    if (widget.existingFamily != null) {
      _isEditMode = true;
      if (_isEditMode) _loadExistingMembersAndHealth();

      final fam = widget.existingFamily!;
      _familyClientId = fam["id"];

      _addressController.text = fam["address_line"] ?? "";
      _landmarkController.text = fam["landmark"] ?? "";
      _mobileController.text = fam["phone"] ?? "";

      _basicsSaved = true;
    }
  }

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  Future<void> _loadExistingMembersAndHealth() async {
    final membersDao = MembersDao();
    final healthDao = HealthRecordsDao();

    final memberRows = await membersDao.getMembersByFamilyId(_familyClientId!);

    _members.clear();

    for (final m in memberRows) {
      final localMemberId = m["id"];

      final healthRows = await healthDao.getHealthByLocalMemberId(localMemberId);

      final List<String> healthCases = [];
      final Map<String, dynamic> healthDetails = {};

      for (final h in healthRows) {
        final visitType = h["visit_type"];
        healthCases.add(visitType);
        healthDetails[visitType] = jsonDecode(h["data_json"]);
      }

      _members.add(
        _MemberSummary(
          name: m["name"],
          age: m["age"],
          gender: m["gender"],
          relation: m["relation"],
          aadhaar: m["aadhaar"],
          phone: m["phone"],
          healthCases: healthCases,
          healthDetails: healthDetails,
        ),
      );
    }

    setState(() {});
  }

  void _onSaveFamilyBasics() async {
    final t = AppLocalization.of(context).t;

    if (_formKey.currentState?.validate() != true) return;

    final now = DateTime.now().toIso8601String();

    if (_isEditMode && _familyClientId != null) {
      final familyUpdate = {
        "address_line": _addressController.text.trim(),
        "landmark": _landmarkController.text.trim(),
        "phone": _mobileController.text.trim(),
        "device_updated_at": now,
        "is_dirty": 1,
        "dirty_operation": "update",
        "local_updated_at": now,
      };

      await _familiesDao.updateFamily(_familyClientId!, familyUpdate);
      _basicsSaved = true;
    } else {
      final String localFamilyId = const Uuid().v4();
      _familyClientId = localFamilyId;

      final familyData = {
        "id": localFamilyId,
        "client_id": null,

        "address_line": _addressController.text.trim(),
        "landmark": _landmarkController.text.trim(),
        "phone": _mobileController.text.trim(),

        "phc_id": Session.instance.phcId,
        "area_id": Session.instance.areaId,
        "asha_worker_id": Session.instance.ashaWorkerId,
        "anm_worker_id": Session.instance.anmWorkerId,

        "device_created_at": now,
        "device_updated_at": now,

        "is_dirty": 1,
        "dirty_operation": "insert",
        "local_updated_at": now,
      };

      await _familiesDao.insertFamily(familyData);
      _basicsSaved = true;
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          _isEditMode ? t("family_basics_updated") : t("family_basics_saved"),
        ),
      ),
    );

    setState(() {});
  }

  Future<void> _onFinalSaveFamily() async {
    final t = AppLocalization.of(context).t;

    if (!_basicsSaved) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("save_basics_first"))),
      );
      return;
    }

    if (_members.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(t("add_member_first"))),
      );
      return;
    }

    final membersRepo = MembersRepository(MembersDao());
    final healthRepo = HealthRecordsRepository(
      HealthRecordsDao(),
      MembersDao(),
      FamiliesDao(),
    );

    for (final m in _members) {
      final localMemberId = await membersRepo.createMember(
        localFamilyId: _familyClientId!,
        member: {
          "name": m.name,
          "age": m.age,
          "gender": m.gender,
          "relation": m.relation,
          "aadhaar": m.aadhaar,
          "phone": m.phone,
        },
      );

      for (final hc in m.healthCases) {
        await healthRepo.saveHealthRecord(
          localMemberId: localMemberId,
          visitType: hc,
          dataJson: m.healthDetails[hc] ?? {},
        );
      }
    }

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(t("family_saved"))),
    );

    Navigator.pop(context);
  }

  Future<void> _onAddMemberPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) => AddMemberPage(
          isFirstMember: _members.isEmpty,   // ⭐ THIS IS THE KEY FIX
        ),
      ),
    );

    if (result != null) {
      setState(() {
        _members.add(
          _MemberSummary(
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
    final t = AppLocalization.of(context).t;

    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditMode ? t("edit_family") : t("add_family")),
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

              SectionTitle(title: t("family_basic_details")),
              const SizedBox(height: 16),

              AppTextField(label: t("address"), controller: _addressController),
              const SizedBox(height: 16),

              AppTextField(label: t("landmark"), controller: _landmarkController),
              const SizedBox(height: 16),

              AppTextField(
                label: t("mobile_number"),
                controller: _mobileController,
                keyboardType: TextInputType.phone,
              ),

              const SizedBox(height: 28),

              SectionTitle(title: t("family_members")),
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
                child: Text(
                  t("no_members_yet"),
                  style: const TextStyle(color: Colors.grey),
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
                        child: Text(
                            m.name.isNotEmpty ? m.name[0] : "?"),
                      ),
                      title: Text(m.name),
                      subtitle: Text("${t("age")}: ${m.age} | ${m.relation ?? ''}"),
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

            // SAVE BASICS
            ElevatedButton(
              onPressed: _onSaveFamilyBasics,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF00897B),
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                _isEditMode ? t("update_family_basics") : t("save_family_basics"),
                style: const TextStyle(color: Colors.white),
              ),
            ),

            const SizedBox(height: 12),

            // ADD MEMBER
            OutlinedButton.icon(
              onPressed: _basicsSaved ? _onAddMemberPressed : null,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: Text(t("add_member")),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),

            const SizedBox(height: 12),

            // FINAL SAVE
            ElevatedButton(
              onPressed: _onFinalSaveFamily,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
              child: Text(
                t("save_entire_family"),
                style: const TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
