import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart'; 
import '../../tickets/screens/home_screen.dart'; // Asegúrate de haber creado este archivo

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  // Para manejar si se ve la contraseña (Pantalla 2 del diseño)
  bool _showPassword = false;

  // 1. Controladores para leer lo que escribe el usuario
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // 2. Función para conectarse al backend
  Future<void> _hacerLogin() async {
    try {
      // Recuerda usar 10.0.2.2 si estás en el emulador de Android local
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3000/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _emailController.text,
          'password': _passwordController.text
        }),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Token recibido: ${data['token']}"); // Para verificar en consola
        
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
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
      print("Error de conexión: $e");
      if (mounted) {
         ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al conectar con el servidor.'), backgroundColor: Colors.red),
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
            // 1. LOS DOS ENGRANAJES
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(top: 50.0),
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
              padding: const EdgeInsets.all(30.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    '¡Bienvenido!',
                    style: Theme.of(context).textTheme.headlineLarge,
                  ),
                  const SizedBox(height: 40),

                  CustomAuthTextField(
                    label: 'Correo electrónico',
                    prefixIcon: Icons.person_outline,
                    keyboardType: TextInputType.emailAddress,
                    controller: _emailController, // <-- Conectado
                  ),
                  const SizedBox(height: 35),
                  CustomAuthTextField(
                    label: 'Contraseña',
                    prefixIcon: Icons.lock_outline,
                    suffixIcon: _showPassword ? Icons.visibility : Icons.visibility_off,
                    obscureText: !_showPassword,
                    controller: _passwordController, // <-- Conectado
                  ),
                  const SizedBox(height: 10),

                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {},
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(color: AppTheme.primaryColor),
                      ),
                    ),
                  ),
                  const SizedBox(height: 30),

                  ElevatedButton(
                    onPressed: _hacerLogin, // <-- Llamamos a la función
                    child: const Text('Iniciar sesión'),
                  ),
                  const SizedBox(height: 15),
                  OutlinedButton(
                    onPressed: () {
                      Navigator.push(
                         context,
                         MaterialPageRoute(builder: (context) => const RegisterScreen()),
                      );
                    },
                    style: OutlinedButton.styleFrom(
                      side: const BorderSide(color: AppTheme.primaryColor),
                      minimumSize: const Size(double.infinity, 50),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    ),
                    child: const Text(
                      'Crear cuenta',
                      style: TextStyle(color: AppTheme.primaryColor, fontSize: 16, fontWeight: FontWeight.w600),
                    ),
                  ),
                  const SizedBox(height: 30),

                  const Text('Iniciar sesión con:', style: TextStyle(color: AppTheme.textBodyColor)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Image.asset('assets/images/google_logo.png', height: 30),
                      const SizedBox(width: 30),
                      Image.asset('assets/images/facebook_logo.png', height: 30),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}