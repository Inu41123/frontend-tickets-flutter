import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// --- IMPORTACIONES DE LOS WIDGETS DE STEFANY ---
import '../../help_center/utils/app_colors.dart';
import '../../help_center/widgets/app_logo.dart';
import '../../help_center/widgets/buttons.dart'; 

import '../../auth/screens/login_screen.dart'; 
import '../../profile/screens/profile_screen.dart'; 
import '../../help_center/screens/help_center_screen.dart'; 

class CustomDrawer extends StatefulWidget {
  const CustomDrawer({Key? key}) : super(key: key);

  @override
  State<CustomDrawer> createState() => _CustomDrawerState();
}

class _CustomDrawerState extends State<CustomDrawer> {
  String nombreUsuario = 'Cargando...';

  @override
  void initState() {
    super.initState();
    _cargarDatosUsuario();
  }

  // LÓGICA INTACTA: Sacamos el nombre del Token
  Future<void> _cargarDatosUsuario() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');
    if (token != null) {
      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final payloadData = jsonDecode(payload);
        setState(() {
          nombreUsuario = payloadData['nombre'] ?? 'Usuario';
        });
      }
    }
  }

  // LÓGICA INTACTA: Cerrar sesión real
  Future<void> _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); 
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, 
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      width: 255, // Stefany le puso exactamente 255 de ancho en su diseño
      backgroundColor: AppColors.fondo,
      child: SafeArea(
        child: Stack(
          children: [
            // LOS ENGRANAJES DE FONDO DE STEFANY
            const MenuGears(),
            
            Column(
              children: [
                // HEADER CON LOGO
                Container(
                  height: 78,
                  padding: const EdgeInsets.symmetric(horizontal: 25),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context), // Cierra el menú al tocar el icono
                        child: const Icon(Icons.menu, size: 28),
                      ),
                      const SizedBox(width: 14),
                      const AppLogo(height: 28),
                    ],
                  ),
                ),
                
                // BARRA CON NOMBRE DE USUARIO Y AVATAR
                Container(
                  height: 56,
                  color: AppColors.verdeClaro,
                  child: Row(
                    children: [
                      const SizedBox(width: 20),
                      Expanded(
                        child: Text(
                          nombreUsuario, // <-- DATO DINÁMICO DEL BACKEND
                          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold),
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                        },
                        child: const CircleAvatar(
                          radius: 21,
                          backgroundColor: Color(0xFFE6E6E6),
                          child: Icon(Icons.person_outline, color: Colors.black),
                        ),
                      ),
                      const SizedBox(width: 18),
                    ],
                  ),
                ),
                const SizedBox(height: 82),

                // BOTONES ANIMADOS DE STEFANY CONECTADOS A TUS RUTAS
                SizedBox(
                  width: 170,
                  child: MainButton(
                    text: 'Perfil',
                    color: const Color(0xFFD6E6B5),
                    textColor: AppColors.texto,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfileScreen()));
                    },
                  ),
                ),
                const SizedBox(height: 18),
                
                SizedBox(
                  width: 170,
                  child: MainButton(
                    text: 'Centro de Ayuda',
                    color: const Color(0xFFD6E6B5),
                    textColor: AppColors.texto,
                    onTap: () {
                      Navigator.pop(context);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const HelpCenterScreen()));
                    },
                  ),
                ),
                
                const Spacer(),
                
                // BOTÓN ROJO PARA CERRAR SESIÓN
                Padding(
                  padding: const EdgeInsets.only(bottom: 55),
                  child: SizedBox(
                    width: 145,
                    child: MainButton(
                      text: 'Cerrar Sesión',
                      color: AppColors.rojo,
                      onTap: () => _cerrarSesion(context), // <-- CONECTADO A TU LÓGICA
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

// COPIA EXACTA DE LOS ENGRANAJES DE STEFANY
class MenuGears extends StatelessWidget {
  const MenuGears({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -55,
          top: 160,
          child: Icon(Icons.settings, size: 150, color: AppColors.texto.withOpacity(.70)),
        ),
        const Positioned(
          left: -70,
          top: 330,
          child: Icon(Icons.settings, size: 145, color: Color(0xFFDDE9DE)),
        ),
        const Positioned(
          right: -38,
          top: 450,
          child: Icon(Icons.settings, size: 110, color: Color(0xFFBFD8D0)),
        ),
        const Positioned(
          left: -20,
          bottom: 120,
          child: Icon(Icons.settings, size: 70, color: Color(0xFFD8E8D4)),
        ),
        Positioned(
          right: -45,
          bottom: -10,
          child: Icon(Icons.settings, size: 170, color: AppColors.texto.withOpacity(.75)),
        ),
      ],
    );
  }
}