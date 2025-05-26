import 'dart:math';

import 'package:flutter/material.dart';

import 'constants.dart';

class GridFlow {
  double offsetX;
  double offsetY;
  final double gridSize = 10; // 10x10 grid
  final Random _random = Random();

  GridFlow()
      : offsetX = 0.0,
        offsetY = 0.0;

  void update(double animationValue) {
    // Move grid diagonally (normalized 0-1)
    offsetX = (offsetX + animationValue * 0.02) % 1.0;
    offsetY = (offsetY + animationValue * 0.02) % 1.0;
  }

  double getIntersectionOpacity(int i, int j) {
    // Pulse opacity based on position and time
    return 0.3 +
        0.4 *
            sin(DateTime.now().millisecondsSinceEpoch / 1000 +
                (i + j) * _random.nextDouble());
  }
}

class GridFlowPainter extends CustomPainter {
  final GridFlow gridFlow;

  GridFlowPainter(this.gridFlow);

  @override
  void paint(Canvas canvas, Size size) {
    final linePaint = Paint()
      ..color = AppColors.primary.withOpacity(0.2)
      ..strokeWidth = 1.0
      ..style = PaintingStyle.stroke;

    final intersectionPaint = Paint()
      ..shader = AppColors.primaryGradient
          .createShader(Rect.fromLTWH(0, 0, size.width, size.height));

    final cellWidth = size.width / gridFlow.gridSize;
    final cellHeight = size.height / gridFlow.gridSize;

    // Draw horizontal lines
    for (int i = 0; i <= gridFlow.gridSize; i++) {
      final y = (i * cellHeight + gridFlow.offsetY * size.height) % size.height;
      canvas.drawLine(
        Offset(0, y),
        Offset(size.width, y),
        linePaint,
      );
    }

    // Draw vertical lines
    for (int j = 0; j <= gridFlow.gridSize; j++) {
      final x = (j * cellWidth + gridFlow.offsetX * size.width) % size.width;
      canvas.drawLine(
        Offset(x, 0),
        Offset(x, size.height),
        linePaint,
      );
    }

    // Draw pulsing intersections
    for (int i = 0; i < gridFlow.gridSize; i++) {
      for (int j = 0; j < gridFlow.gridSize; j++) {
        final x = ((j + 0.5) * cellWidth + gridFlow.offsetX * size.width) % size.width;
        final y = ((i + 0.5) * cellHeight + gridFlow.offsetY * size.height) % size.height;
        final opacity = gridFlow.getIntersectionOpacity(i, j);

        canvas.drawCircle(
          Offset(x, y),
          3.0,
          intersectionPaint..color = intersectionPaint.color.withOpacity(opacity),
        );

        // Add glow effect
        final glowPaint = Paint()
          ..color = AppColors.primary.withOpacity(opacity * 0.5)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(
          Offset(x, y),
          6.0,
          glowPaint,
        );
      }
    }
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => true;
}