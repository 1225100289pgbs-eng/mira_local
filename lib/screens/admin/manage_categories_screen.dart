import 'package:flutter/material.dart' hide Category;
import 'package:provider/provider.dart';

import '../../models/category.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';

class CategoryData {
  const CategoryData(this.name, this.description);

  final String name;
  final String description;
}

class ManageCategoriesScreen extends StatelessWidget {
  const ManageCategoriesScreen({super.key});

  Future<void> _openForm(BuildContext context, AppState state, [Category? c]) async {
    final data = await showDialog<CategoryData>(
      context: context,
      builder: (_) => _CategoryDialog(category: c),
    );
    if (data == null || !context.mounted) return;
    if (c == null) {
      state.addCategory(data.name, data.description);
      showMessage(context, 'Categoría agregada');
    } else {
      state.editCategory(c, data.name, data.description);
      showMessage(context, 'Categoría actualizada');
    }
  }

  Future<void> _delete(BuildContext context, AppState state, Category c) async {
    final count = state.businessCountForCategory(c.id);
    if (count > 0) {
      await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
          title: const Text('No se puede eliminar'),
          content: Text(
              'La categoría "${c.name}" tiene $count emprendimiento(s) asociado(s). '
              'Reasígnalos antes de eliminarla.'),
          actions: [
            FilledButton(
              style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Entendido'),
            ),
          ],
        ),
      );
      return;
    }
    final ok = await confirmDialog(
      context,
      title: '¿Eliminar categoría?',
      message: 'Se eliminará "${c.name}".',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    state.deleteCategory(c);
    showMessage(context, 'Categoría eliminada');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Categorías')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PrimaryButton(
            label: 'Agregar categoría',
            onPressed: () => _openForm(context, state),
          ),
          const SizedBox(height: 16),
          if (state.categories.isEmpty)
            const SizedBox(height: 160, child: EmptyState('No hay categorías.')),
          for (final c in state.categories)
            AppCard(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(c.name,
                      style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
                  Text(c.description,
                      style: const TextStyle(color: AppColors.gris, fontSize: 13)),
                  const SizedBox(height: 4),
                  Text('${state.businessCountForCategory(c.id)} emprendimiento(s)',
                      style: const TextStyle(fontSize: 13)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _openForm(context, state, c),
                        child: const Text('Editar'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () => _delete(context, state, c),
                        child: const Text('Eliminar'),
                      ),
                    ],
                  ),
                ],
              ),
            ),
        ],
      ),
    );
  }
}

class _CategoryDialog extends StatefulWidget {
  const _CategoryDialog({this.category});

  final Category? category;

  @override
  State<_CategoryDialog> createState() => _CategoryDialogState();
}

class _CategoryDialogState extends State<_CategoryDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;

  @override
  void initState() {
    super.initState();
    _name = TextEditingController(text: widget.category?.name);
    _description = TextEditingController(text: widget.category?.description);
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.category == null ? 'Agregar categoría' : 'Editar categoría'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                  controller: _name, label: 'Nombre', validator: Validators.required),
              AppTextField(
                controller: _description,
                label: 'Descripción',
                maxLines: 2,
                validator: Validators.required,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () {
            if (_formKey.currentState!.validate()) {
              Navigator.pop(
                  context, CategoryData(_name.text.trim(), _description.text.trim()));
            }
          },
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
