import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_result.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_scene.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_view.dart';
import 'package:todoey/features/triangle_intersection/models/vector3.dart';

class GeometryPainter extends CustomPainter {
  GeometryPainter({
    required this.a,
    required this.b,
    required this.c,
    required this.p1,
    required this.p2,
    required this.result,
    required this.hasError,
    required this.viewport,
    required this.scenePoints,
    required this.selectedPointId,
    required this.interactionMode,
    required this.isEditingPoint,
    this.showOnlyPoints = false,
  });

  final Vector3 a;
  final Vector3 b;
  final Vector3 c;
  final Vector3 p1;
  final Vector3 p2;
  final GeometryResult? result;
  final bool hasError;
  final GeometryViewport viewport;
  final List<GeometryScenePoint> scenePoints;
  final String? selectedPointId;
  final GeometryInteractionMode interactionMode;
  final bool isEditingPoint;
  final bool showOnlyPoints;

  GeometryProjector get _projector => GeometryProjector(viewport);

  double get _axisExtent {
    final points = [a, b, c, p1, p2];
    var maxCoordinate = 0.0;

    for (final point in points) {
      maxCoordinate = math.max(
        maxCoordinate,
        math.max(point.x.abs(), math.max(point.y.abs(), point.z.abs())),
      );
    }

    return maxCoordinate < 4 ? 4 : maxCoordinate;
  }

  static Color colorForPointId(String id) {
    switch (id) {
      case GeometryPointIds.triangleA:
        return const Color(0xFF4DA1FF);
      case GeometryPointIds.triangleB:
        return const Color(0xFF38BDF8);
      case GeometryPointIds.triangleC:
        return const Color(0xFF0EA5E9);
      case GeometryPointIds.lineP1:
        return const Color(0xFFFF8A3D);
      case GeometryPointIds.lineP2:
        return const Color(0xFFFB7185);
      case GeometryPointIds.intersectionQ:
        return const Color(0xFFF4C95D);
      default:
        return Colors.white;
    }
  }

  @override
  void paint(Canvas canvas, Size size) {
    _paintBackground(canvas, size);
    _paintAxes(canvas, size);

    if (showOnlyPoints) {
      for (final scenePoint in scenePoints) {
        _paintPoint(
          canvas,
          size,
          scenePoint,
          isSelected: scenePoint.id == selectedPointId,
        );
      }
      return;
    }

    if (hasError || result == null) {
      _paintHint(canvas, size, '삼각형과 직선 입력이 유효해야 시각화됩니다.');
      return;
    }

    _paintTriangle(canvas, size);
    _paintLine(canvas, size, p1, p2);
    _paintSegment(canvas, size, p1, p2, const Color(0xFFFF8A3D), 2.8);

    if (result!.intersectionPoint != null) {
      _paintSegment(
        canvas,
        size,
        result!.intersectionPoint!,
        p1,
        const Color(0xFFF4C95D),
        1.6,
        alpha: 0.5,
      );
    }

    for (final scenePoint in scenePoints) {
      _paintPoint(
        canvas,
        size,
        scenePoint,
        isSelected: scenePoint.id == selectedPointId,
      );
    }
  }

  void _paintBackground(Canvas canvas, Size size) {
    final gridPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.05)
      ..strokeWidth = 1;

    for (double x = 0; x <= size.width; x += 32) {
      canvas.drawLine(Offset(x, 0), Offset(x, size.height), gridPaint);
    }
    for (double y = 0; y <= size.height; y += 32) {
      canvas.drawLine(Offset(0, y), Offset(size.width, y), gridPaint);
    }
  }

  void _paintAxes(Canvas canvas, Size size) {
    final axisExtent = _axisExtent;
    _paintAxis(
      canvas,
      size,
      Vector3.zero,
      Vector3(axisExtent, 0, 0),
      const Color(0xFFEF4444),
      'X',
      axisExtent,
    );
    _paintAxis(
      canvas,
      size,
      Vector3.zero,
      Vector3(0, axisExtent, 0),
      const Color(0xFF22C55E),
      'Y',
      axisExtent,
    );
    _paintAxis(
      canvas,
      size,
      Vector3.zero,
      Vector3(0, 0, axisExtent),
      const Color(0xFF38BDF8),
      'Z',
      axisExtent,
    );
  }

  void _paintAxis(
    Canvas canvas,
    Size size,
    Vector3 start,
    Vector3 end,
    Color color,
    String label,
    double axisExtent,
  ) {
    final paint = Paint()
      ..color = color.withValues(alpha: 0.78)
      ..strokeWidth = 2.5;
    final startOffset = _projector.project(start, size);
    final endOffset = _projector.project(end, size);

    canvas.drawLine(startOffset, endOffset, paint);
    _paintAxisTicks(canvas, size, end, color, axisExtent);
    _drawLabel(canvas, endOffset + const Offset(8, -8), label, color);
  }

  void _paintTriangle(Canvas canvas, Size size) {
    final a2 = _projector.project(a, size);
    final b2 = _projector.project(b, size);
    final c2 = _projector.project(c, size);
    final path = Path()
      ..moveTo(a2.dx, a2.dy)
      ..lineTo(b2.dx, b2.dy)
      ..lineTo(c2.dx, c2.dy)
      ..close();

    final fillColor = isEditingPoint
        ? const Color(0xFF0EA5E9).withValues(alpha: 0.22)
        : const Color(0xFF0EA5E9).withValues(alpha: 0.15);
    final strokeColor = interactionMode == GeometryInteractionMode.editPoint
        ? const Color(0xFF7DD3FC)
        : const Color(0xFF38BDF8).withValues(alpha: 0.78);

    canvas.drawPath(path, Paint()..color = fillColor);
    canvas.drawPath(
      path,
      Paint()
        ..color = strokeColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = isEditingPoint ? 2.6 : 1.8,
    );
  }

  void _paintLine(Canvas canvas, Size size, Vector3 lineStart, Vector3 lineEnd) {
    final direction = lineEnd.subtract(lineStart).normalize();
    final start = lineStart.subtract(direction.scale(6));
    final end = lineEnd.add(direction.scale(6));

    canvas.drawLine(
      _projector.project(start, size),
      _projector.project(end, size),
      Paint()
        ..color = const Color(0xFFFF8A3D).withValues(alpha: 0.55)
        ..strokeWidth = 2,
    );
  }

  void _paintSegment(
    Canvas canvas,
    Size size,
    Vector3 start,
    Vector3 end,
    Color color,
    double width, {
    double alpha = 0.82,
  }) {
    canvas.drawLine(
      _projector.project(start, size),
      _projector.project(end, size),
      Paint()
        ..color = color.withValues(alpha: alpha)
        ..strokeWidth = width,
    );
  }

  void _paintPoint(
    Canvas canvas,
    Size size,
    GeometryScenePoint scenePoint, {
    required bool isSelected,
  }) {
    final color = colorForPointId(scenePoint.id);
    final center = _projector.project(scenePoint.position, size);
    final radius = isSelected ? 9.5 : 7.0;

    canvas.drawCircle(
      center,
      isSelected ? 16 : 11,
      Paint()..color = color.withValues(alpha: isSelected ? 0.26 : 0.18),
    );
    canvas.drawCircle(center, radius, Paint()..color = color);
    canvas.drawCircle(
      center,
      isSelected ? 18.5 : 11,
      Paint()
        ..color = color.withValues(alpha: isSelected ? 0.55 : 0.18)
        ..style = PaintingStyle.stroke
        ..strokeWidth = isSelected ? 4 : 3,
    );

    _drawLabel(canvas, center + const Offset(10, -22), scenePoint.label, color);
  }

  void _paintAxisTicks(
    Canvas canvas,
    Size size,
    Vector3 axisEnd,
    Color color,
    double axisExtent,
  ) {
    final startOffset = _projector.project(Vector3.zero, size);
    final endOffset = _projector.project(axisEnd, size);
    final direction = endOffset - startOffset;
    if (direction.distance < 1e-3) {
      return;
    }

    final normal = Offset(-direction.dy, direction.dx) / direction.distance;
    final tickPaint = Paint()
      ..color = color.withValues(alpha: 0.62)
      ..strokeWidth = 1.3;
    final axisDirection = axisEnd.normalize();
    const fractions = [-1.0, -0.5, 0.5, 1.0];

    for (final fraction in fractions) {
      final tickValue = axisExtent * fraction;
      final worldPoint = axisDirection.scale(tickValue);
      final projected = _projector.project(worldPoint, size);
      canvas.drawLine(projected - normal * 5, projected + normal * 5, tickPaint);
      _drawLabel(
        canvas,
        projected + normal * 8 + const Offset(2, 2),
        formatDouble(tickValue, axisExtent >= 10 ? 0 : 2),
        color.withValues(alpha: 0.82),
        fontSize: 10,
      );
    }
  }

  void _paintHint(Canvas canvas, Size size, String message) {
    final paragraphStyle = TextStyle(
      color: Colors.white.withValues(alpha: 0.82),
      fontSize: 16,
      fontWeight: FontWeight.w600,
    );
    final painter = TextPainter(
      text: TextSpan(text: message, style: paragraphStyle),
      textDirection: TextDirection.ltr,
      textAlign: TextAlign.center,
    )..layout(maxWidth: size.width - 40);
    painter.paint(
      canvas,
      Offset((size.width - painter.width) / 2, (size.height - painter.height) / 2),
    );
  }

  void _drawLabel(
    Canvas canvas,
    Offset offset,
    String text,
    Color color, {
    double fontSize = 13,
  }) {
    final painter = TextPainter(
      text: TextSpan(
        text: text,
        style: TextStyle(
          color: color,
          fontSize: fontSize,
          fontWeight: FontWeight.w700,
        ),
      ),
      textDirection: TextDirection.ltr,
    )..layout();
    painter.paint(canvas, offset);
  }

  @override
  bool shouldRepaint(covariant GeometryPainter oldDelegate) {
    return a != oldDelegate.a ||
        b != oldDelegate.b ||
        c != oldDelegate.c ||
        p1 != oldDelegate.p1 ||
        p2 != oldDelegate.p2 ||
        result != oldDelegate.result ||
        hasError != oldDelegate.hasError ||
        viewport != oldDelegate.viewport ||
        selectedPointId != oldDelegate.selectedPointId ||
        scenePoints != oldDelegate.scenePoints ||
        interactionMode != oldDelegate.interactionMode ||
        isEditingPoint != oldDelegate.isEditingPoint ||
        showOnlyPoints != oldDelegate.showOnlyPoints;
  }
}
