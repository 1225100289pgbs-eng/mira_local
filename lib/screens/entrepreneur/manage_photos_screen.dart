import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../../widgets/photo_box.dart';
import '../../widgets/status_badge.dart';

class ManagePhotosScreen extends StatelessWidget {
  const ManagePhotosScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final b = state.ownerBusiness;
    if (b == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Fotografías')),
        body: const EmptyState('Primero registra tu emprendimiento.'),
      );
    }

    Future<void> add() async {
      final label = await promptDialog(
        context,
        title: 'Agregar fotografía',
        label: 'Descripción de la fotografía',
        description: 'En este prototipo las fotografías son simuladas.',
        confirmLabel: 'Agregar',
      );
      if (label == null || !context.mounted) return;
      state.addPhoto(b, label);
      showMessage(context, 'Fotografía agregada');
    }

    Future<void> remove(String photo) async {
      if (b.photos.length <= 1) {
        showMessage(context, 'Debe quedar al menos una fotografía', error: true);
        return;
      }
      final ok = await confirmDialog(
        context,
        title: '¿Eliminar fotografía?',
        message: 'Se quitará "$photo" de tu galería.',
        confirmLabel: 'Eliminar',
        destructive: true,
      );
      if (!ok || !context.mounted) return;
      state.removePhoto(b, photo);
      showMessage(context, 'Fotografía eliminada');
    }

    return Scaffold(
      appBar: AppBar(title: const Text('Fotografías')),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            PrimaryButton(label: 'Agregar fotografía', onPressed: add),
            const SizedBox(height: 12),
            Expanded(
              child: GridView.builder(
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 12,
                  crossAxisSpacing: 12,
                  childAspectRatio: 0.78,
                ),
                itemCount: b.photos.length,
                itemBuilder: (context, i) {
                  final photo = b.photos[i];
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox.expand(child: PhotoBox(label: photo)),
                      ),
                      const SizedBox(height: 4),
                      Wrap(
                        crossAxisAlignment: WrapCrossAlignment.center,
                        spacing: 4,
                        children: [
                          if (i == 0)
                            const StatusBadge(text: 'Portada', color: AppColors.exito)
                          else
                            TextButton(
                              onPressed: () {
                                state.setCover(b, photo);
                                showMessage(context, 'Portada actualizada');
                              },
                              child: const Text('Hacer portada'),
                            ),
                          TextButton(
                            style: TextButton.styleFrom(
                                foregroundColor: AppColors.error),
                            onPressed: () => remove(photo),
                            child: const Text('Eliminar'),
                          ),
                        ],
                      ),
                    ],
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
