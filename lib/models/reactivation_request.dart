class ReactivationRequest {
  const ReactivationRequest({
    required this.id,
    required this.businessId,
    required this.message,
    required this.date,
  });

  final String id;
  final String businessId;
  final String message;
  final DateTime date;
}
