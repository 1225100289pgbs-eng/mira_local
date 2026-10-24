import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../widgets/business_card.dart';
import '../../widgets/common.dart';
import 'admin_business_detail_screen.dart';
import 'admin_route.dart';

class ManageBusinessesScreen extends StatefulWidget {
  const ManageBusinessesScreen({super.key});

  @override
  State<ManageBusinessesScreen> createState() => _ManageBusinessesScreenState();
}

class _ManageBusinessesScreenState extends State<ManageBusinessesScreen> {
  final _search = TextEditingController();
  String? _categoryId;
  BusinessStatus? _status;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final list = state.searchAll(
      query: _search.text,
      categoryId: _categoryId,
      status: _status,
    );

    return Scaffold(
      appBar: AppBar(title: const Text('Emprendimientos')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 12, 20, 10),
            child: TextField(
              controller: _search,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Buscar por nombre'),
            ),
          ),
          ChipFilter<BusinessStatus>(
            options: BusinessStatus.values,
            selected: _status,
            allLabel: 'Todos los estados',
            labelOf: (s) => s.label,
            onSelected: (v) => setState(() => _status = v),
          ),
          const SizedBox(height: 6),
          ChipFilter<String>(
            options: state.categories.map((c) => c.id).toList(),
            selected: _categoryId,
            allLabel: 'Todas las categorías',
            labelOf: state.categoryName,
            onSelected: (v) => setState(() => _categoryId = v),
          ),
          Expanded(
            child: list.isEmpty
                ? const EmptyState('No hay emprendimientos con esos filtros.')
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: list.length,
                    itemBuilder: (context, i) {
                      final b = list[i];
                      return BusinessCard(
                        business: b,
                        categoryName: state.categoryName(b.categoryId),
                        showStatus: true,
                        pendingRequest: state.hasPendingRequest(b.id),
                        onTap: () => Navigator.push(
                          context,
                          adminRoute(AdminBusinessDetailScreen(businessId: b.id)),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}
