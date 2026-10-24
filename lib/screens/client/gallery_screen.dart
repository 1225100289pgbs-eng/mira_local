import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/common.dart';
import '../../widgets/photo_box.dart';

class GalleryScreen extends StatelessWidget {
  const GalleryScreen({super.key, required this.businessId});

  final String businessId;

  void _openLarge(BuildContext context, String label) {
    showDialog<void>(
      context: context,
      builder: (ctx) => Dialog(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              PhotoBox(label: label, aspectRatio: 1, large: true),
              const SizedBox(height: 12),
              PrimaryButton(label: 'Cerrar', onPressed: () => Navigator.pop(ctx)),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final b = context.watch<AppState>().businessById(businessId);
    return Scaffold(
      appBar: AppBar(title: Text(b == null ? 'Galería' : 'Galería · ${b.name}')),
      body: b == null || b.photos.isEmpty
          ? const EmptyState('No hay fotografías para mostrar.')
          : GridView.count(
              padding: const EdgeInsets.all(20),
              crossAxisCount: 2,
              mainAxisSpacing: 10,
              crossAxisSpacing: 10,
              children: [
                for (final p in b.photos)
                  GestureDetector(
                    onTap: () => _openLarge(context, p),
                    child: PhotoBox(label: p, aspectRatio: 1),
                  ),
              ],
            ),
    );
  }
}
