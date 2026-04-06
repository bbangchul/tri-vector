import 'dart:math' as math;

import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_exception.dart';

class Vector3 {
  const Vector3(this.x, this.y, this.z);

  static const zero = Vector3(0, 0, 0);

  final double x;
  final double y;
  final double z;

  Vector3 add(Vector3 other) => Vector3(x + other.x, y + other.y, z + other.z);

  Vector3 subtract(Vector3 other) => Vector3(x - other.x, y - other.y, z - other.z);

  Vector3 scale(double factor) => Vector3(x * factor, y * factor, z * factor);

  double dot(Vector3 other) => x * other.x + y * other.y + z * other.z;

  Vector3 cross(Vector3 other) {
    return Vector3(
      y * other.z - z * other.y,
      z * other.x - x * other.z,
      x * other.y - y * other.x,
    );
  }

  double length() => math.sqrt(dot(this));

  Vector3 normalize() {
    final value = length();
    if (value == 0) {
      throw const GeometryException('길이가 0인 벡터는 정규화할 수 없습니다.');
    }
    return scale(1 / value);
  }

  String format([int precision = 2]) {
    return '(${formatDouble(x, precision)}, ${formatDouble(y, precision)}, ${formatDouble(z, precision)})';
  }

  @override
  bool operator ==(Object other) {
    return other is Vector3 && x == other.x && y == other.y && z == other.z;
  }

  @override
  int get hashCode => Object.hash(x, y, z);
}
