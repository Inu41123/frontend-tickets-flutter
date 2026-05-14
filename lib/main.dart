// lib/main.dart
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:shared_preferences/shared_preferences.dart';
// Tu librería de notificaciones
import 'package:awesome_notifications/awesome_notifications.dart'; 

import 'core/theme/app_theme.dart';
import 'features/auth/screens/login_screen.dart';
// La pantalla de onboarding
import 'features/onboarding/screens/onboarding_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // 1. Inicializamos Firebase 
  await Firebase.initializeApp();

  // ==========================================
  // 2. INICIALIZAR AWESOME NOTIFICATIONS (Tu código)
  // ==========================================
  AwesomeNotifications().initialize(
    null, // Usa el ícono por defecto
    [
      NotificationChannel(
        channelGroupKey: 'basic_channel_group',
        channelKey: 'basic_channel', 
        channelName: 'Notificaciones Básicas',
        channelDescription: 'Canal para notificaciones de tickets',
        defaultColor: const Color(0xFF7D8B7A), 
        ledColor: Colors.white,
        importance: NotificationImportance.High,
      )
    ],
  );

  // Arrancamos la app con la lógica de estado
  runApp(const MyApp());
}

// ==========================================
// 3. LÓGICA DE NAVEGACIÓN (Código de Stefany)
// ==========================================
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool? showOnboarding;

  @override
  void initState() {
    super.initState();
    checkFirstTime();
  }
  
Future<void> checkFirstTime() async {
    // ==========================================
    // 1. PEDIR PERMISOS ANTES DE ARRANCAR
    // ==========================================
    bool isAllowed = await AwesomeNotifications().isNotificationAllowed();
    if (!isAllowed) {
      // El 'await' hace que la app espere en la pantalla de carga (CircularProgressIndicator)
      // hasta que el usuario le dé a "Permitir" o "Denegar"
      await AwesomeNotifications().requestPermissionToSendNotifications();
    }

    // ==========================================
    // 2. LÓGICA DEL ONBOARDING (Memoria)
    // ==========================================
    final prefs = await SharedPreferences.getInstance();
    bool alreadyOpened = prefs.getBool('onboardingShown') ?? false;

    setState(() {
      showOnboarding = !alreadyOpened;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pantalla de carga mientras decide a dónde ir
    if (showOnboarding == null) {
      return MaterialApp(
        debugShowCheckedModeBanner: false,
        home: Scaffold(
          backgroundColor: Colors.white,
          body: Center(
            child: CircularProgressIndicator(
              color: AppTheme.primaryColor,
            ),
          ),
        ),
      );
    }

    // Ya sabe a dónde ir: Onboarding o Login
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Sistema de Tickets',
      theme: AppTheme.lightTheme,
      home: showOnboarding!
          ? const OnboardingScreen()
          : const LoginScreen(),
    );
  }
}