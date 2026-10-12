import 'package:challenge_us/models/challenge.dart';
import 'package:challenge_us/models/evidence.dart';

/// Contrato para validar evidencias. Aquí se enchufará el reconocimiento de
/// imagen o la votación del grupo más adelante.
abstract class EvidenceValidationService {
  Future<ValidationResult> validate({
    required Challenge challenge,
    required Evidence evidence,
  });
}

class MockEvidenceValidationService implements EvidenceValidationService {
  const MockEvidenceValidationService();

  @override
  Future<ValidationResult> validate({
    required Challenge challenge,
    required Evidence evidence,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 900));
    return const ValidationResult(
      approved: true,
      message: 'Evidencia aprobada',
    );
  }
}