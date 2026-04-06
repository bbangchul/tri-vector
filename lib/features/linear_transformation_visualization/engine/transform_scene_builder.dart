import 'package:todoey/features/linear_transformation_visualization/models/transform_scene.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transformation_matrix.dart';

class TransformSceneBuilder {
  const TransformSceneBuilder._();

  static TransformScene build({
    required TransformationMatrix matrix,
    List<TransformVector> vectors = const [],
    int gridExtent = 4,
  }) {
    final originalBasis = const [
      TransformVector.basisX,
      TransformVector.basisY,
    ];
    final transformedBasis = originalBasis
        .map(matrix.applyTo)
        .toList(growable: false);

    final originalVectors = vectors;
    final transformedVectors = vectors
        .map(matrix.applyTo)
        .toList(growable: false);

    final originalGridLines = _buildGridLines(gridExtent);
    final transformedGridLines = originalGridLines
        .map(
          (line) => GridLine(
            start: matrix.applyTo(line.start),
            end: matrix.applyTo(line.end),
            isAxis: line.isAxis,
          ),
        )
        .toList(growable: false);

    final originalViewportExtent = TransformScene.computeViewportExtent(
      vectors: [
        ...originalBasis,
        ...originalVectors,
      ],
      lines: originalGridLines,
      fallbackExtent: gridExtent,
    );

    final transformedViewportExtent = TransformScene.computeViewportExtent(
      vectors: [
        ...transformedBasis,
        ...transformedVectors,
      ],
      lines: transformedGridLines,
      fallbackExtent: gridExtent,
    );

    final viewportExtent = TransformScene.computeViewportExtent(
      vectors: [
        ...originalBasis,
        ...transformedBasis,
        ...originalVectors,
        ...transformedVectors,
      ],
      lines: [
        ...originalGridLines,
        ...transformedGridLines,
      ],
      fallbackExtent: gridExtent,
    );

    return TransformScene(
      matrix: matrix,
      originalBasis: originalBasis,
      transformedBasis: transformedBasis,
      originalVectors: originalVectors,
      transformedVectors: transformedVectors,
      originalGridLines: originalGridLines,
      transformedGridLines: transformedGridLines,
      gridExtent: gridExtent,
      originalViewportExtent: originalViewportExtent,
      transformedViewportExtent: transformedViewportExtent,
      viewportExtent: viewportExtent,
    );
  }

  static List<GridLine> _buildGridLines(int extent) {
    final lines = <GridLine>[];

    for (int value = -extent; value <= extent; value++) {
      lines.add(
        GridLine(
          start: TransformVector(x: value.toDouble(), y: -extent.toDouble()),
          end: TransformVector(x: value.toDouble(), y: extent.toDouble()),
          isAxis: value == 0,
        ),
      );
      lines.add(
        GridLine(
          start: TransformVector(x: -extent.toDouble(), y: value.toDouble()),
          end: TransformVector(x: extent.toDouble(), y: value.toDouble()),
          isAxis: value == 0,
        ),
      );
    }

    return lines;
  }
}
