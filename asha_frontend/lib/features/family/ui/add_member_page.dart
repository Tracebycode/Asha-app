import 'package:flutter/material.dart';
import 'package:asha_frontend/features/family/ui/widgets/common_form_widgets.dart';

// HEALTH CONTROLLERS + FORMS
import 'package:asha_frontend/features/anc/ui/anc_form.dart';
import 'package:asha_frontend/features/anc/state/anc_controller.dart';

import 'package:asha_frontend/features/pnc/ui/pnc_form.dart';
import 'package:asha_frontend/features/pnc/state/pnc_controller.dart';

import 'package:asha_frontend/features/tb/ui/tb_form.dart';
import 'package:asha_frontend/features/tb/state/tb_controller.dart';

import 'package:asha_frontend/features/ncd/ui/ncd_form.dart';
import 'package:asha_frontend/features/ncd/state/ncd_controller.dart';

import 'package:asha_frontend/features/general/ui/general_survey_form.dart';
import 'package:asha_frontend/features/general/state/general_survey_controller.dart';

class AddMemberPage extends StatefulWidget {
  final Map<String, dynamic>? existingMember;

  const AddMemberPage({super.key, this.existingMember});

  @override
  State<AddMemberPage> createState() => _AddMemberPageState();
}

class _AddMemberPageState extends State<AddMemberPage> {
  final _formKey = GlobalKey<FormState>();

  // BASIC FIELDS
  final _name = TextEditingController();
  final _age = TextEditingController();
  final _aadhaar = TextEditingController();
  final _phone = TextEditingController();

  String? _gender;
  String? _relation;

  // HEALTH CASES
  List<String> _selectedHealthCases = [];
  String? _currentHealthCase;
  String? _activeHealthCase;

  // CONTROLLERS
  final ancController = AncController();
  final pncController = PncController();
  final tbController = TbController();
  final ncdController = NcdController();
  final generalController = GeneralSurveyController();

  final Map<String, bool> _savedCaseStatus = {};

  @override
  void initState() {
    super.initState();

    if (widget.existingMember != null) {
      final m = widget.existingMember!;

      _name.text = m["name"] ?? "";
      _age.text = m["age"]?.toString() ?? "";
      _gender = m["gender"];
      _relation = m["relation"];
      _aadhaar.text = m["aadhaar"] ?? "";
      _phone.text = m["phone"] ?? "";


      if (m["healthCases"] != null) {
        _selectedHealthCases = List<String>.from(m["healthCases"]);
      }

      if (m["healthDetails"] != null) {
        final hd = m["healthDetails"];

        if (hd["ANC"] != null) ancController.loadFromMap(hd["ANC"]);
        if (hd["PNC"] != null) pncController.loadFromMap(hd["PNC"]);
        if (hd["TB Screening"] != null) tbController.loadFromMap(hd["TB Screening"]);
        if (hd["NCD Screening"] != null) ncdController.loadFromMap(hd["NCD Screening"]);
        if (hd["General Survey"] != null) generalController.loadFromMap(hd["General Survey"]);
      }
    }
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _aadhaar.dispose();
    _phone.dispose();
    super.dispose();
  }

  // CASE VALIDATION
  bool _isCaseAllowed(String caseName) {
    final int age = int.tryParse(_age.text.trim()) ?? 0;
    final String gender = _gender ?? "";

    if (gender == "Male") {
      if (caseName == "ANC" || caseName == "PNC") return false;
    }

    if (caseName == "Immunization" && age > 3) return false;

    return true;
  }

  // SAVE MEMBER
  void _saveMember() {
    if (!_formKey.currentState!.validate()) {
      print("❌ Validation failed");
      return;
    }

    // --- BUILD HEALTH DETAILS MAP ---
    final Map<String, dynamic> healthDetails = {};

    if (_selectedHealthCases.contains("ANC")) {
      healthDetails["ANC"] = ancController.toMap();
    }
    if (_selectedHealthCases.contains("PNC")) {
      healthDetails["PNC"] = pncController.toMap();
    }
    if (_selectedHealthCases.contains("TB Screening")) {
      healthDetails["TB Screening"] = tbController.toMap();
    }
    if (_selectedHealthCases.contains("NCD Screening")) {
      healthDetails["NCD Screening"] = ncdController.toMap();
    }
    if (_selectedHealthCases.contains("General Survey")) {
      healthDetails["General Survey"] = generalController.toMap();
    }

    // --- PACK FINAL DATA ---
    final Map<String, dynamic> data = {
      "name": _name.text.trim(),
      "age": int.tryParse(_age.text.trim()) ?? 0,
      "gender": _gender,
      "relation": _relation,
      "aadhaar": _aadhaar.text.trim(),
      "phone": _phone.text.trim(),
      "healthCases": List<String>.from(_selectedHealthCases),
      "healthDetails": healthDetails,
    };

    print("✅ Returning MEMBER DATA: $data");

    Navigator.pop(context, data);
  }

  @override
  Widget build(BuildContext context) {
    final bool isEditing = widget.existingMember != null;

    return Scaffold(
      appBar: AppBar(
        title: Text(isEditing ? "Edit Member" : "Add Member"),
        backgroundColor: const Color(0xFF2A5A9E),
        foregroundColor: Colors.white,
      ),

      body: Form(
        key: _formKey,
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),

          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [

              // BASIC INFO
              const SectionTitle(title: "Basic Information"),
              const SizedBox(height: 12),

              AppTextField(label: "Name", controller: _name),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: "Age",
                      controller: _age,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppDropdown(
                      label: "Gender",
                      value: _gender,
                      items: const ["Male", "Female", "Other"],
                      onChanged: (v) => setState(() => _gender = v),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: AppTextField(
                      label: "Aadhaar Number",
                      controller: _aadhaar,
                      keyboardType: TextInputType.number,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: AppTextField(
                      label: "Phone Number",
                      controller: _phone,
                      keyboardType: TextInputType.phone,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              AppDropdown(
                label: "Relation",
                value: _relation,
                items: const [
                  "Head",
                  "Wife",
                  "Husband",
                  "Son",
                  "Daughter",
                  "Mother",
                  "Father",
                  "Other",
                ],
                onChanged: (v) => setState(() => _relation = v),
              ),

              const SizedBox(height: 20),

              // HEALTH CASE SELECTION
              const SectionTitle(title: "Health Cases"),
              const SizedBox(height: 12),

              Row(
                children: [
                  Expanded(
                    child: DropdownButtonFormField<String>(
                      value: _currentHealthCase,
                      decoration: InputDecoration(
                        labelText: "Select Health Case",
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      items: [
                        "ANC",
                        "PNC",
                        "Immunization",
                        "NCD Screening",
                        "TB Screening",
                        "General Survey",
                      ].map((c) {
                        final allowed = _isCaseAllowed(c);
                        return DropdownMenuItem(
                          enabled: allowed,
                          value: allowed ? c : null,
                          child: Text(
                            c,
                            style: TextStyle(
                              color: allowed ? Colors.black : Colors.grey,
                            ),
                          ),
                        );
                      }).toList(),
                      onChanged: (v) => setState(() => _currentHealthCase = v),
                    ),
                  ),

                  const SizedBox(width: 12),

                  ElevatedButton(
                    onPressed: () {
                      if (_currentHealthCase == null) return;
                      if (!_isCaseAllowed(_currentHealthCase!)) return;

                      if (!_selectedHealthCases.contains(_currentHealthCase)) {
                        setState(() {
                          _selectedHealthCases.add(_currentHealthCase!);
                          _activeHealthCase = _currentHealthCase!;
                        });
                      }
                    },
                    child: const Text("Add"),
                  ),
                ],
              ),

              const SizedBox(height: 20),

              // HEALTH CASE CARDS
              if (_selectedHealthCases.isNotEmpty)
                Column(
                  children: _selectedHealthCases.map((caseName) {
                    final isExpanded = _activeHealthCase == caseName;
                    final isSaved = _savedCaseStatus[caseName] == true;

                    return Card(
                      elevation: isExpanded ? 4 : 1,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                        side: BorderSide(
                          color: isSaved
                              ? Colors.green
                              : (isExpanded ? const Color(0xFF2A5A9E) : Colors.grey.shade300),
                          width: 1.4,
                        ),
                      ),
                      child: InkWell(
                        onTap: () => setState(() => _activeHealthCase = caseName),
                        child: Padding(
                          padding: const EdgeInsets.all(12),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [

                              Row(
                                children: [
                                  Icon(Icons.medical_information_outlined,
                                      color: isExpanded ? const Color(0xFF2A5A9E) : Colors.grey),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Text(
                                      caseName,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                  ),
                                  if (isSaved)
                                    const Icon(Icons.check_circle,
                                        color: Colors.green),
                                ],
                              ),

                              if (isExpanded) ...[
                                const SizedBox(height: 12),

                                if (caseName == "ANC")
                                  AncForm(controller: ancController),

                                if (caseName == "PNC")
                                  PncForm(controller: pncController),

                                if (caseName == "TB Screening")
                                  TbForm(controller: tbController),

                                if (caseName == "NCD Screening")
                                  NcdForm(controller: ncdController),

                                if (caseName == "General Survey")
                                  GeneralSurveyForm(controller: generalController),

                                const SizedBox(height: 12),

                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      _savedCaseStatus[caseName] = true;
                                      _activeHealthCase = null;
                                    });
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: const Color(0xFF00897B),
                                  ),
                                  child: const Text("Save Health Case"),
                                ),
                              ]
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),

              const SizedBox(height: 80),
            ],
          ),
        ),
      ),

      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16),
        child: ElevatedButton(
          onPressed: _saveMember,
          style: ElevatedButton.styleFrom(
            minimumSize: const Size(double.infinity, 50),
            backgroundColor: const Color(0xFF00897B),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: Text(
            isEditing ? "Update Member" : "Save Member",
            style: const TextStyle(color: Colors.white, fontSize: 18),
          ),
        ),
      ),
    );
  }
}
