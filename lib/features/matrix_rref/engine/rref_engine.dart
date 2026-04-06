import 'package:todoey/features/matrix_rref/models/matrix.dart';
import 'package:todoey/features/matrix_rref/models/matrix_operation.dart';
import 'package:todoey/features/matrix_rref/models/rref_step.dart';

class RrefEngine {
  const RrefEngine._();

  static const double epsilon = 1e-9;

  static List<RrefStep> reduce(MatrixModel matrix) {
    final working = matrix.deepCopyValues();
    final steps = <RrefStep>[
      RrefStep(
        index: 0,
        title: '초기 행렬',
        description: '입력된 행렬 상태입니다.',
        matrix: _buildMatrixLike(matrix, working),
      ),
    ];

    var stepIndex = 1;
    var pivotRow = 0;

    for (int pivotColumn = 0;
        pivotColumn < matrix.columns && pivotRow < matrix.rows;
        pivotColumn++) {
      int? bestRow;
      double bestValue = 0;

      for (int row = pivotRow; row < matrix.rows; row++) {
        final value = working[row][pivotColumn].abs();
        if (value > bestValue + epsilon) {
          bestValue = value;
          bestRow = row;
        }
      }

      if (bestRow == null || bestValue < epsilon) {
        continue;
      }

      if (bestRow != pivotRow) {
        final temp = working[pivotRow];
        working[pivotRow] = working[bestRow];
        working[bestRow] = temp;
        _normalizeMatrix(working);
        steps.add(
          RrefStep(
            index: stepIndex++,
            title: '행 교환',
            description:
                'Pivot 탐색 후 ${pivotColumn + 1}열의 pivot을 위해 ${RowOperation.swap(firstRow: pivotRow, secondRow: bestRow).describe()} 를 수행합니다.',
            matrix: _buildMatrixLike(matrix, working),
            operation: RowOperation.swap(
              firstRow: pivotRow,
              secondRow: bestRow,
            ),
            pivotRow: pivotRow,
            pivotColumn: pivotColumn,
          ),
        );
      }

      final pivotValue = working[pivotRow][pivotColumn];
      if ((pivotValue - 1).abs() > epsilon) {
        for (int column = 0; column < matrix.columns; column++) {
          working[pivotRow][column] /= pivotValue;
        }
        _normalizeMatrix(working);
        steps.add(
          RrefStep(
            index: stepIndex++,
            title: '피벗 정규화',
            description:
                'Pivot (${pivotRow + 1}, ${pivotColumn + 1}) 값을 1로 만들기 위해 ${RowOperation.scale(row: pivotRow, scalar: 1 / pivotValue).describe()} 를 수행합니다.',
            matrix: _buildMatrixLike(matrix, working),
            operation: RowOperation.scale(
              row: pivotRow,
              scalar: 1 / pivotValue,
            ),
            pivotRow: pivotRow,
            pivotColumn: pivotColumn,
          ),
        );
      }

      for (int row = 0; row < matrix.rows; row++) {
        if (row == pivotRow) {
          continue;
        }

        final factor = working[row][pivotColumn];
        if (factor.abs() < epsilon) {
          continue;
        }

        for (int column = 0; column < matrix.columns; column++) {
          working[row][column] -= factor * working[pivotRow][column];
        }
        _normalizeMatrix(working);
        steps.add(
          RrefStep(
            index: stepIndex++,
            title: '열 소거',
            description:
                'Pivot (${pivotRow + 1}, ${pivotColumn + 1})를 기준으로 ${RowOperation.addScaled(targetRow: row, sourceRow: pivotRow, scalar: -factor).describe()} 를 수행해 같은 열의 다른 값을 제거합니다.',
            matrix: _buildMatrixLike(matrix, working),
            operation: RowOperation.addScaled(
              targetRow: row,
              sourceRow: pivotRow,
              scalar: -factor,
            ),
            pivotRow: pivotRow,
            pivotColumn: pivotColumn,
          ),
        );
      }

      pivotRow++;
    }

    steps.add(
      RrefStep(
        index: stepIndex,
        title: 'RREF 완료',
        description: '모든 pivot 처리와 위/아래 제거가 끝나 RREF 형태에 도달했습니다.',
        matrix: _buildMatrixLike(matrix, working),
      ),
    );

    return steps;
  }

  static MatrixModel _buildMatrixLike(
    MatrixModel original,
    List<List<double>> values,
  ) {
    if (original is AugmentedMatrixModel) {
      return AugmentedMatrixModel(
        rows: original.rows,
        columns: original.columns,
        coefficientColumns: original.coefficientColumns,
        values: values.map((row) => List<double>.from(row)).toList(growable: false),
      );
    }

    return MatrixModel(
      rows: original.rows,
      columns: original.columns,
      values: values.map((row) => List<double>.from(row)).toList(growable: false),
    );
  }

  static void _normalizeMatrix(List<List<double>> values) {
    for (int row = 0; row < values.length; row++) {
      for (int column = 0; column < values[row].length; column++) {
        final value = values[row][column];
        if (value.abs() < epsilon) {
          values[row][column] = 0;
        }
      }
    }
  }
}
