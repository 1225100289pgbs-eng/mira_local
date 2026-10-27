import '../utils/format.dart';
import 'product.dart';
import 'rating.dart';

enum BusinessStatus { pending, active, rejected, suspended }

extension BusinessStatusX on BusinessStatus {
  String get label {
    switch (this) {
      case BusinessStatus.pending:
        return 'Pendiente';
      case BusinessStatus.active:
        return 'Activo';
      case BusinessStatus.rejected:
        return 'Rechazado';
      case BusinessStatus.suspended:
        return 'Suspendido';
    }
  }
}

enum UserRole { cliente, emprendedor, administrador }

/// Cuenta simulada (sin autenticación real) para los tres roles.
class Owner {
  Owner({
    required this.name,
    required this.email,
    required this.password,
    this.role = UserRole.emprendedor,
  });

  final String name;
  final String email;
  final String password;
  UserRole role;
}

class Business {
  Business({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryId,
    required this.photos,
    required this.products,
    required this.days,
    required this.openMinutes,
    required this.closeMinutes,
    required this.available,
    required this.zone,
    required this.ownerName,
    required this.ownerEmail,
    required this.whatsapp,
    required this.ratings,
    required this.status,
  });

  final String id;
  String name;
  String description;
  String categoryId;
  List<String> photos;
  List<Product> products;

  /// Días de atención: 1 = lunes ... 7 = domingo.
  Set<int> days;
  int openMinutes;
  int closeMinutes;
  bool available;
  String zone;
  String ownerName;
  String ownerEmail;
  String whatsapp;
  List<Rating> ratings;
  BusinessStatus status;

  int get ratingCount => ratings.length;

  double get average {
    if (ratings.isEmpty) return 0;
    final total = ratings.fold<int>(0, (sum, r) => sum + r.stars);
    return total / ratings.length;
  }

  /// Posición 0 = una estrella ... posición 4 = cinco estrellas.
  List<int> get distribution {
    final d = List<int>.filled(5, 0);
    for (final r in ratings) {
      d[r.stars - 1]++;
    }
    return d;
  }

  /// Regla de visibilidad: solo activo y disponible.
  bool get visibleToClients => status == BusinessStatus.active && available;

  String? get cover => photos.isEmpty ? null : photos.first;

  String get scheduleText => formatSchedule(days, openMinutes, closeMinutes);
}
