import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'verification_code_screen.dart';

class ForgotPasswordScreen extends StatefulWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  State<ForgotPasswordScreen> createState() => _ForgotPasswordScreenState();
}

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> with SingleTickerProviderStateMixin {
  // 1. Controlador para atrapar el correo que escriba el usuario
  final TextEditingController _emailController = TextEditingController();
  
  // Estado de carga
  bool _isSending = false;
  
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
    _emailController.dispose();
    super.dispose();
  }

  // 2. Función para pedirle el código al backend
  Future<void> _pedirCodigo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      await _shakeField();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa tu correo'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    setState(() => _isSending = true);

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/solicitar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email}),
      );

      setState(() => _isSending = false);

      if (response.statusCode == 200) {
        if (mounted) {
          await _showSuccessAnimation();
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código enviado a tu correo'), backgroundColor: Colors.green, duration: Duration(seconds: 2)),
          );
          
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => VerificationCodeScreen(
              email: email,
              isForRegistration: false,
            ))
          );
        }
      } else {
        final error = jsonDecode(response.body);
        await _shakeField();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error al enviar código'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isSending = false);
      await _shakeField();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Animación de shake para feedback de error
  Future<void> _shakeField() async {
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
  Widget _buildAnimatedTextField() {
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
      child: CustomAuthTextField(
        label: 'Correo electrónico',
        prefixIcon: Icons.person_outline,
        keyboardType: TextInputType.emailAddress,
        controller: _emailController,
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
                          child: Image.asset('assets/images/engrane_izq.png', width: 140),
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
                    // Header con botón de regreso
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
                              'Recuperar contraseña',
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
                    const SizedBox(height: 20),

                    // Texto descriptivo con animación
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double opacity, child) {
                        return Opacity(opacity: opacity, child: child);
                      },
                      child: const Text(
                        '¡Olvidaste tu contraseña! No te preocupes\nIngresa tu Email y te ayudaremos\ncon un código de verificación',
                        textAlign: TextAlign.center,
                        style: TextStyle(color: AppTheme.textBodyColor, fontSize: 14, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Campo de correo electrónico
                    _buildAnimatedTextField(),
                    const SizedBox(height: 30),
                    
                    // Botón Enviar
                    _buildAnimatedButton(
                      onPressed: _isSending ? null : _pedirCodigo,
                      text: 'Enviar',
                      isLoading: _isSending,
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