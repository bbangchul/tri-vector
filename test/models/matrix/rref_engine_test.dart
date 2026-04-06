import 'package:flutter_test/flutter_test.dart';
import 'package:todoey/features/matrix_rref/engine/rref_engine.dart';
import 'package:todoey/features/matrix_rref/models/matrix.dart';
import 'package:todoey/features/matrix_rref/models/matrix_operation.dart';

void main() {
  group('RrefEngine', () {
    test('stores row swap, normalize, eliminate, and final step', () {
      const matrix = MatrixModel(
        rows: 2,
        columns: 2,
        values: [
          [0, 2],
          [1, 3],
        ],
      );

      final steps = RrefEngine.reduce(matrix);

      expect(steps.first.title, '초기 행렬');
      expect(
        steps.any((step) => step.operation?.type == RowOperationType.swap),
        isTrue,
      );
      expect(
        steps.any((step) => step.operation?.type == RowOperationType.scale),
        isTrue,
      );
      expect(
        steps.any((step) => step.operation?.type == RowOperationType.addScaled),
        isTrue,
      );
      expect(steps.last.title, 'RREF 완료');
      expect(steps.last.matrix.values, [
        [1, 0],
        [0, 1],
      ]);
    });

    test('keeps detailed descriptions for each row operation', () {
      const matrix = AugmentedMatrixModel(
        rows: 3,
        columns: 4,
        coefficientColumns: 3,
        values: [
          [1, 1, 1, 6],
          [2, -1, 1, 3],
          [1, 2, -1, 3],
        ],
      );

      final steps = RrefEngine.reduce(matrix);
      final operationSteps = steps.where((step) => step.operation != null).toList();

      expect(operationSteps, isNotEmpty);
      expect(
        operationSteps.every((step) => step.description.contains('R')),
        isTrue,
      );
      expect(
        operationSteps.every((step) => step.pivotRow != null && step.pivotColumn != null),
        isTrue,
      );
    });
  });
}
