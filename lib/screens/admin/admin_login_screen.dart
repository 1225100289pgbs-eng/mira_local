import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import 'admin_dashboard_screen.dart';
import 'admin_route.dart';

class AdminLoginScreen extends StatefulWidget {
  const AdminLoginScreen({super.key});

  @override
  State<AdminLoginScreen> createState() => _AdminLoginScreenState();
}

class _AdminLoginScreenState extends State<AdminLoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _email = TextEditingController();
  final _password = TextEditingController();

  @override
  void dispose() {
    _email.dispose();
    _password.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final ok = context.read<AppState>().loginAdmin(_email.text, _password.text);
    if (!ok) {
      showMessage(context, 'Credenciales de administrador incorrectas', error: true);
      return;
    }
    Navigator.pushReplacement(context, adminRoute(const AdminDashboardScreen()));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Administración')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Acceso administrativo',
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700)),
          const SizedBox(height: 4),
          const Text('Solo personal autorizado de Mira Local.',
              style: TextStyle(color: AppColors.gris)),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                  controller: _email,
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AppTextField(
                  controller: _password,
                  label: 'Contraseña',
                  obscure: true,
                  validator: Validators.required,
                ),
              ],
            ),
          ),
          PrimaryButton(label: 'Entrar como administrador', onPressed: _submit),
          const SizedBox(height: 10),
          PrimaryButton(
            label: 'Regresar a Mira Local',
            outlined: true,
            onPressed: () => Navigator.pop(context),
          ),
          const SizedBox(height: 24),
          const Text('Cuenta de prueba: admin@miralocal.mx · admin1234',
              style: TextStyle(color: AppColors.gris, fontSize: 13)),
        ],
      ),
    );
  }
}
