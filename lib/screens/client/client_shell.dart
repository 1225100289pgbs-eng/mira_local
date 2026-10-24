import 'package:flutter/material.dart';

import '../../theme/app_theme.dart';
import 'categories_screen.dart';
import 'home_screen.dart';
import 'results_screen.dart';

/// Contenedor del flujo del cliente con barra inferior de texto.
class ClientShell extends StatefulWidget {
  const ClientShell({super.key});

  @override
  State<ClientShell> createState() => _ClientShellState();
}

class _ClientShellState extends State<ClientShell> {
  int _index = 0;

  static const _labels = ['Inicio', 'Categorías', 'Buscar'];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(
        index: _index,
        children: [
          HomeScreen(onSeeCategories: () => setState(() => _index = 1)),
          const CategoriesScreen(),
          const ResultsScreen(),
        ],
      ),
      bottomNavigationBar: Container(
        decoration: const BoxDecoration(
          color: Colors.white,
          border: Border(top: BorderSide(color: AppColors.borde)),
        ),
        child: SafeArea(
          top: false,
          child: Row(
            children: [
              for (var i = 0; i < _labels.length; i++)
                Expanded(
                  child: InkWell(
                    onTap: () => setState(() => _index = i),
                    child: Padding(
                      padding: const EdgeInsets.only(top: 14, bottom: 10),
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Text(
                            _labels[i],
                            style: TextStyle(
                              fontSize: 15,
                              fontWeight:
                                  i == _index ? FontWeight.w700 : FontWeight.w500,
                              color: i == _index
                                  ? AppColors.terracota
                                  : AppColors.gris,
                            ),
                          ),
                          const SizedBox(height: 6),
                          Container(
                            height: 3,
                            width: 24,
                            decoration: BoxDecoration(
                              color: i == _index
                                  ? AppColors.terracota
                                  : Colors.transparent,
                              borderRadius: BorderRadius.circular(2),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
