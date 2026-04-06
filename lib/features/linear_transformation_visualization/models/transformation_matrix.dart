import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';

class TransformationMatrix {
  const TransformationMatrix({
    required this.a11,
    required this.a12,
    required this.a21,
    required this.a22,
  });

  final double a11;
  final double a12;
  final double a21;
  final double a22;

  static const identity = TransformationMatrix(
    a11: 1,
    a12: 0,
    a21: 0,
    a22: 1,
  );

  double get determinant => (a11 * a22) - (a12 * a21);

  TransformVector applyTo(TransformVector vector) {
    return vector.copyWith(
      x: (a11 * vector.x) + (a12 * vector.y),
      y: (a21 * vector.x) + (a22 * vector.y),
    );
  }

  TransformVector get transformedBasisX => applyTo(TransformVector.basisX);
  TransformVector get transformedBasisY => applyTo(TransformVector.basisY);

  @override
  bool operator ==(Object other) {
    return other is TransformationMatrix &&
        other.a11 == a11 &&
        other.a12 == a12 &&
        other.a21 == a21 &&
        other.a22 == a22;
  }

  @override
  int get hashCode => Object.hash(a11, a12, a21, a22);
}
