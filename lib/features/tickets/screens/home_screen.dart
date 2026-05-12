// lib/features/tickets/screens/home_screen.dart
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../core/theme/app_theme.dart';
import 'add_ticket_screen.dart';
import '../widgets/custom_drawer.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  List<dynamic> _ticketsOriginales = []; // Todos los tickets que manda Node
  List<dynamic> _ticketsFiltrados = [];  // Los que se van a dibujar en pantalla
  
  bool _isLoading = true;
  int _total = 0;
  int _pendientes = 0;
  int _atendidos = 0;
  bool _esAdmin = false;

  // Controladores para los filtros
  final TextEditingController _searchController = TextEditingController();
  String _filtroPrioridad = 'Todas';

  @override
  void initState() {
    super.initState();
    _obtenerTickets();
  }

  // --- LÓGICA DEL FILTRO ---
  void _filtrarTickets() {
    String busqueda = _searchController.text.toLowerCase();
    
    setState(() {
      _ticketsFiltrados = _ticketsOriginales.where((ticket) {
        // 1. Filtrar por texto (Busca en nombre o en el ID corto)
        String nombre = (ticket['nombre'] ?? '').toLowerCase();
        String idCorto = ticket['_id'].toString().substring(ticket['_id'].toString().length - 5).toLowerCase();
        bool coincideTexto = busqueda.isEmpty || nombre.contains(busqueda) || idCorto.contains(busqueda);

        // 2. Filtrar por prioridad
        bool coincidePrioridad = true;
        if (_filtroPrioridad != 'Todas') {
          int prioTicket = ticket['prioridad'] ?? 5;
          int prioFiltro = 5;
          if (_filtroPrioridad == 'Crítica') prioFiltro = 1;
          if (_filtroPrioridad == 'Alta') prioFiltro = 2;
          if (_filtroPrioridad == 'Media') prioFiltro = 3;
          if (_filtroPrioridad == 'Baja') prioFiltro = 4;
          if (_filtroPrioridad == 'Mínima') prioFiltro = 5;
          
          coincidePrioridad = (prioTicket == prioFiltro);
        }

        return coincideTexto && coincidePrioridad;
      }).toList();

      // Opcional: Actualizar estadísticas para que coincidan con lo que se ve
      _total = _ticketsFiltrados.length;
      _pendientes = _ticketsFiltrados.where((t) => t['estado'] == true).length;
      _atendidos = _ticketsFiltrados.where((t) => t['estado'] == false).length;
    });
  }

  Future<void> _obtenerTickets() async {
    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        setState(() => _isLoading = false);
        return;
      }

      final parts = token.split('.');
      if (parts.length == 3) {
        final payload = utf8.decode(base64Url.decode(base64Url.normalize(parts[1])));
        final payloadData = jsonDecode(payload);
        _esAdmin = payloadData['rol'] == 'admin';
      }

      final response = await http.get(
        Uri.parse('http://10.0.2.2:3005/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        setState(() {
          _ticketsOriginales = data;
          _ticketsFiltrados = data; // Al principio mostramos todos
          _isLoading = false;
        });
        _filtrarTickets(); // Aplicamos filtros por si recarga la página y había algo escrito
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  // ... (Las funciones _cambiarEstatusTicket, _enviarEdicion, _mostrarModalEditar, _mostrarModalExitoEdicion y _eliminarTicket se quedan EXACTAMENTE igual, no las toqué)

  Future<void> _cambiarEstatusTicket(String idTicket, bool estadoActual) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3005/tickets/$idTicket/status'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'estado': !estadoActual}), 
      );
      if (response.statusCode == 200) _obtenerTickets(); 
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red));
    }
  }

  Future<void> _enviarEdicion(String idTicket, String nombre, String problema, int prioridad) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.put(
        Uri.parse('http://10.0.2.2:3005/tickets/$idTicket'),
        headers: {'Content-Type': 'application/json', 'Authorization': 'Bearer $token'},
        body: jsonEncode({'nombre': nombre, 'problema': problema, 'prioridad': prioridad}),
      );
      if (response.statusCode == 200) {
        Navigator.pop(context); 
        _mostrarModalExitoEdicion(); 
        _obtenerTickets(); 
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Error de conexión'), backgroundColor: Colors.red));
    }
  }

  void _mostrarModalEditar(dynamic ticket) {
    TextEditingController nombreCtrl = TextEditingController(text: ticket['nombre']);
    TextEditingController probCtrl = TextEditingController(text: ticket['problema']);
    int prioridadNum = ticket['prioridad'] ?? 5;
    String prioridadSel = 'Mínima';
    if (prioridadNum == 1) prioridadSel = 'Crítica';
    if (prioridadNum == 2) prioridadSel = 'Alta';
    if (prioridadNum == 3) prioridadSel = 'Media';
    if (prioridadNum == 4) prioridadSel = 'Baja';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(builder: (context, setStateModal) {
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
                      width: double.infinity, padding: const EdgeInsets.symmetric(vertical: 20), color: const Color(0xFF7D8B7A),
                      child: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.edit, color: Colors.white), SizedBox(width: 10), Text('Editar Ticket', style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold))]),
                    ),
                    Padding(
                      padding: const EdgeInsets.all(20),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Nombre:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                          TextField(controller: nombreCtrl, decoration: InputDecoration(filled: true, fillColor: AppTheme.inputColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                          const SizedBox(height: 15),
                          const Text('Descripción:', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                          TextField(controller: probCtrl, maxLines: 4, decoration: InputDecoration(filled: true, fillColor: AppTheme.inputColor, border: OutlineInputBorder(borderRadius: BorderRadius.circular(15), borderSide: BorderSide.none))),
                          const SizedBox(height: 15),
                          const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold)), const SizedBox(height: 5),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 15), decoration: BoxDecoration(color: AppTheme.inputColor, borderRadius: BorderRadius.circular(15)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: prioridadSel, isExpanded: true,
                                items: ['Crítica', 'Alta', 'Media', 'Baja', 'Mínima'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (nuevoVal) => setStateModal(() => prioridadSel = nuevoVal!),
                              ),
                            ),
                          ),
                          const SizedBox(height: 30),
                          Row(
                            children: [
                              Expanded(child: ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFF90A48E), padding: const EdgeInsets.symmetric(vertical: 15)), child: const Text('Cancelar', style: TextStyle(color: Colors.white)))),
                              const SizedBox(width: 15),
                              Expanded(child: ElevatedButton(
                                onPressed: () {
                                  int nuevaPrio = 5;
                                  if (prioridadSel == 'Crítica') nuevaPrio = 1;
                                  if (prioridadSel == 'Alta') nuevaPrio = 2;
                                  if (prioridadSel == 'Media') nuevaPrio = 3;
                                  if (prioridadSel == 'Baja') nuevaPrio = 4;
                                  _enviarEdicion(ticket['_id'], nombreCtrl.text, probCtrl.text, nuevaPrio);
                                },
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
        });
      },
    );
  }



  

  void _mostrarModalExitoEdicion() {
    showDialog(
      context: context,
      builder: (context) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: Container(
          padding: const EdgeInsets.all(20), decoration: BoxDecoration(color: AppTheme.backgroundColor, borderRadius: BorderRadius.circular(20)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const CircleAvatar(radius: 30, backgroundColor: Color(0xFF7D8B7A), child: Icon(Icons.check, color: Colors.white, size: 40)), const SizedBox(height: 15),
              const Text('¡Ticket Editado!', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)), const Divider(color: Colors.black54, thickness: 1), const SizedBox(height: 10),
              const Text('El ticket se editó correctamente', style: TextStyle(color: Colors.grey, fontSize: 16)), const SizedBox(height: 25),
              ElevatedButton(onPressed: () => Navigator.pop(context), style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 12)), child: const Text('Aceptar')),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _eliminarTicket(String idTicket) async {
    bool confirmar = await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('¿Eliminar Ticket?'), content: const Text('Esta acción no se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancelar', style: TextStyle(color: Colors.grey))),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C5C)), child: const Text('Eliminar')),
        ],
      ),
    ) ?? false; 
    if (!confirmar) return;

    setState(() => _isLoading = true);
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.delete(Uri.parse('http://10.0.2.2:3005/tickets/$idTicket'), headers: {'Authorization': 'Bearer $token'});
      if (response.statusCode == 200) _obtenerTickets(); 
      else setState(() => _isLoading = false);
    } catch (e) { setState(() => _isLoading = false); }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor, elevation: 0, iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        //title: const Row(mainAxisAlignment: MainAxisAlignment.center, children: [Icon(Icons.confirmation_num, color: AppTheme.primaryColor), SizedBox(width: 8), Text('GestiónTech', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)), SizedBox(width: 48)]),
        title: Row(
  mainAxisAlignment: MainAxisAlignment.center,
  children: [
    Image.asset('assets/images/logotech.png', height: 35), // <-- TU LOGO AQUÍ
    const SizedBox(width: 48), // Mantenemos este espacio para que quede bien centrado
  ],
),
      ),
      drawer: const CustomDrawer(), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20), 
              //decoration: const BoxDecoration(color: Color(0xFF7D8B7A)), 
              decoration: const BoxDecoration(
  color: Color.fromARGB(255, 131, 148, 127),
  image: DecorationImage(
    image: AssetImage('assets/images/fondo_tech.png'), // <-- TU ILUSTRACIÓN AQUÍ
    fit: BoxFit.cover, // Para que cubra todo el contenedor
    opacity: 0.7, // Opacidad baja para que no estorbe la lectura de los números
  ),
),
              child: Column(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15), decoration: BoxDecoration(color: AppTheme.inputColor, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('Pendientes:', '$_pendientes'), Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.5)),
                        _buildStat('Total:', '$_total'), Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.5)),
                        _buildStat('Atendido:', '$_atendidos'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () async {
                      await Navigator.push(context, MaterialPageRoute(builder: (context) => const AddTicketScreen()));
                      _obtenerTickets(); 
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryColor, padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15)), child: const Text('Agrega un Ticket'),
                  ),
                ],
              ),
            ),
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20), padding: const EdgeInsets.all(15), decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)]),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Filtrar:', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 35, 
                            child: TextField(
                              controller: _searchController, // <-- CONECTADO
                              onChanged: (value) => _filtrarTickets(), // <-- FILTRA AL ESCRIBIR
                              decoration: InputDecoration(hintText: 'Buscar Ticket...', contentPadding: const EdgeInsets.symmetric(horizontal: 10), border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)))
                            )
                          )
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text('Prioridad:', style: TextStyle(fontWeight: FontWeight.w600)), const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 35, padding: const EdgeInsets.symmetric(horizontal: 10), decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: _filtroPrioridad, // <-- CONECTADO
                                isExpanded: true,
                                items: ['Todas', 'Crítica', 'Alta', 'Media', 'Baja', 'Mínima'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (nuevoVal) {
                                  setState(() {
                                    _filtroPrioridad = nuevoVal!;
                                    _filtrarTickets(); // <-- FILTRA AL CAMBIAR LA OPCIÓN
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _filtrarTickets, // El botón también hace la magia
                          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 35)), child: const Text('Filtrar')
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),
            _isLoading 
              ? const CircularProgressIndicator(color: AppTheme.primaryColor)
              : _ticketsFiltrados.isEmpty // <-- CAMBIADO A TICKETS FILTRADOS
                  ? const Padding(padding: EdgeInsets.all(20.0), child: Text('No hay tickets que coincidan', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _ticketsFiltrados.length, // <-- CAMBIADO A TICKETS FILTRADOS
                      itemBuilder: (context, index) => Padding(padding: const EdgeInsets.only(left: 20, right: 20, bottom: 20), child: _buildTicketCard(_ticketsFiltrados[index])),
                    ),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildStat(String title, String value) {
    return Column(children: [Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)), const SizedBox(height: 5), Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey))]);
  }

  Widget _buildTicketCard(dynamic ticket) {
    bool esPendiente = ticket['estado'] ?? true;
    String idCorto = ticket['_id'].toString().substring(ticket['_id'].toString().length - 5); 
    int prioridad = ticket['prioridad'] ?? 5;

    Color colorPrioridad;
    switch (prioridad) {
      case 1: colorPrioridad = const Color(0xFFdc3545); break;
      case 2: colorPrioridad = const Color(0xFFfd7e14); break;
      case 3: colorPrioridad = const Color(0xFFffc107); break;
      case 4: colorPrioridad = const Color(0xFF0d6efd); break;
      case 5: default: colorPrioridad = const Color(0xFF6dbd58); break;
    }

    return Container(
      decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(5), boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)]),
      child: Row(
        children: [
          Container(width: 25, height: 165, decoration: BoxDecoration(color: colorPrioridad, borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)))),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(ticket['nombre'] ?? 'Sin nombre', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  Text(idCorto, style: const TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                  const SizedBox(height: 10),
                  Text(ticket['problema'] ?? 'Sin descripción', style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold), maxLines: 2, overflow: TextOverflow.ellipsis),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          const Text('Estatus: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text(esPendiente ? 'Pendiente' : 'Atendido', style: TextStyle(color: esPendiente ? const Color(0xFFFF5C5C) : const Color(0xFF7D8B7A), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      if (_esAdmin)
                        GestureDetector(onTap: () => _cambiarEstatusTicket(ticket['_id'], esPendiente), child: Icon(esPendiente ? Icons.check_box_outline_blank : Icons.check_box, size: 28, color: AppTheme.primaryColor)),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ElevatedButton.icon(onPressed: () => _mostrarModalEditar(ticket), icon: const Icon(Icons.edit, size: 16, color: Colors.black), label: const Text('Editar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFFD166), minimumSize: const Size(90, 35))),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(onPressed: () => _eliminarTicket(ticket['_id']), icon: const Icon(Icons.delete, size: 16, color: Colors.black), label: const Text('Eliminar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)), style: ElevatedButton.styleFrom(backgroundColor: const Color(0xFFFF5C5C), minimumSize: const Size(90, 35))),
                    ],
                  )
                ],
              ),
            ),
          )
        ],
      ),
    );
  }
}