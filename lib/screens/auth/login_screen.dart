import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import '../admin/admin_dashboard_screen.dart';
import '../admin/admin_route.dart';
import '../client/client_shell.dart';
import '../entrepreneur/owner_panel_screen.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
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
    final user = context.read<AppState>().login(_email.text, _password.text);
    if (user == null) {
      showMessage(context, 'Correo o contraseña incorrectos', error: true);
      return;
    }
    switch (user.role) {
      case UserRole.cliente:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const ClientShell()));
      case UserRole.emprendedor:
        Navigator.push(
            context, MaterialPageRoute(builder: (_) => const OwnerPanelScreen()));
      case UserRole.administrador:
        Navigator.push(context, adminRoute(const AdminDashboardScreen()));
    }
  }

  Future<void> _forgot() async {
    final email = await promptDialog(
      context,
      title: 'Recuperar contraseña',
      label: 'Correo electrónico',
      description: 'Te enviaremos un enlace para restablecerla (simulado).',
      confirmLabel: 'Enviar enlace',
    );
    if (email == null || !mounted) return;
    showMessage(context, 'Si el correo está registrado, recibirás un enlace.');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.all(20),
          children: [
            const SizedBox(height: 24),
            Text('Mira Local',
                style: AppTheme.titulo(34, color: AppColors.terracota)),
            const Text('Descubre lo que hay para tí',
                style: TextStyle(color: AppColors.gris)),
            const SizedBox(height: 32),
            Text('Iniciar sesión',
                style: Theme.of(context).textTheme.headlineSmall),
            const SizedBox(height: 16),
            Form(
              key: _formKey,
              child: Column(
                children: [
                  AppTextField(
                    controller: _email,
                    label: 'Correo electrónico',
                    hint: 'tu@correo.com',
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
            Align(
              alignment: Alignment.centerRight,
              child: TextButton(
                onPressed: _forgot,
                child: const Text('¿Olvidaste tu contraseña?'),
              ),
            ),
            const SizedBox(height: 8),
            PrimaryButton(label: 'Ingresar', onPressed: _submit),
            const SizedBox(height: 10),
            PrimaryButton(
              label: 'Crear cuenta',
              outlined: true,
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterScreen()),
              ),
            ),
            const SizedBox(height: 10),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ClientShell()),
              ),
              child: const Text('Continuar como invitado'),
            ),
            const SizedBox(height: 24),
          ],
        ),
      ),
    );
  }
}
