import 'package:flutter/material.dart';
import 'package:asha_frontend/features/family/ui/widgets/common_form_widgets.dart';

class HeadForm extends StatelessWidget {
  final TextEditingController nameController;
  final TextEditingController ageController;
  final TextEditingController addressController;
  final TextEditingController phoneController;
  final TextEditingController aadhaarController;
  final TextEditingController landmarkController;


  final String? gender;
  final ValueChanged<String?> onGenderChanged;

  const HeadForm({
    super.key,
    required this.nameController,
    required this.ageController,
    required this.addressController,
    required this.phoneController,
    required this.aadhaarController,
    required this.landmarkController,
    required this.gender,
    required this.onGenderChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const SectionTitle(title: 'Family Head Details'),
        const SizedBox(height: 16),

        AppTextField(label: 'Family Head Name', controller: nameController),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: 'Age',
                controller: ageController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdown(
                label: 'Gender',
                value: gender,
                items: const ['Male', 'Female', 'Other'],
                onChanged: onGenderChanged,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),
        AppTextField(label: 'Address', controller: addressController),
        const SizedBox(height: 16),
        SizedBox(height: 16),
        AppTextField(
          label: 'Landmark / Reference (e.g., Near Galaxy Gym)',
          controller: landmarkController,
        ),

        AppTextField(
          label: 'Mobile Number',
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),
        const SizedBox(height: 16),
        AppTextField(
          label: 'Aadhaar Number',
          controller: aadhaarController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
