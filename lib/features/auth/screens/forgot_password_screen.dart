import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
// Importa la siguiente pantalla para la navegación
import 'verification_code_screen.dart'; 

class ForgotPasswordScreen extends StatelessWidget {
  const ForgotPasswordScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Engranajes Superiores
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 40.0),
                child: Image.asset('assets/images/engrane_izq.png', width: 120),
              ),
              Image.asset('assets/images/engrane_der.png', width: 160),
            ],
          ),

          // Contenido Central
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
                const CustomAuthTextField(
                  label: 'Correo electrónico',
                  prefixIcon: Icons.person_outline,
                  keyboardType: TextInputType.emailAddress,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Navegamos a la pantalla del código
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const VerificationCodeScreen()));
                  },
                  child: const Text('Enviar'),
                ),
              ],
            ),
          ),

          // Engranaje Inferior
          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset('assets/images/engrane_abajo.png', width: 150),
          ),
        ],
      ),
    );
  }
}