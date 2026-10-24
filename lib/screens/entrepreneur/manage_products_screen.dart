import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../models/product.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../utils/format.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/photo_box.dart';

class ProductData {
  const ProductData(this.name, this.price, this.photo, this.available);

  final String name;
  final double price;
  final String photo;
  final bool available;
}

class ManageProductsScreen extends StatelessWidget {
  const ManageProductsScreen({super.key});

  Future<void> _openForm(BuildContext context, AppState state, Business b,
      [Product? product]) async {
    final data = await showDialog<ProductData>(
      context: context,
      builder: (_) => _ProductDialog(product: product),
    );
    if (data == null || !context.mounted) return;
    if (product == null) {
      state.addProduct(b,
          name: data.name,
          price: data.price,
          photo: data.photo,
          available: data.available);
      showMessage(context, 'Producto agregado');
    } else {
      state.updateProduct(product,
          name: data.name,
          price: data.price,
          photo: data.photo,
          available: data.available);
      showMessage(context, 'Producto actualizado');
    }
  }

  Future<void> _delete(
      BuildContext context, AppState state, Business b, Product p) async {
    final ok = await confirmDialog(
      context,
      title: '¿Eliminar producto?',
      message: 'Se eliminará "${p.name}" de tu lista.',
      confirmLabel: 'Eliminar',
      destructive: true,
    );
    if (!ok || !context.mounted) return;
    state.removeProduct(b, p);
    showMessage(context, 'Producto eliminado');
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final b = state.ownerBusiness;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Productos')),
        body: const EmptyState('Primero registra tu emprendimiento.'),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Mis productos')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          PrimaryButton(
            label: 'Agregar producto',
            onPressed: () => _openForm(context, state, b),
          ),
          const SizedBox(height: 16),
          if (b.products.isEmpty)
            const SizedBox(
              height: 160,
              child: EmptyState('Aún no tienes productos registrados.'),
            ),
          for (final p in b.products)
            AppCard(
              child: Column(
                children: [
                  Row(
                    children: [
                      PhotoBox(label: p.photo, width: 56, height: 56, radius: 10),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(p.name,
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.w600)),
                            Text(formatPrice(p.price),
                                style: const TextStyle(color: AppColors.terracota)),
                          ],
                        ),
                      ),
                      Column(
                        children: [
                          Switch(
                            value: p.available,
                            onChanged: (v) => state.setProductAvailability(p, v),
                          ),
                          Text(p.available ? 'Disponible' : 'Agotado',
                              style: const TextStyle(
                                  fontSize: 11, color: AppColors.gris)),
                        ],
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      TextButton(
                        onPressed: () => _openForm(context, state, b, p),
                        child: const Text('Editar'),
                      ),
                      TextButton(
                        style: TextButton.styleFrom(foregroundColor: AppColors.error),
                        onPressed: () => _delete(context, state, b, p),
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

class _ProductDialog extends StatefulWidget {
  const _ProductDialog({this.product});

  final Product? product;

  @override
  State<_ProductDialog> createState() => _ProductDialogState();
}

class _ProductDialogState extends State<_ProductDialog> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _price;
  late final TextEditingController _photo;
  late bool _available;

  @override
  void initState() {
    super.initState();
    final p = widget.product;
    _name = TextEditingController(text: p?.name);
    _price = TextEditingController(
        text: p == null ? '' : p.price.toStringAsFixed(p.price % 1 == 0 ? 0 : 2));
    _photo = TextEditingController(text: p?.photo);
    _available = p?.available ?? true;
  }

  @override
  void dispose() {
    _name.dispose();
    _price.dispose();
    _photo.dispose();
    super.dispose();
  }

  void _save() {
    if (!_formKey.currentState!.validate()) return;
    final price = double.parse(_price.text.trim().replaceAll(',', '.'));
    Navigator.pop(
      context,
      ProductData(_name.text.trim(), price, _photo.text.trim(), _available),
    );
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: Text(widget.product == null ? 'Agregar producto' : 'Editar producto'),
      content: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppTextField(
                  controller: _name, label: 'Nombre', validator: Validators.required),
              AppTextField(
                controller: _price,
                label: 'Precio (MXN)',
                keyboardType: const TextInputType.numberWithOptions(decimal: true),
                validator: (v) {
                  final n = double.tryParse((v ?? '').trim().replaceAll(',', '.'));
                  return (n == null || n <= 0) ? 'Ingresa un precio válido' : null;
                },
              ),
              AppTextField(
                controller: _photo,
                label: 'Fotografía (descripción)',
                hint: 'Opcional',
              ),
              Row(
                children: [
                  const Expanded(child: Text('Disponible')),
                  Switch(
                    value: _available,
                    onChanged: (v) => setState(() => _available = v),
                  ),
                ],
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
          onPressed: _save,
          child: const Text('Guardar'),
        ),
      ],
    );
  }
}
