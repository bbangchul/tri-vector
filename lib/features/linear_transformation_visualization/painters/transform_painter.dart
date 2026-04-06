import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_palette.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_scene.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';

class TransformPainter extends CustomPainter {
  const TransformPainter({
    required this.gridLines,
    required this.basisVectors,
    required this.vectors,
    required this.viewportExtent,
  });

  final List<GridLine> gridLines;
  final List<TransformVector> basisVectors;
  final List<TransformVector> vectors;
  final double viewportExtent;

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final halfShortestSide = math.min(size.width, size.height) / 2;
    final scale = halfShortestSide / viewportExtent * 0.92;

    _paintBackdrop(canvas, size);
    _paintGrid(canvas, center, scale);
    _paintBasisVectors(canvas, size, center, scale);
    _paintVectors(canvas, size, center, scale);
  }

  void _paintBackdrop(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = const LinearGradient(
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
        colors: [
          TransformPalette.canvasTop,
          TransformPalette.canvasMid,
          TransformPalette.canvasBottom,
        ],
      ).createShader(Offset.zero & size);

    canvas.drawRRect(
      RRect.fromRectAndRadius(Offset.zero & size, const Radius.circular(24)),
      paint,
    );
  }

  void _paintGrid(Canvas canvas, Offset center, double scale) {
    for (final line in gridLines) {
      final paint = Paint()
        ..color = line.isAxis
            ? Colors.white.withValues(alpha: 0.34)
            : Colors.white.withValues(alpha: 0.08)
        ..strokeWidth = line.isAxis ? 1.8 : 1;

      canvas.drawLine(
        _toOffset(line.start, center, scale),
        _toOffset(line.end, center, scale),
        paint,
      );
    }
  }

  void _paintBasisVectors(
    Canvas canvas,
    Size size,
    Offset center,
    double scale,
  ) {
    const colors = [
      TransformPalette.axisX,
      TransformPalette.axisY,
    ];

    for (int index = 0; index < basisVectors.length; index++) {
      final vector = basisVectors[index];
      final color = colors[index % colors.length];
      _paintArrow(
        canvas,
        center: center,
        scale: scale,
        vector: vector,
        color: color,
        strokeWidth: 3.2,
      );
      _paintLabel(
        canvas,
        _labelPosition(vector, size, center, scale),
        vector.label.isEmpty ? 'e${index + 1}' : vector.label,
        color,
      );
    }
  }

  void _paintVectors(
    Canvas canvas,
    Size size,
    Offset center,
    double scale,
  ) {
    const colors = [
      TransformPalette.vectorA,
      TransformPalette.vectorB,
      TransformPalette.vectorC,
    ];

    for (int index = 0; index < vectors.length; index++) {
      final vector = vectors[index];
      final color = colors[index % colors.length];
      _paintArrow(
        canvas,
        center: center,
        scale: scale,
        vector: vector,
        color: color,
        strokeWidth: 2.8,
      );
      if (vector.label.isNotEmpty) {
        _paintLabel(
          canvas,
          _labelPosition(vector, size, center, scale),
          vector.label,
          color,
        );
      }
    }
  }

  void _paintArrow(
    Canvas canvas, {
    required Offset center,
    required double scale,
    required TransformVector vector,
    required Color color,
    required double strokeWidth,
  }) {
    final start = center;
    final end = _toOffset(vector, center, scale);
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..strokeCap = StrokeCap.round;

    canvas.drawCircle(
      end,
      10,
      Paint()..color = color.withValues(alpha: 0.12),
    );
    canvas.drawLine(start, end, paint);
    canvas.drawCircle(
      end,
      4.6,
      Paint()..color = color.withValues(alpha: 0.95),
    );
  }

  void _paintLabel(Canvas canvas, Offset offset, String label, Color color) {
    final textPainter = TextPainter(
      text: TextSpan(
        text: label,
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.w800,
          shadows: [
            Shadow(
              blurRadius: 10,
              color: Colors.black.withValues(alpha: 0.35),
            ),
          ],
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();

    final backgroundRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        offset.dx - 6,
        offset.dy - 3,
        textPainter.width + 12,
        textPainter.height + 6,
      ),
      const Radius.circular(999),
    );
    canvas.drawRRect(
      backgroundRect,
      Paint()..color = color.withValues(alpha: 0.22),
    );
    textPainter.paint(canvas, offset);
  }

  Offset _toOffset(TransformVector vector, Offset center, double scale) {
    return Offset(
      center.dx + (vector.x * scale),
      center.dy - (vector.y * scale),
    );
  }

  Offset _labelPosition(
    TransformVector vector,
    Size size,
    Offset center,
    double scale,
  ) {
    final end = _toOffset(vector, center, scale);
    final horizontalShift = vector.x >= 0 ? 10.0 : -42.0;
    final verticalShift = vector.y >= 0 ? -24.0 : 10.0;

    final dx = (end.dx + horizontalShift).clamp(8.0, size.width - 52.0);
    final dy = (end.dy + verticalShift).clamp(8.0, size.height - 24.0);
    return Offset(dx, dy);
  }

  @override
  bool shouldRepaint(covariant TransformPainter oldDelegate) {
    return oldDelegate.gridLines != gridLines ||
        oldDelegate.basisVectors != basisVectors ||
        oldDelegate.vectors != vectors ||
        oldDelegate.viewportExtent != viewportExtent;
  }
}
