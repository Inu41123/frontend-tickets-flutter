import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class AddTicketScreen extends StatefulWidget {
  const AddTicketScreen({Key? key}) : super(key: key);

  @override
  State<AddTicketScreen> createState() => _AddTicketScreenState();
}

class _AddTicketScreenState extends State<AddTicketScreen> {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _prioridadSeleccionada = 'Baja'; // Valor por defecto

Future<void> _enviarTicket() async {
    if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Por favor, llena todos los campos'), backgroundColor: Colors.orange),
      );
      return;
    }

// El traductor completo para los 5 niveles
  int prioridadNumero;
  switch (_prioridadSeleccionada) {
    case 'Crítica':
      prioridadNumero = 1;
      break;
    case 'Alta':
      prioridadNumero = 2;
      break;
    case 'Media':
      prioridadNumero = 3;
      break;
    case 'Baja':
      prioridadNumero = 4;
      break;
    case 'Mínima':
      prioridadNumero = 5;
      break;
    default:
      prioridadNumero = 3;
  }

    try {
      // 1. Sacamos el Token de la memoria
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      // Si por alguna razón no hay token, lo rebotamos
      if (token == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error: No has iniciado sesión'), backgroundColor: Colors.red),
        );
        return;
      }

      // 2. Le pegamos a Node.js con nuestra llave VIP
      final response = await http.post(
        Uri.parse('http://10.0.2.2:3005/tickets'), // Puerto 3005
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token', // <-- ¡AQUÍ ESTÁ LA MAGIA!
        },
        body: jsonEncode({
          'nombre': _nombreController.text.trim(),
          'problema': _descripcionController.text.trim(),
          'prioridad': prioridadNumero
        }),
      );

      if (response.statusCode == 201) {
        _mostrarModalExito();
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error desconocido'), backgroundColor: Colors.red),
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

  // Función para mostrar el modal de éxito (El que diseñó Stefany)
  void _mostrarModalExito() {
    showDialog(
      context: context,
      barrierDismissible: false, // El usuario debe tocar "Aceptar" para salir
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              color: AppTheme.backgroundColor,
              borderRadius: BorderRadius.circular(20),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const CircleAvatar(
                  radius: 30,
                  backgroundColor: Color(0xFF7D8B7A), // Color verdecito del icono
                  child: Icon(Icons.check, color: Colors.white, size: 40),
                ),
                const SizedBox(height: 15),
                const Text(
                  '¡Ticket Registrado!',
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const Divider(color: Colors.black54, thickness: 1),
                const SizedBox(height: 10),
                const Text(
                  'El ticket se guardo con éxito',
                  style: TextStyle(color: Colors.grey, fontSize: 16),
                ),
                const SizedBox(height: 25),
                ElevatedButton(
                  onPressed: () {
                    // Cierra el modal
                    Navigator.of(context).pop();
                    // Regresa a la pantalla principal (HomeScreen)
                    Navigator.of(context).pop();
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppTheme.primaryColor,
                    padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  ),
                  child: const Text('Aceptar', style: TextStyle(fontSize: 16)),
                ),
              ],
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
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: const Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.confirmation_num, color: AppTheme.primaryColor),
            SizedBox(width: 8),
            Text('GestiónTech', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            SizedBox(width: 48), // Para centrar el título compensando la flecha de regreso
          ],
        ),
      ),
      body: Stack(
        children: [
          // FONDO: Engranaje arriba derecha
          Positioned(
            top: -20,
            right: -30,
            child: Opacity(
              opacity: 0.5,
              child: Image.asset('assets/images/engrane_der.png', width: 150), // Ajusta el nombre de tu imagen
            ),
          ),
          // FONDO: Engranaje abajo izquierda
          Positioned(
            bottom: -20,
            left: -30,
            child: Opacity(
              opacity: 0.3,
              child: Image.asset('assets/images/engrane_izq.png', width: 150),
            ),
          ),
          // FONDO: Engranaje abajo derecha
          Positioned(
            bottom: 50,
            right: -40,
            child: Opacity(
              opacity: 0.4,
              child: Image.asset('assets/images/engrane_abajo.png', width: 180),
            ),
          ),

          // CONTENIDO PRINCIPAL (El Formulario)
          SafeArea(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(25.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      IconButton(
                        icon: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
                        onPressed: () => Navigator.pop(context),
                      ),
                      const Expanded(
                        child: Text(
                          'Registrar Ticket',
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                        ),
                      ),
                      const SizedBox(width: 48), // Espaciador invisible para centrar
                    ],
                  ),
                  const SizedBox(height: 30),

                  // Campo Nombre
                  const Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _nombreController,
                    decoration: InputDecoration(
                      hintText: 'Introduce el nombre del ticket',
                      filled: true,
                      fillColor: AppTheme.inputColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 20),

                  // Campo Descripción
                  const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  TextField(
                    controller: _descripcionController,
                    maxLines: 5,
                    maxLength: 150,
                    decoration: InputDecoration(
                      hintText: 'Describe la problemática',
                      filled: true,
                      fillColor: AppTheme.inputColor,
                      border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none),
                    ),
                  ),
                  const SizedBox(height: 10),

                  // Campo Prioridad (Dropdown)
                  const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 5),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 15),
                    decoration: BoxDecoration(
                      color: AppTheme.inputColor,
                      borderRadius: BorderRadius.circular(15),
                    ),
                    child: DropdownButtonHideUnderline(
                      child: DropdownButton<String>(
                        value: _prioridadSeleccionada,
                        isExpanded: true,
                        items: ['Crítica', 'Alta', 'Media', 'Baja', 'Mínima'].map((String value) {
                          return DropdownMenuItem<String>(
                            value: value,
                            child: Text(value),
                          );
                        }).toList(),
                        onChanged: (newValue) {
                          setState(() {
                            _prioridadSeleccionada = newValue!;
                          });
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 40),

                  // Botón Enviar
Center(
  child: ElevatedButton(
    onPressed: _enviarTicket, // <-- ¡Solo llamamos a la función principal!
    style: ElevatedButton.styleFrom(
      backgroundColor: AppTheme.primaryColor,
      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      minimumSize: const Size(double.infinity, 50),
    ),
    child: const Text('Enviar Ticket', style: TextStyle(fontSize: 16)),
  ),
),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}