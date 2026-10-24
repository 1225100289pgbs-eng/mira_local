import 'package:flutter_test/flutter_test.dart';
import 'package:mira_local/models/business.dart';
import 'package:mira_local/state/app_state.dart';

Business byName(AppState s, String name) =>
    s.businesses.firstWhere((b) => b.name == name);

void main() {
  group('Visibilidad', () {
    test('el cliente solo ve negocios activos y disponibles', () {
      final s = AppState();
      expect(s.visibleBusinesses.length, 3);
      expect(
        s.visibleBusinesses
            .every((b) => b.status == BusinessStatus.active && b.available),
        isTrue,
      );
    });

    test('el administrador ve todos los negocios', () {
      final s = AppState();
      expect(s.searchAll().length, 7);
      expect(s.searchAll(status: BusinessStatus.pending).length, 1);
    });
  });

  group('Moderación', () {
    test('suspender oculta el negocio y crea la notificación', () {
      final s = AppState();
      final b = byName(s, 'Dulces de la Abuela');
      s.suspend(b, 'Motivo de prueba');
      expect(b.visibleToClients, isFalse);
      final notice = s.noticeFor(b.id)!;
      expect(notice.status, BusinessStatus.suspended);
      expect(notice.reason, 'Motivo de prueba');
    });

    test('reactivar activa, marca disponible y limpia solicitud y aviso', () {
      final s = AppState();
      final b = byName(s, 'Lino del Sur');
      expect(s.hasPendingRequest(b.id), isTrue);
      s.reactivate(b);
      expect(b.status, BusinessStatus.active);
      expect(b.available, isTrue);
      expect(s.hasPendingRequest(b.id), isFalse);
      expect(s.noticeFor(b.id), isNull);
      expect(b.visibleToClients, isTrue);
    });
  });

  group('Solicitud de reactivación', () {
    test('no permite duplicados ni mensajes vacíos', () {
      final s = AppState();
      final b = byName(s, 'Feria Verde');
      expect(s.requestReactivation(b, '   '), isFalse);
      expect(s.requestReactivation(b, 'Ya completé la descripción'), isTrue);
      expect(s.requestReactivation(b, 'Otro intento'), isFalse);
      expect(s.pendingRequestsCount, 2);
    });
  });

  group('Categorías', () {
    test('no elimina categorías con negocios asociados', () {
      final s = AppState();
      final comida = s.categories.firstWhere((c) => c.id == 'comida');
      final otros = s.categories.firstWhere((c) => c.id == 'otros');
      expect(s.deleteCategory(comida), isFalse);
      expect(s.deleteCategory(otros), isTrue);
    });
  });

  group('Calificaciones', () {
    test('agregar una calificación actualiza cantidad y distribución', () {
      final s = AppState();
      final b = byName(s, 'Dulces de la Abuela');
      final before = b.ratingCount;
      s.addRating(b, 1, '');
      expect(b.ratingCount, before + 1);
      expect(b.distribution[0], 1);
    });
  });
}
