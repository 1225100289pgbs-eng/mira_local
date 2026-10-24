import 'package:flutter/material.dart';

import '../theme/app_theme.dart';

Future<bool> confirmDialog(
  BuildContext context, {
  required String title,
  required String message,
  String confirmLabel = 'Confirmar',
  bool destructive = false,
}) async {
  final result = await showDialog<bool>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Text(message),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx, false),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(
            minimumSize: const Size(0, 44),
            backgroundColor: destructive ? AppColors.error : null,
          ),
          onPressed: () => Navigator.pop(ctx, true),
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
  return result ?? false;
}

/// Diálogo con un campo de texto obligatorio. Devuelve el texto o null si se cancela.
Future<String?> promptDialog(
  BuildContext context, {
  required String title,
  required String label,
  String? description,
  String? hint,
  String confirmLabel = 'Continuar',
  int maxLines = 1,
  String? initial,
}) {
  final controller = TextEditingController(text: initial);
  final formKey = GlobalKey<FormState>();
  return showDialog<String>(
    context: context,
    builder: (ctx) => AlertDialog(
      title: Text(title),
      content: Form(
        key: formKey,
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (description != null)
              Padding(
                padding: const EdgeInsets.only(bottom: 12),
                child: Text(description),
              ),
            TextFormField(
              controller: controller,
              maxLines: maxLines,
              autofocus: true,
              decoration: InputDecoration(labelText: label, hintText: hint),
              validator: (v) =>
                  (v == null || v.trim().isEmpty) ? 'Este campo es obligatorio' : null,
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(ctx),
          child: const Text('Cancelar'),
        ),
        FilledButton(
          style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
          onPressed: () {
            if (formKey.currentState!.validate()) {
              Navigator.pop(ctx, controller.text.trim());
            }
          },
          child: Text(confirmLabel),
        ),
      ],
    ),
  );
}

/// Rechazar / suspender: pide un motivo obligatorio y luego una confirmación.
/// Devuelve el motivo si el administrador confirma; null en caso contrario.
Future<String?> askReasonAndConfirm(
  BuildContext context, {
  required String action,
  required String businessName,
}) async {
  final reason = await promptDialog(
    context,
    title: '$action emprendimiento',
    label: 'Motivo (obligatorio)',
    description: 'El emprendedor recibirá este motivo en su panel.',
    maxLines: 3,
  );
  if (reason == null || !context.mounted) return null;
  final ok = await confirmDialog(
    context,
    title: '¿$action "$businessName"?',
    message: 'El negocio dejará de ser visible para los clientes.\n\nMotivo: $reason',
    confirmLabel: action,
    destructive: true,
  );
  return ok ? reason : null;
}
