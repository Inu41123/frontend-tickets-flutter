// lib/features/tickets/screens/home_screen.dart
import 'package:flutter/material.dart';
import '../../../core/theme/app_theme.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.backgroundColor,
      // 1. App Bar con el menú hamburguesa y Logo
      appBar: AppBar(
        backgroundColor: AppTheme.backgroundColor,
        elevation: 0,
        iconTheme: const IconThemeData(color: AppTheme.primaryColor),
        title: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.confirmation_num, color: AppTheme.primaryColor), // Icono temporal de ticket
            const SizedBox(width: 8),
            const Text('GestiónTech', style: TextStyle(color: AppTheme.primaryColor, fontWeight: FontWeight.bold)),
            const SizedBox(width: 48), // Espacio para centrar compensando el ícono de menú
          ],
        ),
      ),
      drawer: const Drawer(), // Menú lateral en blanco por ahora
      
      body: SingleChildScrollView(
        child: Column(
          children: [
            // 2. Sección del fondo verde con las Estadísticas
            Container(
              width: double.infinity,
              padding: const EdgeInsets.only(top: 30, bottom: 50, left: 20, right: 20),
              decoration: const BoxDecoration(
                color: Color(0xFF7D8B7A), // El color verde opaco del fondo
                // image: DecorationImage(image: AssetImage('assets/images/fondo_tech.png'), fit: BoxFit.cover, opacity: 0.2),
              ),
              child: Column(
                children: [
                  // Tarjeta blanca de Pendientes / Total / Atendido
                  Container(
                    padding: const EdgeInsets.symmetric(vertical: 15),
                    decoration: BoxDecoration(color: AppTheme.inputColor, borderRadius: BorderRadius.circular(10)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        _buildStat('Pendientes:', '5'),
                        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.5)),
                        _buildStat('Total:', '5'),
                        Container(width: 1, height: 40, color: Colors.grey.withOpacity(0.5)),
                        _buildStat('Atendido:', '0'),
                      ],
                    ),
                  ),
                  const SizedBox(height: 25),
                  
                  // Botón Agrega un Ticket
                  ElevatedButton(
                    onPressed: () {},
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 15),
                    ),
                    child: const Text('Agrega un Ticket'),
                  ),
                ],
              ),
            ),

            // 3. Sección de Filtros (Superpuesta hacia arriba)
            Transform.translate(
              offset: const Offset(0, -30),
              child: Container(
                margin: const EdgeInsets.symmetric(horizontal: 20),
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 8, spreadRadius: 1)],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        const Text('Filtrar:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: SizedBox(
                            height: 35,
                            child: TextField(
                              decoration: InputDecoration(
                                hintText: 'Buscar Ticket...',
                                contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                                border: OutlineInputBorder(borderRadius: BorderRadius.circular(5)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 15),
                    Row(
                      children: [
                        const Text('Filtrar por prioridad:', style: TextStyle(fontWeight: FontWeight.w600)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Container(
                            height: 35,
                            padding: const EdgeInsets.symmetric(horizontal: 10),
                            decoration: BoxDecoration(border: Border.all(color: Colors.grey), borderRadius: BorderRadius.circular(5)),
                            child: DropdownButtonHideUnderline(
                              child: DropdownButton<String>(
                                value: 'Todas',
                                isExpanded: true,
                                items: ['Todas', 'Alta', 'Media', 'Baja'].map((String val) => DropdownMenuItem(value: val, child: Text(val))).toList(),
                                onChanged: (_) {},
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {},
                          style: ElevatedButton.styleFrom(minimumSize: const Size(80, 35)),
                          child: const Text('Filtrar'),
                        )
                      ],
                    )
                  ],
                ),
              ),
            ),

            // 4. Tarjeta del Ticket
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20),
              child: _buildTicketCard(),
            ),
            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  // Mini-widget para las estadísticas
  Widget _buildStat(String title, String value) {
    return Column(
      children: [
        Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
        const SizedBox(height: 5),
        Text(value, style: const TextStyle(fontSize: 16, color: Colors.grey)),
      ],
    );
  }

  // Mini-widget para la tarjeta del ticket
  Widget _buildTicketCard() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(5),
        boxShadow: const [BoxShadow(color: Colors.black12, blurRadius: 5, spreadRadius: 1)],
      ),
      child: Row(
        children: [
          // Barra de color roja
          Container(
            width: 25,
            height: 165,
            decoration: const BoxDecoration(
              color: Color(0xFFFF5C5C),
              borderRadius: BorderRadius.only(topLeft: Radius.circular(5), bottomLeft: Radius.circular(5)),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('Internet Lento', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const Text('012', style: TextStyle(color: Colors.grey, decoration: TextDecoration.underline)),
                  const SizedBox(height: 10),
                  const Text('El dia 7 de Mayo del 2026 el internet comenzó con fallas a las 10 horas', style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Row(
                        children: [
                          Text('Estatus: ', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
                          Text('Pendiente', style: TextStyle(color: Color(0xFFFF5C5C), fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      Icon(Icons.check_box_outline_blank, size: 28, color: AppTheme.primaryColor),
                    ],
                  ),
                  const SizedBox(height: 15),
                  Row(
                    children: [
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.edit, size: 16, color: Colors.black),
                        label: const Text('Editar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFFD166), // Amarillo
                          minimumSize: const Size(90, 35),
                        ),
                      ),
                      const SizedBox(width: 15),
                      ElevatedButton.icon(
                        onPressed: () {},
                        icon: const Icon(Icons.delete, size: 16, color: Colors.black),
                        label: const Text('Eliminar', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFFF5C5C), // Rojo
                          minimumSize: const Size(90, 35),
                        ),
                      ),
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