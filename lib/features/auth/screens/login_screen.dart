import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart';
import '../../tickets/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';
import '../services/google_auth_service.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> with SingleTickerProviderStateMixin {
  // Para manejar si se ve la contraseña (Pantalla 2 del diseño)
  bool _showPassword = false;

  // 1. Controladores para leer lo que escribe el usuario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // Estado de carga para el botón de login
  bool _isLoggingIn = false;
  bool _isGoogleLoggingIn = false;

  // Controladores de animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    // Configurar animaciones de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );

    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );

    _scaleAnimation = Tween<double>(begin: 0.95, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutBack),
    );

    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  // 2. Función para conectarse al backend
  Future<void> _hacerLogin() async {
    if (_emailController.text.trim().isEmpty || _passwordController.text.isEmpty) {
      await _showShakeAnimation();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Por favor, ingresa tu correo y contraseña'),
            backgroundColor: Colors.orange,
            duration: Duration(milliseconds: 1500),
          ),
        );
      }
      return;
    }

    setState(() => _isLoggingIn = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _emailController.text.trim(),
          'password': _passwordController.text
        }),
      );

      print("======= RESPUESTA DEL SERVIDOR =======");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");
      print("======================================");

      if (response.body.startsWith('<!DOCTYPE html>') || response.body.startsWith('<html')) {
        setState(() => _isLoggingIn = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error del servidor: Devolvió HTML en lugar de JSON. Revisa la consola.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return;
      }

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Token recibido: ${data['token']}");

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);

        if (mounted) {
          // Animación de salida antes de navegar
          await _animationController.reverse();
          if (mounted) {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => const HomeScreen()),
            );
          }
        }
      } else {
        setState(() => _isLoggingIn = false);
        final error = jsonDecode(response.body);
        if (mounted) {
          await _showShakeAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error al iniciar sesión'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoggingIn = false);
      print("Error de conexión interno: $e");
      if (mounted) {
        await _showShakeAnimation();
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor.'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Animación de shake para feedback de error
  Future<void> _showShakeAnimation() async {
    final scaffoldContext = context;
    // Efecto visual de shake (simulado con un breve delay y rebuild)
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Botón animado reutilizable
  Widget _buildAnimatedButton({
    required VoidCallback? onPressed,
    required String text,
    required bool isOutlined,
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
                // 1. LOS DOS ENGRANAJES (con animación de rotación suave)
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TweenAnimationBuilder(
                      duration: const Duration(seconds: 20),
                      tween: Tween<double>(begin: 0, end: 360),
                      builder: (context, double angle, child) {
                        return Transform.rotate(
                          angle: angle * 3.14159 / 180 * 0.3,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 50.0),
                            child: Image.asset('assets/images/engrane_izq.png', width: 100),
                          ),
                        );
                      },
                    ),
                    TweenAnimationBuilder(
                      duration: const Duration(seconds: 25),
                      tween: Tween<double>(begin: 0, end: 360),
                      builder: (context, double angle, child) {
                        return Transform.rotate(
                          angle: angle * 3.14159 / 180 * -0.2,
                          child: Padding(
                            padding: const EdgeInsets.only(top: 20.0),
                            child: Image.asset('assets/images/engrane_der.png', width: 220),
                          ),
                        );
                      },
                    ),
                  ],
                ),

                Padding(
                  padding: const EdgeInsets.all(30.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      // Texto "¡Bienvenido!" con animación de escala
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 600),
                        tween: Tween<double>(begin: 0.5, end: 1.0),
                        curve: Curves.elasticOut,
                        builder: (context, double scale, child) {
                          return Transform.scale(scale: scale, child: child);
                        },
                        child: Text(
                          '¡Bienvenido!',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                      ),
                      const SizedBox(height: 40),

                      // Campo de correo con animación
                      _buildAnimatedTextField(
                        label: 'Correo electrónico',
                        prefixIcon: Icons.person_outline,
                        keyboardType: TextInputType.emailAddress,
                        controller: _emailController,
                        delay: 100,
                      ),
                      const SizedBox(height: 35),

                      // Campo de contraseña con animación
                      _buildAnimatedPasswordField(),
                      const SizedBox(height: 10),

                      // Botón "¿Olvidaste tu contraseña?" con efecto hover
                      Align(
                        alignment: Alignment.centerRight,
                        child: TweenAnimationBuilder(
                          duration: const Duration(milliseconds: 300),
                          tween: Tween<double>(begin: 1, end: 1),
                          builder: (context, double scale, child) {
                            return Transform.scale(scale: scale, child: child);
                          },
                          child: TextButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(builder: (context) => const ForgotPasswordScreen()),
                              );
                            },
                            child: const Text(
                              '¿Olvidaste tu contraseña?',
                              style: TextStyle(color: AppTheme.primaryColor),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 30),

                      // Botón Iniciar sesión
                      _buildAnimatedButton(
                        onPressed: _isLoggingIn ? null : _hacerLogin,
                        text: 'Iniciar sesión',
                        isOutlined: false,
                        isLoading: _isLoggingIn,
                      ),
                      const SizedBox(height: 15),

                      // Botón Crear cuenta
                      _buildAnimatedButton(
                        onPressed: _isLoggingIn ? null : () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(builder: (context) => const RegisterScreen()),
                          );
                        },
                        text: 'Crear cuenta',
                        isOutlined: true,
                      ),
                      const SizedBox(height: 30),

                      // Texto "Iniciar sesión con:" con animación
                      TweenAnimationBuilder(
                        duration: const Duration(milliseconds: 400),
                        tween: Tween<double>(begin: 0, end: 1),
                        builder: (context, double opacity, child) {
                          return Opacity(opacity: opacity, child: child);
                        },
                        child: const Text('Iniciar sesión con:', style: TextStyle(color: AppTheme.textBodyColor)),
                      ),
                      const SizedBox(height: 15),

                      // Botones sociales con animaciones
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildAnimatedSocialButton(
                            onTap: _isGoogleLoggingIn ? null : () async {
                              setState(() => _isGoogleLoggingIn = true);
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
                                setState(() => _isGoogleLoggingIn = false);
                                await _showShakeAnimation();
                                ScaffoldMessenger.of(context).showSnackBar(
                                  const SnackBar(content: Text('Error al iniciar sesión con Google'), backgroundColor: Colors.red),
                                );
                              }
                            },
                            assetPath: 'assets/logos/google_logo.png',
                            isLoading: _isGoogleLoggingIn,
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

  // Campo de texto animado
  Widget _buildAnimatedTextField({
    required String label,
    required IconData prefixIcon,
    required TextInputType keyboardType,
    required TextEditingController controller,
    int delay = 0,
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
        keyboardType: keyboardType,
        controller: controller,
      ),
    );
  }

  // Campo de contraseña animado con toggle
  Widget _buildAnimatedPasswordField() {
    return TweenAnimationBuilder(
      duration: const Duration(milliseconds: 500),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOut,
      builder: (context, double value, child) {
        return Transform.translate(
          offset: Offset(0, 20 * (1 - value)),
          child: Opacity(opacity: value, child: child),
        );
      },
      child: StatefulBuilder(
        builder: (context, setStatePassword) {
          return GestureDetector(
            onTap: () => setStatePassword(() {}),
            child: CustomAuthTextField(
              label: 'Contraseña',
              prefixIcon: Icons.lock_outline,
              suffixIcon: _showPassword ? Icons.visibility : Icons.visibility_off,
              obscureText: !_showPassword,
              controller: _passwordController,
              //final VoidCallback? onSuffixTap
              
              // onSuffixTap: () {
              //  setState(() => _showPassword = !_showPassword);
              //},
            ),
          );
        },
      ),
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
}