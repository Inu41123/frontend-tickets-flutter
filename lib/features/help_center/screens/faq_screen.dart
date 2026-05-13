import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';

class FAQScreen extends StatelessWidget {
  const FAQScreen({super.key});

  static const preguntas = [
    FAQItem(
      icon: Icons.add_circle_outline,
      pregunta: '¿Cómo puedo crear un ticket nuevo?',
      respuesta:
          'Ve a la pantalla principal y toca “Agregar un Ticket”. Completa los campos requeridos y guarda.',
    ),
    FAQItem(
      icon: Icons.edit,
      pregunta: '¿Cómo edito o actualizo un ticket existente?',
      respuesta:
          'Abre el ticket desde la lista y selecciona “Editar”. Cambia los datos y guarda los cambios.',
    ),
    FAQItem(
      icon: Icons.hourglass_empty,
      pregunta: '¿Qué significan los estados Pendiente, En progreso y Atendido?',
      respuesta:
          'Pendiente: aún no se ha trabajado.\nAtendido: el problema fue resuelto.',
    ),
    FAQItem(
      icon: Icons.key,
      pregunta: '¿Cómo puedo recuperar mi contraseña?',
      respuesta:
          'En la pantalla de inicio de sesión, selecciona “¿Olvidaste tu contraseña?” y sigue las instrucciones.',
    ),
    FAQItem(
      icon: Icons.manage_accounts,
      pregunta: '¿Cómo cambio mi información de cuenta?',
      respuesta: 'En el menú, entra a “Perfil” y edita tus datos personales.',
    ),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Column(
          children: [
            const FAQHeader(),
            const SizedBox(height: 48),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 28),
                itemCount: preguntas.length,
                cacheExtent: 500,
                itemBuilder: (context, index) {
                  return FAQCard(
                    key: ValueKey(preguntas[index].pregunta),
                    item: preguntas[index],
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

class FAQItem {
  final IconData icon;
  final String pregunta;
  final String respuesta;

  const FAQItem({
    required this.icon,
    required this.pregunta,
    required this.respuesta,
  });
}

class FAQHeader extends StatelessWidget {
  const FAQHeader({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          alignment: Alignment.center,
          height: 68,
          child: const AppLogo(height: 34),
        ),
        Row(
          children: [
            const SizedBox(width: 26),
            GestureDetector(
              onTap: () => Navigator.pop(context),
              child: const Icon(Icons.arrow_back, size: 34),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Preguntas Frecuentes',
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
        const SizedBox(height: 24),
        Container(
          height: 1.2,
          margin: const EdgeInsets.symmetric(horizontal: 28),
          color: AppColors.texto.withOpacity(.65),
        ),
      ],
    );
  }
}

class FAQCard extends StatefulWidget {
  final FAQItem item;

  const FAQCard({
    super.key,
    required this.item,
  });

  @override
  State<FAQCard> createState() => _FAQCardState();
}

class _FAQCardState extends State<FAQCard>
    with AutomaticKeepAliveClientMixin {
  bool isOpen = false;

  @override
  bool get wantKeepAlive => true;

  void toggle() {
    setState(() {
      isOpen = !isOpen;
    });
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);

    return Padding(
      padding: const EdgeInsets.only(bottom: 16),
      child: Material(
        elevation: 4,
        shadowColor: Colors.black38,
        borderRadius: BorderRadius.circular(9),
        child: InkWell(
          borderRadius: BorderRadius.circular(9),
          onTap: toggle,
          child: Stack(
            children: [
              Container(
                width: double.infinity,
                padding: const EdgeInsets.fromLTRB(14, 15, 14, 15),
                decoration: BoxDecoration(
                  color: AppColors.verdeClaro,
                  borderRadius: BorderRadius.circular(9),
                ),
                child: AnimatedSize(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOut,
                  alignment: Alignment.topCenter,
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Icon(widget.item.icon, size: 24),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              widget.item.pregunta,
                              textAlign: TextAlign.center,
                              style: const TextStyle(
                                color: AppColors.texto,
                                fontSize: 13.2,
                                fontWeight: FontWeight.w900,
                                height: 1.1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (isOpen) ...[
                        const SizedBox(height: 12),
                        Container(
                          height: 1,
                          color: AppColors.texto.withOpacity(.65),
                        ),
                        const SizedBox(height: 12),
                        Text(
                          widget.item.respuesta,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.texto,
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            height: 1.2,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
              Positioned(
                right: -7,
                bottom: -7,
                child: Icon(
                  Icons.settings,
                  size: 34,
                  color: const Color(0xFFBFD8D0).withOpacity(.95),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}