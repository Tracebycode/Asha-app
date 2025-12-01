import 'package:asha_frontend/features/anc/state/anc_controller.dart';

bool isAncCritical(AncController c) {
  // main dangerous symptoms
  if (c.symptoms.contains('Bleeding')) return true;
  if (c.symptoms.contains('Severe Headache')) return true;
  if (c.symptoms.contains('Convulsions')) return true;

  // Pregnancy history
  if (c.previousStillbirth == true) return true;
  if (c.previousComplications == true) return true;

  // BP high?
  final parts = c.bp.text.split('/');
  if (parts.length == 2) {
    final s = int.tryParse(parts[0]);
    final d = int.tryParse(parts[1]);
    if ((s != null && s >= 140) || (d != null && d >= 90)) return true;
  }

  return false;
}
