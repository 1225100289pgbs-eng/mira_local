import 'business.dart';

/// Mensaje que recibe el emprendedor cuando su negocio es rechazado o suspendido.
class ModerationNotice {
  const ModerationNotice({
    required this.id,
    required this.businessId,
    required this.status,
    required this.reason,
    required this.date,
  });

  final String id;
  final String businessId;
  final BusinessStatus status;
  final String reason;
  final DateTime date;
}
