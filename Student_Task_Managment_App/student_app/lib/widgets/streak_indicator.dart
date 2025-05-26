import 'package:flutter/material.dart';
import '../utils/constants.dart';

class AnimatedStreakIndicator extends StatefulWidget {
  final int streak;
  const AnimatedStreakIndicator({super.key, required this.streak});

  @override
  State<AnimatedStreakIndicator> createState() => _AnimatedStreakIndicatorState();
}

class _AnimatedStreakIndicatorState extends State<AnimatedStreakIndicator>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _scaleAnimation = Tween<double>(begin: 0.8, end: 1.0).animate(
      CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
    );
    _controller.forward();
    debugPrint('AnimatedStreakIndicator: Initialized with streak ${widget.streak}');
  }

  @override
  void didUpdateWidget(covariant AnimatedStreakIndicator oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.streak != widget.streak) {
      _controller.reset();
      _controller.forward();
    }
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
        return Transform.scale(
          scale: _scaleAnimation.value,
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.accent.withOpacity(0.2),
                  AppColors.primary.withOpacity(0.2),
                ],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: AppColors.accent.withOpacity(0.2),
                  blurRadius: 8,
                  spreadRadius: 1,
                ),
              ],
            ),
            child: Row(
              children: [
                Icon(
                  Icons.local_fire_department,
                  color: AppColors.accent,
                  size: 32,
                ),
                const SizedBox(width: 12),
                Text(
                  '${widget.streak} Day${widget.streak == 1 ? '' : 's'} Streak',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}