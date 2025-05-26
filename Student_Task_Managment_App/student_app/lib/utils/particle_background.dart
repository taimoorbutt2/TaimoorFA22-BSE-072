import 'dart:math';
import 'package:flutter/material.dart';

class ParticleBackground extends StatefulWidget {
  final List<Color> colors;

  const ParticleBackground({super.key, required this.colors});

  @override
  State<ParticleBackground> createState() => _ParticleBackgroundState();
}

class _ParticleBackgroundState extends State<ParticleBackground>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  List<Particle> particles = [];

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 10),
    )..repeat();
    _initializeParticles();
  }

  void _initializeParticles() {
    particles = List.generate(50, (index) {
      return Particle(
        position: Offset(
          Random().nextDouble() * 400,
          Random().nextDouble() * 800,
        ),
        velocity: Offset(
          Random().nextDouble() * 2 - 1,
          Random().nextDouble() * 2 - 1,
        ),
        size: Random().nextDouble() * 5 + 2,
        color: widget.colors[Random().nextInt(widget.colors.length)],
      );
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        for (var particle in particles) {
          particle.position += particle.velocity;
          if (particle.position.dx < 0 || particle.position.dx > 400) {
            particle.velocity = Offset(-particle.velocity.dx, particle.velocity.dy);
          }
          if (particle.position.dy < 0 || particle.position.dy > 800) {
            particle.velocity = Offset(particle.velocity.dx, -particle.velocity.dy);
          }
        }
        return CustomPaint(
          painter: ParticlePainter(particles: particles),
          size: Size.infinite,
        );
      },
    );
  }
}

class Particle {
  Offset position;
  Offset velocity;
  double size;
  Color color;

  Particle({
    required this.position,
    required this.velocity,
    required this.size,
    required this.color,
  });
}

class ParticlePainter extends CustomPainter {
  final List<Particle> particles;

  ParticlePainter({required this.particles});

  @override
  void paint(Canvas canvas, Size size) {
    for (var particle in particles) {
      final paint = Paint()
        ..color = particle.color.withOpacity(0.5)
        ..style = PaintingStyle.fill;
      canvas.drawCircle(particle.position, particle.size, paint);
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}