import 'package:flutter/material.dart';

class MainButton extends StatefulWidget {
  final String text;
  final Color color;
  final VoidCallback onTap;
  final Color textColor;

  const MainButton({
    super.key,
    required this.text,
    required this.color,
    required this.onTap,
    this.textColor = Colors.white,
  });

  @override
  State<MainButton> createState() => _MainButtonState();
}

class _MainButtonState extends State<MainButton> {
  bool pressed = false;

  @override
  Widget build(BuildContext context) {
    return AnimatedScale(
      scale: pressed ? 0.96 : 1,
      duration: const Duration(milliseconds: 120),
      child: Material(
        elevation: pressed ? 2 : 4,
        borderRadius: BorderRadius.circular(18),
        child: InkWell(
          borderRadius: BorderRadius.circular(18),
          onTapDown: (_) {
            setState(() {
              pressed = true;
            });
          },
          onTapUp: (_) {
            setState(() {
              pressed = false;
            });
          },
          onTapCancel: () {
            setState(() {
              pressed = false;
            });
          },
          onTap: widget.onTap,
          child: Container(
            height: 40,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: widget.color,
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              widget.text,
              style: TextStyle(
                color: widget.textColor,
                fontWeight: FontWeight.w900,
                fontSize: 14,
              ),
            ),
          ),
        ),
      ),
    );
  }
}