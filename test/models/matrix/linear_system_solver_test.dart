import 'package:flutter_test/flutter_test.dart';
import 'package:todoey/features/matrix_rref/engine/linear_system_solver.dart';
import 'package:todoey/features/matrix_rref/models/matrix.dart';

void main() {
  group('LinearSystemSolver', () {
    test('classifies unique solution from augmented matrix', () {
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

      final solution = LinearSystemSolver.solve(matrix);

      expect(solution.type, LinearSystemSolutionType.unique);
      expect(solution.values, isNotNull);
      expect(solution.values!.length, 3);
      expect(solution.freeVariableColumns, isEmpty);
    });

    test('classifies infinite solutions and exposes free variables', () {
      const matrix = AugmentedMatrixModel(
        rows: 3,
        columns: 4,
        coefficientColumns: 3,
        values: [
          [1, 1, 1, 3],
          [2, 2, 2, 6],
          [0, 1, 1, 2],
        ],
      );

      final solution = LinearSystemSolver.solve(matrix);

      expect(solution.type, LinearSystemSolutionType.infinite);
      expect(solution.freeVariableColumns, isNotEmpty);
      expect(solution.explanation.contains('자유변수 열'), isTrue);
    });

    test('classifies no solution when contradiction row exists', () {
      const matrix = AugmentedMatrixModel(
        rows: 3,
        columns: 4,
        coefficientColumns: 3,
        values: [
          [1, 1, 1, 3],
          [1, 1, 1, 4],
          [0, 1, -1, 0],
        ],
      );

      final solution = LinearSystemSolver.solve(matrix);

      expect(solution.type, LinearSystemSolutionType.none);
      expect(solution.values, isNull);
      expect(solution.explanation.contains('모순 행'), isTrue);
    });
  });
}
