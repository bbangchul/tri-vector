import 'package:todoey/features/matrix_rref/engine/rref_engine.dart';
import 'package:todoey/features/matrix_rref/models/matrix.dart';
import 'package:todoey/features/matrix_rref/models/rref_step.dart';

enum LinearSystemSolutionType {
  unique,
  infinite,
  none,
  notApplicable,
}

class LinearSystemSolution {
  const LinearSystemSolution({
    required this.type,
    required this.reducedMatrix,
    required this.steps,
    required this.explanation,
    this.values,
    this.freeVariableColumns = const [],
  });

  final LinearSystemSolutionType type;
  final MatrixModel reducedMatrix;
  final List<RrefStep> steps;
  final String explanation;
  final List<double>? values;
  final List<int> freeVariableColumns;
}

class LinearSystemSolver {
  const LinearSystemSolver._();

  static const double epsilon = RrefEngine.epsilon;

  static LinearSystemSolution solve(AugmentedMatrixModel matrix) {
    final steps = RrefEngine.reduce(matrix);
    final reduced = steps.last.matrix as AugmentedMatrixModel;
    final values = reduced.values;
    final coefficientColumns = matrix.coefficientColumns;

    for (final row in values) {
      final hasNonZeroCoefficient = row
          .take(coefficientColumns)
          .any((value) => value.abs() > epsilon);
      final constant = row[coefficientColumns];
      if (!hasNonZeroCoefficient && constant.abs() > epsilon) {
        return LinearSystemSolution(
          type: LinearSystemSolutionType.none,
          reducedMatrix: reduced,
          steps: steps,
          explanation: '0 = ${constant.toStringAsFixed(4)} 형태의 모순 행이 있어 해가 없습니다.',
        );
      }
    }

    final pivotColumns = <int>{};
    for (final row in values) {
      for (int column = 0; column < coefficientColumns; column++) {
        if (row[column].abs() > epsilon) {
          pivotColumns.add(column);
          break;
        }
      }
    }

    if (pivotColumns.length < coefficientColumns) {
      final freeColumns = <int>[];
      for (int column = 0; column < coefficientColumns; column++) {
        if (!pivotColumns.contains(column)) {
          freeColumns.add(column);
        }
      }
      return LinearSystemSolution(
        type: LinearSystemSolutionType.infinite,
        reducedMatrix: reduced,
        steps: steps,
        explanation:
            'pivot column 수가 변수 수보다 작아서 자유변수가 존재합니다. 자유변수 열: ${freeColumns.map((column) => 'x${column + 1}').join(', ')}',
        freeVariableColumns: freeColumns,
      );
    }

    final solutionValues = List<double>.filled(coefficientColumns, 0);
    for (final row in values) {
      for (int column = 0; column < coefficientColumns; column++) {
        if ((row[column] - 1).abs() < epsilon) {
          solutionValues[column] = row[coefficientColumns];
          break;
        }
      }
    }

    return LinearSystemSolution(
      type: LinearSystemSolutionType.unique,
      reducedMatrix: reduced,
      steps: steps,
      explanation: '모든 변수 열에 pivot이 있어 유일해가 존재합니다.',
      values: solutionValues,
    );
  }
}
