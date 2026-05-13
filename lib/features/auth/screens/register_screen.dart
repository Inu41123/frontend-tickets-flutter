import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'verification_code_screen.dart';
import '../services/google_auth_service.dart';
import '../../tickets/screens/home_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> with SingleTickerProviderStateMixin {
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // 1. Controladores para capturar el texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // Estados de carga
  bool _isRegistering = false;
  bool _isGoogleRegistering = false;

  // Controladores de animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    // Configurar animaciones de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nombreController.dispose();
    _apellidosController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    super.dispose();
  }

  // 2. Función para mandar los datos al backend
  Future<void> _hacerRegistro() async {
    // Validación rápida: que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      await _showShakeAnimation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    // Validación de campos vacíos
    if (_nombreController.text.trim().isEmpty ||
        _apellidosController.text.trim().isEmpty ||
        _emailController.text.trim().isEmpty ||
        _passwordController.text.isEmpty) {
      await _showShakeAnimation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor, llena todos los campos'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    setState(() => _isRegistering = true);

    try {
      String nombreCompleto = '${_nombreController.text.trim()} ${_apellidosController.text.trim()}';

      final response = await http.post(
        Uri.parse('https://backend-tickets-flutter.onrender.com/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreCompleto': nombreCompleto,
          'correo': _emailController.text.trim(),
          'password': _passwordController.text
        }),
      );

      setState(() => _isRegistering = false);

      if (response.statusCode == 201) {
        if (mounted) {
          // Animación de éxito antes de navegar
          await _showSuccessAnimation();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Cuenta creada! Revisa tu correo'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
            );
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => VerificationCodeScreen(
                email: _emailController.text.trim(),
                isForRegistration: true,
              )),
            );
          }
        }
      } else {
        final error = jsonDecode(response.body);
        await _showShakeAnimation();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error al registrar'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isRegistering = false);
      print("Error de conexión: $e");
      await _showShakeAnimation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Animación de shake para feedback de error
  Future<void> _showShakeAnimation() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Animación de éxito
  Future<void> _showSuccessAnimation() async {
    // Pequeña vibración visual (opcional)
    await Future.delayed(const Duration(milliseconds: 100));
  }

  // Botón animado reutilizable
  Widget _buildAnimatedButton({
    required VoidCallback? onPressed,
    required String text,
    bool isOutlined = false,
    bool isLoading = false,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1, end: 1),
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            width: isLoading ? 60 : MediaQuery.of(context).size.width,
            height: 50,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(isLoading ? 30 : 12),
              boxShadow: !isOutlined && !isLoading
                  ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  : null,
            ),
            child: isOutlined
                ? OutlinedButton(
                    onPressed: isLoading ? null : onPressed,
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                          )
                        : Text(text, style: const TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.w600)),
                  )
                : ElevatedButton(
                    onPressed: isLoading ? null : onPressed,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(isLoading ? 30 : 12)),
                    ),
                    child: isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(strokeWidth: 2.5, valueColor: AlwaysStoppedAnimation<Color>(Colors.white)),
                          )
                        : Text(text, style: const TextStyle(fontSize: 16)),
                  ),
          ),
        );
      },
    );
  }

  // Botón social animado
  Widget _buildAnimatedSocialButton({
    required VoidCallback? onTap,
    required String assetPath,
    required bool isLoading,
  }) {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1, end: 1),
      builder: (context, double scale, child) {
        return GestureDetector(
          onTap: onTap,
          child: Transform.scale(
            scale: scale,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: isLoading ? 50 : 50,
              height: isLoading ? 50 : 50,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: isLoading
                  ? const Center(
                      child: SizedBox(
                        width: 24,
                        height: 24,
                        child: CircularProgressIndicator(strokeWidth: 2, color: AppTheme.primaryColor),
                      ),
                    )
                  : Image.asset(assetPath, height: 30),
            ),
          ),
        );
      },
    );
  }

  // Campo de texto animado
  Widget _buildAnimatedTextField({
    required String label,
    IconData? prefixIcon,
    IconData? suffixIcon,
    bool obscureText = false,
    TextInputType keyboardType = TextInputType.text,
    required TextEditingController controller,
    int delay = 0,
    VoidCallback? onSuffixTap,
  }) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 400 + delay),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: CustomAuthTextField(
        label: label,
        prefixIcon: prefixIcon,
        suffixIcon: suffixIcon,
        obscureText: obscureText,
        keyboardType: keyboardType,
        controller: controller,
        onSuffixTap: onSuffixTap
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FadeTransition(
        opacity: _fadeAnimation,
        child: SlideTransition(
          position: _slideAnimation,
          child: SingleChildScrollView(
            child: Column(
              children: [
                // Los engranajes con animación de rotación suave
                Row(
  mainAxisAlignment: MainAxisAlignment.spaceBetween,
  crossAxisAlignment: CrossAxisAlignment.start,
  children: [
    Padding(
      padding: const EdgeInsets.only(top: 40.0),
      child: Image.asset(
        'assets/images/engrane_izq.png',
        width: 100,
      ),
    ),

    Padding(
      padding: const EdgeInsets.only(top: 20.0),
      child: Image.asset(
        'assets/images/engrane_der.png',
        width: 220,
      ),
    ),
  ],
),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30.0),
                  child: Column(
                    children: [
                      // Header con botón de regreso animado
                      Row(
                        children: [
                          _buildAnimatedBackButton(),
                          const Expanded(
                            child: Text(
                              'Crear cuenta',
                              style: TextStyle(
                                fontSize: 32,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Fila de Nombre y Apellidos
                      Row(
                        children: [
                          Expanded(
                            child: _buildAnimatedTextField(
                              label: 'Nombre',
                              controller: _nombreController,
                              delay: 0,
                            ),
                          ),
                          const SizedBox(width: 15),
                          Expanded(
                            child: _buildAnimatedTextField(
                              label: 'Apellidos',
                              controller: _apellidosController,
                              delay: 50,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 15),

                      // Campo Correo electrónico
                      _buildAnimatedTextField(
                        label: 'Correo electrónico',
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        delay: 100,
                      ),
                      const SizedBox(height: 15),

                      // Campo Contraseña
                      _buildAnimatedTextField(
                        label: 'Contraseña',
                        suffixIcon: _showPassword ? Icons.visibility : Icons.visibility_off,
                        obscureText: !_showPassword,
                        controller: _passwordController,
                        delay: 150,
                        onSuffixTap: () {
                          setState(() => _showPassword = !_showPassword);
                        },
                      ),
                      const SizedBox(height: 15),

                      // Campo Confirmar contraseña
                      _buildAnimatedTextField(
                        label: 'Confirmar contraseña',
                        suffixIcon: _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                        obscureText: !_showConfirmPassword,
                        controller: _confirmPasswordController,
                        delay: 200,
                        onSuffixTap: () {
                          setState(() => _showConfirmPassword = !_showConfirmPassword);
                        },
                      ),
                      const SizedBox(height: 10),

                      // Texto de ayuda con animación
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double opacity, child) {
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: const Align(
                          alignment: Alignment.centerLeft,
                          child: Text(
                            'La contraseña debe de tener al menos 8 caracteres',
                            style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón Crear cuenta
                      _buildAnimatedButton(
                        onPressed: _isRegistering ? null : _hacerRegistro,
                        text: 'Crear cuenta',
                        isLoading: _isRegistering,
                      ),
                      const SizedBox(height: 30),

                      // Texto "Iniciar sesión con:" con animación
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 500),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double opacity, child) {
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: const Text('Iniciar sesión con:', style: TextStyle(color: AppTheme.textBodyColor)),
                      ),
                      const SizedBox(height: 15),

                      // Botones sociales
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimatedSocialButton(
                            onTap: _isGoogleRegistering ? null : () async {
                              setState(() => _isGoogleRegistering = true);
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Conectando con Google...'), duration: Duration(seconds: 1)),
                              );

                              bool exito = await GoogleAuthService().signInWithGoogle();

                              if (exito && mounted) {
                                await _animationController.reverse();
                                if (mounted) {
                                  Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
                                }
                              } else if (mounted) {
                                setState(() => _isGoogleRegistering = false);
                                await _showShakeAnimation();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error al iniciar sesión con Google'), backgroundColor: Colors.red),
                                );
                              }
                            },
                            assetPath: 'assets/logos/google_logo.png',
                            isLoading: _isGoogleRegistering,
                          ),
                          const SizedBox(width: 30),

                          _buildAnimatedSocialButton(
                            onTap: () {
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Próximamente'),
                                  content: const Text('El inicio de sesión con Facebook estará disponible en versiones futuras.'),
                                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context),
                                      child: const Text('Aceptar'),
                                    ),
                                  ],
                                ),
                              );
                            },
                            assetPath: 'assets/logos/facebook_logo.png',
                            isLoading: false,
                          ),
                        ],
                      ),
                      const SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // Botón de regreso animado
  Widget _buildAnimatedBackButton() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 200),
      tween: Tween<double>(begin: 1, end: 1),
      builder: (context, double scale, child) {
        return GestureDetector(
          onTapDown: (_) => setState(() {}),
          onTapUp: (_) {
            setState(() {});
            Navigator.pop(context);
          },
          child: Transform.scale(
            scale: scale,
            child: Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 8,
                    offset: const Offset(0, 2),
                  ),
                ],
              ),
              child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 30),
            ),
          ),
        );
      },
    );
  }
}