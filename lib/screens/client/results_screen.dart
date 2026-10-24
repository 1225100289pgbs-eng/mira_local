import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/business_card.dart';
import '../../widgets/common.dart';
import 'business_profile_screen.dart';

class ResultsScreen extends StatefulWidget {
  const ResultsScreen({super.key, this.initialQuery = '', this.initialCategoryId});

  final String initialQuery;
  final String? initialCategoryId;

  @override
  State<ResultsScreen> createState() => _ResultsScreenState();
}

class _ResultsScreenState extends State<ResultsScreen> {
  late final TextEditingController _controller;
  String? _categoryId;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.initialQuery);
    _categoryId = widget.initialCategoryId;
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final results =
        state.searchVisible(query: _controller.text, categoryId: _categoryId);

    return Scaffold(
      appBar: AppBar(title: const Text('Resultados')),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 10),
            child: TextField(
              controller: _controller,
              onChanged: (_) => setState(() {}),
              decoration: const InputDecoration(hintText: 'Buscar por nombre'),
            ),
          ),
          ChipFilter<String>(
            options: state.categories.map((c) => c.id).toList(),
            selected: _categoryId,
            labelOf: state.categoryName,
            onSelected: (v) => setState(() => _categoryId = v),
          ),
          Expanded(
            child: results.isEmpty
                ? const EmptyState('No encontramos emprendimientos con esos filtros.')
                : ListView.builder(
                    padding: const EdgeInsets.all(20),
                    itemCount: results.length,
                    itemBuilder: (context, i) {
                      final b = results[i];
                      return BusinessCard(
                        business: b,
                        categoryName: state.categoryName(b.categoryId),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (_) => BusinessProfileScreen(businessId: b.id),
                          ),
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
