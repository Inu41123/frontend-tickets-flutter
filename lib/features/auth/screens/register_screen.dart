import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'verification_code_screen.dart'; // Importamos la pantalla del código
import '../services/google_auth_service.dart';
import '../../tickets/screens/home_screen.dart';



class RegisterScreen extends StatefulWidget {
  const RegisterScreen({Key? key}) : super(key: key);

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  bool _showPassword = false;
  bool _showConfirmPassword = false;

  // 1. Controladores para capturar el texto
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _apellidosController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPasswordController = TextEditingController();

  // 2. Función para mandar los datos al backend
  Future<void> _hacerRegistro() async {
    // Validación rápida: que las contraseñas coincidan
    if (_passwordController.text != _confirmPasswordController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      // Juntamos nombre y apellidos para mandarlo como lo pide tu backend
      String nombreCompleto = '${_nombreController.text.trim()} ${_apellidosController.text.trim()}';

      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/registro'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'nombreCompleto': nombreCompleto,
          'correo': _emailController.text.trim(),
          'password': _passwordController.text
        }),
      );

      if (response.statusCode == 201) {
        // ¡Registro exitoso!
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('¡Cuenta creada! Revisa tu correo'), backgroundColor: Colors.green),
          );
          // Lo mandamos a la pantalla para que meta el código de 6 dígitos
// Lo mandamos a la pantalla para que meta el código de 6 dígitos
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => VerificationCodeScreen(
              email: _emailController.text.trim(), // Le pasamos el correo
              isForRegistration: true,             // ¡Le decimos que es un registro!
            )),
          );
        }
      } else {
        // El backend nos devolvió un error (ej. el correo ya existe)
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje']), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      print("Error de conexión: $e");
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
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Los engranajes
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 40.0),
                  child: Image.asset('assets/images/engrane_izq.png', width: 100),
                ),
                Padding(
                  padding: const EdgeInsets.only(top: 20.0),
                  child: Image.asset('assets/images/engrane_der.png', width: 220),
                ),
              ],
            ),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30.0),
              child: Column(
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, color: AppTheme.primaryColor, size: 30),
                        onPressed: () => Navigator.pop(context),
                      ),
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

                  // Fila de Nombre y Apellidos conectada
                  Row(
                    children: [
                      Expanded(
                        child: CustomAuthTextField(
                          label: 'Nombre',
                          controller: _nombreController, // <-- Conectado
                        ),
                      ),
                      const SizedBox(width: 15),
                      Expanded(
                        child: CustomAuthTextField(
                          label: 'Apellidos',
                          controller: _apellidosController, // <-- Conectado
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 15),

                  CustomAuthTextField(
                    label: 'Correo electrónico',
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController, // <-- Conectado
                  ),
                  const SizedBox(height: 15),

                  CustomAuthTextField(
                    label: 'Contraseña',
                    suffixIcon: _showPassword ? Icons.visibility : Icons.visibility_off,
                    obscureText: !_showPassword,
                    controller: _passwordController, // <-- Conectado
                  ),
                  const SizedBox(height: 15),

                  CustomAuthTextField(
                    label: 'Confirmar contraseña',
                    suffixIcon: _showConfirmPassword ? Icons.visibility : Icons.visibility_off,
                    obscureText: !_showConfirmPassword,
                    controller: _confirmPasswordController, // <-- Conectado
                  ),
                  const SizedBox(height: 10),

                  const Align(
                    alignment: Alignment.centerLeft,
                    child: Text(
                      'La contraseña debe de tener al menos 8 caracteres',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 12),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _hacerRegistro, // <-- LLAMAMOS A LA FUNCIÓN AL HACER CLIC
                    child: const Text('Crear cuenta'),
                  ),
                  const SizedBox(height: 30),

                  const Text('Iniciar sesión con:', style: TextStyle(color: AppTheme.textBodyColor)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [


GestureDetector(
      onTap: () async {
        // Mostramos un indicador de carga opcional (UX)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Conectando con Google...')),
        );
        
        // Llamamos a nuestro servicio
        bool exito = await GoogleAuthService().signInWithGoogle();
        
        if (exito && context.mounted) {
          // Si jala, ¡para adentro!
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
        } else if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al iniciar sesión con Google'), backgroundColor: Colors.red),
          );
        }
      },
      child: Image.asset('assets/logos/google_logo.png', height: 30),
    ),
                      

                      const SizedBox(width: 30),


                      GestureDetector(
  onTap: () {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Próximamente'),
        content: const Text('El inicio de sesión con Facebook estará disponible en versiones futuras.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context), child: const Text('Aceptar')),
        ],
      ),
    );
  },
  child: Image.asset('assets/logos/facebook_logo.png', height: 30),
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
    );
  }
}