import '../models/business.dart';
import '../models/category.dart';
import '../models/moderation_notice.dart';
import '../models/product.dart';
import '../models/rating.dart';
import '../models/reactivation_request.dart';

/// Datos ficticios almacenados localmente.
/// Cuentas de prueba: contraseña "mira1234" para todos los emprendedores.
class MockData {
  static List<Category> categories() => [
        Category(id: 'comida', name: 'Comida', description: 'Platillos, antojitos y panadería.'),
        Category(id: 'postres', name: 'Postres', description: 'Dulces, pasteles y repostería.'),
        Category(id: 'ropa', name: 'Ropa y accesorios', description: 'Prendas, bolsas y complementos.'),
        Category(id: 'artesanias', name: 'Artesanías', description: 'Piezas hechas a mano.'),
        Category(id: 'servicios', name: 'Servicios', description: 'Oficios y servicios locales.'),
        Category(id: 'otros', name: 'Otros', description: 'Todo lo demás.'),
      ];

  static List<Owner> owners() => [
        Owner(name: 'Guadalupe Ramírez', email: 'dulces@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Rosa Medina', email: 'mesa@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Elena Cruz', email: 'manos@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Mario Ibarra', email: 'taller@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Andrea Solís', email: 'lino@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Jorge Paredes', email: 'feria@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Socorro Pérez', email: 'pan@miralocal.mx', password: 'mira1234'),
        Owner(name: 'Cliente de prueba', email: 'cliente@miralocal.mx', password: 'mira1234', role: UserRole.cliente),
        Owner(name: 'Administrador', email: 'admin@miralocal.mx', password: 'admin1234', role: UserRole.administrador),
      ];

  static List<Rating> _ratings(String businessId, List<int> dist) {
    const comments = ['', 'Muy buena atención.', 'Productos de calidad.', 'Lo recomiendo.', ''];
    final list = <Rating>[];
    var n = 0;
    for (var s = 0; s < 5; s++) {
      for (var i = 0; i < dist[s]; i++) {
        list.add(Rating(
          id: '$businessId-r$n',
          businessId: businessId,
          stars: s + 1,
          comment: comments[n % comments.length],
          date: DateTime(2026, 9, 1 + n % 25),
        ));
        n++;
      }
    }
    return list;
  }

  static List<Business> businesses() => [
        Business(
          id: 'b1',
          name: 'Dulces de la Abuela',
          description: 'Repostería casera con recetas de familia: tortas, alfajores y mermeladas.',
          categoryId: 'postres',
          photos: ['Vitrina de pasteles', 'Alfajores recién hechos', 'Tarta de frutos rojos'],
          products: [
            Product(id: 'p1', name: 'Torta de chocolate', price: 150, photo: 'Torta de chocolate'),
            Product(id: 'p2', name: 'Alfajores (6 piezas)', price: 120, photo: 'Alfajores'),
            Product(id: 'p3', name: 'Galletas de avena', price: 80, photo: 'Galletas', available: false),
            Product(id: 'p4', name: 'Mermelada casera', price: 90, photo: 'Mermelada'),
          ],
          days: {1, 2, 3, 4, 5, 6},
          openMinutes: 8 * 60,
          closeMinutes: 18 * 60,
          available: true,
          zone: 'Centro Histórico',
          ownerName: 'Guadalupe Ramírez',
          ownerEmail: 'dulces@miralocal.mx',
          whatsapp: '418 555 0101',
          ratings: _ratings('b1', [0, 0, 1, 5, 28]),
          status: BusinessStatus.active,
        ),
        Business(
          id: 'b2',
          name: 'La Mesa del Pueblo',
          description: 'Comida corrida y antojitos mexicanos preparados al momento.',
          categoryId: 'comida',
          photos: ['Mesa con platillos', 'Guisados del día', 'Salsas caseras'],
          products: [
            Product(id: 'p5', name: 'Comida corrida', price: 85, photo: 'Comida corrida'),
            Product(id: 'p6', name: 'Gorditas (3 piezas)', price: 60, photo: 'Gorditas'),
            Product(id: 'p7', name: 'Agua fresca (litro)', price: 35, photo: 'Agua fresca'),
          ],
          days: {1, 2, 3, 4, 5, 6, 7},
          openMinutes: 12 * 60,
          closeMinutes: 19 * 60,
          available: true,
          zone: 'Barrio de Abajo',
          ownerName: 'Rosa Medina',
          ownerEmail: 'mesa@miralocal.mx',
          whatsapp: '418 555 0102',
          ratings: _ratings('b2', [0, 1, 2, 8, 13]),
          status: BusinessStatus.active,
        ),
        Business(
          id: 'b3',
          name: 'Manos que Crean',
          description: 'Artesanías en barro y textil hechas por artesanas de la región.',
          categoryId: 'artesanias',
          photos: ['Taller de barro', 'Jarras pintadas', 'Tejidos de lana'],
          products: [
            Product(id: 'p8', name: 'Jarra de barro', price: 220, photo: 'Jarra de barro'),
            Product(id: 'p9', name: 'Servilletas bordadas', price: 130, photo: 'Servilletas'),
          ],
          days: {4, 5, 6, 7},
          openMinutes: 10 * 60,
          closeMinutes: 17 * 60,
          available: false, // activo pero no disponible: no se ve para clientes
          zone: 'Plaza Principal',
          ownerName: 'Elena Cruz',
          ownerEmail: 'manos@miralocal.mx',
          whatsapp: '418 555 0103',
          ratings: _ratings('b3', [0, 0, 2, 4, 9]),
          status: BusinessStatus.active,
        ),
        Business(
          id: 'b4',
          name: 'Taller Jacarandá',
          description: 'Carpintería y restauración de muebles a medida.',
          categoryId: 'servicios',
          photos: ['Mesa restaurada', 'Herramientas del taller'],
          products: [
            Product(id: 'p10', name: 'Restauración de silla', price: 350, photo: 'Silla restaurada'),
            Product(id: 'p11', name: 'Mueble a medida (cotización)', price: 1200, photo: 'Mueble a medida'),
          ],
          days: {1, 2, 3, 4, 5},
          openMinutes: 9 * 60,
          closeMinutes: 17 * 60,
          available: true,
          zone: 'Colonia Jardines',
          ownerName: 'Mario Ibarra',
          ownerEmail: 'taller@miralocal.mx',
          whatsapp: '418 555 0104',
          ratings: [],
          status: BusinessStatus.pending,
        ),
        Business(
          id: 'b5',
          name: 'Lino del Sur',
          description: 'Ropa de lino y accesorios de temporada.',
          categoryId: 'ropa',
          photos: ['Camisas de lino', 'Bolsas de manta'],
          products: [
            Product(id: 'p12', name: 'Camisa de lino', price: 480, photo: 'Camisa de lino'),
            Product(id: 'p13', name: 'Bolsa de manta', price: 190, photo: 'Bolsa de manta'),
          ],
          days: {2, 3, 4, 5, 6},
          openMinutes: 10 * 60,
          closeMinutes: 18 * 60,
          available: false,
          zone: 'Calle Hidalgo',
          ownerName: 'Andrea Solís',
          ownerEmail: 'lino@miralocal.mx',
          whatsapp: '418 555 0105',
          ratings: _ratings('b5', [1, 1, 1, 2, 3]),
          status: BusinessStatus.suspended, // con solicitud de reactivación
        ),
        Business(
          id: 'b6',
          name: 'Feria Verde',
          description: 'Verduras orgánicas y comida vegetariana de temporada.',
          categoryId: 'comida',
          photos: ['Puesto de verduras', 'Canasta de temporada'],
          products: [
            Product(id: 'p14', name: 'Canasta de verduras', price: 140, photo: 'Canasta'),
            Product(id: 'p15', name: 'Tamal de rajas', price: 25, photo: 'Tamal de rajas'),
          ],
          days: {6, 7},
          openMinutes: 8 * 60,
          closeMinutes: 14 * 60,
          available: true,
          zone: 'Jardín del Carmen',
          ownerName: 'Jorge Paredes',
          ownerEmail: 'feria@miralocal.mx',
          whatsapp: '418 555 0106',
          ratings: [],
          status: BusinessStatus.rejected, // sin solicitud todavía
        ),
        Business(
          id: 'b7',
          name: 'Pan Caliente de Doña Chela',
          description: 'Pan de pueblo horneado cada mañana en horno de leña.',
          categoryId: 'comida',
          photos: ['Horno de leña', 'Conchas y bolillos', 'Canasta de pan'],
          products: [
            Product(id: 'p16', name: 'Conchas (6 piezas)', price: 50, photo: 'Conchas'),
            Product(id: 'p17', name: 'Bolillos (10 piezas)', price: 40, photo: 'Bolillos'),
          ],
          days: {1, 2, 3, 4, 5, 6, 7},
          openMinutes: 6 * 60,
          closeMinutes: 13 * 60,
          available: true,
          zone: 'Barrio de Arriba',
          ownerName: 'Socorro Pérez',
          ownerEmail: 'pan@miralocal.mx',
          whatsapp: '418 555 0107',
          ratings: _ratings('b7', [0, 0, 1, 3, 7]),
          status: BusinessStatus.active,
        ),
      ];

  static List<ModerationNotice> notices() => [
        ModerationNotice(
          id: 'n1',
          businessId: 'b5',
          status: BusinessStatus.suspended,
          reason: 'Las fotografías no corresponden a los productos que ofreces.',
          date: DateTime(2026, 10, 12),
        ),
        ModerationNotice(
          id: 'n2',
          businessId: 'b6',
          status: BusinessStatus.rejected,
          reason: 'La descripción está incompleta y falta el horario de atención.',
          date: DateTime(2026, 10, 14),
        ),
      ];

  static List<ReactivationRequest> requests() => [
        ReactivationRequest(
          id: 'q1',
          businessId: 'b5',
          message: 'Ya reemplacé las fotografías por imágenes reales de mis prendas.',
          date: DateTime(2026, 10, 18),
        ),
      ];
}
