import 'package:todoey/models/vector3.dart';

class Line3D {
  const Line3D({
    required this.point,
    required this.direction,
  });

  final Vector3 point;
  final Vector3 direction;

  Vector3 pointAt(double t) {
    return point.add(direction.scale(t));
  }
}
