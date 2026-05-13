import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

// --- IMPORTACIONES ARREGLADAS (Apuntando a help_center como te diste cuenta) ---
import '../../help_center/utils/app_colors.dart';
import '../../help_center/widgets/app_logo.dart';
import '../../help_center/widgets/rotating_gear.dart'; 
import '../../auth/screens/login_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _isLoading = true;
  
  String _nombre = '';
  String _correo = '';
  String _rol = '';
  String _telefono = 'No registrado';
  String _calle = '';
  String _colonia = '';
  String _direccionCompleta = 'No registrada';

  @override
  void initState() {
    super.initState();
    _obtenerDatosPerfil();
  }

  // --- 1. LÓGICA DEL BACKEND (Intacta) ---
  Future<void> _obtenerDatosPerfil() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3005/usuarios/perfil'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final usuarioData = data['usuario'] ?? {};
        final direccionData = data['direccion'] ?? {};
        final telefonoData = data['telefono'] ?? {};

        setState(() {
          _nombre = usuarioData['nombreCompleto'] ?? 'Sin nombre';
          _correo = usuarioData['correo'] ?? 'Sin correo';
          _rol = usuarioData['rol'] ?? 'usuario';
          
          _telefono = telefonoData['numero'] == '0000000000' || telefonoData['numero'] == null 
              ? 'No registrado' : telefonoData['numero'];
              
          _calle = direccionData['calle'] ?? '';
          _colonia = direccionData['colonia'] ?? '';
          
          if (_calle == 'Pendiente' || _calle.isEmpty) {
            _direccionCompleta = 'No registrada';
          } else {
            _direccionCompleta = '$_calle, $_colonia';
          }

          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  Future<void> _actualizarPerfil(String nuevoNombre, String nuevoTel, String nuevaCalle, String nuevaColonia) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3005/usuarios/perfil'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({
          'nombreCompleto': nuevoNombre, 'telefono': nuevoTel, 'calle': nuevaCalle, 'colonia': nuevaColonia
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); 
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green));
        setState(() => _isLoading = true);
        _obtenerDatosPerfil(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red));
    }
  }

  Future<void> _eliminarCuenta() async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Cuenta?', style: TextStyle(color: Colors.red)),
        content: const Text('Esta acción borrará todos tus datos de forma permanente. No podrás deshacer esto.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C5C)), child: const Text('Eliminar definitivamente')),
        ],
      ),
    ) ?? false;

    if (!confirmar) return;

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.delete(
        Uri.parse('http://10.0.2.2:3005/usuarios/eliminar-cuenta'),
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        await prefs.remove('token'); 
        if (mounted) {
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
        }
      }
    } catch (e) {}
  }

  // --- 2. MODAL DE EDICIÓN (Adaptado al diseño verde) ---
  void _mostrarModalEditar() {
    TextEditingController nombreCtrl = TextEditingController(text: _nombre);
    TextEditingController telCtrl = TextEditingController(text: _telefono == 'No registrado' ? '' : _telefono);
    TextEditingController calleCtrl = TextEditingController(text: _calle == 'Pendiente' ? '' : _calle);
    TextEditingController coloniaCtrl = TextEditingController(text: _colonia);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          backgroundColor: Colors.white,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), color: const Color(0xFFA1B6AA),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, color: Colors.white), SizedBox(width: 10), Text('Editar Perfil', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 5),
                        TextField(controller: nombreCtrl, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFE8EEDF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15))),
                        const SizedBox(height: 15),
                        const Text('Teléfono:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 5),
                        TextField(controller: telCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFE8EEDF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15))),
                        const SizedBox(height: 15),
                        const Text('Calle y Número:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 5),
                        TextField(controller: calleCtrl, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFE8EEDF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15))),
                        const SizedBox(height: 15),
                        const Text('Colonia:', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)), const SizedBox(height: 5),
                        TextField(controller: coloniaCtrl, decoration: InputDecoration(filled: true, fillColor: const Color(0xFFE8EEDF), border: OutlineInputBorder(borderRadius: BorderRadius.circular(18), borderSide: BorderSide.none), contentPadding: const EdgeInsets.symmetric(horizontal: 15))),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF6363), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('Cancelar', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)))),
                            const SizedBox(width: 15),
                            Expanded(child: ElevatedButton(onPressed: () => _actualizarPerfil(nombreCtrl.text, telCtrl.text, calleCtrl.text, coloniaCtrl.text), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFDF57), padding: const EdgeInsets.symmetric(vertical: 12), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18))), child: const Text('Guardar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)))),
                          ],
                        )
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  // --- 3. UI CON EL DISEÑO DE STEFANY PERO DATOS DINÁMICOS ---
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo, // Usando AppColors
      body: SafeArea(
        child: _isLoading 
        ? const Center(child: CircularProgressIndicator())
        : Stack(
          children: [
            const ProfileGears(),

            Column(
              children: [
                const SizedBox(height: 18),
                const Center(child: AppLogo(height: 42)), // Usando AppLogo
                const SizedBox(height: 16),

                Container(
                  width: double.infinity,
                  height: 78,
                  color: AppColors.verdeClaro,
                  child: Row(
                    children: [
                      const SizedBox(width: 18),
                      GestureDetector(onTap: () => Navigator.pop(context), child: const Icon(Icons.arrow_back, size: 34, color: Colors.black)),
                      const Spacer(),
                      Container(
                        width: 68, height: 68, decoration: const BoxDecoration(color: Color(0xFFEAE7EE), shape: BoxShape.circle),
                        child: const Icon(Icons.person_outline, size: 38, color: Colors.black),
                      ),
                      const Spacer(),
                    ],
                  ),
                ),

                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 34),
                    child: SingleChildScrollView(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const SizedBox(height: 30),

                          // DATOS CONECTADOS AL BACKEND
                          const Text('Nombre:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_nombre, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),
                          
                          const SizedBox(height: 20),
                          const Text('Correo electrónico:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_correo, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),

                          const SizedBox(height: 20),
                          const Text('Teléfono:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_telefono, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),

                          const SizedBox(height: 20),
                          const Text('Dirección:', style: TextStyle(fontSize: 14, color: Colors.black54)),
                          const SizedBox(height: 4),
                          Text(_direccionCompleta, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w900, color: Colors.black)),

                          const SizedBox(height: 40),

                          // BOTONES CONECTADOS
                          ProfileButton(
                            text: 'Editar Datos',
                            color: const Color(0xFFF4D74D),
                            onTap: _mostrarModalEditar, // Llama a tu función
                          ),
                          const SizedBox(height: 18),
                          ProfileButton(
                            text: 'Eliminar Cuenta',
                            color: const Color(0xFFFF5D5D),
                            onTap: _eliminarCuenta, // Llama a tu función
                          ),
                          const SizedBox(height: 40),
                        ],
                      ),
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

// COMPONENTES VISUALES
class ProfileButton extends StatelessWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;

  const ProfileButton({super.key, required this.text, required this.color, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 58,
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(30),
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(.20), blurRadius: 7, offset: const Offset(0, 4))],
        ),
        child: Center(child: Text(text, style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 18))),
      ),
    );
  }
}

class ProfileGears extends StatelessWidget {
  const ProfileGears({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(right: -45, top: 190, child: RotatingGear(size: 130, color: AppColors.texto.withOpacity(.55))),
        Positioned(left: -75, top: 360, child: RotatingGear(size: 145, color: const Color(0xFFDDE9DE).withOpacity(.75))),
        Positioned(right: -35, bottom: 160, child: RotatingGear(size: 105, color: const Color(0xFFBFD8D0).withOpacity(.85))),
        Positioned(left: -25, bottom: 90, child: RotatingGear(size: 75, color: const Color(0xFFD8E8D4).withOpacity(.85))),
      ],
    );
  }
}