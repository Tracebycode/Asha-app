// import 'package:flutter/material.dart';
// // Import the reusable widget we created
// import '../widgets/health_case_dropdown.dart';
//
// class AddFamilyDetailsPage extends StatefulWidget {
//   const AddFamilyDetailsPage({super.key});
//
//   @override
//   State<AddFamilyDetailsPage> createState() => _AddFamilyDetailsPageState();
// }
//
// class _Member {
//   final int id;
//   String? selectedGender;
//   String? selectedHealthCase;
//   String? selectedExtraHealthCase;
//   String? selectedRelationship;
//   bool showTbScreening = false;
//   bool showAncSection = false;
//   bool showPncSection = false;
//   bool showNcdScreening = false;
//   _Member({required this.id});
// }
//
// class _AddFamilyDetailsPageState extends State<AddFamilyDetailsPage> {
//   final _formKey = GlobalKey<FormState>();
//   String? _selectedGender;
//   String? _selectedHealthCase;
//   String? _selectedExtraHealthCase;
//   bool _showTbScreening = false;
//   bool _showAncSection = false;
//   bool _showPncSection = false;
//   bool _showExtraAncSection = false;
//   bool _showExtraPncSection = false;
//   bool _showExtraNcdScreening = false;
//   bool _showExtraTbScreening = false;
//
//   // ANC State
//   int _gravida = 0;
//   int _para = 0;
//   int _living = 0;
//   int _abortions = 0;
//   DateTime? _lmpDate;
//   DateTime? _eddDate;
//   bool _showFollowUpSection = false;
//   final _bpController = TextEditingController();
//   final _weightController = TextEditingController();
//   final _hemoglobinController = TextEditingController();
//   final _bloodSugarController = TextEditingController();
//   final _otherSymptomsController = TextEditingController();
//   final _ifaTabletsController = TextEditingController();
//   final _calciumTabletsController = TextEditingController();
//   final Set<String> _currentSymptoms = {};
//   bool? _previousCesarean;
//   bool? _previousStillbirth;
//   bool? _previousComplications;
//   String? _selectedVaccineDose;
//   DateTime? _vaccinationDate;
//
//   // PNC State (Mother)
//   DateTime? _pncCheckupDate;
//   final _pncBpController = TextEditingController();
//   final _pncPulseController = TextEditingController();
//   bool? _hasExcessiveBleeding;
//   bool? _isBreastHealthNormal;
//   String? _motherFeeling;
//   final Set<String> _motherDangerSigns = {};
//   final Set<String> _babyDangerSigns = {};
//   final _pncNotesController = TextEditingController();
//
//   // START: Add state variables for PNC section (Baby)
//   final _babyWeightController = TextEditingController();
//   final _babyTempController = TextEditingController();
//   String? _babyActivity; // 'Active' or 'Lethargic'
//   String? _babyBreathing; // 'Normal' or 'Fast'
//   String? _babySkinColor; // 'Normal' or 'Jaundiced'
//   bool? _isBreastfeeding;
//   bool? _hasGoodAttachment;
//   DateTime? _followUpDate;
//   TimeOfDay? _followUpTime;
//   bool? _motherHasComplications;
//   final _followUpBpController = TextEditingController();
//   bool _newbornImmunizationsUpToDate = true;
//   final _newbornWeightController = TextEditingController();
//   // END: Add PNC (Baby) state variables
//
//   // TB Screening State
//   bool _hasCough = false;
//   String _coughDuration = 'Days';
//   final Set<String> _coughTypes = {};
//   bool _hasFever = false;
//   String _feverDurationUnit = 'Days';
//   String? _selectedFeverPattern;
//   bool _hasWeightLoss = false;
//   String _weightLossPeriod = 'Last 2 weeks';
//   bool _hasChestPain = false;
//   bool _hasTbPatientAtHome = false;
//   bool _hadTbInPast = false;
//
//
//   //NCD screnning
//   bool _showNcdScreening = false;
//   final _ncdSystolicController = TextEditingController();
//   final _ncdDiastolicController = TextEditingController();
//   final _ncdWeightController = TextEditingController();
//   final _ncdHeightController = TextEditingController();
//   final _ncdRandomBloodSugarController = TextEditingController();
//   bool _usesTobacco = false;
//   bool _consumesAlcohol = false;
//   String? _extraSaltIntake;
//   String? _exerciseFrequency;
//
//   // Member List State
//   final List<_Member> _members = [];
//   int _nextMemberId = 0;
//
//   final List<Map<String, dynamic>> _healthCases = [
//     {'value': 'None', 'title': 'None', 'icon': Icons.not_interested},
//     {'value': 'ANC', 'title': 'ANC', 'icon': Icons.pregnant_woman},
//     {'value': 'PNC', 'title': 'PNC', 'icon': Icons.sentiment_satisfied_alt},
//     {'value': 'Immunization', 'title': 'Immunization', 'icon': Icons.vaccines},
//     {'value': 'NCD Screening','title': 'NCD Screening','icon': Icons.monitor_heart},
//     {'value': 'TB Screening', 'title': 'TB Screening', 'icon': Icons.local_hospital_outlined},
//   ];
//
//   final List<String> _relationshipOptions = [
//     'Spouse',
//     'Son',
//     'Daughter',
//     'Father',
//     'Mother',
//     'Brother',
//     'Sister',
//     'Other'
//   ];
//
//
//   bool get _isTbCaseCritical {
//     int score = 0;
//     if (_coughTypes.contains('With Blood')) score += 3;
//     if (_hadTbInPast) score += 2;
//     if (_hasTbPatientAtHome) score += 2;
//     if (_hasWeightLoss) score += 1;
//     if (_hasFever) score += 1;
//     if (_hasChestPain) score += 1;
//     if (_hasCough) score += 1;
//     if (_hasChestPain) score += 1;
//     if (_hasCough) score += 1;
//     return score >= 3;
//   }
//
//   bool get _isNcdCaseCritical {
//     final systolic = int.tryParse(_ncdSystolicController.text);
//     final diastolic = int.tryParse(_ncdDiastolicController.text);
//     if ((systolic != null && systolic >= 140) ||
//         (diastolic != null && diastolic >= 90)) {
//       return true;
//     }
//
//     // Random Blood Sugar
//     final bloodSugar = int.tryParse(_ncdRandomBloodSugarController.text);
//     if (bloodSugar != null && bloodSugar >= 200) {
//       return true;
//     }
//
//     // BMI Calculation
//     final weight = double.tryParse(_ncdWeightController.text);
//     final height = double.tryParse(_ncdHeightController.text);
//     if (weight != null && height != null && height > 0) {
//       final heightInMeters = height / 100;
//       final bmi = weight / (heightInMeters * heightInMeters);
//       if (bmi < 18.5 || bmi >= 25) {
//         return true;
//       }
//     }
//     return false;
//   }
//
//   bool get _isPncCaseCritical {
//     if (_motherDangerSigns.isNotEmpty || _babyDangerSigns.isNotEmpty) {
//       return true;
//     }
//     return false;
//   }
//   bool get _isAncCaseCritical {
//     const criticalSymptoms = {'Bleeding', 'Severe Headache', 'Convulsions (Fits)'};
//     if (_currentSymptoms.any((symptom) => criticalSymptoms.contains(symptom))) {
//       return true;
//     }
//     if (_previousStillbirth == true || _previousComplications == true) {
//       return true;
//     }
//     final bp = _bpController.text;
//     if (bp.isNotEmpty) {
//       final parts = bp.split('/');
//       if (parts.length == 2) {
//         final systolic = int.tryParse(parts[0].trim());
//         final diastolic = int.tryParse(parts[1].trim());
//         if ((systolic != null && systolic >= 140) || (diastolic != null && diastolic >= 90)) {
//           return true;
//         }
//       }
//     }
//     return false;
//   }
//
//   @override
//   void dispose() {
//     // Dispose all controllers
//     _bpController.dispose();
//     _weightController.dispose();
//     _hemoglobinController.dispose();
//     _bloodSugarController.dispose();
//     _otherSymptomsController.dispose();
//     _ifaTabletsController.dispose();
//     _calciumTabletsController.dispose();
//     _pncBpController.dispose();
//     _pncPulseController.dispose();
//     _babyWeightController.dispose(); // <-- Dispose new controller
//     _babyTempController.dispose();   // <-- Dispose new controller
//     _pncNotesController.dispose();
//     super.dispose();
//     _followUpBpController.dispose();
//     _newbornWeightController.dispose();
//     _ncdSystolicController.dispose();
//     _ncdDiastolicController.dispose();
//     _ncdWeightController.dispose();
//     _ncdHeightController.dispose();
//     _ncdRandomBloodSugarController.dispose();
//     bool _usesTobacco = false;
//     bool _consumesAlcohol = false;  String? _extraSaltIntake;
//     String? _exerciseFrequency;
//   }
//
//   void _addMember() {
//     setState(() {
//       _members.add(_Member(id: _nextMemberId++));
//     });
//   }
//
//   void _deleteMember(int id) {
//     setState(() {
//       _members.removeWhere((member) => member.id == id);
//     });
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
//           padding: const EdgeInsets.all(16.0),
//           child: Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               _buildTextField(label: 'Family Head Name', icon: Icons.person_outline),
//               const SizedBox(height: 16),
//               Row(
//                 children: [
//                   Expanded(child: _buildTextField(label: 'Age', keyboardType: TextInputType.number)),
//                   const SizedBox(width: 16),
//                   Expanded(child: _buildGenderDropdown()),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               _buildTextField(label: 'Address', icon: Icons.home_outlined),
//               const SizedBox(height: 16),
//               _buildTextField(label: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
//               const SizedBox(height: 16),
//               _buildTextField(label: 'Aadhaar Number', icon: Icons.credit_card_outlined, keyboardType: TextInputType.number),
//               const SizedBox(height: 32),
//
//               HealthCaseDropdown(label: 'Health Case',
//                 value: _selectedHealthCase,
//                 healthCases: _healthCases,
//                 onChanged: (value) {
//                   setState(() {
//                     _selectedHealthCase = value;
//                     _showTbScreening = value == 'TB Screening';
//                     _showAncSection = value == 'ANC';
//                     _showPncSection = value == 'PNC';
//                     _showNcdScreening = value == 'NCD Screening';
//                   });
//                 },
//               ),
//
//               if (_showAncSection) _buildAncSection(),
//               if (_showTbScreening) _buildTbScreeningSection(_selectedHealthCase),
//               if (_showPncSection) _buildPncSection(),
//               if (_showNcdScreening) _buildNcdSection(),
//               if (_showAncSection || _showTbScreening)
//                 Padding(
//                   padding: const EdgeInsets.only(top: 24.0),
//                   child: HealthCaseDropdown(
//                     label: 'Add Another Health Case (Optional)',
//                     value: _selectedExtraHealthCase,
//                     healthCases: _healthCases,
//                     onChanged: (value) {
//                       setState(() {
//                         _selectedExtraHealthCase = value;
//                       });
//                     },
//                   ),
//                 ),
//               Padding(
//                 padding: const EdgeInsets.only(top: 24.0),
//                 child: HealthCaseDropdown(
//                   label: 'Add Another Health Case (Optional)',
//                   value: _selectedExtraHealthCase,
//                   healthCases: _healthCases,
//                   onChanged: (value) {
//                     setState(() {
//                       _selectedExtraHealthCase = value;
//                       // Logic to show/hide the EXTRA sections
//                       _showExtraAncSection = value == 'ANC';
//                       _showExtraPncSection = value == 'PNC';
//                       _showExtraNcdScreening = value == 'NCD Screening';
//                       _showExtraTbScreening = value == 'TB Screening';
//                     });
//                   },
//                 ),
//               ),
//
//
//               if (_showExtraAncSection) _buildAncSection(),
//               if (_showExtraPncSection) _buildPncSection(),
//               if (_showExtraNcdScreening) _buildNcdSection(),
//               if (_showExtraTbScreening) _buildTbScreeningSection(_selectedExtraHealthCase),
//
//               const SizedBox(height: 16),
//               ..._members.map((member) => _buildAddMemberCard(member)).toList(),
//             ],
//           ),
//         ),
//       ),
//       bottomNavigationBar: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           mainAxisSize: MainAxisSize.min,
//           children: [
//             ElevatedButton(
//               onPressed: () {
//                 if (_formKey.currentState!.validate()) {
//                   ScaffoldMessenger.of(context).showSnackBar(
//                     const SnackBar(
//                       content: Text('Family Head Details Saved!'),
//                       backgroundColor: Colors.green,
//                     ),
//                   );
//                 }
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF00897B),
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               child: const Text(
//                 'Save Family Head',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//             const SizedBox(height: 16),
//             _buildLightBlueButton(
//               text: 'Add New Member',
//               icon: Icons.person_add_alt_1_outlined,
//               onTap: _addMember,
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: () {
//                 ScaffoldMessenger.of(context).showSnackBar(
//                   const SnackBar(content: Text('Saving All Family Details...')),
//                 );
//               },
//               style: ElevatedButton.styleFrom(
//                 backgroundColor: const Color(0xFF2A5A9E),
//                 minimumSize: const Size(double.infinity, 50),
//                 shape: RoundedRectangleBorder(
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//               ),
//               child: const Text(
//                 'Save Entire Family',
//                 style: TextStyle(color: Colors.white, fontSize: 18),
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   //PNC section starts here
//   Widget _buildPncSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         // --- Mother's Check ---
//         const Padding(
//           padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
//           child: Text(
//             'Post-Natal Survey: Mother Check',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2A5A9E)),
//           ),
//         ),
//         _buildDatePicker(
//           label: 'Date of checkup',
//           selectedDate: _pncCheckupDate,
//           onDateSelected: (date) {
//             setState(() {
//               _pncCheckupDate = date;
//             });
//           },
//         ),
//         const SizedBox(height: 24),
//         const Text('Vital Signs', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(child: _buildTextFieldWithLabel(label: 'Blood Pressure', controller: _pncBpController, hint: 'e.g. 120/80')),
//             const SizedBox(width: 16),
//             Expanded(child: _buildTextFieldWithLabel(label: 'Pulse Rate', controller: _pncPulseController, hint: 'e.g. 72 bpm')),
//           ],
//         ),
//         const SizedBox(height: 24),
//         const Text('Physical Assessment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         _buildYesNoQuestion(
//           label: 'Signs of excessive bleeding?',
//           value: _hasExcessiveBleeding,
//           onChanged: (val) => setState(() => _hasExcessiveBleeding = val),
//         ),
//         const SizedBox(height: 16),
//         _buildYesNoQuestion(
//           label: 'Breast health normal?',
//           value: _isBreastHealthNormal,
//           onChanged: (val) => setState(() => _isBreastHealthNormal = val),
//         ),
//         const SizedBox(height: 24),
//         const Text('Mental Well-being', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         const Text('How is the mother feeling today?'),
//         const SizedBox(height: 16),
//         Row(
//           mainAxisAlignment: MainAxisAlignment.spaceAround,
//           children: [
//             _buildFeelingCard(icon: Icons.sentiment_very_satisfied, label: 'Happy', feeling: 'Happy'),
//             _buildFeelingCard(icon: Icons.sentiment_neutral, label: 'Neutral', feeling: 'Neutral'),
//             _buildFeelingCard(icon: Icons.sentiment_very_dissatisfied, label: 'Sad', feeling: 'Sad'),
//           ],
//         ),
//         const Divider(height: 48),
//
//         // --- Baby's Check ---
//         const Padding(
//           padding: EdgeInsets.only(bottom: 16.0),
//           child: Text(
//             'Post-Natal Survey: Baby Check',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2A5A9E)),
//           ),
//         ),
//         const Text('Vitals & Measurements', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         _buildTextField(label: "Baby's Weight (kg)", controller: _babyWeightController, icon: Icons.scale_outlined, keyboardType: TextInputType.number),
//         const SizedBox(height: 16),
//         _buildTextField(label: "Temperature (°C)", controller: _babyTempController, icon: Icons.thermostat_outlined, keyboardType: TextInputType.number),
//
//         const SizedBox(height: 24),
//         const Text('General Condition', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         _buildToggleQuestion<String>(
//           label: 'Is baby active?',
//           option1: 'Active',
//           option2: 'Lethargic',
//           icon1: Icons.sentiment_satisfied,
//           icon2: Icons.sentiment_dissatisfied,
//           groupValue: _babyActivity,
//           onChanged: (val) => setState(() => _babyActivity = val),
//         ),
//         const SizedBox(height: 16),
//         _buildToggleQuestion<String>(
//           label: 'Breathing status',
//           option1: 'Normal',
//           option2: 'Fast',
//           icon1: Icons.waves, // Placeholder icon
//           icon2: Icons.double_arrow,
//           groupValue: _babyBreathing,
//           onChanged: (val) => setState(() => _babyBreathing = val),
//         ),
//         const SizedBox(height: 16),
//         _buildToggleQuestion<String>(
//           label: 'Skin color',
//           option1: 'Normal',
//           option2: 'Jaundiced',
//           icon1: Icons.face,
//           icon2: Icons.face_retouching_off,
//           groupValue: _babySkinColor,
//           onChanged: (val) => setState(() => _babySkinColor = val),
//         ),
//
//         const SizedBox(height: 24),
//         const Text('Feeding Assessment', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         _buildToggleQuestion<bool>(
//           label: 'Breastfeeding?',
//           option1: true,
//           option2: false,
//           icon1: Icons.check_circle,
//           icon2: Icons.cancel,
//           groupValue: _isBreastfeeding,
//           onChanged: (val) => setState(() => _isBreastfeeding = val),
//         ),
//         const SizedBox(height: 16),
//         _buildToggleQuestion<bool>(
//           label: 'Signs of good attachment?',
//           option1: true,
//           option2: false,
//           icon1: Icons.thumb_up,
//           icon2: Icons.thumb_down,
//           groupValue: _hasGoodAttachment,
//           onChanged: (val) => setState(() => _hasGoodAttachment = val),
//         ),
//         const Divider(height: 48),
//
//         // --- Danger Signs and Notes ---
//         const Text("Mother's Danger Signs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         _buildDangerSignCheckbox(label: 'Fever', icon: Icons.thermostat, group: _motherDangerSigns),
//         _buildDangerSignCheckbox(label: 'Severe Bleeding', icon: Icons.opacity, group: _motherDangerSigns),
//         _buildDangerSignCheckbox(label: 'Foul-smelling Discharge', icon: Icons.personal_injury_outlined, group: _motherDangerSigns),
//         _buildDangerSignCheckbox(label: 'Severe Headache', icon: Icons.sentiment_very_dissatisfied, group: _motherDangerSigns),
//         _buildDangerSignCheckbox(label: 'Convulsions/Fits', icon: Icons.flash_on, group: _motherDangerSigns),
//
//         const SizedBox(height: 24),
//         const Text("Baby's Danger Signs", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         _buildDangerSignCheckbox(label: 'Difficulty Breathing', icon: Icons.air, group: _babyDangerSigns),
//         _buildDangerSignCheckbox(label: 'High/Low Temperature', icon: Icons.thermostat_auto, group: _babyDangerSigns),
//         _buildDangerSignCheckbox(label: 'Not Feeding Well', icon: Icons.no_food, group: _babyDangerSigns),
//         _buildDangerSignCheckbox(label: 'Yellow Skin/Eyes', icon: Icons.face_retouching_natural, group: _babyDangerSigns),
//
//         const SizedBox(height: 24),
//         const Text('Notes (Optional)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _pncNotesController,
//           maxLines: 4,
//           decoration: InputDecoration(
//             hintText: 'Add any additional observations here...',
//             fillColor: Colors.white,
//             filled: true,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide.none,
//             ),
//           ),
//         ),
//
//         const Divider(height: 48),
//
//         // --- Follow-up Details ---
//         const Text('Follow-up Details', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//         const SizedBox(height: 16),
//         _buildDatePicker(
//           label: 'Follow-up Visit Date',
//           selectedDate: _followUpDate,
//           onDateSelected: (date) {
//             setState(() {
//               _followUpDate = date;
//             });
//           },
//         ),
//         const SizedBox(height: 16),
//         _buildTimePicker(
//           label: 'Follow-up Visit Time',
//           selectedTime: _followUpTime,
//           onTimeSelected: (time) {
//             setState(() {
//               _followUpTime = time;
//             });
//           },
//         ),
//
//         const SizedBox(height: 24),
//         const Text("Mother's Health Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         _buildYesNoQuestion(
//           label: 'Any complications observed?',
//           value: _motherHasComplications,
//           onChanged: (val) => setState(() => _motherHasComplications = val),
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           label: 'Blood Pressure (Systolic/Diastolic)',
//           controller: _followUpBpController,
//           hintText: 'e.g., 120/80',
//         ),
//
//         const SizedBox(height: 24),
//         const Text("Newborn's Health Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Immunizations up to date?', style: TextStyle(fontSize: 14)),
//               Switch(
//                 value: _newbornImmunizationsUpToDate,
//                 onChanged: (value) {
//                   setState(() {
//                     _newbornImmunizationsUpToDate = value;
//                   });
//                 },
//                 activeColor: Colors.green,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           label: 'Weight (in kg)',
//           controller: _newbornWeightController,
//           hintText: 'e.g., 3.1',
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 16),
//         _buildPncCriticalCaseCard(),
//       ],
//     );
//   }
// //end of PNC
//
//
//
//   Widget _buildToggleQuestion<T>({
//     required String label,
//     required T option1,
//     required T option2,
//     required IconData icon1,
//     required IconData icon2,
//     required T? groupValue,
//     required ValueChanged<T?> onChanged,
//   }) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 14)),
//         const SizedBox(height: 8),
//         Row(
//           children: [
//             Expanded(child: _buildToggleCard(text: option1.toString() == 'true' ? 'Yes' : (option1.toString() == 'false' ? 'No' : option1.toString()), icon: icon1, isSelected: groupValue == option1, onTap: () => onChanged(option1))),
//             const SizedBox(width: 16),
//             Expanded(child: _buildToggleCard(text: option2.toString() == 'true' ? 'Yes' : (option2.toString() == 'false' ? 'No' : option2.toString()), icon: icon2, isSelected: groupValue == option2, onTap: () => onChanged(option2))),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildToggleCard({required String text, required IconData icon, required bool isSelected, required VoidCallback onTap}) {
//     final color = isSelected ? const Color(0xFF2A5A9E) : Colors.black54;
//     final bgColor = isSelected ? const Color(0xFF2A5A9E).withOpacity(0.1) : Colors.white;
//
//     return GestureDetector(
//       onTap: onTap,
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 16.0),
//         decoration: BoxDecoration(
//           color: bgColor,
//           borderRadius: BorderRadius.circular(12.0),
//           border: Border.all(color: isSelected ? const Color(0xFF2A5A9E) : Colors.grey.shade300, width: 1.5),
//         ),
//         child: Row(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: color),
//             const SizedBox(width: 8),
//             Text(text, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
//           ],
//         ),
//       ),
//     );
//   }
//
//   // NOTE: The rest of the file's methods are below for completeness.
//   // ... (The code from the previous correct response) ...
//
//   Widget _buildTextFieldWithLabel({required String label, required TextEditingController controller, required String hint}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           decoration: InputDecoration(
//             hintText: hint,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildYesNoQuestion({required String label, required bool? value, required ValueChanged<bool> onChanged}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 14)),
//         const SizedBox(height: 8),
//         ToggleButtons(
//           isSelected: [value == true, value == false],
//           onPressed: (index) {
//             onChanged(index == 0);
//           },
//           borderRadius: BorderRadius.circular(8.0),
//           selectedColor: Colors.white,
//           fillColor: const Color(0xFF2A5A9E),
//           selectedBorderColor: const Color(0xFF2A5A9E),
//           constraints: const BoxConstraints(minHeight: 40.0, minWidth: 100.0),
//           children: const [
//             Text('Yes'),
//             Text('No'),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildFeelingCard({required IconData icon, required String label, required String feeling}) {
//     final bool isSelected = _motherFeeling == feeling;
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           _motherFeeling = feeling;
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF2A5A9E) : Colors.white,
//           borderRadius: BorderRadius.circular(12.0),
//           border: Border.all(color: isSelected ? const Color(0xFF2A5A9E) : Colors.grey.shade300),
//           boxShadow: [
//             if (isSelected)
//               BoxShadow(
//                 color: const Color(0xFF2A5A9E).withOpacity(0.3),
//                 blurRadius: 5,
//                 spreadRadius: 1,
//               )
//           ],
//         ),
//         child: Column(
//           children: [
//             Icon(
//               icon,
//               size: 32,
//               color: isSelected ? Colors.white : (feeling == 'Happy' ? Colors.green : (feeling == 'Neutral' ? Colors.orange : Colors.red)),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               label,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black,
//                 fontWeight: FontWeight.bold,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildTextField({required String label, IconData? icon, TextInputType? keyboardType, TextEditingController? controller, String? hintText}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: controller,
//           keyboardType: keyboardType,
//           decoration: InputDecoration(
//             hintText: hintText ?? 'Enter $label',
//             prefixIcon: icon != null ? Icon(icon, color: Colors.grey) : null,
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//           validator: (value) {
//             if (value == null || value.isEmpty) {
//               return 'Please enter $label';
//             }
//             return null;
//           },
//         ),
//       ],
//     );
//   }
//
//   Widget _buildGenderDropdown() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Text('Gender', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         DropdownButtonFormField<String>(
//           value: _selectedGender,
//           hint: const Text('Select'),
//           decoration: InputDecoration(
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//           items: ['Male', 'Female', 'Other'].map((String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//           onChanged: (newValue) {
//             setState(() {
//               _selectedGender = newValue;
//             });
//           },
//           validator: (value) => value == null ? 'Please select gender' : null,
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTbScreeningSection(String? healthCase) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (healthCase != null && healthCase != 'None')
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
//             child: Text(
//               healthCase!,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//           ),
//         const Text('Does the patient have a cough?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         _buildYesNoToggle(value: _hasCough, onChanged: (val) => setState(() => _hasCough = val)),
//         if (_hasCough)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               const Text('For how long?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//               const SizedBox(height: 8),
//               Row(
//                 children: [
//                   Expanded(child: _buildTextField(label: 'e.g., 2', keyboardType: TextInputType.number)),
//                   const SizedBox(width: 8),
//                   ToggleButtons(
//                     isSelected: [_coughDuration == 'Days', _coughDuration == 'Weeks'],
//                     onPressed: (index) {
//                       setState(() {
//                         _coughDuration = index == 0 ? 'Days' : 'Weeks';
//                       });
//                     },
//                     borderRadius: BorderRadius.circular(8.0),
//                     selectedColor: Colors.white,
//                     fillColor: const Color(0xFF2A5A9E),
//                     children: const [Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Days')), Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Weeks'))],
//                   ),
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Text('What kind of cough is it?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//               const Text('Select all that apply', style: TextStyle(fontSize: 12, color: Colors.grey)),
//               const SizedBox(height: 8),
//               _buildCoughTypeCheckbox(title: 'Dry', icon: Icons.air),
//               const SizedBox(height: 8),
//               _buildCoughTypeCheckbox(title: 'With Phlegm', icon: Icons.blur_on),
//               const SizedBox(height: 8),
//               _buildCoughTypeCheckbox(title: 'With Blood', icon: Icons.water_drop_outlined),
//             ],
//           ),
//         const SizedBox(height: 16),
//         const Divider(),
//         const SizedBox(height: 16),
//         const Text('Does the patient have a fever?',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         _buildYesNoToggle(value: _hasFever, onChanged: (val) => setState(() => _hasFever = val)),
//         if (_hasFever)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               Row(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Expanded(
//                     child: _buildTextField(
//                         label: 'Duration', keyboardType: TextInputType.number),
//                   ),
//                   const SizedBox(width: 8),
//                   Expanded(
//                     child: Column(
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         const Text('Unit', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//                         const SizedBox(height: 8),
//                         DropdownButtonFormField<String>(
//                           value: _feverDurationUnit,
//                           decoration: InputDecoration(
//                             border: OutlineInputBorder(
//                               borderRadius: BorderRadius.circular(12.0),
//                               borderSide: BorderSide.none,
//                             ),
//                             filled: true,
//                             fillColor: Colors.white,
//                           ),
//                           items: ['Days', 'Weeks', 'Months'].map((String value) {
//                             return DropdownMenuItem<String>(
//                               value: value,
//                               child: Text(value),
//                             );
//                           }).toList(),
//                           onChanged: (newValue) {
//                             setState(() {
//                               _feverDurationUnit = newValue!;
//                             });
//                           },
//                         ),
//                       ],
//                     ),
//                   ),
//
//                 ],
//               ),
//               const SizedBox(height: 16),
//               const Text('Fever Pattern', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//               const SizedBox(height: 8),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.spaceAround,
//                 children: [
//                   _buildFeverPatternChip('Continuous'),
//                   _buildFeverPatternChip('Intermittent'),
//                   _buildFeverPatternChip('Remittent'),
//                 ],
//               ),
//             ],
//           ),
//         const SizedBox(height: 16),
//         const Divider(),
//         const SizedBox(height: 16),
//         const Text('Has the patient had recent unintentional weight loss?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         _buildYesNoToggle(value: _hasWeightLoss, onChanged: (val) => setState(() => _hasWeightLoss = val)),
//         if(_hasWeightLoss)
//           Column(
//             crossAxisAlignment: CrossAxisAlignment.start,
//             children: [
//               const SizedBox(height: 16),
//               _buildTextField(label: 'Amount of weight loss (in kg)', icon: Icons.scale, keyboardType: TextInputType.number),
//               const SizedBox(height: 16),
//               DropdownButtonFormField<String>(
//                 value: _weightLossPeriod,
//                 decoration: InputDecoration(
//                   labelText: 'Time period',
//                   prefixIcon: const Icon(Icons.calendar_today, color: Colors.grey),
//                   border: OutlineInputBorder(
//                     borderRadius: BorderRadius.circular(12.0),
//                     borderSide: BorderSide.none,
//                   ),
//                   filled: true,
//                   fillColor: Colors.white,
//                 ),
//                 items: ['Last 2 weeks', 'Last month', 'Last 3 months'].map((String value) {
//                   return DropdownMenuItem<String>(
//                     value: value,
//                     child: Text(value),
//                   );
//                 }).toList(),
//                 onChanged: (newValue) {
//                   setState(() {
//                     _weightLossPeriod = newValue!;
//                   });
//                 },
//               ),
//             ],
//           ),
//         const SizedBox(height: 16),
//         const Divider(),
//         const SizedBox(height: 16),
//         const Text('Is the patient experiencing chest pain?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         _buildYesNoToggle(value: _hasChestPain, onChanged: (val) => setState(() => _hasChestPain = val)),
//         const SizedBox(height: 16),
//         const Divider(),
//         const SizedBox(height: 16),
//         const Text('Is there a TB patient at home?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         _buildYesNoToggle(value: _hasTbPatientAtHome, onChanged: (val) => setState(() => _hasTbPatientAtHome = val)),
//         const SizedBox(height: 16),
//         const Divider(),
//         const SizedBox(height: 16),
//         const Text('Has the patient had TB in the past?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         _buildYesNoToggle(value: _hadTbInPast, onChanged: (val) => setState(() => _hadTbInPast = val)),
//         const SizedBox(height: 24),
//         _buildCriticalCaseCard(),
//       ],
//     );
//   }
//
//   Widget _buildAncSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         if (_selectedHealthCase != null && _selectedHealthCase != 'None')
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0, bottom: 16.0),
//             child: Text(
//               _selectedHealthCase!,
//               style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
//             ),
//           ),
//         const Text(
//           "Mother's Details",
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
//         ),
//         const SizedBox(height: 16),
//         const Text(
//           'Parity',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildCounterField(
//                 label: 'Gravida',
//                 value: _gravida,
//                 onIncrement: () => setState(() => _gravida++),
//                 onDecrement: () => setState(() => _gravida > 0 ? _gravida-- : 0),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildCounterField(
//                 label: 'Para',
//                 value: _para,
//                 onIncrement: () => setState(() => _para++),
//                 onDecrement: () => setState(() => _para > 0 ? _para-- : 0),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         Row(
//           children: [
//             Expanded(
//               child: _buildCounterField(
//                 label: 'Living',
//                 value: _living,
//                 onIncrement: () => setState(() => _living++),
//                 onDecrement: () => setState(() => _living > 0 ? _living-- : 0),
//               ),
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: _buildCounterField(
//                 label: 'Abortions',
//                 value: _abortions,
//                 onIncrement: () => setState(() => _abortions++),
//                 onDecrement: () => setState(() => _abortions > 0 ? _abortions-- : 0),
//               ),
//             ),
//           ],
//         ),
//         const SizedBox(height: 24),
//         _buildDatePicker(
//           label: 'Last Menstrual Period (LMP)',
//           selectedDate: _lmpDate,
//           onDateSelected: (date) {
//             setState(() {
//               _lmpDate = date;
//               if (date != null) {
//                 _eddDate = date.add(const Duration(days: 280));
//               }
//             });
//           },
//         ),
//         const SizedBox(height: 16),
//         const Text('Estimated Delivery Date (EDD)', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         Container(
//           padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
//           decoration: BoxDecoration(
//             color: Colors.grey[300],
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           width: double.infinity,
//           child: Text(
//             _eddDate != null ? "${_eddDate!.day}/${_eddDate!.month}/${_eddDate!.year}" : 'Auto-calculated',
//             style: TextStyle(fontSize: 16, color: _eddDate != null ? Colors.black87 : Colors.grey[600]),
//           ),
//         ),
//         const SizedBox(height: 24),
//         const Text(
//           'Vitals',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 16),
//         _buildVitalsTextField(
//           controller: _bpController,
//           icon: Icons.monitor_heart,
//           title: 'BP (Systolic / Diastolic)',
//           subtitle: 'e.g. 120/80 mmHg',
//         ),
//         const SizedBox(height: 16),
//         _buildVitalsTextField(
//           controller: _weightController,
//           icon: Icons.scale,
//           title: 'Weight',
//           subtitle: 'Enter weight in kg',
//         ),
//         const SizedBox(height: 16),
//         _buildVitalsTextField(
//           controller: _hemoglobinController,
//           icon: Icons.opacity,
//           title: 'Hemoglobin',
//           subtitle: 'Enter value in g/dL',
//         ),
//         const SizedBox(height: 16),
//         _buildVitalsTextField(
//           controller: _bloodSugarController,
//           icon: Icons.bloodtype,
//           title: 'Blood Sugar',
//           subtitle: 'Enter value in mg/dL',
//         ),
//         const SizedBox(height: 24),
//         _buildVitalsTextField(
//           controller: _ifaTabletsController,
//           icon: Icons.medication,
//           title: 'IFA Tablets Received',
//           subtitle: 'Enter the number of tablets',
//         ),
//         const SizedBox(height: 16),
//         _buildVitalsTextField(
//           controller: _calciumTabletsController,
//           icon: Icons.medication_liquid,
//           title: 'Calcium Tablets Received',
//           subtitle: 'Enter the number of tablets',
//         ),
//         const SizedBox(height: 24),
//         const Text(
//           'TT/TD Vaccination Dose',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         _buildVaccinationDose(),
//         if (_selectedVaccineDose != null && _selectedVaccineDose != 'None')
//           Padding(
//             padding: const EdgeInsets.only(top: 16.0),
//             child: _buildDatePicker(
//               label: 'Date of Vaccination',
//               selectedDate: _vaccinationDate,
//               onDateSelected: (date) {
//                 setState(() {
//                   _vaccinationDate = date;
//                 });
//               },
//             ),
//           ),
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A5A9E).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: const Icon(Icons.warning_amber_rounded, color: Color(0xFF2A5A9E), size: 24),
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Current Symptoms',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         GridView.count(
//           shrinkWrap: true,
//           crossAxisCount: 2,
//           crossAxisSpacing: 8,
//           mainAxisSpacing: 8,
//           childAspectRatio: 1.8,
//           physics: const NeverScrollableScrollPhysics(),
//           children: [
//             _buildSymptomCard(title: 'Bleeding', icon: Icons.opacity, symptom: 'Bleeding'),
//             _buildSymptomCard(title: 'Severe Headache', icon: Icons.sentiment_very_dissatisfied, symptom: 'Severe Headache'),
//             _buildSymptomCard(title: 'Swelling in hand/feet', icon: Icons.back_hand, symptom: 'Swelling'),
//             _buildSymptomCard(title: 'Blurred Vision', icon: Icons.visibility_off, symptom: 'Blurred Vision'),
//             _buildSymptomCard(title: 'Fever', icon: Icons.thermostat, symptom: 'Fever'),
//             _buildSymptomCard(title: 'Convulsions (Fits)', icon: Icons.flash_on, symptom: 'Convulsions'),
//           ],
//         ),
//         const SizedBox(height: 24),
//         const Text(
//           'Other Symptoms',
//           style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//         ),
//         const SizedBox(height: 8),
//         TextFormField(
//           controller: _otherSymptomsController,
//           maxLines: 3,
//           decoration: InputDecoration(
//             hintText: 'Describe any other symptoms...',
//             border: OutlineInputBorder(
//               borderRadius: BorderRadius.circular(12.0),
//               borderSide: BorderSide.none,
//             ),
//             filled: true,
//             fillColor: Colors.white,
//           ),
//         ),
//         const SizedBox(height: 24),
//         Row(
//           children: [
//             Container(
//               padding: const EdgeInsets.all(8),
//               decoration: BoxDecoration(
//                 color: const Color(0xFF2A5A9E).withOpacity(0.1),
//                 borderRadius: BorderRadius.circular(8.0),
//               ),
//               child: const Icon(Icons.history, color: Color(0xFF2A5A9E), size: 24),
//             ),
//             const SizedBox(width: 8),
//             const Text(
//               'Pregnancy History',
//               style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildHistoryToggle(
//           label: 'Previous Cesarean',
//           value: _previousCesarean,
//           onChanged: (val) {
//             setState(() {
//               _previousCesarean = val;
//             });
//           },
//         ),
//         const Divider(height: 24),
//         _buildHistoryToggle(
//           label: 'Previous Stillbirth',
//           value: _previousStillbirth,
//           onChanged: (val) {
//             setState(() {
//               _previousStillbirth = val;
//             });
//           },
//         ),
//         const Divider(height: 24),
//         _buildHistoryToggle(
//           label: 'Previous Complications',
//           value: _previousComplications,
//           onChanged: (val) {
//             setState(() {
//               _previousComplications = val;
//             });
//           },
//         ),
//         const SizedBox(height: 24),
//         _buildAncCriticalCaseCard(),
//       ],
//     );
//   }
//
//   Widget _buildCounterField(
//       {required String label,
//         required int value,
//         required VoidCallback onIncrement,
//         required VoidCallback onDecrement}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         Container(
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               IconButton(
//                 icon: const Icon(Icons.remove),
//                 onPressed: onDecrement,
//                 color: const Color(0xFF2A5A9E),
//               ),
//               Text(
//                 '$value',
//                 style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//               ),
//               IconButton(
//                 icon: const Icon(Icons.add),
//                 onPressed: onIncrement,
//                 color: const Color(0xFF2A5A9E),
//               ),
//             ],
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildDatePicker(
//       {required String label, required DateTime? selectedDate, required Function(DateTime?) onDateSelected}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () async {
//             final date = await showDatePicker(
//               context: context,
//               initialDate: selectedDate ?? DateTime.now(),
//               firstDate: DateTime(2000),
//               lastDate: DateTime.now(),
//             );
//             onDateSelected(date);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   selectedDate != null ? "${selectedDate.day}/${selectedDate.month}/${selectedDate.year}" : 'Select Date',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const Icon(Icons.calendar_today, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVitalsTextField({required TextEditingController controller, required IconData icon, required String title, required String subtitle}) {
//     return Container(
//       padding: const EdgeInsets.only(left: 16, right: 16, top: 8, bottom: 8),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: Row(
//         children: [
//           Container(
//             padding: const EdgeInsets.all(12),
//             decoration: BoxDecoration(
//               color: const Color(0xFF2A5A9E).withOpacity(0.1),
//               borderRadius: BorderRadius.circular(8.0),
//             ),
//             child: Icon(icon, color: const Color(0xFF2A5A9E), size: 28),
//           ),
//           const SizedBox(width: 16),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//                 const SizedBox(height: 4),
//                 TextFormField(
//                   controller: controller,
//                   decoration: InputDecoration(
//                     hintText: subtitle,
//                     border: InputBorder.none,
//                   ),
//                   onChanged: (value) {
//                     setState(() {});
//                   },
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }
//
//   Widget _buildSymptomCard({required String title, required IconData icon, required String symptom}) {
//     final bool isSelected = _currentSymptoms.contains(symptom);
//     return GestureDetector(
//       onTap: () {
//         setState(() {
//           if (isSelected) {
//             _currentSymptoms.remove(symptom);
//           } else {
//             _currentSymptoms.add(symptom);
//           }
//         });
//       },
//       child: Container(
//         padding: const EdgeInsets.all(8.0),
//         decoration: BoxDecoration(
//           color: isSelected ? const Color(0xFF2A5A9E) : Colors.white,
//           borderRadius: BorderRadius.circular(12.0),
//           border: Border.all(
//             color: isSelected ? const Color(0xFF2A5A9E) : Colors.grey.shade300,
//           ),
//         ),
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(icon, color: isSelected ? Colors.white : const Color(0xFF2A5A9E), size: 28),
//             const SizedBox(height: 8),
//             Text(
//               title,
//               textAlign: TextAlign.center,
//               style: TextStyle(
//                 color: isSelected ? Colors.white : Colors.black87,
//                 fontWeight: FontWeight.bold,
//                 fontSize: 12,
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildHistoryToggle({required String label, required bool? value, required ValueChanged<bool?> onChanged}) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Text(label, style: const TextStyle(fontSize: 16)),
//         ToggleButtons(
//           isSelected: [value == true, value == false],
//           onPressed: (index) {
//             onChanged(index == 0);
//           },
//           borderRadius: BorderRadius.circular(8.0),
//           selectedColor: Colors.white,
//           fillColor: const Color(0xFF2A5A9E),
//           borderColor: Colors.grey,
//           selectedBorderColor: const Color(0xFF2A5A9E),
//           children: const [
//             Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Yes')),
//             Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('No')),
//           ],
//         ),
//       ],
//     );
//   }
//
//   Widget _buildVaccinationDose() {
//     final doses = ['None', 'TT-1', 'TT-2', 'Booster'];
//     return ToggleButtons(
//       isSelected: doses.map((dose) => _selectedVaccineDose == dose).toList(),
//       onPressed: (index) {
//         setState(() {
//           _selectedVaccineDose = doses[index];
//         });
//       },
//       borderRadius: BorderRadius.circular(8.0),
//       selectedColor: Colors.white,
//       fillColor: const Color(0xFF2A5A9E),
//       children: doses.map((dose) => Padding(padding: const EdgeInsets.symmetric(horizontal: 16.0), child: Text(dose))).toList(),
//     );
//   }
//
//   Widget _buildRelationshipDropdown({required String? value, required ValueChanged<String?> onChanged}) {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: DropdownButtonHideUnderline(
//         child: DropdownButton<String>(
//           value: value,
//           isExpanded: true,
//           hint: const Text('Select relationship'),
//           icon: const Icon(Icons.people_alt_outlined, color: Colors.grey),
//           onChanged: onChanged,
//           items: _relationshipOptions.map<DropdownMenuItem<String>>((
//               String value) {
//             return DropdownMenuItem<String>(
//               value: value,
//               child: Text(value),
//             );
//           }).toList(),
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildAddMemberCard(_Member member) {
//     return Card(
//       margin: const EdgeInsets.only(bottom: 16.0),elevation: 2,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12.0)),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text('Family Member #${member.id + 1}', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
//                 IconButton(
//                   icon: const Icon(Icons.delete_outline, color: Colors.red),
//                   onPressed: () => _deleteMember(member.id),
//                 ),
//               ],
//             ),
//             const SizedBox(height: 16),
//
//             // --- ALL MEMBER FIELDS ---
//             _buildTextField(label: 'Name', icon: Icons.person_outline),
//             const SizedBox(height: 16),
//             Row(
//               children: [
//                 Expanded(child: _buildTextField(label: 'Age', keyboardType: TextInputType.number)),
//                 const SizedBox(width: 16),
//                 Expanded(child: _buildGenderDropdown()), // Assumes this method exists
//               ],
//             ),
//             const SizedBox(height: 16),
//             // --- ADDING THE NEW FIELDS HERE ---
//             _buildRelationshipDropdown(
//               value: member.selectedRelationship,
//               onChanged: (newValue) {
//                 setState(() {
//                   member.selectedRelationship = newValue;
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//             _buildTextField(label: 'Address', icon: Icons.home_outlined),
//             const SizedBox(height: 16),
//             _buildTextField(label: 'Mobile Number', icon: Icons.phone_outlined, keyboardType: TextInputType.phone),
//             const SizedBox(height: 16),
//             _buildTextField(label: 'Aadhaar Number', icon: Icons.credit_card_outlined, keyboardType: TextInputType.number),
//             const SizedBox(height: 32),
//             // --- END OF NEW FIELDS ---
//
//             HealthCaseDropdown(
//               label: 'Health Case',
//               value: member.selectedHealthCase,
//               healthCases: _healthCases,
//               onChanged: (value) {
//                 setState(() {
//                   member.selectedHealthCase = value;
//                   member.showAncSection = value == 'ANC';
//                   member.showPncSection = value == 'PNC';
//                   member.showNcdScreening = value == 'NCD Screening';
//                   member.showTbScreening = value == 'TB Screening';
//                 });
//               },
//             ),
//             const SizedBox(height: 16),
//
//             // Conditionally show sections based on the member's state
//             if (member.showAncSection) _buildAncSection(),
//             if (member.showPncSection) _buildPncSection(),
//             if (member.showNcdScreening) _buildNcdSection(),
//             if (member.showTbScreening) _buildTbScreeningSection(member.selectedHealthCase),
//           ],
//         ),
//       ),
//     );
//   }
//
//
//   Widget _buildCriticalCaseCard() {
//     bool isCritical = _isTbCaseCritical;
//     return Card(
//       elevation: 2,
//       color: isCritical ? Colors.red.shade50 : Colors.green.shade50,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         side: BorderSide(
//           color: isCritical ? Colors.red.shade200 : Colors.green.shade200,
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(
//               isCritical ? Icons.warning_rounded : Icons.check_circle_outline_rounded,
//               color: isCritical ? Colors.red.shade700 : Colors.green.shade700,
//               size: 32,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isCritical ? 'Critical Case' : 'Non-Critical Case',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: isCritical ? Colors.red.shade900 : Colors.green.shade900,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     isCritical
//                         ? 'This case requires immediate attention based on the provided symptoms.'
//                         : 'The provided symptoms do not indicate a critical case at this time.',
//                     style: TextStyle(
//                       color: isCritical ? Colors.red.shade800 : Colors.green.shade800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildAncCriticalCaseCard() {
//     bool isCritical = _isAncCaseCritical;
//     return Card(
//       elevation: 2,
//       color: isCritical ? Colors.red.shade50 : Colors.green.shade50,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         side: BorderSide(
//           color: isCritical ? Colors.red.shade200 : Colors.green.shade200,
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(
//               isCritical ? Icons.warning_rounded : Icons.check_circle_outline_rounded,
//               color: isCritical ? Colors.red.shade700 : Colors.green.shade700,
//               size: 32,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isCritical ? 'Critical Case' : 'Non-Critical Case',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: isCritical ? Colors.red.shade900 : Colors.green.shade900,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     isCritical
//                         ? 'This case requires immediate attention based on the provided symptoms or history.'
//                         : 'The provided symptoms do not indicate a critical case at this time.',
//                     style: TextStyle(
//                       color: isCritical ? Colors.red.shade800 : Colors.green.shade800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//
//   Widget _buildYesNoToggle({required bool value, required ValueChanged<bool> onChanged}) {
//     return ToggleButtons(
//       isSelected: [value, !value],
//       onPressed: (index) {
//         onChanged(index == 0);
//       },
//       borderRadius: BorderRadius.circular(8.0),
//       selectedColor: Colors.white,
//       fillColor: const Color(0xFF2A5A9E),
//       children: const [
//         Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('Yes')),
//         Padding(padding: EdgeInsets.symmetric(horizontal: 16.0), child: Text('No')),
//       ],
//     );
//   }
//
//   Widget _buildFeverPatternChip(String pattern) {
//     final isSelected = _selectedFeverPattern == pattern;
//     return ChoiceChip(
//       label: Text(pattern, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
//       selected: isSelected,
//       onSelected: (selected) {
//         setState(() {
//           _selectedFeverPattern = selected ? pattern : null;
//         });
//       },
//       selectedColor: const Color(0xFF2A5A9E),
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//         side: BorderSide(color: isSelected ? const Color(0xFF2A5A9E) : Colors.grey),
//       ),
//     );
//   }
//
//   Widget _buildCoughTypeCheckbox({required String title, required IconData icon}) {
//     return CheckboxListTile(
//       title: Row(children: [Icon(icon, color: Colors.grey), const SizedBox(width: 10), Text(title)]),
//       value: _coughTypes.contains(title),
//       onChanged: (value) {
//         setState(() {
//           if (value == true) {
//             _coughTypes.add(title);
//           } else {
//             _coughTypes.remove(title);
//           }
//         });
//       },
//       controlAffinity: ListTileControlAffinity.trailing,
//       activeColor: const Color(0xFF2A5A9E),
//       checkColor: Colors.white,
//       shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
//       tileColor: Colors.white,
//     );
//   }
//
//   Widget _buildLightBlueButton({required String text, required IconData icon, required VoidCallback onTap}) {
//     return OutlinedButton.icon(
//       onPressed: onTap,
//       icon: Icon(icon, color: const Color(0xFF2A5A9E)),
//       label: Text(text, style: const TextStyle(color: Color(0xFF2A5A9E), fontWeight: FontWeight.bold)),
//       style: OutlinedButton.styleFrom(
//         minimumSize: const Size(double.infinity, 50),
//         backgroundColor: const Color(0xFF2A5A9E).withOpacity(0.1),
//         side: const BorderSide(color: Colors.transparent),
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//       ),
//     );
//   }
//
// // START: Paste this new method at the end of the class
//   Widget _buildDangerSignCheckbox({required String label, required IconData icon, required Set<String> group}) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: CheckboxListTile(
//         value: group.contains(label),
//         onChanged: (bool? value) {
//           setState(() {
//             if (value == true) {
//               group.add(label);
//             } else {
//               group.remove(label);
//             }
//           });
//         },
//         title: Text(label),
//         secondary: Icon(icon, color: const Color(0xFF2A5A9E)),
//         activeColor: const Color(0xFF2A5A9E),
//         controlAffinity: ListTileControlAffinity.trailing,
//         shape: RoundedRectangleBorder(
//           borderRadius: BorderRadius.circular(12.0),
//         ),
//       ),
//     );
//   }
//
//
// // START: Paste these two new methods at the end of the class
//
//   Widget _buildFollowUpSection() {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
//           child: Text(
//             'Follow-up Details',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2A5A9E)),
//           ),
//         ),
//         _buildDatePicker(
//           label: 'Follow-up Visit Date',
//           selectedDate: _followUpDate,
//           onDateSelected: (date) {
//             setState(() {
//               _followUpDate = date;
//             });
//           },
//         ),
//         const SizedBox(height: 16),
//         _buildTimePicker(
//           label: 'Follow-up Visit Time',
//           selectedTime: _followUpTime,
//           onTimeSelected: (time) {
//             setState(() {
//               _followUpTime = time;
//             });
//           },
//         ),
//         const SizedBox(height: 24),
//         const Text("Mother's Health Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         _buildYesNoQuestion(
//           label: 'Any complications observed?',
//           value: _motherHasComplications,
//           onChanged: (val) => setState(() => _motherHasComplications = val),
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           label: 'Blood Pressure (Systolic/Diastolic)',
//           controller: _followUpBpController,
//           hintText: 'e.g., 120/80',
//         ),
//         const SizedBox(height: 24),
//         const Text("Newborn's Health Status", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//         const SizedBox(height: 16),
//         Container(
//           padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
//           decoration: BoxDecoration(
//             color: Colors.white,
//             borderRadius: BorderRadius.circular(12.0),
//           ),
//           child: Row(
//             mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             children: [
//               const Text('Immunizations up to date?', style: TextStyle(fontSize: 14)),
//               Switch(
//                 value: _newbornImmunizationsUpToDate,
//                 onChanged: (value) {
//                   setState(() {
//                     _newbornImmunizationsUpToDate = value;
//                   });
//                 },
//                 activeColor: Colors.green,
//               ),
//             ],
//           ),
//         ),
//         const SizedBox(height: 16),
//         _buildTextField(
//           label: 'Weight (in kg)',
//           controller: _newbornWeightController,
//           hintText: 'e.g., 3.1', // Use the hintText parameter
//           keyboardType: TextInputType.number,
//         ),
//         const SizedBox(height: 24),
//         OutlinedButton.icon(
//           onPressed: () {
//             // TODO: Implement image picker logic
//           },
//           icon: const Icon(Icons.camera_alt_outlined, color: Color(0xFF2A5A9E)),
//           label: const Text('Upload Health Card Photo', style: TextStyle(color: Color(0xFF2A5A9E), fontWeight: FontWeight.bold)),
//           style: OutlinedButton.styleFrom(
//             minimumSize: const Size(double.infinity, 50),
//             backgroundColor: const Color(0xFF2A5A9E).withOpacity(0.1),
//             side: const BorderSide(color: Color(0xFF2A5A9E), width: 1.5),
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//           ),
//         ),
//       ],
//     );
//   }
//
//   Widget _buildTimePicker({required String label, required TimeOfDay? selectedTime, required Function(TimeOfDay?) onTimeSelected}) {
//     return Column(
//       crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
//         const SizedBox(height: 8),
//         InkWell(
//           onTap: () async {
//             final time = await showTimePicker(
//               context: context,
//               initialTime: selectedTime ?? TimeOfDay.now(),
//             );
//             onTimeSelected(time);
//           },
//           child: Container(
//             padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
//             decoration: BoxDecoration(
//               color: Colors.white,
//               borderRadius: BorderRadius.circular(12.0),
//             ),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.spaceBetween,
//               children: [
//                 Text(
//                   selectedTime != null ? selectedTime.format(context) : 'Select Time',
//                   style: const TextStyle(fontSize: 16),
//                 ),
//                 const Icon(Icons.access_time, color: Colors.grey),
//               ],
//             ),
//           ),
//         ),
//       ],
//     );
//   }
// //critical pnc card
//   Widget _buildPncCriticalCaseCard() {
//     bool isCritical = _isPncCaseCritical;
//     return Card(
//       elevation: 2,
//       color: isCritical ? Colors.red.shade50 : Colors.green.shade50,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(12.0),
//         side: BorderSide(
//           color: isCritical ? Colors.red.shade200 : Colors.green.shade200,
//           width: 1,
//         ),
//       ),
//       child: Padding(
//         padding: const EdgeInsets.all(16.0),
//         child: Row(
//           children: [
//             Icon(
//               isCritical ? Icons.warning_rounded : Icons.check_circle_outline_rounded,
//               color: isCritical ? Colors.red.shade700 : Colors.green.shade700,
//               size: 32,
//             ),
//             const SizedBox(width: 16),
//             Expanded(
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     isCritical ? 'Critical Case' : 'Non-Critical Case',
//                     style: TextStyle(
//                       fontWeight: FontWeight.bold,
//                       fontSize: 16,
//                       color: isCritical ? Colors.red.shade900 : Colors.green.shade900,
//                     ),
//                   ),
//                   const SizedBox(height: 4),
//                   Text(
//                     isCritical
//                         ? 'Danger signs have been observed. This case requires immediate attention.'
//                         : 'The provided symptoms do not indicate a critical case at this time.',
//                     style: TextStyle(
//                       color: isCritical ? Colors.red.shade800 : Colors.green.shade800,
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ],
//         ),
//       ),
//     );
//   }
//   //NCD Screnning
// // ... existing code before _buildNcdSection
//   //NCD Screnning
//   Widget _buildNcdSection() {
//     return Column(crossAxisAlignment: CrossAxisAlignment.start,
//       children: [
//         const Padding(
//           padding: EdgeInsets.only(top: 16.0, bottom: 16.0),
//           child: Text(
//             'NCD Screening',
//             style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20, color: Color(0xFF2A5A9E)),
//           ),
//         ),
//         _buildNcdMetricCard(
//           title: 'Blood Pressure',
//           icon: Icons.monitor_heart,
//           children: [
//             _buildTextField(label: 'Systolic', controller: _ncdSystolicController, hintText: 'mm Hg', keyboardType: TextInputType.number),
//             const SizedBox(height: 16),
//             _buildTextField(label: 'Diastolic', controller: _ncdDiastolicController, hintText: 'mm Hg', keyboardType: TextInputType.number),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildNcdMetricCard(
//           title: 'Body Mass Index (BMI)',
//           icon: Icons.square_foot,
//           children: [
//             _buildTextField(label: 'Weight', controller: _ncdWeightController, hintText: 'kg', keyboardType: TextInputType.number),
//             const SizedBox(height: 16),
//             _buildTextField(label: 'Height', controller: _ncdHeightController, hintText: 'cm', keyboardType: TextInputType.number),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildNcdMetricCard(
//           title: 'Blood Sugar',
//           icon: Icons.opacity,
//           children: [
//             _buildTextField(label: 'Random Blood Sugar', controller: _ncdRandomBloodSugarController, hintText: 'mg/dL', keyboardType: TextInputType.number),
//           ],
//         ),
//         const SizedBox(height: 16),
//
//         // Lifestyle Questions
//         _buildNcdMetricCard(
//             title: 'Tobacco & Alcohol Use',
//             icon: Icons.smoke_free, // Changed icon for relevance
//             children: [
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Do you smoke or use tobacco?'),
//                     Switch(value: _usesTobacco, onChanged: (val) => setState(() => _usesTobacco = val), activeColor: Colors.green),
//                   ],
//                 ),
//               ),
//               const Divider(),
//               Container(
//                 padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 4.0),
//                 decoration: BoxDecoration(
//                   color: Colors.white,
//                   borderRadius: BorderRadius.circular(12.0),
//                 ),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceBetween,
//                   children: [
//                     const Text('Do you consume alcohol?'),
//                     Switch(value: _consumesAlcohol, onChanged: (val) => setState(() => _consumesAlcohol = val), activeColor: Colors.green),
//                   ],
//                 ),
//               ),
//             ]
//         ),
//         const SizedBox(height: 16),
//         _buildNcdMetricCard(
//           title: 'Diet & Nutrition',
//           icon: Icons.restaurant_menu,
//           children: [
//             const Text('How much extra salt do you add?'),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8.0,
//               children: ['None', 'A little', 'A lot'].map((label) => _buildLifestyleChoiceChip(
//                 label: label,
//                 groupValue: _extraSaltIntake,
//                 onSelected: (val) => setState(() => _extraSaltIntake = val),
//               )).toList(),
//             ),
//           ],
//         ),
//         const SizedBox(height: 16),
//         _buildNcdMetricCard(
//           title: 'Physical Activity',
//           icon: Icons.directions_run,
//           children: [
//             const Text('How often do you exercise?'),
//             const SizedBox(height: 8),
//             Wrap(
//               spacing: 8.0,
//               runSpacing: 8.0,
//               children: ['Daily', 'A few times a week', 'Rarely', 'Never'].map((label) => _buildLifestyleChoiceChip(
//                 label: label,
//                 groupValue: _exerciseFrequency,
//                 onSelected: (val) => setState(() => _exerciseFrequency = val),
//               )).toList(),
//             ),
//           ],
//         ),
//       ],
//     );
//   }
//
//   // START: Paste this new method at the end of the class
//
//
//
//
//   Widget _buildNcdMetricCard({required String title, required IconData icon, required List<Widget> children}) {
//     return Container(
//       padding: const EdgeInsets.all(16.0),
//       decoration: BoxDecoration(
//         color: Colors.white,
//         borderRadius: BorderRadius.circular(12.0),
//       ),
//       child: Column(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Row(
//             children: [
//               Container(
//                 padding: const EdgeInsets.all(8),
//                 decoration: BoxDecoration(
//                   color: const Color(0xFF2A5A9E).withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(8.0),
//                 ),
//                 child: Icon(icon, color: const Color(0xFF2A5A9E), size: 24),
//               ),
//               const SizedBox(width: 12),
//               Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
//             ],
//           ),
//           const Divider(height: 24),
//           ...children,
//         ],
//       ),
//     );
//   }
//
//   // START: Paste this new method at the end of the class
//
//
// // START: Paste these two new methods at the end of the class
//
//
// //critical pnc card
//   //NCD Screnning
//
//
//   Widget _buildLifestyleChoiceChip({required String label, required String? groupValue, required ValueChanged<String?> onSelected}) {
//     final isSelected = groupValue == label;
//     return ChoiceChip(
//       label: Text(label, style: TextStyle(color: isSelected ? Colors.white : Colors.black)),
//       selected: isSelected,
//       onSelected: (selected) {
//         onSelected(selected ? label : null);
//       },
//       selectedColor: const Color(0xFF2A5A9E),
//       backgroundColor: Colors.white,
//       shape: RoundedRectangleBorder(
//         borderRadius: BorderRadius.circular(8.0),
//         side: BorderSide(color: isSelected ? const Color(0xFF2A5A9E) : Colors.grey),
//       ),
//     );
//   }
//
// }
