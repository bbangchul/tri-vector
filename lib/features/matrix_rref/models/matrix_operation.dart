import 'package:todoey/features/shared/formatters.dart';

enum RowOperationType { swap, scale, addScaled }

class RowOperation {
  const RowOperation._({
    required this.type,
    required this.targetRow,
    this.sourceRow,
    this.scalar,
  });

  final RowOperationType type;
  final int targetRow;
  final int? sourceRow;
  final double? scalar;

  factory RowOperation.swap({required int firstRow, required int secondRow}) {
    return RowOperation._(
      type: RowOperationType.swap,
      targetRow: firstRow,
      sourceRow: secondRow,
    );
  }

  factory RowOperation.scale({required int row, required double scalar}) {
    return RowOperation._(
      type: RowOperationType.scale,
      targetRow: row,
      scalar: scalar,
    );
  }

  factory RowOperation.addScaled({
    required int targetRow,
    required int sourceRow,
    required double scalar,
  }) {
    return RowOperation._(
      type: RowOperationType.addScaled,
      targetRow: targetRow,
      sourceRow: sourceRow,
      scalar: scalar,
    );
  }

  String describe() {
    switch (type) {
      case RowOperationType.swap:
        return 'R${targetRow + 1} <-> R${(sourceRow ?? 0) + 1}';
      case RowOperationType.scale:
        return 'R${targetRow + 1} <- ${formatDouble(scalar ?? 1, 4)}R${targetRow + 1}';
      case RowOperationType.addScaled:
        final factor = scalar ?? 0;
        final sign = factor < 0 ? '-' : '+';
        final magnitude = formatDouble(factor.abs(), 4);
        return 'R${targetRow + 1} <- R${targetRow + 1} $sign ${magnitude}R${(sourceRow ?? 0) + 1}';
    }
  }
}
