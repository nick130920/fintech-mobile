import 'package:flutter/material.dart';

import '../../../../shared/widgets/custom_snackbar.dart';
import '../../data/repositories/auth_repository.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({super.key});

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  final _requestFormKey = GlobalKey<FormState>();
  final _resetFormKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _tokenController = TextEditingController();
  final _newPasswordController = TextEditingController();
  bool _isLoading = false;
  bool _requestCompleted = false;

  @override
  void dispose() {
    _emailController.dispose();
    _tokenController.dispose();
    _newPasswordController.dispose();
    super.dispose();
  }

  Future<void> _submitEmailRequest() async {
    if (!_requestFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthRepository.requestPasswordReset(_emailController.text.trim());
      if (!mounted) return;
      setState(() => _requestCompleted = true);
      CustomSnackBar.showSuccess(
        context,
        'Revisa tu correo y usa el token para restablecer tu contraseña.',
      );
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.showError(context, 'No se pudo iniciar la recuperación: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submitPasswordReset() async {
    if (!_resetFormKey.currentState!.validate()) return;
    setState(() => _isLoading = true);
    try {
      await AuthRepository.resetPassword(
        token: _tokenController.text.trim(),
        newPassword: _newPasswordController.text.trim(),
      );
      if (!mounted) return;
      CustomSnackBar.showSuccess(context, 'Contraseña actualizada correctamente');
      Navigator.of(context).pop();
    } catch (e) {
      if (!mounted) return;
      CustomSnackBar.showError(context, 'No se pudo restablecer la contraseña: $e');
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      appBar: AppBar(
        title: const Text('Recuperar contraseña'),
        backgroundColor: Theme.of(context).colorScheme.surface.withValues(alpha: 0),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Paso 1: Solicitar token',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Ingresa tu correo y te enviaremos un token temporal.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _requestFormKey,
              child: TextFormField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: InputDecoration(
                  labelText: 'Correo electrónico',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                validator: (value) {
                  if (value == null || value.trim().isEmpty) return 'Ingresa tu correo';
                  if (!value.contains('@')) return 'Correo inválido';
                  return null;
                },
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitEmailRequest,
                child: Text(_isLoading ? 'Enviando...' : 'Solicitar token'),
              ),
            ),
            const SizedBox(height: 32),
            Text(
              'Paso 2: Restablecer contraseña',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _requestCompleted
                  ? 'Token enviado. Ingresa el token y tu nueva contraseña.'
                  : 'Cuando tengas el token, completa el siguiente formulario.',
              style: TextStyle(
                color: Theme.of(context).colorScheme.onSurface.withValues(alpha: 0.7),
              ),
            ),
            const SizedBox(height: 16),
            Form(
              key: _resetFormKey,
              child: Column(
                children: [
                  TextFormField(
                    controller: _tokenController,
                    decoration: InputDecoration(
                      labelText: 'Token de recuperación',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.trim().isEmpty) return 'Ingresa el token';
                      return null;
                    },
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _newPasswordController,
                    obscureText: true,
                    decoration: InputDecoration(
                      labelText: 'Nueva contraseña',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    validator: (value) {
                      if (value == null || value.length < 8) {
                        return 'Debe tener al menos 8 caracteres';
                      }
                      return null;
                    },
                  ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _isLoading ? null : _submitPasswordReset,
                child: Text(_isLoading ? 'Procesando...' : 'Restablecer contraseña'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
