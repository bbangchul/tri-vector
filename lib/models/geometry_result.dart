import 'package:todoey/models/line3d.dart';
import 'package:todoey/models/vector3.dart';

class GeometryResult {
  const GeometryResult({
    required this.line,
    required this.planeNormal,
    required this.isParallel,
    required this.intersectionPoint,
    required this.parameterT,
    required this.isOnSegment,
    required this.isInsideTriangle,
  });

  final Line3D line;
  final Vector3 planeNormal;
  final bool isParallel;
  final Vector3? intersectionPoint;
  final double? parameterT;
  final bool isOnSegment;
  final bool isInsideTriangle;
}
