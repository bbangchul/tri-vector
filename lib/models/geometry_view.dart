import 'dart:math' as math;
import 'dart:ui';

import 'package:flutter/widgets.dart';
import 'package:todoey/models/geometry_scene.dart';
import 'package:todoey/models/vector3.dart';

enum GeometryInteractionMode {
  orbit,
  editPoint,
}

class GeometryCameraPreset {
  const GeometryCameraPreset({
    required this.id,
    required this.label,
    required this.viewport,
  });

  final String id;
  final String label;
  final GeometryViewport viewport;
}

class GeometryViewport {
  const GeometryViewport({
    this.yaw = -math.pi / 4,
    this.pitch = math.pi / 5,
    this.zoom = 34,
  });

  final double yaw;
  final double pitch;
  final double zoom;

  GeometryViewport copyWith({
    double? yaw,
    double? pitch,
    double? zoom,
  }) {
    return GeometryViewport(
      yaw: yaw ?? this.yaw,
      pitch: pitch ?? this.pitch,
      zoom: zoom ?? this.zoom,
    );
  }

  GeometryViewport orbit({
    required double deltaYaw,
    required double deltaPitch,
  }) {
    return copyWith(
      yaw: yaw + deltaYaw,
      pitch: (pitch + deltaPitch).clamp(-1.35, 1.35).toDouble(),
    );
  }

  GeometryViewport zoomByFactor(double factor) {
    return copyWith(
      zoom: (zoom * factor).clamp(18, 90).toDouble(),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is GeometryViewport &&
        yaw == other.yaw &&
        pitch == other.pitch &&
        zoom == other.zoom;
  }

  @override
  int get hashCode => Object.hash(yaw, pitch, zoom);
}

class GeometryProjector {
  const GeometryProjector(this.viewport);

  final GeometryViewport viewport;

  Vector3 screenRightAxis() {
    return Vector3(math.cos(viewport.yaw), 0, math.sin(viewport.yaw));
  }

  Vector3 screenUpAxis() {
    final sinY = math.sin(viewport.yaw);
    final cosY = math.cos(viewport.yaw);
    final sinX = math.sin(viewport.pitch);
    final cosX = math.cos(viewport.pitch);

    return Vector3(
      sinY * sinX,
      cosX,
      -cosY * sinX,
    ).normalize();
  }

  Vector3 screenForwardAxis() {
    final sinY = math.sin(viewport.yaw);
    final cosY = math.cos(viewport.yaw);
    final sinX = math.sin(viewport.pitch);
    final cosX = math.cos(viewport.pitch);

    return Vector3(
      -sinY * cosX,
      sinX,
      cosY * cosX,
    ).normalize();
  }

  double depthOf(Vector3 point3D) {
    return point3D.dot(screenForwardAxis());
  }

  Vector3 pointFromScreen({
    required Offset offset,
    required Size size,
    required double depth,
  }) {
    final center = Offset(size.width / 2, size.height / 2);
    final local = offset - center;
    final scale = viewport.zoom * (1 + depth * 0.02);
    final x1 = local.dx / scale;
    final y1 = -local.dy / scale;

    return screenRightAxis()
        .scale(x1)
        .add(screenUpAxis().scale(y1))
        .add(screenForwardAxis().scale(depth));
  }

  Offset project(Vector3 point3D, Size size) {
    final cosY = math.cos(viewport.yaw);
    final sinY = math.sin(viewport.yaw);
    final cosX = math.cos(viewport.pitch);
    final sinX = math.sin(viewport.pitch);

    final x1 = point3D.x * cosY + point3D.z * sinY;
    final z1 = -point3D.x * sinY + point3D.z * cosY;
    final y1 = point3D.y * cosX - z1 * sinX;
    final depth = point3D.y * sinX + z1 * cosX;
    final scale = viewport.zoom * (1 + depth * 0.02);

    return Offset(
      size.width / 2 + x1 * scale,
      size.height / 2 - y1 * scale,
    );
  }

  GeometryScenePoint? hitTest({
    required Offset offset,
    required Size size,
    required List<GeometryScenePoint> scenePoints,
    double radius = 22,
  }) {
    GeometryScenePoint? nearest;
    double nearestDistance = radius;

    for (final scenePoint in scenePoints) {
      final projected = project(scenePoint.position, size);
      final distance = (projected - offset).distance;
      if (distance <= nearestDistance) {
        nearest = scenePoint;
        nearestDistance = distance;
      }
    }

    return nearest;
  }

  bool hitTestTriangle({
    required Offset offset,
    required Size size,
    required Vector3 a,
    required Vector3 b,
    required Vector3 c,
  }) {
    final path = Path()
      ..moveTo(project(a, size).dx, project(a, size).dy)
      ..lineTo(project(b, size).dx, project(b, size).dy)
      ..lineTo(project(c, size).dx, project(c, size).dy)
      ..close();
    return path.contains(offset);
  }
}

GeometryViewport lerpGeometryViewport(
  GeometryViewport a,
  GeometryViewport b,
  double t,
) {
  return GeometryViewport(
    yaw: a.yaw + (b.yaw - a.yaw) * t,
    pitch: a.pitch + (b.pitch - a.pitch) * t,
    zoom: a.zoom + (b.zoom - a.zoom) * t,
  );
}

const List<GeometryCameraPreset> geometryCameraPresets = [
  GeometryCameraPreset(
    id: 'iso',
    label: 'Iso',
    viewport: GeometryViewport(),
  ),
  GeometryCameraPreset(
    id: 'front',
    label: 'Front',
    viewport: GeometryViewport(
      yaw: 0,
      pitch: 0.18,
      zoom: 38,
    ),
  ),
  GeometryCameraPreset(
    id: 'side',
    label: 'Side',
    viewport: GeometryViewport(
      yaw: math.pi / 2,
      pitch: 0.2,
      zoom: 38,
    ),
  ),
  GeometryCameraPreset(
    id: 'top',
    label: 'Top',
    viewport: GeometryViewport(
      yaw: -math.pi / 4,
      pitch: 1.08,
      zoom: 34,
    ),
  ),
];
