import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/business_card.dart';
import '../../widgets/common.dart';
import '../admin/admin_login_screen.dart';
import '../admin/admin_route.dart';
import '../entrepreneur/entrepreneur_login_screen.dart';
import 'business_profile_screen.dart';
import 'results_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required this.onSeeCategories});

  final VoidCallback onSeeCategories;

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _search = TextEditingController();

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _openResults({String? categoryId}) {
    final query = _search.text;
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (_) =>
            ResultsScreen(initialQuery: query, initialCategoryId: categoryId),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final featured = state.featured();

    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 24),
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text('Mira Local',
                    style: AppTheme.titulo(28, color: AppColors.terracota)),
                TextButton(
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const EntrepreneurLoginScreen()),
                  ),
                  child: const Text('Soy emprendedor'),
                ),
              ],
            ),
            const Text('Descubre. Conoce. Elige.',
                style: TextStyle(color: AppColors.gris, fontSize: 15)),
            const SizedBox(height: 20),
            TextField(
              controller: _search,
              textInputAction: TextInputAction.search,
              onSubmitted: (_) => _openResults(),
              decoration:
                  const InputDecoration(hintText: 'Buscar emprendimientos por nombre'),
            ),
            const SizedBox(height: 10),
            PrimaryButton(label: 'Buscar', onPressed: _openResults),
            SectionTitle(
              'Categorías',
              trailing: TextButton(
                onPressed: widget.onSeeCategories,
                child: const Text('Ver todas'),
              ),
            ),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final c in state.categories)
                  ActionChip(
                    label: Text(c.name),
                    onPressed: () => _openResults(categoryId: c.id),
                  ),
              ],
            ),
            const SectionTitle('Emprendimientos destacados'),
            if (featured.isEmpty)
              const SizedBox(
                height: 120,
                child: EmptyState('Aún no hay emprendimientos disponibles.'),
              )
            else
              for (final b in featured)
                BusinessCard(
                  business: b,
                  categoryName: state.categoryName(b.categoryId),
                  onTap: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => BusinessProfileScreen(businessId: b.id)),
                  ),
                ),
            const SizedBox(height: 8),
            Center(
              child: TextButton(
                onPressed: () => Navigator.push(
                  context,
                  adminRoute(const AdminLoginScreen()),
                ),
                style: TextButton.styleFrom(foregroundColor: AppColors.gris),
                child: const Text('Acceso administrativo'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
