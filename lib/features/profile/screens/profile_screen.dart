import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
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

  // 1. LEER PERFIL (Conectado a tu backend con las tablas separadas)
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
        
        // Sacamos los datos de las "carpetas" que manda tu backend
        final usuarioData = data['usuario'] ?? {};
        final direccionData = data['direccion'] ?? {};
        final telefonoData = data['telefono'] ?? {};

        setState(() {
          _nombre = usuarioData['nombreCompleto'] ?? 'Sin nombre';
          _correo = usuarioData['correo'] ?? 'Sin correo';
          _rol = usuarioData['rol'] ?? 'usuario';
          
          _telefono = telefonoData['numero'] == '0000000000' || telefonoData['numero'] == null 
              ? 'No registrado' 
              : telefonoData['numero'];
              
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

  // 2. EDITAR PERFIL 
  Future<void> _actualizarPerfil(String nuevoNombre, String nuevoTel, String nuevaCalle, String nuevaColonia) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      final response = await http.put(
        Uri.parse('http://10.0.2.2:3005/usuarios/perfil'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token'
        },
        body: jsonEncode({
          'nombreCompleto': nuevoNombre,
          'telefono': nuevoTel,
          'calle': nuevaCalle,
          'colonia': nuevaColonia
        }),
      );

      if (response.statusCode == 200) {
        Navigator.pop(context); // Cerramos el modal
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Perfil actualizado'), backgroundColor: Colors.green));
        setState(() => _isLoading = true);
        _obtenerDatosPerfil(); // Recargamos la pantalla con los datos nuevos
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al actualizar'), backgroundColor: Colors.red));
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red));
    }
  }

  // 3. ELIMINAR CUENTA
  Future<void> _eliminarCuenta() async {
    // Alerta de confirmación antes de borrar
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
        await prefs.remove('token'); // Borramos el token para cerrar sesión
        if (mounted) {
          // Destruimos el historial y lo mandamos al Login
          Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const LoginScreen()), (Route<dynamic> route) => false);
        }
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error al eliminar'), backgroundColor: Colors.red));
    }
  }

  // EL MODAL VISUAL PARA EDITAR
  void _mostrarModalEditar() {
    TextEditingController nombreCtrl = TextEditingController(text: _nombre);
    TextEditingController telCtrl = TextEditingController(text: _telefono == 'No registrado' ? '' : _telefono);
    TextEditingController calleCtrl = TextEditingController(text: _calle == 'Pendiente' ? '' : _calle);
    TextEditingController coloniaCtrl = TextEditingController(text: _colonia);

    showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          insetPadding: const EdgeInsets.all(20),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(20),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), color: const Color(0xFFFFD166),
                    child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, color: Colors.black), SizedBox(width: 10), Text('Editar Perfil', style: TextStyle(color: Colors.black, fontSize: 22, fontWeight: FontWeight.bold))]),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                        TextField(controller: nombreCtrl, decoration: InputDecoration(filled: true, fillColor: AppTheme.inputColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                        const SizedBox(height: 15),
                        const Text('Teléfono:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                        TextField(controller: telCtrl, keyboardType: TextInputType.phone, decoration: InputDecoration(filled: true, fillColor: AppTheme.inputColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                        const SizedBox(height: 15),
                        const Text('Calle y Número:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                        TextField(controller: calleCtrl, decoration: InputDecoration(filled: true, fillColor: AppTheme.inputColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                        const SizedBox(height: 15),
                        const Text('Colonia:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                        TextField(controller: coloniaCtrl, decoration: InputDecoration(filled: true, fillColor: AppTheme.inputColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                        const SizedBox(height: 30),
                        Row(
                          children: [
                            Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90A48E), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Cancelar', style: TextStyle(color: Colors.white)))),
                            const SizedBox(width: 15),
                            Expanded(child: ElevatedButton(
                              onPressed: () => _actualizarPerfil(nombreCtrl.text, telCtrl.text, calleCtrl.text, coloniaCtrl.text),
                              style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Guardar', style: TextStyle(color: Colors.white)))),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: Colors.black),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_num, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('GestiónTech', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            SizedBox(width: 48), 
          ],
        ),
      ),
      body: _isLoading 
        ? const Center(child: CircularProgressIndicator(color: AppTheme.primaryColor))
        : SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              height: 140,
              decoration: const BoxDecoration(color: Color(0xFFE8EDE6)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const CircleAvatar(radius: 40, backgroundColor: Colors.white, child: Icon(Icons.person_outline, size: 50, color: Colors.black)),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                    decoration: BoxDecoration(color: _rol == 'admin' ? const Color(0xFFFFD166) : AppTheme.primaryColor, borderRadius: BorderRadius.circular(10)),
                    child: Text(_rol.toUpperCase(), style: TextStyle(color: _rol == 'admin' ? Colors.black : Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  )
                ],
              ),
            ),
            const SizedBox(height: 30),

            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 30),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildDataField('Nombre:', _nombre), 
                  const SizedBox(height: 20),
                  _buildDataField('Correo electrónico:', _correo),
                  const SizedBox(height: 20),
                  _buildDataField('Teléfono:', _telefono), 
                  const SizedBox(height: 20),
                  _buildDataField('Dirección:', _direccionCompleta), 
                  
                  const SizedBox(height: 50),

                  _buildActionButton('Editar Datos', const Color(0xFFFFD166), _mostrarModalEditar), 
                  const SizedBox(height: 15),
                  _buildActionButton('Eliminar Cuenta', const Color(0xFFFF5C5C), _eliminarCuenta), 
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDataField(String titulo, String valor) {
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [Text(titulo, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)), const SizedBox(height: 2), Text(valor, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold))]);
  }

  Widget _buildActionButton(String titulo, Color color, VoidCallback onPressed) {
    return ElevatedButton(onPressed: onPressed, style: ElevatedButton.styleFrom(backgroundColor: color, minimumSize: const Size(double.infinity, 50), shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)), elevation: 0), child: Text(titulo, style: TextStyle(color: color == const Color(0xFFFFD166) ? Colors.black : Colors.white, fontSize: 16, fontWeight: FontWeight.bold)));
  }
}