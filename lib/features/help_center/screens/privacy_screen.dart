import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';

class PrivacyScreen extends StatelessWidget {
  const PrivacyScreen({super.key});

  final policies = const [
    {
      'icon': Icons.storage,
      'title': 'Datos Recopilados',
      'desc': 'Recopilamos tu nombre, correo y actividad en la app',
    },
    {
      'icon': Icons.shield,
      'title': 'Protección y Seguridad',
      'desc':
          'Tus datos están cifrados y seguros. No los compartimos con terceros sin tu permiso',
    },
    {
      'icon': Icons.groups,
      'title': 'Derechos del Usuario',
      'desc':
          'Puedes eliminar tu cuenta ya que al eliminar tu cuenta perderemos tus datos',
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,
      body: SafeArea(
        child: Column(
          children: [
            const PrivacyHeader(),
            const SizedBox(height: 25),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 28),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Tu privacidad es importante para nosotros.\nA continuación te explicamos cómo protegemos tus datos',
                  style: TextStyle(
                    color: AppColors.texto,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 25),
            Expanded(
              child: ListView.builder(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                itemCount: policies.length,
                itemBuilder: (context, index) {
                  final item = policies[index];

                  return Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: PrivacyCard(
                      icon: item['icon'] as IconData,
                      title: item['title'] as String,
                      desc: item['desc'] as String,
                    ),
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

class PrivacyHeader extends StatelessWidget {
  const PrivacyHeader({super.key});

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
              child: const Icon(
                Icons.arrow_back,
                size: 34,
                color: Colors.black,
              ),
            ),
            const Expanded(
              child: Center(
                child: Text(
                  'Políticas de Privacidad',
                  style: TextStyle(
                    color: AppColors.texto,
                    fontSize: 20,
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

class PrivacyCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String desc;

  const PrivacyCard({
    super.key,
    required this.icon,
    required this.title,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Material(
      elevation: 4,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(10),
      child: Stack(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
            decoration: BoxDecoration(
              color: AppColors.verdeClaro,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(icon, size: 35, color: Colors.black),
                const SizedBox(width: 18),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: const TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w900,
                          color: Colors.black,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Container(height: 1, color: Colors.black54),
                      const SizedBox(height: 8),
                      Text(
                        desc,
                        style: const TextStyle(
                          fontSize: 12.5,
                          color: AppColors.texto,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            right: -7,
            bottom: -7,
            child: Icon(
              Icons.settings,
              size: 36,
              color: const Color(0xFFBFD8D0).withOpacity(.95),
            ),
          ),
        ],
      ),
    );
  }
}