import 'package:flutter/material.dart';
import 'package:asha_frontend/localization/app_localization.dart';
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
    final t = AppLocalization.of(context).t;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SectionTitle(title: t("family_head_details")),
        const SizedBox(height: 16),

        AppTextField(
          label: t("family_head_name"),
          controller: nameController,
        ),
        const SizedBox(height: 16),

        Row(
          children: [
            Expanded(
              child: AppTextField(
                label: t("age"),
                controller: ageController,
                keyboardType: TextInputType.number,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: AppDropdown(
                label: t("gender"),
                value: gender,
                items: [t("male"), t("female"), t("other")],
                onChanged: onGenderChanged,
              ),
            ),
          ],
        ),

        const SizedBox(height: 16),

        AppTextField(
          label: t("address"),
          controller: addressController,
        ),

        const SizedBox(height: 16),

        AppTextField(
          label: t("landmark_reference"),
          controller: landmarkController,
        ),

        const SizedBox(height: 16),

        AppTextField(
          label: t("mobile_number"),
          controller: phoneController,
          keyboardType: TextInputType.phone,
        ),

        const SizedBox(height: 16),

        AppTextField(
          label: t("aadhaar_number"),
          controller: aadhaarController,
          keyboardType: TextInputType.number,
        ),
      ],
    );
  }
}
