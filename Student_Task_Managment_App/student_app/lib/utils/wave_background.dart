import 'dart:math';
import 'package:flutter/material.dart';

class WaveBackground extends StatefulWidget {
  final List<Color> colors;

  const WaveBackground({super.key, required this.colors});

  @override
  State<WaveBackground> createState() => _WaveBackgroundState();
}

class _WaveBackgroundState extends State<WaveBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  double _time = 0.0;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 1), // Short duration for frequent updates
    )
      ..addListener(() {
        setState(() {
          _time += 0.02; // Increment time for continuous motion
        });
      })
      ..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: WavePainter(
        time: _time,
        colors: widget.colors,
      ),
      size: Size.infinite,
    );
  }
}

class WavePainter extends CustomPainter {
  final double time;
  final List<Color> colors;

  WavePainter({required this.time, required this.colors});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()..style = PaintingStyle.fill;
    final height = size.height;
    final width = size.width;

    // Draw three wave layers
    for (int i = 0; i < 3; i++) {
      final path = Path();
      final waveHeight = 50.0 + i * 20; // Vary wave height
      final speed = 0.5 + i * 0.2; // Vary wave speed
      final offsetY = height * (0.6 + i * 0.1); // Vary vertical position

      paint.shader = LinearGradient(
        colors: colors,
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        tileMode: TileMode.mirror,
      ).createShader(Rect.fromLTWH(0, 0, width, height));

      path.moveTo(0, offsetY);
      for (double x = 0; x <= width; x += 5) {
        final y = offsetY +
            sin((x / width * 2 * pi) + (time * speed)) * waveHeight;
        path.lineTo(x, y);
      }
      path.lineTo(width, height);
      path.lineTo(0, height);
      path.close();

      canvas.drawPath(path, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}