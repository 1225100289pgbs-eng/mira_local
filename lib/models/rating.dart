class Rating {
  const Rating({
    required this.id,
    required this.businessId,
    required this.stars,
    required this.comment,
    required this.date,
  });

  final String id;
  final String businessId;
  final int stars;
  final String comment;
  final DateTime date;
}
