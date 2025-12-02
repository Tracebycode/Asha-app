import 'package:flutter/material.dart';
import 'package:asha_frontend/features/family/ui/widgets/common_form_widgets.dart';
import 'package:asha_frontend/features/family/ui/add_member_page.dart';

class _MemberSummary {
  String name;
  int age;
  String? gender;
  String? relation;
  List<String> healthCases;
  Map<String, dynamic> healthDetails;
  String? aadhaar;
  String? phone;


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

  @override
  void dispose() {
    _addressController.dispose();
    _landmarkController.dispose();
    _mobileController.dispose();
    super.dispose();
  }

  void _onSaveFamilyBasics() {
    if (_formKey.currentState?.validate() != true) return;

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text("Family basics saved.")),
    );
  }

  // ADD MEMBER
  Future<void> _onAddMemberPressed() async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const AddMemberPage()),
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
            "aadhaar":m.aadhaar,
             "phone":m.phone,
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
          aadhaar:updated["aadhaar"],
          phone:updated["phone"],
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
              onPressed: _onAddMemberPressed,
              icon: const Icon(Icons.person_add_alt_1_outlined),
              label: const Text("Add Member"),
              style: OutlinedButton.styleFrom(
                minimumSize: const Size(double.infinity, 48),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12)),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
