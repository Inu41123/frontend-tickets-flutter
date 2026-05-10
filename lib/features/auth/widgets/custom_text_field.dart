import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomAuthTextField extends StatelessWidget {
  final String label;
  final IconData? prefixIcon; // Ahora es opcional (tiene el signo de interrogación)
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  const CustomAuthTextField({
    Key? key,
    required this.label,
    this.prefixIcon, // Ya no dice "required"
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller, // Agregado para manejar el texto desde afuera
        obscureText: obscureText,
        keyboardType: keyboardType,
        textAlign: prefixIcon == null ? TextAlign.center : TextAlign.start, // Centra si no hay ícono
        style: const TextStyle(color: AppTheme.primaryColor),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(color: AppTheme.primaryColor.withOpacity(0.7)),
          // Solo dibuja el ícono izquierdo si existe
          prefixIcon: prefixIcon != null ? Icon(prefixIcon, color: AppTheme.primaryColor) : null,
          suffixIcon: suffixIcon != null ? Icon(suffixIcon, color: AppTheme.primaryColor) : null,
          border: InputBorder.none,
          contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
        ),
      ),
    );
  }
}