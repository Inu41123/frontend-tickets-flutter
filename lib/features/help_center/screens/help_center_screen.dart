import 'package:flutter/material.dart';
import '../utils/app_colors.dart';
import '../widgets/app_logo.dart';
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
                Container(
                  height: 72,
                  color: AppColors.fondo,
                  alignment: Alignment.center,
                  child: const AppLogo(height: 34),
                ),
                Container(
                  height: 112,
                  color: AppColors.verde,
                  child: Row(
                    children: [
                      const SizedBox(width: 28),
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: const Icon(
                          Icons.arrow_back,
                          size: 34,
                          color: Colors.black,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 118),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 30),
                  child: Column(
                    children: [
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
                      const SizedBox(height: 16),
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
                      const SizedBox(height: 16),
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
    return Material(
      elevation: 4,
      shadowColor: Colors.black38,
      borderRadius: BorderRadius.circular(7),
      child: InkWell(
        borderRadius: BorderRadius.circular(7),
        onTap: onTap,
        child: Container(
          height: 42,
          width: double.infinity,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            color: AppColors.verdeClaro,
            borderRadius: BorderRadius.circular(7),
          ),
          child: Text(
            text,
            style: const TextStyle(
              color: AppColors.texto,
              fontWeight: FontWeight.w900,
              fontSize: 17,
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
          right: -50,
          top: 235,
          child: Icon(
            Icons.settings,
            size: 145,
            color: AppColors.texto.withOpacity(.72),
          ),
        ),
        Positioned(
          left: -75,
          top: 390,
          child: Icon(
            Icons.settings,
            size: 150,
            color: const Color(0xFFDDE9DE).withOpacity(.8),
          ),
        ),
        Positioned(
          right: -45,
          bottom: 145,
          child: Icon(
            Icons.settings,
            size: 105,
            color: const Color(0xFFBFD8D0).withOpacity(.9),
          ),
        ),
        Positioned(
          left: -22,
          bottom: 125,
          child: Icon(
            Icons.settings,
            size: 72,
            color: const Color(0xFFD8E8D4).withOpacity(.9),
          ),
        ),
        Positioned(
          right: -45,
          bottom: -38,
          child: Icon(
            Icons.settings,
            size: 178,
            color: AppColors.texto.withOpacity(.75),
          ),
        ),
      ],
    );
  }
}