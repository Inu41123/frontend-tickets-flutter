import 'package:flutter/material.dart';

class RotatingGear extends StatefulWidget {
  final double size;
  final Color color;
  final Duration duration;

  const RotatingGear({
    super.key,
    required this.size,
    required this.color,
    this.duration = const Duration(seconds: 18),
  });

  @override
  State<RotatingGear> createState() => _RotatingGearState();
}

class _RotatingGearState extends State<RotatingGear>
    with SingleTickerProviderStateMixin {
  late final AnimationController controller;

  @override
  void initState() {
    super.initState();

    controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    )..repeat();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: RotationTransition(
        turns: controller,
        child: Icon(
          Icons.settings,
          size: widget.size,
          color: widget.color,
        ),
      ),
    );
  }

  @override
  void dispose() {
    controller.dispose();
    super.dispose();
  }
}