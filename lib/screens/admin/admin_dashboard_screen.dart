import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import 'admin_ratings_screen.dart';
import 'admin_route.dart';
import 'manage_businesses_screen.dart';
import 'manage_categories_screen.dart';
import 'statistics_screen.dart';

class AdminDashboardScreen extends StatelessWidget {
  const AdminDashboardScreen({super.key});

  Future<void> _logout(BuildContext context) async {
    final ok = await confirmDialog(
      context,
      title: '¿Cerrar sesión?',
      message: 'Saldrás del panel administrativo.',
      confirmLabel: 'Cerrar sesión',
    );
    if (!ok || !context.mounted) return;
    context.read<AppState>().logoutAdmin();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<AppState>();
    final metrics = <(String, String)>[
      ('Emprendimientos', '${s.totalBusinesses}'),
      ('Activos', '${s.countByStatus(BusinessStatus.active)}'),
      ('Pendientes', '${s.countByStatus(BusinessStatus.pending)}'),
      ('Suspendidos', '${s.countByStatus(BusinessStatus.suspended)}'),
      ('Rechazados', '${s.countByStatus(BusinessStatus.rejected)}'),
      ('Categorías', '${s.categories.length}'),
      ('Calificación promedio', s.globalAverage.toStringAsFixed(1)),
      ('Solicitudes de reactivación', '${s.pendingRequestsCount}'),
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Panel administrativo'),
        automaticallyImplyLeading: false,
        actions: [
          TextButton(
            style: TextButton.styleFrom(foregroundColor: Colors.white),
            onPressed: () => _logout(context),
            child: const Text('Cerrar sesión'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            mainAxisSpacing: 10,
            crossAxisSpacing: 10,
            childAspectRatio: 1.7,
            children: [
              for (final m in metrics)
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.borde),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(m.$2,
                          style: const TextStyle(
                              fontSize: 26, fontWeight: FontWeight.w700)),
                      Text(m.$1,
                          maxLines: 2,
                          style: const TextStyle(
                              color: AppColors.gris, fontSize: 12)),
                    ],
                  ),
                ),
            ],
          ),
          const SectionTitle('Secciones'),
          _Tile(
            title: 'Emprendimientos',
            subtitle: s.pendingRequestsCount > 0
                ? '${s.pendingRequestsCount} solicitud(es) de reactivación pendiente(s)'
                : 'Revisar, aprobar, rechazar y suspender',
            onTap: () =>
                Navigator.push(context, adminRoute(const ManageBusinessesScreen())),
          ),
          _Tile(
            title: 'Categorías',
            subtitle: 'Agregar, editar y eliminar',
            onTap: () =>
                Navigator.push(context, adminRoute(const ManageCategoriesScreen())),
          ),
          _Tile(
            title: 'Calificaciones',
            subtitle: 'Consulta de solo lectura',
            onTap: () =>
                Navigator.push(context, adminRoute(const AdminRatingsScreen())),
          ),
          _Tile(
            title: 'Estadísticas',
            subtitle: 'Totales, categorías y mejor calificados',
            onTap: () =>
                Navigator.push(context, adminRoute(const StatisticsScreen())),
          ),
        ],
      ),
    );
  }
}

class _Tile extends StatelessWidget {
  const _Tile({required this.title, required this.subtitle, required this.onTap});

  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return AppCard(
      onTap: onTap,
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title,
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                const SizedBox(height: 2),
                Text(subtitle,
                    style: const TextStyle(color: AppColors.gris, fontSize: 13)),
              ],
            ),
          ),
          const Text('›', style: TextStyle(fontSize: 24, color: AppColors.gris)),
        ],
      ),
    );
  }
}
