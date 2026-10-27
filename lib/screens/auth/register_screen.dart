import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../models/business.dart';
import '../../state/app_state.dart';
import '../../theme/app_theme.dart';
import '../../widgets/app_text_field.dart';
import '../../widgets/common.dart';
import '../client/client_shell.dart';
import '../entrepreneur/business_form_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _email = TextEditingController();
  final _password = TextEditingController();
  final _confirm = TextEditingController();
  UserRole _role = UserRole.cliente;

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
          role: _role,
        );
    if (error != null) {
      showMessage(context, error, error: true);
      return;
    }
    if (_role == UserRole.emprendedor) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const BusinessFormScreen()),
      );
    } else {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (_) => const ClientShell()),
        (route) => route.isFirst,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Crear cuenta')),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          const Text('Tipo de cuenta',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
          const SizedBox(height: 8),
          Wrap(
            spacing: 8,
            children: [
              ChoiceChip(
                label: const Text('Cliente'),
                selected: _role == UserRole.cliente,
                showCheckmark: false,
                onSelected: (_) => setState(() => _role = UserRole.cliente),
              ),
              ChoiceChip(
                label: const Text('Emprendedor'),
                selected: _role == UserRole.emprendedor,
                showCheckmark: false,
                onSelected: (_) => setState(() => _role = UserRole.emprendedor),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            _role == UserRole.cliente
                ? 'Descubre y califica emprendimientos.'
                : 'Registra y administra tu emprendimiento.',
            style: const TextStyle(color: AppColors.gris, fontSize: 13),
          ),
          const SizedBox(height: 18),
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
          PrimaryButton(label: 'Registrarme', onPressed: _submit),
        ],
      ),
    );
  }
}
