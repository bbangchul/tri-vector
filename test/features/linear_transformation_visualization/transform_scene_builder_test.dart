import 'package:flutter_test/flutter_test.dart';
import 'package:todoey/features/linear_transformation_visualization/engine/transform_scene_builder.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_preset.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transformation_matrix.dart';

void main() {
  group('TransformationMatrix', () {
    test('applies a 2x2 matrix to a vector', () {
      const matrix = TransformationMatrix(
        a11: 2,
        a12: 1,
        a21: 0,
        a22: 3,
      );

      final result = matrix.applyTo(
        const TransformVector(id: 'v', label: 'v', x: 1, y: 2),
      );

      expect(
        result,
        const TransformVector(id: 'v', label: 'v', x: 4, y: 6),
      );
      expect(matrix.determinant, 6);
    });

    test('exposes basis vector images', () {
      const matrix = TransformationMatrix(
        a11: 0,
        a12: -1,
        a21: 1,
        a22: 0,
      );

      expect(
        matrix.transformedBasisX,
        const TransformVector(id: 'e1', label: 'e1', x: 0, y: 1),
      );
      expect(
        matrix.transformedBasisY,
        const TransformVector(id: 'e2', label: 'e2', x: -1, y: 0),
      );
    });
  });

  group('TransformSceneBuilder', () {
    test('builds original and transformed grid scenes', () {
      final scene = TransformSceneBuilder.build(
        matrix: TransformPreset.shear.matrix,
        vectors: const [
          TransformVector(id: 'v1', label: 'v1', x: 2, y: 1),
        ],
        gridExtent: 2,
      );

      expect(scene.originalBasis.length, 2);
      expect(scene.transformedBasis.length, 2);
      expect(scene.originalVectors.length, 1);
      expect(scene.transformedVectors.length, 1);
      expect(scene.originalGridLines.length, 10);
      expect(scene.transformedGridLines.length, 10);
      expect(
        scene.transformedVectors.single,
        const TransformVector(id: 'v1', label: 'v1', x: 3, y: 1),
      );
      expect(scene.viewportExtent, greaterThanOrEqualTo(3));
    });
  });
}
