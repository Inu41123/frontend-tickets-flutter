import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart';

class UpdatePasswordScreen extends StatefulWidget {
  final String email;
  final String codigo;

  const UpdatePasswordScreen({
    Key? key, 
    required this.email, 
    required this.codigo
  }) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> with SingleTickerProviderStateMixin {
  bool _showPass1 = false;
  bool _showPass2 = false;
  bool _isUpdating = false;

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

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
    _passController.dispose();
    _confirmPassController.dispose();
    super.dispose();
  }

  Future<void> _actualizarPassword() async {
    final newPassword = _passController.text;
    final confirmPassword = _confirmPassController.text;

    // Validación: contraseña vacía
    if (newPassword.isEmpty || confirmPassword.isEmpty) {
      await _shakeFields();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa tu nueva contraseña'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    // Validación: contraseñas no coinciden
    if (newPassword != confirmPassword) {
      await _shakeFields();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    // Validación: longitud mínima
    if (newPassword.length < 8) {
      await _shakeFields();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('La contraseña debe tener al menos 8 caracteres'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final response = await http.post(
        Uri.parse('https://backend-tickets-flutter.onrender.com/usuarios/restablecer-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': widget.email,
          'codigo': widget.codigo,
          'nuevaPassword': newPassword
        }),
      );

      setState(() => _isUpdating = false);

      if (response.statusCode == 200) {
        if (mounted) {
          await _showSuccessAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Contraseña actualizada con éxito!'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
          );
          Navigator.pushAndRemoveUntil(
            context, 
            MaterialPageRoute(builder: (context) => const LoginScreen()), 
            (route) => false
          );
        }
      } else {
        final error = jsonDecode(response.body);
        await _shakeFields();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error al actualizar'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isUpdating = false);
      await _shakeFields();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Animación de shake para feedback de error
  Future<void> _shakeFields() async {
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {});
      }
    }
  }

  // Animación de éxito
  Future<void> _showSuccessAnimation() async {
    await Future.delayed(const Duration(milliseconds: 200));
  }

  // Botón animado reutilizable
  Widget _buildAnimatedButton({
    required VoidCallback? onPressed,
    required String text,
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
              boxShadow: !isLoading
                  ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4))]
                  : null,
            ),
            child: ElevatedButton(
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
              child: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 28),
            ),
          ),
        );
      },
    );
  }

  // Campo de texto animado
  Widget _buildAnimatedTextField({
    required String label,
    required IconData? suffixIcon,
    required bool obscureText,
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
        suffixIcon: suffixIcon,
        obscureText: obscureText,
        controller: controller,
        //onSuffixTap: onSuffixTap,
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
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              // Engranajes superiores con animación de rotación
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
                          padding: const EdgeInsets.only(top: 40.0),
                          child: Image.asset('assets/images/engrane_izq.png', width: 120),
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
                        child: Image.asset('assets/images/engrane_der.png', width: 160),
                      );
                    },
                  ),
                ],
              ),

              // Contenido central
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Column(
                  children: [
                    // Header con botón de regreso y título
                    Row(
                      children: [
                        _buildAnimatedBackButton(),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TweenAnimationBuilder(
                            duration: const Duration(milliseconds: 400),
                            tween: Tween<double>(begin: 0, end: 1),
                            builder: (context, double opacity, child) {
                              return Opacity(opacity: opacity, child: child);
                            },
                            child: const Text(
                              'Actualizar contraseña',
                              style: TextStyle(
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                color: AppTheme.primaryColor,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                        const SizedBox(width: 48), // Espaciador para centrar
                      ],
                    ),
                    const SizedBox(height: 30),

                    // Texto de ayuda informativo
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double opacity, child) {
                        return Opacity(opacity: opacity, child: child);
                      },
                      child: Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppTheme.inputColor,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Text(
                          'La contraseña debe tener al menos 8 caracteres',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30),

                    // Campo Contraseña nueva
                    _buildAnimatedTextField(
                      label: 'Contraseña nueva',
                      suffixIcon: _showPass1 ? Icons.visibility : Icons.visibility_off,
                      obscureText: !_showPass1,
                      controller: _passController,
                      delay: 0,
                      onSuffixTap: () {
                        setState(() => _showPass1 = !_showPass1);
                      },
                    ),
                    const SizedBox(height: 20),

                    // Campo Confirmar contraseña
                    _buildAnimatedTextField(
                      label: 'Confirmar contraseña',
                      suffixIcon: _showPass2 ? Icons.visibility : Icons.visibility_off,
                      obscureText: !_showPass2,
                      controller: _confirmPassController,
                      delay: 100,
                      onSuffixTap: () {
                        setState(() => _showPass2 = !_showPass2);
                      },
                    ),
                    const SizedBox(height: 30),

                    // Botón Actualizar
                    _buildAnimatedButton(
                      onPressed: _isUpdating ? null : _actualizarPassword,
                      text: 'Actualizar',
                      isLoading: _isUpdating,
                    ),
                  ],
                ),
              ),

              // Engranaje inferior derecho
              TweenAnimationBuilder(
                duration: const Duration(seconds: 30),
                tween: Tween<double>(begin: 0, end: 360),
                builder: (context, double angle, child) {
                  return Transform.rotate(
                    angle: angle * 3.14159 / 180 * 0.1,
                    child: Align(
                      alignment: Alignment.bottomRight,
                      child: Image.asset('assets/images/en_login_abajo.png', width: 150),
                    ),
                  );
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}