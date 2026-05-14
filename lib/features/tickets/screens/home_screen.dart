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
        Uri.parse('https://backend-tickets-flutter.onrender.com/tickets'),
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

  Future<void> _cambiarEstatusTicket(String idTicket, bool estadoActual) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');
      final response = await http.put(
        Uri.parse('https://backend-tickets-flutter.onrender.com/tickets/$idTicket/status'),
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
        Uri.parse('https://backend-tickets-flutter.onrender.com/tickets/$idTicket'),
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

// ==========================================
  // FUNCIÓN PARA PINTAR EL COLOR DE LA PRIORIDAD
  // ==========================================
  Widget _buildPriorityOption(String priority) {
    Color color;
    switch (priority) {
      case 'Crítica': color = const Color(0xFFdc3545); break;
      case 'Alta': color = const Color(0xFFfd7e14); break;
      case 'Media': color = const Color(0xFFffc107); break;
      case 'Baja': color = const Color(0xFF0d6efd); break;
      case 'Todas': color = Colors.grey; break; // <-- Le agregamos gris al filtro general
      default: color = const Color(0xFF6dbd58); // Mínima
    }
    return Row(
      children: [
        Container(width: 12, height: 12, decoration: BoxDecoration(color: color, shape: BoxShape.circle)),
        const SizedBox(width: 8), 
        Text(priority),
      ],
    );
  }

  // --- FUNCIONES PARA MOSTRAR LOS MODALES DE EDICIÓN ---
  void _mostrarModalEditar(dynamic ticket) {
    TextEditingController nombreCtrl =
        TextEditingController(text: ticket['nombre']);

    TextEditingController probCtrl =
        TextEditingController(text: ticket['problema']);

    int prioridadNum = ticket['prioridad'] ?? 5;

    String prioridadSel = 'Mínima';

    if (prioridadNum == 1) prioridadSel = 'Crítica';
    if (prioridadNum == 2) prioridadSel = 'Alta';
    if (prioridadNum == 3) prioridadSel = 'Media';
    if (prioridadNum == 4) prioridadSel = 'Baja';

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setStateModal) {
            return Dialog(
              backgroundColor: Colors.transparent,
              insetPadding: const EdgeInsets.all(18),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(22),
                child: Stack(
                  children: [
                    Container(
                      color: Colors.white,
                    ),

                    Positioned(
                      top: 120,
                      right: -35,
                      child: Opacity(
                        opacity: 0.22,
                        child: Image.asset(
                          'assets/images/eng_dere_arriba_editicket.png',
                          width: 145,
                        ),
                      ),
                    ),

                    Positioned(
                      left: -55,
                      bottom: 180,
                      child: Opacity(
                        opacity: 0.22,
                        child: Image.asset(
                          'assets/images/engrane_izq.png',
                          width: 185,
                        ),
                      ),
                    ),

                    Positioned(
                      right: -30,
                      bottom: -35,
                      child: Opacity(
                        opacity: 0.30,
                        child: Image.asset(
                          'assets/images/eng_izq_aba_editicket.png',
                          width: 165,
                        ),
                      ),
                    ),

                    SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              vertical: 22,
                            ),
                            color: const Color(0xFF90A48E),
                            child: const Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Icon(
                                  Icons.edit,
                                  color: Colors.white,
                                  size: 26,
                                ),
                                SizedBox(width: 12),
                                Text(
                                  'Editar Ticket',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 25,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),
                              ],
                            ),
                          ),

                          Padding(
                            padding: const EdgeInsets.fromLTRB(
                              22,
                              22,
                              22,
                              24,
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Nombre:',
                                  style: TextStyle(
                                    color: Color(0xFF1D2E36),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextField(
                                  controller: nombreCtrl,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFE9EEDF)
                                        .withOpacity(0.90),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Descripción:',
                                  style: TextStyle(
                                    color: Color(0xFF1D2E36),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                TextField(
                                  controller: probCtrl,
                                  maxLines: 5,
                                  decoration: InputDecoration(
                                    filled: true,
                                    fillColor: const Color(0xFFE9EEDF)
                                        .withOpacity(0.90),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(15),
                                      borderSide: BorderSide.none,
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 18,
                                      vertical: 18,
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 20),

                                const Text(
                                  'Prioridad',
                                  style: TextStyle(
                                    color: Color(0xFF1D2E36),
                                    fontSize: 16,
                                    fontWeight: FontWeight.w900,
                                  ),
                                ),

                                const SizedBox(height: 8),

                                Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 18,
                                  ),
                                  decoration: BoxDecoration(
                                    color: const Color(0xFFE9EEDF)
                                        .withOpacity(0.90),
                                    borderRadius: BorderRadius.circular(15),
                                  ),
                                  child: DropdownButtonHideUnderline(
                                    child: DropdownButton<String>(
                                      value: prioridadSel,
                                      isExpanded: true,
                                      icon: const Icon(
                                        Icons.keyboard_arrow_down,
                                        color: Color(0xFF173847),
                                      ),
                                      items: [
                                        'Crítica',
                                        'Alta',
                                        'Media',
                                        'Baja',
                                        'Mínima',
                                      ].map((String val) {
                                        return DropdownMenuItem(
                                          value: val,
                                          // AQUÍ ESTÁ LA MAGIA DEL COLOR INTEGRADA
                                          child: _buildPriorityOption(val), 
                                        );
                                      }).toList(),
                                      onChanged: (nuevoVal) {
                                        setStateModal(() {
                                          prioridadSel = nuevoVal!;
                                        });
                                      },
                                    ),
                                  ),
                                ),

                                const SizedBox(height: 32),

                                Row(
                                  children: [
                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () =>
                                            Navigator.pop(context),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF90A48E),
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Cancelar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),

                                    const SizedBox(width: 16),

                                    Expanded(
                                      child: ElevatedButton(
                                        onPressed: () {
                                          int nuevaPrio = 5;

                                          if (prioridadSel == 'Crítica') {
                                            nuevaPrio = 1;
                                          }

                                          if (prioridadSel == 'Alta') {
                                            nuevaPrio = 2;
                                          }

                                          if (prioridadSel == 'Media') {
                                            nuevaPrio = 3;
                                          }

                                          if (prioridadSel == 'Baja') {
                                            nuevaPrio = 4;
                                          }

                                          _enviarEdicion(
                                            ticket['_id'],
                                            nombreCtrl.text,
                                            probCtrl.text,
                                            nuevaPrio,
                                          );
                                        },
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor:
                                              const Color(0xFF173847),
                                          padding:
                                              const EdgeInsets.symmetric(
                                            vertical: 16,
                                          ),
                                          shape: RoundedRectangleBorder(
                                            borderRadius:
                                                BorderRadius.circular(12),
                                          ),
                                        ),
                                        child: const Text(
                                          'Guardar',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w900,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        );
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
      final response = await http.delete(Uri.parse('https://backend-tickets-flutter.onrender.com/tickets/$idTicket'), headers: {'Authorization': 'Bearer $token'});
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
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/images/logotech.png', height: 35), 
            const SizedBox(width: 48), 
          ],
        ),
      ),
      drawer: const CustomDrawer(), 
      body: SingleChildScrollView(
        child: Column(
          children: [
            Container(
              width: double.infinity, padding: const EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20), 
              decoration: const BoxDecoration(
                color: Color.fromARGB(255, 131, 148, 127),
                image: DecorationImage(
                  image: AssetImage('assets/images/fondo_tech.png'), 
                  fit: BoxFit.cover, 
                  opacity: 0.7, 
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
                              controller: _searchController, 
                              onChanged: (value) => _filtrarTickets(), 
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
                                value: _filtroPrioridad, 
                                isExpanded: true,
                                // AQUÍ HACEMOS EL CAMBIO PARA LLAMAR A LA MAGIA DE COLORES
                                items: ['Todas', 'Crítica', 'Alta', 'Media', 'Baja', 'Mínima'].map((String val) {
                                  return DropdownMenuItem(
                                    value: val, 
                                    child: _buildPriorityOption(val) // <-- Reemplazamos el Text(val)
                                  );
                                }).toList(),
                                onChanged: (nuevoVal) {
                                  setState(() {
                                    _filtroPrioridad = nuevoVal!;
                                    _filtrarTickets(); 
                                  });
                                },
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: _filtrarTickets, 
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
              : _ticketsFiltrados.isEmpty 
                  ? const Padding(padding: EdgeInsets.all(20.0), child: Text('No hay tickets que coincidan', style: TextStyle(fontSize: 16, color: Colors.grey)))
                  : ListView.builder(
                      shrinkWrap: true, physics: const NeverScrollableScrollPhysics(), itemCount: _ticketsFiltrados.length, 
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
          Container(width: 25, height: 205, decoration: BoxDecoration(color: colorPrioridad, borderRadius: const BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)))),
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
                          Text(esPendiente ? 'Pendiente' : 'Atendido', style: TextStyle(color: esPendiente ? const Color(0xFFFF5C5C) : const Color.fromARGB(244, 17, 157, 34), fontWeight: FontWeight.bold, fontSize: 13)),
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