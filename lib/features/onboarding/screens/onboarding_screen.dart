import 'package:flutter/material.dart';
import '../../auth/screens/login_screen.dart';

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() =>
      _OnboardingScreenState();
}

class _OnboardingScreenState
    extends State<OnboardingScreen> {
  final PageController _controller = PageController();

  int currentPage = 0;

  final List<Map<String, String>> pages = [
    {
      "image":
          "assets/onboarding/CrearCuenta.jpeg",
      "title": "Crea tu cuenta",
      "desc":
          "Regístrate con tus datos para comenzar a usar GestiónTech.",
    },
    {
      "image":
          "assets/onboarding/iniciaSesion.jpeg",
      "title": "Inicia sesión",
      "desc":
          "Accede con tu correo y contraseña para consultar tus tickets.",
    },
    {
      "image":
          "assets/onboarding/PantallaPrincipal.jpeg",
      "title": "Gestiona tickets",
      "desc":
          "Consulta tickets pendientes, atendidos y filtra por prioridad.",
    },
    {
      "image":
          "assets/onboarding/AgregarTicket.jpeg",
      "title": "Registra tickets",
      "desc":
          "Describe tu problema y envía tickets fácilmente.",
    },
    {
  "image": "assets/onboarding/editar.jpeg",
  "title": "Edita tickets",
  "desc":
      "Actualiza información, cambia prioridad o modifica tickets registrados.",
},
  ];

  void nextPage() {
    if (currentPage < pages.length - 1) {
      _controller.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOut,
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const LoginScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF8F9F3),

      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.only(
                top: 8,
                right: 15,
              ),
              child: Align(
                alignment: Alignment.topRight,
                child: TextButton(
                  onPressed: () {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (_) =>
                            const LoginScreen(),
                      ),
                    );
                  },
                  child: const Text(
                    'Omitir',
                    style: TextStyle(
                      color: Color(0xFF173847),
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                    ),
                  ),
                ),
              ),
            ),

            Expanded(
              child: PageView.builder(
                controller: _controller,
                itemCount: pages.length,

                onPageChanged: (value) {
                  setState(() {
                    currentPage = value;
                  });
                },

                itemBuilder: (context, index) {
                  final page = pages[index];

                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(
                            horizontal: 28),

                    child: Column(
                      mainAxisAlignment:
                          MainAxisAlignment.center,

                      children: [
                        Container(
                          height: 430,

                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(
                                    30),

                            boxShadow: [
                              BoxShadow(
                                color: Colors.black
                                    .withOpacity(.12),
                                blurRadius: 15,
                                offset:
                                    const Offset(0, 8),
                              ),
                            ],
                          ),

                          child: ClipRRect(
                            borderRadius:
                                BorderRadius.circular(
                                    30),

                            child: Image.asset(
                              page["image"]!,
                              fit: BoxFit.cover,
                            ),
                          ),
                        ),

                        const SizedBox(height: 40),

                        Text(
                          page["title"]!,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w900,
                            color: Color(0xFF173847),
                          ),
                        ),

                        const SizedBox(height: 18),

                        Text(
                          page["desc"]!,
                          textAlign: TextAlign.center,

                          style: const TextStyle(
                            fontSize: 15,
                            height: 1.4,
                            color: Colors.black54,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),

            Row(
              mainAxisAlignment:
                  MainAxisAlignment.center,

              children: List.generate(
                pages.length,
                (index) => AnimatedContainer(
                  duration:
                      const Duration(milliseconds: 250),

                  margin:
                      const EdgeInsets.symmetric(
                          horizontal: 4),

                  width:
                      currentPage == index ? 24 : 8,

                  height: 8,

                  decoration: BoxDecoration(
                    color: currentPage == index
                        ? const Color(0xFF173847)
                        : Colors.grey.shade400,

                    borderRadius:
                        BorderRadius.circular(30),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            Padding(
              padding:
                  const EdgeInsets.symmetric(
                      horizontal: 28),

              child: SizedBox(
                width: double.infinity,
                height: 58,

                child: ElevatedButton(
                  onPressed: nextPage,

                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        const Color(0xFF173847),

                    shape: RoundedRectangleBorder(
                      borderRadius:
                          BorderRadius.circular(18),
                    ),
                  ),

                  child: Text(
                    currentPage ==
                            pages.length - 1
                        ? 'Comenzar'
                        : 'Siguiente',

                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),

            const SizedBox(height: 35),
          ],
        ),
      ),
    );
  }
}