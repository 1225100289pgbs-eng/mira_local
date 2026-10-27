import 'package:flutter/foundation.dart' show ChangeNotifier;

import '../data/mock_data.dart';
import '../models/business.dart';
import '../models/category.dart';
import '../models/moderation_notice.dart';
import '../models/product.dart';
import '../models/rating.dart';
import '../models/reactivation_request.dart';

/// Estado compartido entre los flujos de cliente, emprendedor y administrador.
class AppState extends ChangeNotifier {
  AppState()
      : _categories = MockData.categories(),
        _owners = MockData.owners(),
        _businesses = MockData.businesses(),
        _notices = MockData.notices(),
        _requests = MockData.requests();

  final List<Category> _categories;
  final List<Owner> _owners;
  final List<Business> _businesses;
  final List<ModerationNotice> _notices;
  final List<ReactivationRequest> _requests;

  String? _ownerEmail;
  bool _adminLogged = false;
  int _idCounter = 100;

  String _newId(String prefix) => '$prefix${_idCounter++}';

  // ───────────── Consultas ─────────────
  List<Category> get categories => List.unmodifiable(_categories);
  List<Business> get businesses => List.unmodifiable(_businesses);
  List<ModerationNotice> get notices => List.unmodifiable(_notices);
  List<ReactivationRequest> get requests => List.unmodifiable(_requests);

  String categoryName(String id) {
    for (final c in _categories) {
      if (c.id == id) return c.name;
    }
    return 'Sin categoría';
  }

  Business? businessById(String id) {
    for (final b in _businesses) {
      if (b.id == id) return b;
    }
    return null;
  }

  /// Solo negocios activos y disponibles (regla de visibilidad del cliente).
  List<Business> get visibleBusinesses =>
      _businesses.where((b) => b.visibleToClients).toList();

  List<Business> featured({int limit = 4}) {
    final list = visibleBusinesses
      ..sort((a, b) => b.average.compareTo(a.average));
    return list.take(limit).toList();
  }

  int visibleCountForCategory(String categoryId) =>
      visibleBusinesses.where((b) => b.categoryId == categoryId).length;

  List<Business> searchVisible({String query = '', String? categoryId}) =>
      _filter(visibleBusinesses, query, categoryId, null);

  /// El administrador ve todos los negocios sin importar estado o disponibilidad.
  List<Business> searchAll({
    String query = '',
    String? categoryId,
    BusinessStatus? status,
  }) =>
      _filter(_businesses, query, categoryId, status);

  List<Business> _filter(
    Iterable<Business> source,
    String query,
    String? categoryId,
    BusinessStatus? status,
  ) {
    final q = query.trim().toLowerCase();
    return source
        .where((b) =>
            (q.isEmpty || b.name.toLowerCase().contains(q)) &&
            (categoryId == null || b.categoryId == categoryId) &&
            (status == null || b.status == status))
        .toList();
  }

  // ───────────── Sesiones simuladas ─────────────
  Owner? get currentOwner {
    if (_ownerEmail == null) return null;
    for (final o in _owners) {
      if (o.email == _ownerEmail) return o;
    }
    return null;
  }

  Business? get ownerBusiness {
    if (_ownerEmail == null) return null;
    for (final b in _businesses) {
      if (b.ownerEmail == _ownerEmail) return b;
    }
    return null;
  }

  bool get adminLogged => _adminLogged;
  bool get isLoggedIn => _ownerEmail != null;

  UserRole? get role => currentOwner?.role;

  /// Login único para los tres roles. Devuelve el usuario o null si falla.
  Owner? login(String email, String password) {
    final e = email.trim().toLowerCase();
    for (final o in _owners) {
      if (o.email == e && o.password == password) {
        _ownerEmail = e;
        notifyListeners();
        return o;
      }
    }
    return null;
  }

  bool loginOwner(String email, String password) {
    final e = email.trim().toLowerCase();
    final ok = _owners.any((o) => o.email == e && o.password == password);
    if (ok) {
      _ownerEmail = e;
      notifyListeners();
    }
    return ok;
  }

  /// Devuelve un mensaje de error o null si todo salió bien.
  String? registerOwner({
    required String name,
    required String email,
    required String password,
    UserRole role = UserRole.emprendedor,
  }) {
    final e = email.trim().toLowerCase();
    if (_owners.any((o) => o.email == e)) {
      return 'Ya existe una cuenta con ese correo';
    }
    _owners.add(Owner(name: name.trim(), email: e, password: password, role: role));
    _ownerEmail = e;
    notifyListeners();
    return null;
  }

  void becomeEntrepreneur() {
  final o = currentOwner;
  if (o == null) return;
  o.role = UserRole.emprendedor;
  notifyListeners();
  }
  
  void logoutOwner() {
    _ownerEmail = null;
    notifyListeners();
  }

  bool loginAdmin(String email, String password) {
    final ok = email.trim().toLowerCase() == 'admin@miralocal.mx' &&
        password == 'admin1234';
    if (ok) {
      _adminLogged = true;
      notifyListeners();
    }
    return ok;
  }

  void logoutAdmin() {
    _adminLogged = false;
    notifyListeners();
  }

  // ───────────── Emprendedor ─────────────
  Business registerBusiness({
    required String name,
    required String categoryId,
    required String description,
    required String zone,
    required Set<int> days,
    required int openMinutes,
    required int closeMinutes,
    required String whatsapp,
    required List<String> photos,
  }) {
    final owner = currentOwner!;
    final business = Business(
      id: _newId('b'),
      name: name.trim(),
      description: description.trim(),
      categoryId: categoryId,
      photos: List<String>.of(photos),
      products: [],
      days: Set<int>.of(days),
      openMinutes: openMinutes,
      closeMinutes: closeMinutes,
      available: true,
      zone: zone.trim(),
      ownerName: owner.name,
      ownerEmail: owner.email,
      whatsapp: whatsapp.trim(),
      ratings: [],
      status: BusinessStatus.pending,
    );
    _businesses.add(business);
    notifyListeners();
    return business;
  }

  void updateBusinessInfo(
    Business b, {
    required String name,
    required String categoryId,
    required String description,
    required String zone,
    required String whatsapp,
  }) {
    b.name = name.trim();
    b.categoryId = categoryId;
    b.description = description.trim();
    b.zone = zone.trim();
    b.whatsapp = whatsapp.trim();
    notifyListeners();
  }

  void setAvailability(Business b, bool value) {
    b.available = value;
    notifyListeners();
  }

  void updateSchedule(Business b, Set<int> days, int open, int close) {
    b.days = Set<int>.of(days);
    b.openMinutes = open;
    b.closeMinutes = close;
    notifyListeners();
  }

  void addProduct(Business b,
      {required String name,
      required double price,
      required String photo,
      required bool available}) {
    b.products.add(Product(
      id: _newId('p'),
      name: name.trim(),
      price: price,
      photo: photo.trim().isEmpty ? name.trim() : photo.trim(),
      available: available,
    ));
    notifyListeners();
  }

  void updateProduct(Product p,
      {required String name,
      required double price,
      required String photo,
      required bool available}) {
    p.name = name.trim();
    p.price = price;
    p.photo = photo.trim().isEmpty ? name.trim() : photo.trim();
    p.available = available;
    notifyListeners();
  }

  void setProductAvailability(Product p, bool value) {
    p.available = value;
    notifyListeners();
  }

  void removeProduct(Business b, Product p) {
    b.products.remove(p);
    notifyListeners();
  }

  void addPhoto(Business b, String label) {
    b.photos.add(label.trim());
    notifyListeners();
  }

  /// No permite eliminar la última fotografía. Devuelve si se eliminó.
  bool removePhoto(Business b, String label) {
    if (b.photos.length <= 1) return false;
    b.photos.remove(label);
    notifyListeners();
    return true;
  }

  void setCover(Business b, String label) {
    if (b.photos.remove(label)) {
      b.photos.insert(0, label);
      notifyListeners();
    }
  }

  // ───────────── Cliente ─────────────
  void addRating(Business b, int stars, String comment) {
    b.ratings.add(Rating(
      id: _newId('r'),
      businessId: b.id,
      stars: stars,
      comment: comment.trim(),
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  // ───────────── Moderación ─────────────
  void approve(Business b) {
    b.status = BusinessStatus.active;
    notifyListeners();
  }

  void reject(Business b, String reason) =>
      _sanction(b, BusinessStatus.rejected, reason);

  void suspend(Business b, String reason) =>
      _sanction(b, BusinessStatus.suspended, reason);

  void _sanction(Business b, BusinessStatus status, String reason) {
    b.status = status;
    _notices.removeWhere((n) => n.businessId == b.id);
    _requests.removeWhere((r) => r.businessId == b.id);
    _notices.add(ModerationNotice(
      id: _newId('n'),
      businessId: b.id,
      status: status,
      reason: reason.trim(),
      date: DateTime.now(),
    ));
    notifyListeners();
  }

  /// Activa, marca disponible, elimina la solicitud y resuelve la notificación.
  void reactivate(Business b) {
    b.status = BusinessStatus.active;
    b.available = true;
    _requests.removeWhere((r) => r.businessId == b.id);
    _notices.removeWhere((n) => n.businessId == b.id);
    notifyListeners();
  }

  ModerationNotice? noticeFor(String businessId) {
    for (final n in _notices) {
      if (n.businessId == businessId) return n;
    }
    return null;
  }

  ReactivationRequest? requestFor(String businessId) {
    for (final r in _requests) {
      if (r.businessId == businessId) return r;
    }
    return null;
  }

  bool hasPendingRequest(String businessId) => requestFor(businessId) != null;

  int get pendingRequestsCount => _requests.length;

  /// Devuelve false si ya hay una pendiente, el mensaje está vacío
  /// o el negocio no está rechazado/suspendido.
  bool requestReactivation(Business b, String message) {
    if (hasPendingRequest(b.id)) return false;
    if (message.trim().isEmpty) return false;
    if (b.status != BusinessStatus.rejected &&
        b.status != BusinessStatus.suspended) {
      return false;
    }
    _requests.add(ReactivationRequest(
      id: _newId('q'),
      businessId: b.id,
      message: message.trim(),
      date: DateTime.now(),
    ));
    notifyListeners();
    return true;
  }

  // ───────────── Categorías ─────────────
  int businessCountForCategory(String categoryId) =>
      _businesses.where((b) => b.categoryId == categoryId).length;

  void addCategory(String name, String description) {
    _categories.add(Category(
      id: _newId('c'),
      name: name.trim(),
      description: description.trim(),
    ));
    notifyListeners();
  }

  void editCategory(Category c, String name, String description) {
    c.name = name.trim();
    c.description = description.trim();
    notifyListeners();
  }

  /// No elimina categorías con negocios asociados. Devuelve si se eliminó.
  bool deleteCategory(Category c) {
    if (businessCountForCategory(c.id) > 0) return false;
    _categories.remove(c);
    notifyListeners();
    return true;
  }

  // ───────────── Estadísticas ─────────────
  int get totalBusinesses => _businesses.length;

  int countByStatus(BusinessStatus s) =>
      _businesses.where((b) => b.status == s).length;

  double get globalAverage {
    var total = 0;
    var count = 0;
    for (final b in _businesses) {
      for (final r in b.ratings) {
        total += r.stars;
        count++;
      }
    }
    return count == 0 ? 0 : total / count;
  }

  List<Business> topRated({int limit = 5}) {
    final list = _businesses.where((b) => b.ratingCount > 0).toList()
      ..sort((a, b) {
        final c = b.average.compareTo(a.average);
        return c != 0 ? c : b.ratingCount.compareTo(a.ratingCount);
      });
    return list.take(limit).toList();
  }

  List<MapEntry<Category, int>> categoriesRanking() {
    final list = _categories
        .map((c) => MapEntry(c, businessCountForCategory(c.id)))
        .toList()
      ..sort((a, b) => b.value.compareTo(a.value));
    return list;
  }
}
