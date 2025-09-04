import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../shared/widgets/custom_button.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'login_screen.dart';

class RegisterScreen extends StatefulWidget {
  final VoidCallback? onRegisterSuccess;

  const RegisterScreen({super.key, this.onRegisterSuccess});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _firstNameController = TextEditingController();
  final _lastNameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  String? _validateFirstName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El nombre es requerido';
    }
    if (value.length < 2) {
      return 'El nombre debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateLastName(String? value) {
    if (value == null || value.isEmpty) {
      return 'El apellido es requerido';
    }
    if (value.length < 2) {
      return 'El apellido debe tener al menos 2 caracteres';
    }
    return null;
  }

  String? _validateEmail(String? value) {
    if (value == null || value.isEmpty) {
      return 'El email es requerido';
    }
    final emailRegex = RegExp(r'^[^@]+@[^@]+\.[^@]+');
    if (!emailRegex.hasMatch(value)) {
      return 'Ingresa un email válido';
    }
    return null;
  }

  String? _validatePassword(String? value) {
    if (value == null || value.isEmpty) {
      return 'La contraseña es requerida';
    }
    if (value.length < 6) {
      return 'La contraseña debe tener al menos 6 caracteres';
    }
    return null;
  }

  void _handleCreateAccount() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.register(
          firstName: _firstNameController.text.trim(),
          lastName: _lastNameController.text.trim(),
          email: _emailController.text.trim(),
          password: _passwordController.text,
        );

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          // Si hay un callback, ejecutarlo y navegar de vuelta
          widget.onRegisterSuccess?.call();
          Navigator.of(context).pop(); // Cerrar pantalla de register
        } else if (mounted) {
          // Mostrar error
          CustomSnackBar.showError(
            context,
            authProvider.errorMessage ?? 'Error en el registro',
          );
        }
      } catch (e) {
        setState(() {
          _isLoading = false;
        });
        
        if (mounted) {
          CustomSnackBar.showError(
            context,
            'Error inesperado: $e',
          );
        }
      }
    }
  }

  void _navigateToLogin() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const LoginScreen()),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header
            _buildHeader(),
            
            // Main content
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 32),
                child: _buildMainContent(),
              ),
            ),
            
            // Footer
            _buildFooter(),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Back button
          IconButton(
            onPressed: _navigateBack,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              fixedSize: const Size(40, 40),
            ),
          ),
          
          // Login link
          TextButton(
            onPressed: _navigateToLogin,
            child: Text(
              'Iniciar Sesión',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMainContent() {
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 384), // max-w-sm equivalent
        child: Column(
          children: [
            // Logo/Icon
            _buildLogo(),
            
            const SizedBox(height: 32),
            
            // Title and subtitle
            _buildTitleSection(),
            
            const SizedBox(height: 32),
            
            // Form
            _buildForm(),
            
            const SizedBox(height: 24),
            
            // Legal text
            _buildLegalText(),
          ],
        ),
      ),
    );
  }

  Widget _buildLogo() {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(48),
      ),
      child: const Center(
        child: Text(
          '💸',
          style: TextStyle(fontSize: 64),
        ),
      ),
    );
  }

  Widget _buildTitleSection() {
    return Column(
      children: [
        Text(
          'Crea tu Cuenta',
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                fontWeight: FontWeight.w700,
                fontSize: 28,
              ),
          textAlign: TextAlign.center,
        ),
        const SizedBox(height: 8),
        Text(
          'Comienza a gestionar tus finanzas con MoneyFlow.',
          style: Theme.of(context).textTheme.bodyMedium,
          textAlign: TextAlign.center,
        ),
      ],
    );
  }

  Widget _buildForm() {
    return Form(
      key: _formKey,
      child: Column(
        children: [
          // First Name field
          CustomTextField(
            label: 'Nombre',
            placeholder: 'e.g. Juan',
            prefixIcon: Icons.person_outline,
            controller: _firstNameController,
            validator: _validateFirstName,
          ),
          
          const SizedBox(height: 16),
          
          // Last Name field
          CustomTextField(
            label: 'Apellido',
            placeholder: 'e.g. Pérez',
            prefixIcon: Icons.person_outline,
            controller: _lastNameController,
            validator: _validateLastName,
          ),
          
          const SizedBox(height: 16),
          
          // Email field
          CustomTextField(
            label: 'Dirección de Email',
            placeholder: 'tucorreo@ejemplo.com',
            prefixIcon: Icons.email_outlined,
            keyboardType: TextInputType.emailAddress,
            controller: _emailController,
            validator: _validateEmail,
          ),
          
          const SizedBox(height: 16),
          
          // Password field
          CustomTextField(
            label: 'Contraseña',
            placeholder: '••••••••',
            prefixIcon: Icons.lock_outline,
            obscureText: true,
            showToggleVisibility: true,
            controller: _passwordController,
            validator: _validatePassword,
          ),
          
          const SizedBox(height: 24),
          
          // Create Account button
          CustomButton(
            text: 'Crear Cuenta',
            onPressed: _handleCreateAccount,
            isLoading: _isLoading,
          ),
        ],
      ),
    );
  }

  Widget _buildLegalText() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: RichText(
        textAlign: TextAlign.center,
        text: TextSpan(
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                fontSize: 12,
              ),
          children: [
            const TextSpan(text: 'Al crear una cuenta, aceptas nuestros '),
            TextSpan(
              text: 'Términos de Servicio',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: ' y '),
            TextSpan(
              text: 'Política de Privacidad',
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                decoration: TextDecoration.underline,
              ),
            ),
            const TextSpan(text: '.'),
          ],
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Center(
        child: RichText(
          textAlign: TextAlign.center,
          text: TextSpan(
            style: Theme.of(context).textTheme.bodySmall,
            children: [
              const TextSpan(text: '¿Necesitas ayuda? '),
              TextSpan(
                text: 'Contáctanos',
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                  decoration: TextDecoration.underline,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
