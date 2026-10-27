import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/business_card.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../entrepreneur/business_form_screen.dart';
import '../entrepreneur/owner_panel_screen.dart';
import 'business_profile_screen.dart';

/// Vista del cliente: una sola pantalla con buscador, categorías y lista.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  final _search = TextEditingController();
  String? _categoryId;

  @override
  void dispose() {
    _search.dispose();
    super.dispose();
  }

  void _logout() {
    context.read<AppState>().logoutOwner();
    Navigator.popUntil(context, (route) => route.isFirst);
  }

  Future<void> _startBusiness() async {
    final state = context.read<AppState>();
    if (state.currentOwner == null) {
      final login = await confirmDialog(
        context,
        title: 'Inicia sesión',
        message: 'Necesitas una cuenta para registrar tu negocio.',
        confirmLabel: 'Ir a iniciar sesión',
      );
      if (login && mounted) {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
      return;
    }
    final ok = await confirmDialog(
      context,
      title: '¿Registrar tu negocio?',
      message:
          'Tu cuenta pasará a ser de emprendedor y podrás administrar tu emprendimiento.',
      confirmLabel: 'Continuar',
    );
    if (!ok || !mounted) return;
    state.becomeEntrepreneur();
    Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const BusinessFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();
    final user = state.currentOwner;
    final results =
        state.searchVisible(query: _search.text, categoryId: _categoryId);

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 12, 20, 0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Mira Local',
                          style: AppTheme.titulo(26, color: AppColors.terracota)),
                      const Text('Descubre lo que hay para tí',
                          style: TextStyle(color: AppColors.gris)),
                    ],
                  ),
                  TextButton(
                    onPressed: _logout,
                    child: Text(user == null ? 'Iniciar sesión' : 'Cerrar sesión'),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.fromLTRB(20, 14, 20, 10),
              child: TextField(
                controller: _search,
                onChanged: (_) => setState(() {}),
                decoration:
                    const InputDecoration(hintText: 'Buscar emprendimientos'),
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
                  ? const EmptyState(
                      'No encontramos emprendimientos con esos filtros.')
                  : ListView.builder(
                      padding: const EdgeInsets.fromLTRB(20, 14, 20, 8),
                      itemCount: results.length,
                      itemBuilder: (context, i) {
                        final b = results[i];
                        return BusinessCard(
                          business: b,
                          categoryName: state.categoryName(b.categoryId),
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  BusinessProfileScreen(businessId: b.id),
                            ),
                          ),
                        );
                      },
                    ),
            ),
            if (user == null || user.role == UserRole.cliente)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: PrimaryButton(
                  label: 'Quiero registrar mi negocio',
                  outlined: true,
                  onPressed: _startBusiness,
                ),
              ),
            if (user != null && user.role == UserRole.emprendedor)
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 14),
                child: PrimaryButton(
                  label: 'Ir a mi negocio',
                  outlined: true,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(builder: (_) => const OwnerPanelScreen()),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}