// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';

void main() async{
  // 2. Agrega estas dos líneas de seguridad
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
// Aqui cambiamos el async para asegurarnos de que Firebase se inicialice antes de ejecutar la app, si de plano vuelo la app, puedes quitar el await y el async, pero es recomendable inicializar Firebase antes de ejecutar la app para evitar errores relacionados con Firebase.

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sistema de Tickets',
      theme: AppTheme.lightTheme, // Cargamos nuestro tema global
      home: const LoginScreen(),   // Arrancamos directo en el Login
    );
  }
}