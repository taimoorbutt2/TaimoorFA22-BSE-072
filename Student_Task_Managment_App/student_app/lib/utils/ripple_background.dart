import 'dart:math';
import 'package:flutter/material.dart';

class RippleBackground extends StatefulWidget {
  final List<Color> colors;

  const RippleBackground({super.key, required this.colors});

  @override
  State<RippleBackground> createState() => _RippleBackgroundState();
}

class _RippleBackgroundState extends State<RippleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Ripple> ripples = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 4),
    )..repeat();
    _controller.addListener(() {
      if (_controller.value == 0) {
        _addRipple();
      }
      setState(() {});
    });
  }

  void _addRipple() {
    ripples.add(Ripple(
      center: Offset(
        Random().nextDouble() * 400,
        Random().nextDouble() * 800,
      ),
      radius: 0,
      opacity: 0.5,
      color: widget.colors[Random().nextInt(widget.colors.length)],
    ));
    if (ripples.length > 10) {
      ripples.removeAt(0);
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: RipplePainter(
        ripples: ripples,
        animationValue: _controller.value,
      ),
      size: Size.infinite,
    );
  }
}

class Ripple {
  Offset center;
  double radius;
  double opacity;
  Color color;

  Ripple({
    required this.center,
    required this.radius,
    required this.opacity,
    required this.color,
  });
}

class RipplePainter extends CustomPainter {
  final List<Ripple> ripples;
  final double animationValue;

  RipplePainter({required this.ripples, required this.animationValue});

  @override
  void paint(Canvas canvas, Size size) {
    for (var ripple in ripples) {
      final paint = Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = 2
        ..shader = LinearGradient(
          colors: [ripple.color, ripple.color.withOpacity(0)],
          begin: Alignment.center,
          end: Alignment.topRight,
        ).createShader(Rect.fromCircle(
          center: ripple.center,
          radius: ripple.radius,
        ));

      ripple.radius = animationValue * 200;
      ripple.opacity = 0.5 * (1 - animationValue);

      canvas.drawCircle(
        ripple.center,
        ripple.radius,
        paint..color = ripple.color.withOpacity(ripple.opacity),
      );
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}