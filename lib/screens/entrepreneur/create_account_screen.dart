import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import 'business_form_screen.dart';

class CreateAccountScreen extends StatefulWidget {
  const CreateAccountScreen({super.key});

  @override
  State<CreateAccountScreen> createState() => _CreateAccountScreenState();
}

class _CreateAccountScreenState extends State<CreateAccountScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();

  @override
  void dispose() {
    _name.dispose();
    _email.dispose();
    _password.dispose();
    _confirm.dispose();
    super.dispose();
  }

  void _submit() {
    if (!_formKey.currentState!.validate()) return;
    final error = context.read<AppState>().registerOwner(
          name: _name.text,
          email: _email.text,
          password: _password.text,
        );
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const BusinessFormScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Regístrate para dar a conocer tu emprendimiento.',
              style: TextStyle(color: AppColors.gris)),
          const SizedBox(height: 20),
          Form(
            key: _formKey,
            child: Column(
              children: [
                AppTextField(
                    controller: _name,
                    label: 'Nombre completo',
                    validator: Validators.required),
                AppTextField(
                  controller: _email,
                  label: 'Correo electrónico',
                  keyboardType: TextInputType.emailAddress,
                  validator: Validators.email,
                ),
                AppTextField(
                  controller: _password,
                  label: 'Contraseña',
                  hint: 'Mínimo 6 caracteres',
                  obscure: true,
                  validator: Validators.password,
                ),
                AppTextField(
                  controller: _confirm,
                  label: 'Confirmar contraseña',
                  obscure: true,
                  validator: (v) =>
                      v != _password.text ? 'Las contraseñas no coinciden' : null,
                ),
              ],
            ),
          ),
          PrimaryButton(label: 'Continuar', onPressed: _submit),
        ],
      ),
    );
  }
}
