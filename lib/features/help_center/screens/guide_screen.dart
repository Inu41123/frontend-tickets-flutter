import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';

class GuideScreen extends StatelessWidget {
  const GuideScreen({super.key});

  final steps = const [
    {
      'numero': '1',
      'icon': Icons.login,
      'title': 'Iniciar Sesión',
      'desc': 'Ingresa tu correo y\ncontraseña'
    },
    {
      'numero': '2',
      'icon': Icons.person,
      'title': 'Crear Cuenta',
      'desc': 'Regístrate con tus datos\nen caso de no tener\ncuenta'
    },
    {
      'numero': '3',
      'icon': Icons.confirmation_number,
      'title': 'Crear un Ticket',
      'desc': 'Pulsa “Agregar un\nTicket”'
    },
    {
      'numero': '4',
      'icon': Icons.edit,
      'title': 'Editar Ticket',
      'desc': 'Modifica y Guarda\ncambios'
    },
    {
      'numero': '5',
      'icon': Icons.filter_alt,
      'title': 'Filtrar Tickets',
      'desc': 'Busca y filtra por\nprioridad'
    },
    {
      'numero': '6',
      'icon': Icons.manage_history,
      'title': 'Estado de Tickets',
      'desc': 'Marca si ya realizaste algún\nticket con “Pendiente o\nAtendido”'
    },
    {
      'numero': '7',
      'icon': Icons.settings,
      'title': 'Configuración',
      'desc': 'Edita tu perfil'
    },
    {
      'numero': '8',
      'icon': Icons.help,
      'title': 'Centro de Ayuda',
      'desc': 'Preguntas frecuentes'
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Column(
          children: [
            const GuideHeader(),
            const SizedBox(height: 18),
            Expanded(
              child: GridView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                itemCount: steps.length,
                gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2,
                  mainAxisSpacing: 18,
                  crossAxisSpacing: 18,
                  childAspectRatio: .92,
                ),
                itemBuilder: (context, index) {
                  final item = steps[index];

                  return GuideCard(
                    number: item['numero'] as String,
                    icon: item['icon'] as IconData,
                    title: item['title'] as String,
                    desc: item['desc'] as String,
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class GuideHeader extends StatelessWidget {
  const GuideHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          height: 68,
          alignment: Alignment.center,
          child: const AppLogo(height: 34),
        ),
        Row(
          children: [
            const SizedBox(width: 28),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, size: 34),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Guía Paso a Paso',
                  style: TextStyle(
                    color: AppColors.texto,
                    fontSize: 21,
                    fontWeight: FontWeight.w900,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 62),
          ],
        ),
        const SizedBox(height: 22),
        Container(
          height: 1.2,
          margin: const EdgeInsets.symmetric(horizontal: 28),
          color: AppColors.texto.withOpacity(.65),
        ),
      ],
    );
  }
}

class GuideCard extends StatelessWidget {
  final String number;
  final IconData icon;
  final String title;
  final String desc;

  const GuideCard({
    super.key,
    required this.number,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Material(
          elevation: 4,
          shadowColor: Colors.black38,
          borderRadius: BorderRadius.circular(10),
          child: Container(
            decoration: BoxDecoration(
              color: AppColors.verdeClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Column(
              children: [
                Container(
                  height: 34,
                  alignment: Alignment.center,
                  decoration: const BoxDecoration(
                    color: AppColors.verde,
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(10),
                      topRight: Radius.circular(10),
                    ),
                  ),
                  child: Text(
                    title,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                ),
                const SizedBox(height: 13),
                Icon(icon, size: 45, color: AppColors.texto),
                const SizedBox(height: 10),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 7),
                  child: Text(
                    desc,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: 11.5,
                      height: 1.08,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
        Positioned(
          left: -9,
          top: -8,
          child: CircleAvatar(
            radius: 17,
            backgroundColor: Color(0xFF8BA9A3),
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w900,
              ),
            ),
          ),
        ),
        Positioned(
          right: -8,
          bottom: -8,
          child: Icon(
            Icons.settings,
            size: 35,
            color: const Color(0xFFBFD8D0).withOpacity(.9),
          ),
        ),
      ],
    );
  }
}