import 'package:flutter/material.dart';
import '../utils/app_colors.dart';

class StatusBox extends StatelessWidget {
  final String title;
  final String number;

  const StatusBox({
    super.key,
    required this.title,
    required this.number,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        height: 55,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: AppColors.fondo,
          border: Border.all(width: .8),
          borderRadius: BorderRadius.circular(5),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 11,
                fontWeight: FontWeight.w900,
              ),
            ),
            const SizedBox(height: 5),
            Text(number),
          ],
        ),
      ),
    );
  }
}