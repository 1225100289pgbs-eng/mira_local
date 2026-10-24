import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../../widgets/confirmation_dialog.dart';
import 'create_account_screen.dart';
import 'owner_panel_screen.dart';

class EntrepreneurLoginScreen extends StatefulWidget {
  const EntrepreneurLoginScreen({super.key});

  @override
  State<EntrepreneurLoginScreen> createState() => _EntrepreneurLoginScreenState();
}

class _EntrepreneurLoginScreenState extends State<EntrepreneurLoginScreen> {
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
    final ok = context.read<AppState>().loginOwner(_email.text, _password.text);
    if (!ok) {
      showMessage(context, 'Correo o contraseña incorrectos', error: true);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const OwnerPanelScreen()),
    );
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
      appBar: AppBar(title: const Text('Acceso emprendedor')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Administra tu emprendimiento desde aquí.',
              style: TextStyle(color: AppColors.gris)),
          const SizedBox(height: 20),
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
              MaterialPageRoute(builder: (_) => const CreateAccountScreen()),
            ),
          ),
          const SizedBox(height: 24),
          const Text(
            'Cuentas de prueba (contraseña mira1234):\n'
            'dulces@miralocal.mx · activo\n'
            'lino@miralocal.mx · suspendido con solicitud\n'
            'feria@miralocal.mx · rechazado\n'
            'taller@miralocal.mx · pendiente',
            style: TextStyle(color: AppColors.gris, fontSize: 13, height: 1.5),
          ),
        ],
      ),
    );
  }
}
