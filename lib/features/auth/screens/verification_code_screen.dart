import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import 'update_password_screen.dart';
import 'login_screen.dart'; // Importamos el login para regresar

class VerificationCodeScreen extends StatefulWidget {
  final String email; // Para saber a qué correo verificar
  final bool isForRegistration; // La variable mágica que separa los flujos

  const VerificationCodeScreen({
    Key? key, 
    required this.email, 
    required this.isForRegistration
  }) : super(key: key);

  @override
  State<VerificationCodeScreen> createState() => _VerificationCodeScreenState();
}

class _VerificationCodeScreenState extends State<VerificationCodeScreen> {
  // 6 controladores para los 6 cuadritos
  final List<TextEditingController> _controllers = List.generate(6, (_) => TextEditingController());

  Future<void> _enviarCodigo() async {
    // Juntamos los 6 numeritos en un solo string de texto
    String codigoIngresado = _controllers.map((c) => c.text).join();

    if (codigoIngresado.length < 6) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa los 6 dígitos'), backgroundColor: Colors.orange),
      );
      return;
    }

    // FLUJO 1: SI VIENE DE CREAR CUENTA
    if (widget.isForRegistration) {
      try {
        final response = await http.post(
          Uri.parse('http://10.0.2.2:3005/usuarios/verificar-cuenta'), // Tu puerto 3005
          headers: {'Content-Type': 'application/json'},
          body: jsonEncode({
            'correo': widget.email,
            'codigo': codigoIngresado
          }),
        );

        if (response.statusCode == 200) {
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Cuenta verificada! Ya puedes iniciar sesión.'), backgroundColor: Colors.green),
            );
            // Lo regresamos al Login y borramos todo el historial de pantallas atrás
            Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const LoginScreen()), 
              (route) => false
            );
          }
        } else {
          final error = jsonDecode(response.body);
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(error['mensaje']), backgroundColor: Colors.red),
            );
          }
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
          );
        }
      }
    } 
    // FLUJO 2: SI VIENE DE OLVIDÉ MI CONTRASEÑA
    else {
      // Como solo estamos recuperando, saltamos a la pantalla de Nueva Contraseña
      // y le pasamos el correo y el código para que el backend lo valide allá.
      Navigator.push(
        context, 
        MaterialPageRoute(builder: (context) => UpdatePasswordScreen(
          email: widget.email, 
          codigo: codigoIngresado
        ))
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset('assets/images/engrane_izq.png', width: 120),
              ),
              Image.asset('assets/images/engrane_der.png', width: 160),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                Text(
                  widget.isForRegistration 
                    ? 'Verifica tu cuenta nueva' 
                    : 'Ingresa el código de verificación',
                  style: const TextStyle(color: AppTheme.textBodyColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 45,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppTheme.inputColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                        child: TextField(
                          controller: _controllers[index], // Conectamos el controlador
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1, 
                          decoration: const InputDecoration(
                            border: InputBorder.none,
                            counterText: '', 
                          ),
                          style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                          onChanged: (value) {
                            // UX: Brincar al siguiente cuadrito automáticamente
                            if (value.isNotEmpty && index < 5) {
                              FocusScope.of(context).nextFocus();
                            } else if (value.isEmpty && index > 0) {
                              FocusScope.of(context).previousFocus();
                            }
                          },
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: _enviarCodigo, // Llamamos a nuestra función "inteligente"
                  child: const Text('Enviar'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {},
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.9), 
                  ),
                  child: const Text('Reenviar código'),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset('assets/images/en_login_abajo.png', width: 150)
          ),
        ],
      ),
    );
  }
}