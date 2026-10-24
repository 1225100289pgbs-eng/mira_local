class Product {
  Product({
    required this.id,
    required this.name,
    required this.price,
    required this.photo,
    this.available = true,
  });

  final String id;
  String name;
  double price;

  /// Descripción de la fotografía (en el prototipo las fotos son simuladas).
  String photo;
  bool available;
}
