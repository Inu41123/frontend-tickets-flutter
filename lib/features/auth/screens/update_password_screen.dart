import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';

class UpdatePasswordScreen extends StatefulWidget {
  const UpdatePasswordScreen({Key? key}) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  bool _showPass1 = false;
  bool _showPass2 = false;

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
                CustomAuthTextField(
                  label: 'Contraseña nueva',
                  suffixIcon: _showPass1 ? Icons.visibility : Icons.visibility_off,
                  obscureText: !_showPass1,
                ),
                const SizedBox(height: 20),
                CustomAuthTextField(
                  label: 'Confirmar contraseña',
                  suffixIcon: _showPass2 ? Icons.visibility : Icons.visibility_off,
                  obscureText: !_showPass2,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () {
                    // Aquí llamaremos al endpoint restablecer-password y mostraremos el modal verde
                  },
                  child: const Text('Actualizar'),
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