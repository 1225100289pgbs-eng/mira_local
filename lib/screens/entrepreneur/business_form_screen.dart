import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/photo_box.dart';
import 'owner_panel_screen.dart';
import 'schedule_editor.dart';

/// Registro del emprendimiento (editing == null) o información general (editing != null).
class BusinessFormScreen extends StatefulWidget {
  const BusinessFormScreen({super.key, this.editing});

  final Business? editing;

  @override
  State<BusinessFormScreen> createState() => _BusinessFormScreenState();
}

class _BusinessFormScreenState extends State<BusinessFormScreen> {
  final _formKey = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _description;
  late final TextEditingController _zone;
  late final TextEditingController _whatsapp;

  String? _categoryId;
  bool _categoryError = false;
  Set<int> _days = {1, 2, 3, 4, 5, 6};
  int _open = 9 * 60;
  int _close = 18 * 60;
  final List<String> _photos = [];

  bool get _isEditing => widget.editing != null;

  @override
  void initState() {
    super.initState();
    final b = widget.editing;
    _name = TextEditingController(text: b?.name);
    _description = TextEditingController(text: b?.description);
    _zone = TextEditingController(text: b?.zone);
    _whatsapp = TextEditingController(text: b?.whatsapp);
    _categoryId = b?.categoryId;
  }

  @override
  void dispose() {
    _name.dispose();
    _description.dispose();
    _zone.dispose();
    _whatsapp.dispose();
    super.dispose();
  }

  Future<void> _addPhoto() async {
    final label = await promptDialog(
      context,
      title: 'Agregar fotografía',
      label: 'Descripción de la fotografía',
      description: 'En este prototipo las fotografías son simuladas.',
      confirmLabel: 'Agregar',
    );
    if (label != null) setState(() => _photos.add(label));
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final formOk = _formKey.currentState!.validate();
    setState(() => _categoryError = _categoryId == null);
    if (!formOk || _categoryId == null) return;

    if (_isEditing) {
      state.updateBusinessInfo(
        widget.editing!,
        name: _name.text,
        categoryId: _categoryId!,
        description: _description.text,
        zone: _zone.text,
        whatsapp: _whatsapp.text,
      );
      showMessage(context, 'Información actualizada');
      Navigator.pop(context);
      return;
    }

    if (_days.isEmpty) {
      showMessage(context, 'Selecciona al menos un día de atención', error: true);
      return;
    }
    if (_close <= _open) {
      showMessage(context, 'La hora de cierre debe ser posterior a la apertura',
          error: true);
      return;
    }
    if (_photos.isEmpty) {
      showMessage(context, 'Agrega al menos una fotografía', error: true);
      return;
    }

    final ok = await confirmDialog(
      context,
      title: '¿Registrar emprendimiento?',
      message:
          'Quedará pendiente de aprobación. Los clientes lo verán cuando el administrador lo active.',
      confirmLabel: 'Registrar',
    );
    if (!ok || !mounted) return;

    state.registerBusiness(
      name: _name.text,
      categoryId: _categoryId!,
      description: _description.text,
      zone: _zone.text,
      days: _days,
      openMinutes: _open,
      closeMinutes: _close,
      whatsapp: _whatsapp.text,
      photos: _photos,
    );
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Registro enviado!'),
        content: const Text('Tu emprendimiento quedó pendiente de aprobación.'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Ir a mi panel'),
          ),
        ],
      ),
    );
    if (!mounted) return;
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const OwnerPanelScreen()),
      (route) => route.isFirst,
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(
        title: Text(_isEditing ? 'Información general' : 'Registro del emprendimiento'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                    controller: _name,
                    label: 'Nombre del emprendimiento',
                    validator: Validators.required),
                Align(
                  alignment: Alignment.centerLeft,
                  child: const Text('Categoría',
                      style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
                ),
                const SizedBox(height: 8),
                Align(
                  alignment: Alignment.centerLeft,
                  child: Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: [
                      for (final c in state.categories)
                        ChoiceChip(
                          label: Text(c.name),
                          selected: _categoryId == c.id,
                          showCheckmark: false,
                          onSelected: (_) => setState(() {
                            _categoryId = c.id;
                            _categoryError = false;
                          }),
                        ),
                    ],
                  ),
                ),
                if (_categoryError)
                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text('Selecciona una categoría',
                          style: TextStyle(color: AppColors.error, fontSize: 12)),
                    ),
                  ),
                const SizedBox(height: 16),
                AppTextField(
                    controller: _description,
                    label: 'Descripción',
                    maxLines: 4,
                    validator: Validators.required),
                AppTextField(
                    controller: _zone,
                    label: 'Zona general',
                    hint: 'Ej. Centro, Barrio de Abajo',
                    validator: Validators.required),
                AppTextField(
                  controller: _whatsapp,
                  label: 'WhatsApp',
                  hint: 'Incluye lada, ej. 418 555 0000',
                  keyboardType: TextInputType.phone,
                  validator: (v) {
                    final digits = (v ?? '').replaceAll(RegExp(r'\D'), '');
                    return digits.length < 10 ? 'Ingresa al menos 10 dígitos' : null;
                  },
                ),
              ],
            ),
          ),
          if (!_isEditing) ...[
            const SectionTitle('Horarios'),
            ScheduleEditor(
              days: _days,
              openMinutes: _open,
              closeMinutes: _close,
              onDaysChanged: (v) => setState(() => _days = v),
              onOpenChanged: (v) => setState(() => _open = v),
              onCloseChanged: (v) => setState(() => _close = v),
            ),
            const SectionTitle('Fotografías'),
            if (_photos.isEmpty)
              const Text('Aún no agregas fotografías.',
                  style: TextStyle(color: AppColors.gris)),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                for (final p in _photos)
                  Stack(
                    children: [
                      PhotoBox(label: p, width: 100, height: 100),
                      Positioned(
                        right: 0,
                        top: 0,
                        child: GestureDetector(
                          onTap: () => setState(() => _photos.remove(p)),
                          child: Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Text('Quitar',
                                style: TextStyle(
                                    fontSize: 11, color: AppColors.error)),
                          ),
                        ),
                      ),
                    ],
                  ),
              ],
            ),
            const SizedBox(height: 10),
            PrimaryButton(
                label: 'Agregar fotografía', outlined: true, onPressed: _addPhoto),
          ],
          const SizedBox(height: 24),
          PrimaryButton(
            label: _isEditing ? 'Guardar cambios' : 'Registrar emprendimiento',
            onPressed: _submit,
          ),
        ],
      ),
    );
  }
}
