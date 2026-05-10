import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import '../../../core/theme/app_theme.dart';
import '../widgets/custom_text_field.dart';
import 'login_screen.dart'; // Para regresarlo al login

class UpdatePasswordScreen extends StatefulWidget {
  final String email;
  final String codigo;

  const UpdatePasswordScreen({
    Key? key, 
    required this.email, 
    required this.codigo
  }) : super(key: key);

  @override
  State<UpdatePasswordScreen> createState() => _UpdatePasswordScreenState();
}

class _UpdatePasswordScreenState extends State<UpdatePasswordScreen> {
  bool _showPass1 = false;
  bool _showPass2 = false;

  final TextEditingController _passController = TextEditingController();
  final TextEditingController _confirmPassController = TextEditingController();

  Future<void> _actualizarPassword() async {
    if (_passController.text != _confirmPassController.text) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Las contraseñas no coinciden'), backgroundColor: Colors.red),
      );
      return;
    }

    try {
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/usuarios/restablecer-password'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({
          'correo': widget.email,
          'codigo': widget.codigo,
          'nuevaPassword': _passController.text
        }),
      );

      if (response.statusCode == 200) {
        if (mounted) {
           ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('¡Contraseña actualizada con éxito!'), backgroundColor: Colors.green),
            );
           // Lo mandamos de regreso al login
           Navigator.pushAndRemoveUntil(
              context, 
              MaterialPageRoute(builder: (context) => const LoginScreen()), 
              (route) => false
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
      if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
          );
      }
    }
  }

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
                  controller: _passController,
                ),
                const SizedBox(height: 20),
                CustomAuthTextField(
                  label: 'Confirmar contraseña',
                  suffixIcon: _showPass2 ? Icons.visibility : Icons.visibility_off,
                  obscureText: !_showPass2,
                  controller: _confirmPassController,
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: _actualizarPassword, // ¡Ahora sí hace algo!
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