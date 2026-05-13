import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class CustomAuthTextField extends StatelessWidget {
  final String label;
  final IconData? prefixIcon;
  final IconData? suffixIcon;
  final bool obscureText;
  final TextInputType keyboardType;
  final TextEditingController? controller;

  // NUEVO
  final VoidCallback? onSuffixTap;

  const CustomAuthTextField({
    Key? key,
    required this.label,
    this.prefixIcon,
    this.suffixIcon,
    this.obscureText = false,
    this.keyboardType = TextInputType.text,
    this.controller,

    // NUEVO
    this.onSuffixTap,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppTheme.inputColor,
        borderRadius: BorderRadius.circular(30),
      ),
      child: TextField(
        controller: controller,
        obscureText: obscureText,
        keyboardType: keyboardType,
        textAlign:
            prefixIcon == null ? TextAlign.center : TextAlign.start,
        style: const TextStyle(
          color: AppTheme.primaryColor,
        ),
        decoration: InputDecoration(
          hintText: label,
          hintStyle: TextStyle(
            color: AppTheme.primaryColor.withOpacity(0.7),
          ),

          // ÍCONO IZQUIERDO
          prefixIcon: prefixIcon != null
              ? Icon(
                  prefixIcon,
                  color: AppTheme.primaryColor,
                )
              : null,

          // ÍCONO DERECHO FUNCIONAL
          suffixIcon: suffixIcon != null
              ? IconButton(
                  onPressed: onSuffixTap,
                  icon: Icon(
                    suffixIcon,
                    color: AppTheme.primaryColor,
                  ),
                )
              : null,

          border: InputBorder.none,

          contentPadding: const EdgeInsets.symmetric(
            horizontal: 20,
            vertical: 15,
          ),
        ),
      ),
    );
  }
}