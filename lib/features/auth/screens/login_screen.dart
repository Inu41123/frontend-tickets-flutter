import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'register_screen.dart'; 
import '../../tickets/screens/home_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'forgot_password_screen.dart';

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
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/login'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': _emailController.text.trim(), // Le puse .trim() para limpiar espacios fantasma
          'password': _passwordController.text
        }),
      );

      // ¡NUEVO!: Imprimimos la respuesta cruda en la consola para ver qué nos mandaron
      print("======= RESPUESTA DEL SERVIDOR =======");
      print("Status Code: ${response.statusCode}");
      print("Body: ${response.body}");
      print("======================================");

      // ESCUDO: Si la respuesta es HTML, detenemos todo para que no explote la app
      if (response.body.startsWith('<!DOCTYPE html>') || response.body.startsWith('<html')) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Error del servidor: Devolvió HTML en lugar de JSON. Revisa la consola.'),
              backgroundColor: Colors.red,
            ),
          );
        }
        return; // Cortamos la función aquí
      }

      // Si pasamos el escudo, significa que sí es un JSON
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        print("Token recibido: ${data['token']}"); 

        // ¡NUEVO! Guardamos el token como si fuera una "cookie"
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', data['token']);
        
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
      print("Error de conexión interno: $e");
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
                      Image.asset('assets/logos/google_logo.png', height: 30),
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
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}