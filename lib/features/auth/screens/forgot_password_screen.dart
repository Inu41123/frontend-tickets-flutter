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

class _ForgotPasswordScreenState extends State<ForgotPasswordScreen> {
  // 1. Controlador para atrapar el correo que escriba el usuario
  final TextEditingController _emailController = TextEditingController();

  // 2. Función para pedirle el código al backend
  Future<void> _pedirCodigo() async {
    final email = _emailController.text.trim();

    if (email.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor ingresa tu correo'), backgroundColor: Colors.orange),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/solicitar-codigo'), // Puerto 3005
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'correo': email}),
      );

      if (response.statusCode == 200) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Código enviado a tu correo'), backgroundColor: Colors.green),
          );
          
          // 3. ¡EL ARREGLO DEL ERROR! Le pasamos los datos que exige la pantalla
          Navigator.push(
            context, 
            MaterialPageRoute(builder: (context) => VerificationCodeScreen(
              email: email,                  // Pasamos el correo
              isForRegistration: false,      // ¡Le decimos que NO es registro, es recuperación!
            ))
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
                child: Image.asset('assets/images/engrane_izq.png', width: 140),
              ),
              Image.asset('assets/images/engrane_der.png', width: 160),
            ],
          ),

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const Text(
                  '¡Olvidaste tu contraseña!, No te preocupes\nIngresa tu Email y te ayudaremos\ncon un código de verificación',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: AppTheme.textBodyColor, fontSize: 14, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                
                CustomAuthTextField(
                  label: 'Correo electrónico',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                  controller: _emailController, // <-- Conectamos el input
                ),
                const SizedBox(height: 30),
                
                ElevatedButton(
                  onPressed: _pedirCodigo, // <-- Conectamos el botón al backend
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset('assets/images/en_login_abajo.png', width: 150),
          ),
        ],
      ),
    );
  }
}