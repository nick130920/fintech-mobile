import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../core/services/biometric_service.dart';
import '../../../../core/services/storage_service.dart';
import '../../../../shared/widgets/custom_snackbar.dart';
import '../../../../shared/widgets/custom_text_field.dart';
import '../providers/auth_provider.dart';
import 'register_screen.dart';

class LoginScreen extends StatefulWidget {
  final VoidCallback? onLoginSuccess;

  const LoginScreen({super.key, this.onLoginSuccess});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _formKey = GlobalKey<FormState>();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  bool _isLoading = false;
  bool _isBiometricAvailable = false;
  bool _enableBiometric = false;
  String _biometricType = 'Huella dactilar';

  @override
  void initState() {
    super.initState();
    _checkBiometricAvailability();
    _loadSavedEmail();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  Future<void> _checkBiometricAvailability() async {
    final isAvailable = await BiometricService.isBiometricAvailable();
    final biometricType = await BiometricService.getBiometricTypeDescription();
    
    if (mounted) {
      setState(() {
        _isBiometricAvailable = isAvailable;
        _biometricType = biometricType;
      });
    }
  }

  Future<void> _loadSavedEmail() async {
    final savedEmail = await StorageService.getSavedEmail();
    final isBiometricEnabled = await StorageService.isBiometricEnabled();
    
    if (mounted && savedEmail != null) {
      setState(() {
        _emailController.text = savedEmail;
        _enableBiometric = isBiometricEnabled;
      });
    }
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

  void _handleLogin() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
      });

      final authProvider = Provider.of<AuthProvider>(context, listen: false);

      try {
        final success = await authProvider.login(
          email: _emailController.text.trim(),
          password: _passwordController.text,
          saveBiometricCredentials: _enableBiometric,
        );

        setState(() {
          _isLoading = false;
        });

        if (success && mounted) {
          // Si hay un callback, ejecutarlo y navegar de vuelta
          widget.onLoginSuccess?.call();
          Navigator.of(context).pop(); // Cerrar pantalla de login
        } else if (mounted) {
          // Mostrar error
          CustomSnackBar.showError(
            context,
            authProvider.errorMessage ?? 'Error en el login',
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

  void _handleBiometricLogin() async {
    setState(() {
      _isLoading = true;
    });

    final authProvider = Provider.of<AuthProvider>(context, listen: false);

    try {
      final success = await authProvider.loginWithBiometric();

      setState(() {
        _isLoading = false;
      });

      if (success && mounted) {
        // Si hay un callback, ejecutarlo y navegar de vuelta
        widget.onLoginSuccess?.call();
        Navigator.of(context).pop(); // Cerrar pantalla de login
      } else if (mounted) {
        // Mostrar error
        CustomSnackBar.showError(
          context,
          authProvider.errorMessage ?? 'Error en la autenticación biométrica',
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

  void _navigateToRegister() {
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(builder: (context) => const RegisterScreen()),
    );
  }

  void _navigateBack() {
    Navigator.of(context).pop();
  }

  void _handleForgotPassword() {
    // TODO: Implementar forgot password
    CustomSnackBar.showWarning(
      context,
      'Funcionalidad de recuperar contraseña próximamente',
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // Header con botón de back
            _buildHeader(),
            
            // Content principal
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    // Título y subtítulo
                    _buildTitleSection(),
                    
                    // Form
                    _buildForm(),
                  ],
                ),
              ),
            ),
            
            // Footer con botón y link
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
        children: [
          IconButton(
            onPressed: _navigateBack,
            icon: const Icon(Icons.arrow_back),
            style: IconButton.styleFrom(
              backgroundColor: Colors.transparent,
              foregroundColor: Theme.of(context).colorScheme.onSurface,
              iconSize: 24,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildTitleSection() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 40),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
                     SizedBox(
             width: double.infinity,
             child: Text(
               '¡Bienvenido de nuevo!',
               style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                     fontWeight: FontWeight.w700,
                     fontSize: 32,
                     height: 1.1,
                     letterSpacing: -0.5,
                   ),
             ),
           ),
           const SizedBox(height: 8),
           SizedBox(
             width: double.infinity,
             child: Text(
               'Inicia sesión en tu cuenta de MoneyFlow.',
               style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                     fontSize: 16,
                   ),
             ),
           ),
        ],
      ),
    );
  }

  Widget _buildForm() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Form(
        key: _formKey,
        child: Column(
          children: [
            // Email field
            _buildEmailField(),
            
            const SizedBox(height: 16),
            
            // Password field
            _buildPasswordField(),
            
            const SizedBox(height: 8),
            
            // Biometric checkbox (si está disponible)
            if (_isBiometricAvailable) _buildBiometricCheckbox(),
            
            const SizedBox(height: 8),
            
            // Forgot password link
            _buildForgotPasswordLink(),
            
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildBiometricCheckbox() {
    return CheckboxListTile(
      value: _enableBiometric,
      onChanged: (value) {
        setState(() {
          _enableBiometric = value ?? false;
        });
      },
      title: Text(
        'Habilitar inicio con $_biometricType',
        style: TextStyle(
          fontSize: 14,
          color: Theme.of(context).colorScheme.onSurface,
        ),
      ),
      contentPadding: EdgeInsets.zero,
      controlAffinity: ListTileControlAffinity.leading,
      dense: true,
      activeColor: Theme.of(context).colorScheme.primary,
    );
  }

  Widget _buildEmailField() {
    return CustomTextField(
      label: 'Email o Usuario',
      placeholder: 'tucorreo@ejemplo.com',
      prefixIcon: Icons.email_outlined,
      keyboardType: TextInputType.emailAddress,
      controller: _emailController,
      validator: _validateEmail,
    );
  }

  Widget _buildPasswordField() {
    return CustomTextField(
      label: 'Contraseña',
      placeholder: '••••••••',
      prefixIcon: Icons.lock_outline,
      obscureText: true,
      showToggleVisibility: true,
      controller: _passwordController,
      validator: _validatePassword,
    );
  }

  Widget _buildForgotPasswordLink() {
    return Align(
      alignment: Alignment.centerRight,
      child: TextButton(
        onPressed: _handleForgotPassword,
                 child: Text(
           '¿Olvidaste tu contraseña?',
          style: Theme.of(context).textTheme.bodySmall?.copyWith(
                color: Theme.of(context).colorScheme.primary,
                fontWeight: FontWeight.w500,
                fontSize: 14,
              ),
        ),
      ),
    );
  }

  Widget _buildFooter() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          // Login button
          SizedBox(
            width: double.infinity,
            height: 56,
            child: ElevatedButton(
              onPressed: _isLoading ? null : _handleLogin,
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    )
                  : const Text('Iniciar Sesión'),
            ),
          ),
          
          // Biometric login button (si está disponible y habilitado)
          if (_isBiometricAvailable && _enableBiometric) ...[
            const SizedBox(height: 16),
            _buildBiometricButton(),
          ],
          
          const SizedBox(height: 16),
          
          // Sign up link
          RichText(
            textAlign: TextAlign.center,
            text: TextSpan(
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    fontSize: 14,
                  ),
              children: [
                const TextSpan(text: "¿No tienes cuenta? "),
                WidgetSpan(
                  child: GestureDetector(
                    onTap: _navigateToRegister,
                    child: Text(
                      'Registrarse',
                      style: TextStyle(
                        color: Theme.of(context).colorScheme.primary,
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBiometricButton() {
    return SizedBox(
      width: double.infinity,
      height: 56,
      child: OutlinedButton.icon(
        onPressed: _isLoading ? null : _handleBiometricLogin,
        icon: Icon(
          Icons.fingerprint,
          size: 28,
          color: Theme.of(context).colorScheme.primary,
        ),
        label: Text(
          'Iniciar con $_biometricType',
          style: TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w600,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
        style: OutlinedButton.styleFrom(
          side: BorderSide(
            color: Theme.of(context).colorScheme.primary,
            width: 2,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
        ),
      ),
    );
  }
}
