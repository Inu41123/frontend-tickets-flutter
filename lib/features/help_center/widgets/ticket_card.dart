import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class TicketCard extends StatelessWidget {
  final Color color;
  final String title;
  final String code;
  final String desc;

  const TicketCard({
    super.key,
    required this.color,
    required this.title,
    required this.code,
    required this.desc,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 178,
      margin: const EdgeInsets.symmetric(
        horizontal: 34,
        vertical: 12,
      ),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(3),
        boxShadow: const [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 4,
          ),
        ],
      ),
      child: Row(
        children: [
          Container(
            width: 28,
            color: color,
          ),

          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 14,
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w900,
                    ),
                  ),

                  const SizedBox(height: 5),

                  Text(
                    code,
                    style: const TextStyle(
                      fontSize: 12,
                      color: Colors.black45,
                      fontWeight: FontWeight.w700,
                    ),
                  ),

                  const SizedBox(height: 3),

                  Container(
                    width: 42,
                    height: 3,
                    color: const Color(0xFF6F8A7F),
                  ),

                  const SizedBox(height: 16),

                  Expanded(
                    child: Text(
                      desc,
                      maxLines: 4,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                        fontSize: 11.5,
                        fontWeight: FontWeight.w700,
                        height: 1.3,
                      ),
                    ),
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      const Text(
                        'Estatus:',
                        style: TextStyle(
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const SizedBox(width: 10),

                      const Text(
                        'Pendiente',
                        style: TextStyle(
                          color: Colors.redAccent,
                          fontSize: 11.5,
                          fontWeight: FontWeight.w900,
                        ),
                      ),

                      const Spacer(),

                      Container(
                        width: 20,
                        height: 20,
                        decoration: BoxDecoration(
                          border: Border.all(
                            color: Colors.black,
                            width: 2,
                          ),
                        ),
                      ),
                    ],
                  ),

                  const SizedBox(height: 10),

                  Row(
                    children: [
                      Container(
                        width: 68,
                        height: 24,
                        decoration: BoxDecoration(
                          color: const Color(0xFFC7B53B),
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.edit,
                              size: 12,
                              color: Colors.black,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Editar',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),

                      const SizedBox(width: 12),

                      Container(
                        width: 82,
                        height: 24,
                        decoration: BoxDecoration(
                          color: AppColors.rojo,
                          borderRadius: BorderRadius.circular(4),
                        ),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.delete_outline,
                              size: 12,
                              color: Colors.black,
                            ),
                            SizedBox(width: 4),
                            Text(
                              'Eliminar',
                              style: TextStyle(
                                fontSize: 10,
                                fontWeight: FontWeight.w900,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}