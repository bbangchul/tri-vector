import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_result.dart';
import 'package:todoey/features/triangle_intersection/models/vector3.dart';

class GeometryPointIds {
  static const triangleA = 'triangle_a';
  static const triangleB = 'triangle_b';
  static const triangleC = 'triangle_c';
  static const lineP1 = 'line_p1';
  static const lineP2 = 'line_p2';
  static const intersectionQ = 'intersection_q';
}

class GeometryScenePoint {
  const GeometryScenePoint({
    required this.id,
    required this.label,
    required this.position,
    required this.description,
    this.isEditable = true,
  });

  final String id;
  final String label;
  final Vector3 position;
  final String description;
  final bool isEditable;
}

List<GeometryScenePoint> buildGeometryScenePoints({
  required Vector3 a,
  required Vector3 b,
  required Vector3 c,
  required Vector3 p1,
  required Vector3 p2,
  required GeometryResult? result,
}) {
  final points = <GeometryScenePoint>[
    GeometryScenePoint(
      id: GeometryPointIds.triangleA,
      label: 'A',
      position: a,
      description: '삼각형 꼭짓점 A = ${a.format()}',
    ),
    GeometryScenePoint(
      id: GeometryPointIds.triangleB,
      label: 'B',
      position: b,
      description: '삼각형 꼭짓점 B = ${b.format()}',
    ),
    GeometryScenePoint(
      id: GeometryPointIds.triangleC,
      label: 'C',
      position: c,
      description: '삼각형 꼭짓점 C = ${c.format()}',
    ),
    GeometryScenePoint(
      id: GeometryPointIds.lineP1,
      label: 'P1',
      position: p1,
      description: '직선 시작점 P1 = ${p1.format()}',
    ),
    GeometryScenePoint(
      id: GeometryPointIds.lineP2,
      label: 'P2',
      position: p2,
      description: '직선 끝점 P2 = ${p2.format()}',
    ),
  ];

  if (result?.intersectionPoint != null) {
    points.add(
      GeometryScenePoint(
        id: GeometryPointIds.intersectionQ,
        label: 'Q',
        position: result!.intersectionPoint!,
        description:
            '교점 Q = ${result.intersectionPoint!.format()} | t = ${formatDouble(result.parameterT ?? 0, 4)}'
            ' | ${result.isInsideTriangle ? '삼각형 내부' : '삼각형 외부'}'
            ' | ${result.isOnSegment ? '선분 위' : '무한 직선 위'}',
        isEditable: false,
      ),
    );
  }

  return points;
}

GeometryScenePoint? findScenePointById(List<GeometryScenePoint> points, String? id) {
  if (id == null) {
    return null;
  }

  for (final point in points) {
    if (point.id == id) {
      return point;
    }
  }

  return null;
}
