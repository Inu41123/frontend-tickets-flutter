import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import 'update_password_screen.dart';
import 'login_screen.dart';

class VerificationCodeScreen extends StatefulWidget {
  final String email;
  final bool isForRegistration;

  const VerificationCodeScreen({
    Key? key, 
    required this.email, 
    required this.isForRegistration
  }) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> with SingleTickerProviderStateMixin {
  // 6 controladores para los 6 cuadritos
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());
  final List<FocusNode> _focusNodes = List.generate(6, (_) => FocusNode());
  
  // Estados de carga
  bool _isVerifying = false;
  bool _isResending = false;
  
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
    for (var controller in _controllers) {
      controller.dispose();
    }
    for (var focusNode in _focusNodes) {
      focusNode.dispose();
    }
    super.dispose();
  }

  Future<void> _enviarCodigo() async {
    String codigoIngresado = _controllers.map((c) => c.text).join();

    if (codigoIngresado.length < 6) {
      await _shakeCodeFields();
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Por favor ingresa los 6 dígitos'), backgroundColor: Colors.orange, duration: Duration(milliseconds: 1500)),
        );
      }
      return;
    }

    setState(() => _isVerifying = true);

    // FLUJO 1: SI VIENE DE CREAR CUENTA
    if (widget.isForRegistration) {
      try {
        final response = await http.post(
          Uri.parse('https://backend-tickets-flutter.onrender.com/usuarios/verificar-cuenta'),
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'correo': widget.email,
            'codigo': codigoIngresado
          }),
        );

        setState(() => _isVerifying = false);

        if (response.statusCode == 200) {
          if (mounted) {
            await _showSuccessAnimation();
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Cuenta verificada! Ya puedes iniciar sesión.'), backgroundColor: Colors.green),
            );
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const LoginScreen()), 
              (route) => false
            );
          }
        } else {
          final error = jsonDecode(response.body);
          await _shakeCodeFields();
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error['mensaje'] ?? 'Código incorrecto'), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        setState(() => _isVerifying = false);
        await _shakeCodeFields();
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
          );
        }
      }
    } 
    // FLUJO 2: SI VIENE DE OLVIDÉ MI CONTRASEÑA
    else {
      setState(() => _isVerifying = false);
      await _animationController.reverse();
      if (mounted) {
        Navigator.push(
          context, 
          MaterialPageRoute(builder: (context) => UpdatePasswordScreen(
            email: widget.email, 
            codigo: codigoIngresado
          ))
        );
      }
    }
  }

  Future<void> _reenviarCodigo() async {
    setState(() => _isResending = true);
    
    try {
      final response = await http.post(
        Uri.parse('https://backend-tickets-flutter.onrender.com/usuarios/reenviar-codigo'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': widget.email,
        }),
      );

      setState(() => _isResending = false);

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código reenviado a tu correo'), backgroundColor: Colors.green),
          );
          // Limpiar los campos
          for (var controller in _controllers) {
            controller.clear();
          }
          _focusNodes[0].requestFocus();
        }
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error al reenviar código'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isResending = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Animación de shake para los campos de código
  Future<void> _shakeCodeFields() async {
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
    bool isSecondary = false,
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
                backgroundColor: isSecondary ? AppTheme.primaryColor.withOpacity(0.9) : AppTheme.primaryColor,
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

  // Widget para cada dígito del código
  Widget _buildCodeDigit(int index) {
    return TweenAnimationBuilder(
      duration: Duration(milliseconds: 300 + (index * 50)),
      tween: Tween<double>(begin: 0, end: 1),
      curve: Curves.easeOutBack,
      builder: (context, double scale, child) {
        return Transform.scale(
          scale: scale,
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1, end: 1),
            builder: (context, double shakeValue, child) {
              return Transform.translate(
                offset: Offset(5 * shakeValue, 0),
                child: Container(
                  width: 45,
                  height: 55,
                  decoration: BoxDecoration(
                    color: AppTheme.inputColor,
                    borderRadius: BorderRadius.circular(10),
                    boxShadow: _focusNodes[index].hasFocus
                        ? [BoxShadow(color: AppTheme.primaryColor.withOpacity(0.3), blurRadius: 8, spreadRadius: 2)]
                        : null,
                    border: _focusNodes[index].hasFocus
                        ? Border.all(color: AppTheme.primaryColor, width: 2)
                        : null,
                  ),
                  child: Center(
                    child: TextField(
                      controller: _controllers[index],
                      focusNode: _focusNodes[index],
                      textAlign: TextAlign.center,
                      keyboardType: TextInputType.number,
                      maxLength: 1,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        counterText: '',
                      ),
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                      onChanged: (value) {
                        if (value.isNotEmpty && index < 5) {
                          FocusScope.of(context).nextFocus();
                        } else if (value.isEmpty && index > 0) {
                          FocusScope.of(context).previousFocus();
                        }
                        setState(() {});
                      },
                    ),
                  ),
                ),
              );
            },
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
                    // Texto de instrucciones con animación
                    TweenAnimationBuilder(
                      duration: const Duration(milliseconds: 500),
                      tween: Tween<double>(begin: 0, end: 1),
                      builder: (context, double opacity, child) {
                        return Opacity(opacity: opacity, child: child);
                      },
                      child: Text(
                        widget.isForRegistration 
                          ? 'Verifica tu cuenta nueva' 
                          : 'Ingresa el código de verificación',
                        style: const TextStyle(color: AppTheme.textBodyColor, fontSize: 16, fontWeight: FontWeight.w600),
                      ),
                    ),
                    const SizedBox(height: 30),
                    
                    // Campos de código de 6 dígitos
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: List.generate(6, (index) => _buildCodeDigit(index)),
                    ),
                    const SizedBox(height: 40),

                    // Botón Enviar
                    _buildAnimatedButton(
                      onPressed: _isVerifying ? null : _enviarCodigo,
                      text: 'Enviar',
                      isLoading: _isVerifying,
                    ),
                    const SizedBox(height: 15),

                    // Botón Reenviar código
                    _buildAnimatedButton(
                      onPressed: _isResending ? null : _reenviarCodigo,
                      text: 'Reenviar código',
                      isLoading: _isResending,
                      isSecondary: true,
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