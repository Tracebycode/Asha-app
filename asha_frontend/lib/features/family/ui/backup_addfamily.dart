// import 'package:flutter/material.dart';
// import 'head_form.dart';
// import 'package:asha_frontend/features/family/ui/widgets/common_form_widgets.dart';
// // IMPORTANT: apna HealthCaseDropdown jaha rakha hai uska sahi import lagao:
// import 'package:asha_frontend/features/family/ui/widgets/health_case_dropdown.dart'; // path adjust if needed
// import 'package:asha_frontend/features/anc/state/anc_controller.dart';
// import 'package:asha_frontend/features/anc/ui/anc_form.dart';
// import 'package:asha_frontend/features/pnc/state/pnc_controller.dart';
// import 'package:asha_frontend/features/pnc/ui/pnc_form.dart';
// import 'package:asha_frontend/features/tb/state/tb_controller.dart';
// import 'package:asha_frontend/features/tb/ui/tb_form.dart';
// import 'package:asha_frontend/features/ncd/state/ncd_controller.dart';
// import 'package:asha_frontend/features/ncd/ui/ncd_form.dart';
// import 'package:asha_frontend/features/general/state/general_survey_controller.dart';
// import 'package:asha_frontend/features/general/ui/general_survey_form.dart';
//
//
//
//
//
//
// class AddFamilyPage extends StatefulWidget {
//   const AddFamilyPage({super.key});
//
//   @override
//   State<AddFamilyPage> createState() => _AddFamilyPageState();
// }
//
// class _AddFamilyPageState extends State<AddFamilyPage> {
//   final _formKey = GlobalKey<FormState>();
//
//   // head controllers
//   final _headName = TextEditingController();
//   final _headAge = TextEditingController();
//   final _headAddress = TextEditingController();
//   final _headPhone = TextEditingController();
//   final _headAadhaar = TextEditingController();
//   final _headLandmark = TextEditingController();
//   final _ancController = AncController();
//   final _pncController = PncController();
//   final _tbController = TbController();
//   final _ncdController = NcdController();
//   final _generalController = GeneralSurveyController();
//
//
//
//
//
//
//   String? _gender;
//
//   // health case
//   String? _selectedHealthCase;
//   final List<Map<String, dynamic>> _healthCases = const [
//     {'value': 'None', 'title': 'None', 'icon': Icons.not_interested},
//     {'value': 'ANC', 'title': 'ANC', 'icon': Icons.pregnant_woman},
//     {'value': 'PNC', 'title': 'PNC', 'icon': Icons.sentiment_satisfied_alt},
//     {'value': 'Immunization', 'title': 'Immunization', 'icon': Icons.vaccines},
//     {'value': 'NCD Screening','title': 'NCD Screening','icon': Icons.monitor_heart},
//     {'value': 'TB Screening', 'title': 'TB Screening', 'icon': Icons.local_hospital_outlined},
//     {'value': 'General', 'title': 'General Survey', 'icon': Icons.house_outlined},
//
//   ];
//
//   @override
//   void dispose() {
//     _headName.dispose();
//     _headAge.dispose();
//     _headAddress.dispose();
//     _headPhone.dispose();
//     _headAadhaar.dispose();
//     _headLandmark.dispose();
//
//     super.dispose();
//   }
//
//   void _onSave() {
//     if (_formKey.currentState?.validate() != true) return;
//
//     // yaha abhi sirf print/log kar rahe hain
//     debugPrint('Head name: ${_headName.text}');
//     debugPrint('Gender: $_gender');
//     debugPrint('Health case: $_selectedHealthCase');
//
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(content: Text('Family head saved (frontend only for now).')),
//     );
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: const Text('Add New Family'),
//         backgroundColor: const Color(0xFF2A5A9E),
//         foregroundColor: Colors.white,
//       ),
//       backgroundColor: Colors.grey[200],
//       body: Form(
//         key: _formKey,
//         child: SingleChildScrollView(
//           padding: const EdgeInsets.all(16),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               HeadForm(
//                 nameController: _headName,
//                 ageController: _headAge,
//                 addressController: _headAddress,
//                 landmarkController: _headLandmark,
//                 phoneController: _headPhone,
//                 aadhaarController: _headAadhaar,
//                 gender: _gender,
//                 onGenderChanged: (val) {
//                   setState(() => _gender = val);
//                 },
//               ),
//               const SizedBox(height: 24),
//
//               const SectionTitle(title: 'Health Case'),
//               const SizedBox(height: 8),
//               HealthCaseDropdown(
//                 label: 'Health Case',
//                 value: _selectedHealthCase,
//                 healthCases: _healthCases,
//                 onChanged: (val) {
//                   setState(() => _selectedHealthCase = val);
//                 },
//               ),
//
//               const SizedBox(height: 24),
//               // yaha baad me: ANC / PNC / TB / NCD sections conditionally add karenge
//               if (_selectedHealthCase == 'ANC')
//                 AncForm(controller: _ancController),
//               if (_selectedHealthCase == "PNC")
//                 PncForm(controller: _pncController),
//               if (_selectedHealthCase == "TB Screening")
//                 TbForm(controller: _tbController),
//               if (_selectedHealthCase == "NCD Screening")
//                 NcdForm(controller: _ncdController),
//               if (_selectedHealthCase == "General")
//                 GeneralSurveyForm(controller: _generalController),
//
//
//
//
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16),
//         child: ElevatedButton(
//           onPressed: _onSave,
//           style: ElevatedButton.styleFrom(
//             backgroundColor: const Color(0xFF00897B),
//             minimumSize: const Size(double.infinity, 50),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12),
//             ),
//           ),
//           child: const Text(
//             'Save Family Head',
//             style: TextStyle(color: Colors.white, fontSize: 18),
//           ),
//         ),
//       ),
//     );
//   }
// }
