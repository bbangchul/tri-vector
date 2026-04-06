import 'package:todoey/features/matrix_rref/models/matrix.dart';
import 'package:todoey/features/matrix_rref/models/matrix_operation.dart';

class RrefStep {
  const RrefStep({
    required this.index,
    required this.title,
    required this.description,
    required this.matrix,
    this.operation,
    this.pivotRow,
    this.pivotColumn,
  });

  final int index;
  final String title;
  final String description;
  final MatrixModel matrix;
  final RowOperation? operation;
  final int? pivotRow;
  final int? pivotColumn;
}
