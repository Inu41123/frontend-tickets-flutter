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

class _AddTicketScreenState extends State<AddTicketScreen> with SingleTickerProviderStateMixin {
  final TextEditingController _nombreController = TextEditingController();
  final TextEditingController _descripcionController = TextEditingController();
  String _prioridadSeleccionada = 'Baja';
  
  // Controladores de animación
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;
  late Animation<Offset> _slideAnimation;
  
  // Para el efecto de carga del botón
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    // Configurar animaciones de entrada
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    
    _fadeAnimation = Tween<double>(begin: 0.0, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOut),
    );
    
    _slideAnimation = Tween<Offset>(begin: const Offset(0, 0.3), end: Offset.zero).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeOutCubic),
    );
    
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    _nombreController.dispose();
    _descripcionController.dispose();
    super.dispose();
  }

  Future<void> _enviarTicket() async {
    if (_nombreController.text.isEmpty || _descripcionController.text.isEmpty) {
      // Animación de error en los campos
      await _shakeFields();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Por favor, llena todos los campos'),
          backgroundColor: Colors.orange,
          duration: Duration(milliseconds: 1500),
        ),
      );
      return;
    }

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

    setState(() => _isLoading = true);

    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString('token');

      if (token == null) {
        if (mounted) {
          setState(() => _isLoading = false);
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error: No has iniciado sesión'), backgroundColor: Colors.red),
          );
        }
        return;
      }

      final response = await http.post(
        Uri.parse('https://backend-tickets-flutter.onrender.com/tickets'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: jsonEncode({
          'nombre': _nombreController.text.trim(),
          'problema': _descripcionController.text.trim(),
          'prioridad': prioridadNumero
        }),
      );

      setState(() => _isLoading = false);

      if (response.statusCode == 201) {
        await _mostrarModalExito();
      } else {
        final error = jsonDecode(response.body);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(error['mensaje'] ?? 'Error desconocido'), backgroundColor: Colors.red),
          );
        }
      }
    } catch (e) {
      setState(() => _isLoading = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Error al conectar con el servidor'), backgroundColor: Colors.red),
        );
      }
    }
  }

  // Animación de "shake" para campos vacíos
  Future<void> _shakeFields() async {
    final scaffoldContext = context;
    // Encontrar los campos y hacerles shake
    // (efecto visual simple con un breve delay)
    for (int i = 0; i < 3; i++) {
      await Future.delayed(const Duration(milliseconds: 50));
      if (mounted) {
        setState(() {});
      }
    }
  }

  Future<void> _mostrarModalExito() async {
    // Animación del modal con escala
    await showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return Dialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 400),
            tween: Tween<double>(begin: 0.8, end: 1.0),
            curve: Curves.elasticOut,
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: child,
              );
            },
            child: Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.backgroundColor,
                borderRadius: BorderRadius.circular(20),
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // Animación del ícono de check
                  TweenAnimationBuilder(
                    duration: const Duration(milliseconds: 500),
                    tween: Tween<double>(begin: 0, end: 1),
                    curve: Curves.elasticOut,
                    builder: (context, double value, child) {
                      return Transform.scale(
                        scale: value,
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            boxShadow: [
                              BoxShadow(
                                color: const Color(0xFF7D8B7A).withOpacity(0.3),
                                blurRadius: 20,
                                spreadRadius: 5 * (1 - value),
                              ),
                            ],
                          ),
                          child: const CircleAvatar(
                            radius: 30,
                            backgroundColor: Color(0xFF7D8B7A),
                            child: Icon(Icons.check, color: Colors.white, size: 40),
                          ),
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 15),
                  const Text(
                    '¡Ticket Registrado!',
                    style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                  ),
                  const Divider(color: Colors.black54, thickness: 1),
                  const SizedBox(height: 10),
                  const Text(
                    'El ticket se guardó con éxito',
                    style: TextStyle(color: Colors.grey, fontSize: 16),
                  ),
                  const SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.of(context).pop();
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
            SizedBox(width: 48),
          ],
        ),
      ),
      body: Stack(
        children: [
          // FONDO: Engranajes con animación de rotación suave
          _buildGearAnimation('assets/images/eng_dere_arriba_agregarticket.png', top: -20, right: -30, width: 150, opacity: 0.5, speed: 0.5),
          _buildGearAnimation('assets/images/engrane_izq.png', bottom: -20, left: -30, width: 150, opacity: 0.3, speed: -0.3),
          _buildGearAnimation('assets/images/eng_dere_abajo_agregarticket.png', bottom: 50, right: -40, width: 180, opacity: 0.4, speed: 0.7),

          // CONTENIDO PRINCIPAL CON ANIMACIONES DE ENTRADA
          FadeTransition(
            opacity: _fadeAnimation,
            child: SlideTransition(
              position: _slideAnimation,
              child: SafeArea(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Header con animación de botón de regreso
                      Row(
                        children: [
                          _buildAnimatedBackButton(),
                          const Expanded(
                            child: Text(
                              'Registrar Ticket',
                              textAlign: TextAlign.center,
                              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                            ),
                          ),
                          const SizedBox(width: 48),
                        ],
                      ),
                      const SizedBox(height: 30),

                      // Campo Nombre con animación al focus
                      _buildAnimatedTextField(
                        label: 'Nombre:',
                        hint: 'Introduce el nombre del ticket',
                        controller: _nombreController,
                      ),
                      const SizedBox(height: 20),

                      // Campo Descripción
                      _buildAnimatedTextField(
                        label: 'Descripción:',
                        hint: 'Describe la problemática',
                        controller: _descripcionController,
                        maxLines: 5,
                        maxLength: 150,
                      ),
                      const SizedBox(height: 10),

                      // Campo Prioridad con animación
                      _buildAnimatedPriorityDropdown(),
                      const SizedBox(height: 40),

                      // Botón Enviar con animaciones de hover/click
                      Center(
                        child: _buildAnimatedSubmitButton(),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Widget: Engranaje con animación de rotación
  Widget _buildGearAnimation(String asset, {double? top, double? right, double? bottom, double? left, required double width, required double opacity, required double speed}) {
    return Positioned(
      top: top,
      right: right,
      bottom: bottom,
      left: left,
      child: TweenAnimationBuilder(
        duration: const Duration(seconds: 20),
        tween: Tween<double>(begin: 0, end: 360),
        builder: (context, double angle, child) {
          return Transform.rotate(
            angle: angle * 3.14159 / 180 * speed,
            child: Opacity(
              opacity: opacity,
              child: Image.asset(asset, width: width),
            ),
          );
        },
      ),
    );
  }

  // Widget: Botón de regreso animado
  Widget _buildAnimatedBackButton() {
    return StatefulBuilder(
      builder: (context, setStateButton) {
        return GestureDetector(
          onTapDown: (_) => setStateButton(() {}),
          onTapUp: (_) {
            setStateButton(() {});
            Navigator.pop(context);
          },
          onTapCancel: () => setStateButton(() {}),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 150),
            tween: Tween<double>(begin: 1, end: 0.8),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: 1 - (scale * 0.2),
                child: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.1),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.arrow_back, size: 30, color: Colors.black),
                ),
              );
            },
          ),
        );
      },
    );
  }

  // Widget: Campo de texto con animaciones
  Widget _buildAnimatedTextField({
    required String label,
    required String hint,
    required TextEditingController controller,
    int maxLines = 1,
    int? maxLength,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 5),
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 300),
          tween: Tween<double>(begin: 0, end: 1),
          builder: (context, double value, child) {
            return Transform.translate(
              offset: Offset(0, 20 * (1 - value)),
              child: Opacity(
                opacity: value,
                child: child,
              ),
            );
          },
          child: TextField(
            controller: controller,
            maxLines: maxLines,
            maxLength: maxLength,
            decoration: InputDecoration(
              hintText: hint,
              filled: true,
              fillColor: AppTheme.inputColor,
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide.none,
              ),
              focusedBorder: OutlineInputBorder(
                borderRadius: BorderRadius.circular(15),
                borderSide: BorderSide(color: AppTheme.primaryColor, width: 2),
              ),
            ),
          ),
        ),
      ],
    );
  }

  // Widget: Dropdown de prioridad animado
  Widget _buildAnimatedPriorityDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Prioridad', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        const SizedBox(height: 5),
        TweenAnimationBuilder(
          duration: const Duration(milliseconds: 400),
          tween: Tween<double>(begin: 0, end: 1),
          curve: Curves.easeOut,
          builder: (context, double value, child) {
            return Transform.scale(
              scale: 0.9 + (value * 0.1),
              child: child,
            );
          },
          child: Container(
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
                    child: _buildPriorityOption(value),
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
        ),
      ],
    );
  }

  // Opción de prioridad con color
  Widget _buildPriorityOption(String priority) {
    Color color;
    switch (priority) {
      case 'Crítica':
        color = const Color(0xFFdc3545);
        break;
      case 'Alta':
        color = const Color(0xFFfd7e14);
        break;
      case 'Media':
        color = const Color(0xFFffc107);
        break;
      case 'Baja':
        color = const Color(0xFF0d6efd);
        break;
      default:
        color = const Color(0xFF6dbd58);
    }
    return Row(
      children: [
        Container(
          width: 12,
          height: 12,
          decoration: BoxDecoration(
            color: color,
            shape: BoxShape.circle,
          ),
        ),
        const SizedBox(width: 8),
        Text(priority),
      ],
    );
  }

  // Widget: Botón de enviar con animaciones completas
  Widget _buildAnimatedSubmitButton() {
    return StatefulBuilder(
      builder: (context, setStateButton) {
        return MouseRegion(
          onEnter: (_) => setStateButton(() {}),
          onExit: (_) => setStateButton(() {}),
          child: TweenAnimationBuilder(
            duration: const Duration(milliseconds: 200),
            tween: Tween<double>(begin: 1, end: 1),
            builder: (context, double scale, child) {
              return Transform.scale(
                scale: scale,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 300),
width: _isLoading ? 60 : MediaQuery.of(context).size.width,
                  height: 50,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(_isLoading ? 30 : 10),
                    boxShadow: [
                      BoxShadow(
                        color: AppTheme.primaryColor.withOpacity(0.4),
                        blurRadius: 12,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: ElevatedButton(
                    onPressed: _isLoading ? null : _enviarTicket,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppTheme.primaryColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(_isLoading ? 30 : 10),
                      ),
                      animationDuration: const Duration(milliseconds: 300),
                    ),
                    child: _isLoading
                        ? const SizedBox(
                            width: 24,
                            height: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2.5,
                              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : const Text('Enviar Ticket', style: TextStyle(fontSize: 16)),
                  ),
                ),
              );
            },
          ),
        );
      },
    );
  }
}