import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/rating_stars.dart';

class RatingScreen extends StatefulWidget {
  const RatingScreen({super.key, required this.businessId});

  final String businessId;

  @override
  State<RatingScreen> createState() => _RatingScreenState();
}

class _RatingScreenState extends State<RatingScreen> {
  final _comment = TextEditingController();
  int _stars = 0;

  @override
  void dispose() {
    _comment.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    final state = context.read<AppState>();
    final b = state.businessById(widget.businessId);
    if (b == null) return;
    if (_stars == 0) {
      showMessage(context, 'Selecciona de una a cinco estrellas', error: true);
      return;
    }
    state.addRating(b, _stars, _comment.text);
    await showDialog<void>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¡Gracias por tu calificación!'),
        content: Text('Calificaste a ${b.name} con $_stars de 5 estrellas.'),
        actions: [
          FilledButton(
            style: FilledButton.styleFrom(minimumSize: const Size(0, 44)),
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Aceptar'),
          ),
        ],
      ),
    );
    if (mounted) Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    final b = context.watch<AppState>().businessById(widget.businessId);
    return Scaffold(
      appBar: AppBar(title: const Text('Calificar')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          Text(b?.name ?? '', style: Theme.of(context).textTheme.headlineSmall),
          const SizedBox(height: 4),
          const Text('¿Cómo fue tu experiencia?'),
          const SizedBox(height: 16),
          RatingInput(value: _stars, onChanged: (v) => setState(() => _stars = v)),
          const SizedBox(height: 20),
          AppTextField(
            controller: _comment,
            label: 'Comentario (opcional)',
            hint: 'Cuéntanos qué te pareció',
            maxLines: 4,
          ),
          const SizedBox(height: 8),
          PrimaryButton(label: 'Enviar calificación', onPressed: _submit),
        ],
      ),
    );
  }
}
