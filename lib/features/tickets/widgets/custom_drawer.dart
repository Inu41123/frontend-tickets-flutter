import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../core/theme/app_theme.dart';
import '../../auth/screens/login_screen.dart'; // Ajusta la ruta a tu Login
import '../../profile/screens/profile_screen.dart'; // El archivo que crearemos abajo
import '../../help_center/screens/help_center_screen.dart'; // Ajusta la ruta según dónde la guardaste

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

  // Sacamos el nombre directamente del Token guardado
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

  Future<void> _cerrarSesion(BuildContext context) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token'); // Borramos el token de la memoria
    
    if (context.mounted) {
      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(builder: (context) => const LoginScreen()),
        (Route<dynamic> route) => false, // Destruye todas las pantallas anteriores
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      backgroundColor: AppTheme.backgroundColor,
      child: Stack(
        children: [
          // FONDO: Engranajes
          Positioned(top: 150, left: -50, child: Opacity(opacity: 0.3, child: Image.asset('assets/images/engrane_izq.png', width: 200))),
          Positioned(bottom: 100, right: -50, child: Opacity(opacity: 0.4, child: Image.asset('assets/images/engrane_abajo.png', width: 200))),

          // CONTENIDO DEL MENÚ
          Column(
            children: [
              // Header del Menú
              Container(
                width: double.infinity,
                padding: const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
                decoration: const BoxDecoration(color: Color(0xFFE8EDE6)), // Verde clarito
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text(nombreUsuario, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))),
                    const CircleAvatar(
                      backgroundColor: Colors.white,
                      radius: 25,
                      child: Icon(Icons.person_outline, size: 30, color: Colors.black),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 40),

              // Botones del menú
              _buildMenuButton('Perfil', () {
                Navigator.pop(context); // Cierra el menú
                Navigator.push(context, MaterialPageRoute(builder: (context) => const ProfileScreen()));
              }),
              const SizedBox(height: 15),
              _buildMenuButton('Centro de Ayuda', () {
                Navigator.pop(context); // Cierra el menú lateral primero
                Navigator.push(
                  context, 
                  MaterialPageRoute(builder: (context) => const HelpCenterScreen()) // <-- ¡Abre el diseño de Stefany!
                );
              }),

              const Spacer(), // Empuja el botón de cerrar sesión hasta abajo

              // Botón Cerrar Sesión
              Padding(
                padding: const EdgeInsets.only(bottom: 40),
                child: ElevatedButton(
                  onPressed: () => _cerrarSesion(context),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFFFF5C5C),
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  ),
                  child: const Text('Cerrar Sesión', style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                ),
              )
            ],
          ),
        ],
      ),
    );
  }

  // Mini-widget para hacer los botones verdes del menú
  Widget _buildMenuButton(String title, VoidCallback onPressed) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 40),
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFFD3E0C8), // Verde pastel del diseño
          foregroundColor: Colors.black,
          minimumSize: const Size(double.infinity, 45),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          elevation: 0,
        ),
        child: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
      ),
    );
  }
}