import 'package:flutter/material.dart';

class AppTheme {
  // Definimos los colores clave sacados del diseño
  static const Color backgroundColor = Color(0xFFF9FAEF); // El crema del fondo
  static const Color primaryColor = Color(0xFF1E3A42);    // El verde-azulado oscuro de botones y títulos
  static const Color inputColor = Color(0xFFE8ECD7);      // El color de fondo de los inputs
  static const Color textBodyColor = Color(0xFF4A4A4A);   // Un gris oscuro para textos normales

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: backgroundColor,
      primaryColor: primaryColor,
      
      // Estilos globales de texto
      textTheme: const TextTheme(
        // El estilo para "¡Bienvenido!"
        headlineLarge: TextStyle(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: primaryColor,
        ),
        // Estilo para los textos dentro de los inputs
        bodyLarge: TextStyle(
          fontSize: 16,
          color: primaryColor,
        ),
        // Estilo para los botones
        labelLarge: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),

      // Estilo global de los botones (elevados con bordes redondeados)
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 50), // Botones anchos
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: const TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        ),
      ),
    );
  }
}