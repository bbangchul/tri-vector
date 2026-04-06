import 'dart:math' as math;

import 'package:todoey/models/geometry_exception.dart';
import 'package:todoey/models/geometry_result.dart';
import 'package:todoey/models/line3d.dart';
import 'package:todoey/models/vector3.dart';

class GeometryEngine {
  static const double epsilon = 1e-9;

  static GeometryResult compute({
    required Vector3 a,
    required Vector3 b,
    required Vector3 c,
    required Vector3 p1,
    required Vector3 p2,
  }) {
    final direction = p2.subtract(p1);
    if (direction.length() == 0) {
      throw const GeometryException('직선을 이루는 두 점 P1 과 P2 는 서로 달라야 합니다.');
    }

    final planeNormal = b.subtract(a).cross(c.subtract(a));
    if (planeNormal.length() == 0) {
      throw const GeometryException('삼각형 A, B, C 가 일직선이면 평면을 만들 수 없습니다.');
    }

    final denom = direction.dot(planeNormal);
    final line = Line3D(point: p1, direction: direction);

    if (denom.abs() < epsilon) {
      return GeometryResult(
        line: line,
        planeNormal: planeNormal,
        isParallel: true,
        intersectionPoint: null,
        parameterT: null,
        isOnSegment: false,
        isInsideTriangle: false,
      );
    }

    final t = a.subtract(p1).dot(planeNormal) / denom;
    final q = p1.add(direction.scale(t));
    final onSegment = t >= 0.0 && t <= 1.0;
    final insideTriangle = isInsideTriangle(a: a, b: b, c: c, p: q);

    return GeometryResult(
      line: line,
      planeNormal: planeNormal,
      isParallel: false,
      intersectionPoint: q,
      parameterT: t,
      isOnSegment: onSegment,
      isInsideTriangle: insideTriangle,
    );
  }

  static bool isInsideTriangle({
    required Vector3 a,
    required Vector3 b,
    required Vector3 c,
    required Vector3 p,
  }) {
    final v0 = b.subtract(a);
    final v1 = c.subtract(a);
    final v2 = p.subtract(a);

    final d00 = v0.dot(v0);
    final d01 = v0.dot(v1);
    final d11 = v1.dot(v1);
    final d20 = v2.dot(v0);
    final d21 = v2.dot(v1);

    final denom = d00 * d11 - d01 * d01;
    if (denom.abs() < epsilon) {
      return false;
    }

    final v = (d11 * d20 - d01 * d21) / denom;
    final w = (d00 * d21 - d01 * d20) / denom;
    final u = 1.0 - v - w;

    return u >= -epsilon && v >= -epsilon && w >= -epsilon;
  }

  static Vector3 dragPointInViewPlane({
    required Vector3 point,
    required Vector3 screenRight,
    required Vector3 screenUp,
    required double deltaX,
    required double deltaY,
    required double zoom,
  }) {
    final step = math.max(zoom, 1) * 0.035;
    return point
        .add(screenRight.scale(deltaX / step))
        .add(screenUp.scale(-deltaY / step));
  }
}
