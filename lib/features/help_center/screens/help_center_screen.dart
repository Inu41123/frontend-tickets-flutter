
import 'package:flutter/material.dart';

import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
import '../widgets/rotating_gear.dart';

import 'faq_screen.dart';
import 'guide_screen.dart';
import 'privacy_screen.dart';

class HelpCenterScreen extends StatelessWidget {
  const HelpCenterScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.fondo,

      body: SafeArea(
        child: Stack(
          children: [
            const HelpGears(),

            Column(
              children: [
                const SizedBox(height: 16),

                const Center(
                  child: AppLogo(height: 40),
                ),

                const SizedBox(height: 14),

                Container(
                  width: double.infinity,
                  height: 96,
                  color: const Color(0xFFA8BBB0),
                  alignment: Alignment.centerLeft,
                  padding: const EdgeInsets.only(left: 28),
                  child: GestureDetector(
                    onTap: () => Navigator.pop(context),
                    child: const Icon(
                      Icons.arrow_back,
                      size: 38,
                      color: Colors.black,
                    ),
                  ),
                ),

                const SizedBox(height: 90),

                HelpButton(
                  text: 'Preguntas frecuentes',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const FAQScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                HelpButton(
                  text: 'Guía paso a paso',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const GuideScreen(),
                      ),
                    );
                  },
                ),

                const SizedBox(height: 20),

                HelpButton(
                  text: 'Políticas de privacidad',
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => const PrivacyScreen(),
                      ),
                    );
                  },
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class HelpButton extends StatelessWidget {
  final String text;
  final VoidCallback onTap;

  const HelpButton({
    super.key,
    required this.text,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,

      child: Container(
        width: 330,
        height: 58,

        decoration: BoxDecoration(
          color: const Color(0xFFE8EEE0),

          borderRadius: BorderRadius.circular(12),

          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(.18),
              blurRadius: 7,
              offset: const Offset(0, 4),
            ),
          ],
        ),

        child: Center(
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.texto,
              fontSize: 18,
              fontWeight: FontWeight.w900,
            ),
          ),
        ),
      ),
    );
  }
}

class HelpGears extends StatelessWidget {
  const HelpGears({super.key});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          right: -40,
          top: 255,
          child: RotatingGear(
            size: 120,
            color: AppColors.texto.withOpacity(.70),
          ),
        ),

        Positioned(
          left: -70,
          top: 420,
          child: RotatingGear(
            size: 150,
            color: const Color(0xFFE6F0E4).withOpacity(.85),
          ),
        ),

        Positioned(
          right: -35,
          bottom: 135,
          child: RotatingGear(
            size: 110,
            color: const Color(0xFFC7DDD6).withOpacity(.95),
          ),
        ),

        Positioned(
          left: -18,
          bottom: 55,
          child: RotatingGear(
            size: 72,
            color: const Color(0xFFD9E8D3).withOpacity(.90),
          ),
        ),
      ],
    );
  }
}