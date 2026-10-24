import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import 'results_screen.dart';

class CategoriesScreen extends StatelessWidget {
  const CategoriesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: state.categories.isEmpty
          ? const EmptyState('No hay categorías registradas.')
          : ListView(
              padding: const EdgeInsets.all(20),
              children: [
                const Padding(
                  padding: EdgeInsets.only(bottom: 14),
                  child: Text('¿Qué estás buscando hoy?',
                      style: TextStyle(color: AppColors.gris)),
                ),
                for (final c in state.categories)
                  AppCard(
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ResultsScreen(initialCategoryId: c.id),
                      ),
                    ),
                    child: Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(c.name,
                                  style: const TextStyle(
                                      fontSize: 16, fontWeight: FontWeight.w600)),
                              const SizedBox(height: 2),
                              Text(c.description,
                                  style: const TextStyle(
                                      color: AppColors.gris, fontSize: 13)),
                            ],
                          ),
                        ),
                        Text('${state.visibleCountForCategory(c.id)}',
                            style: AppTheme.titulo(20, color: AppColors.terracota)),
                      ],
                    ),
                  ),
              ],
            ),
    );
  }
}
