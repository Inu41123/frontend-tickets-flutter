import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'update_password_screen.dart';

class VerificationCodeScreen extends StatelessWidget {
  const VerificationCodeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
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

          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30.0),
            child: Column(
              children: [
                const Text(
                  'Ingresa el código de verificación',
                  style: TextStyle(color: AppTheme.textBodyColor, fontSize: 16, fontWeight: FontWeight.w600),
                ),
                const SizedBox(height: 30),
                
                // Fila de 6 cuadros
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(6, (index) {
                    return Container(
                      width: 45,
                      height: 55,
                      decoration: BoxDecoration(
                        color: AppTheme.inputColor,
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: const Center(
                        child: TextField(
                          textAlign: TextAlign.center,
                          keyboardType: TextInputType.number,
                          maxLength: 1, // Solo un número por cuadro
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            counterText: '', // Oculta el contador de texto abajo
                          ),
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: AppTheme.primaryColor),
                        ),
                      ),
                    );
                  }),
                ),
                const SizedBox(height: 40),

                ElevatedButton(
                  onPressed: () {
                    // Pasar a actualizar contraseña
                    Navigator.push(context, MaterialPageRoute(builder: (context) => const UpdatePasswordScreen()));
                  },
                  child: const Text('Enviar'),
                ),
                const SizedBox(height: 15),
                ElevatedButton(
                  onPressed: () {
                    // Lógica para reenviar código
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor.withOpacity(0.9), // Un poco más claro
                  ),
                  child: const Text('Reenviar código'),
                ),
              ],
            ),
          ),

          Align(
            alignment: Alignment.bottomRight,
            child: Image.asset('assets/images/engrane_abajo.png', width: 150),
          ),
        ],
      ),
    );
  }
}