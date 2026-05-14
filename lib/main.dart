// lib/main.dart
import 'package:flutter/material.dart';
import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:awesome_notifications/awesome_notifications.dart'; 

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Inicializamos Firebase primero
  await Firebase.initializeApp();

  // ==========================================
  // 2. INICIALIZAR AWESOME NOTIFICATIONS
  // ==========================================
  AwesomeNotifications().initialize(
    null, // null significa que usará el ícono por defecto de tu app
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel', // Este es el ID que usamos en tu add_ticket_screen
        channelName: 'Notificaciones Básicas',
        channelDescription: 'Canal para notificaciones de tickets',
        defaultColor: const Color(0xFF7D8B7A), // El color verde primario de tu AppTheme
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

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