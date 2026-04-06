import 'dart:math' as math;

import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transformation_matrix.dart';

class GridLine {
  const GridLine({
    required this.start,
    required this.end,
    required this.isAxis,
  });

  final TransformVector start;
  final TransformVector end;
  final bool isAxis;

  static GridLine lerp(
    GridLine from,
    GridLine to,
    double t,
  ) {
    return GridLine(
      start: TransformVector.lerp(from.start, to.start, t),
      end: TransformVector.lerp(from.end, to.end, t),
      isAxis: from.isAxis || to.isAxis,
    );
  }
}

class TransformScene {
  const TransformScene({
    required this.matrix,
    required this.originalBasis,
    required this.transformedBasis,
    required this.originalVectors,
    required this.transformedVectors,
    required this.originalGridLines,
    required this.transformedGridLines,
    required this.gridExtent,
    required this.originalViewportExtent,
    required this.transformedViewportExtent,
    required this.viewportExtent,
  });

  final TransformationMatrix matrix;
  final List<TransformVector> originalBasis;
  final List<TransformVector> transformedBasis;
  final List<TransformVector> originalVectors;
  final List<TransformVector> transformedVectors;
  final List<GridLine> originalGridLines;
  final List<GridLine> transformedGridLines;
  final int gridExtent;
  final double originalViewportExtent;
  final double transformedViewportExtent;
  final double viewportExtent;

  List<TransformVector> lerpBasis(double t) {
    return List.generate(
      originalBasis.length,
      (index) => TransformVector.lerp(
        originalBasis[index],
        transformedBasis[index],
        t,
      ),
      growable: false,
    );
  }

  List<TransformVector> lerpVectors(double t) {
    return List.generate(
      originalVectors.length,
      (index) => TransformVector.lerp(
        originalVectors[index],
        transformedVectors[index],
        t,
      ),
      growable: false,
    );
  }

  List<GridLine> lerpGridLines(double t) {
    return List.generate(
      originalGridLines.length,
      (index) => GridLine.lerp(
        originalGridLines[index],
        transformedGridLines[index],
        t,
      ),
      growable: false,
    );
  }

  static double computeViewportExtent({
    required List<TransformVector> vectors,
    required List<GridLine> lines,
    required int fallbackExtent,
  }) {
    var maxValue = fallbackExtent.toDouble();

    for (final vector in vectors) {
      maxValue = math.max(maxValue, vector.x.abs());
      maxValue = math.max(maxValue, vector.y.abs());
    }

    for (final line in lines) {
      maxValue = math.max(maxValue, line.start.x.abs());
      maxValue = math.max(maxValue, line.start.y.abs());
      maxValue = math.max(maxValue, line.end.x.abs());
      maxValue = math.max(maxValue, line.end.y.abs());
    }

    final padding = math.max(0.35, maxValue * 0.08);
    return maxValue + padding;
  }
}
