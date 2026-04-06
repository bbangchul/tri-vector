enum MatrixInputKind {
  square2x2,
  square3x3,
  augmented3x4,
}

class MatrixModel {
  const MatrixModel({
    required this.rows,
    required this.columns,
    required this.values,
  });

  final int rows;
  final int columns;
  final List<List<double>> values;

  bool get isAugmented => false;

  List<List<double>> deepCopyValues() {
    return values.map((row) => List<double>.from(row)).toList(growable: false);
  }

  MatrixModel copyWith({
    int? rows,
    int? columns,
    List<List<double>>? values,
  }) {
    return MatrixModel(
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      values: values ?? deepCopyValues(),
    );
  }

  factory MatrixModel.sample(MatrixInputKind kind) {
    switch (kind) {
      case MatrixInputKind.square2x2:
        return const MatrixModel(
          rows: 2,
          columns: 2,
          values: [
            [1, 2],
            [3, 4],
          ],
        );
      case MatrixInputKind.square3x3:
        return const MatrixModel(
          rows: 3,
          columns: 3,
          values: [
            [1, 2, 0],
            [0, 1, 3],
            [2, -1, 1],
          ],
        );
      case MatrixInputKind.augmented3x4:
        return AugmentedMatrixModel.sample3x4();
    }
  }
}

class AugmentedMatrixModel extends MatrixModel {
  const AugmentedMatrixModel({
    required super.rows,
    required super.columns,
    required super.values,
    required this.coefficientColumns,
  });

  final int coefficientColumns;

  @override
  bool get isAugmented => true;

  int get constantColumnIndex => coefficientColumns;

  factory AugmentedMatrixModel.sample3x4() {
    return const AugmentedMatrixModel(
      rows: 3,
      columns: 4,
      coefficientColumns: 3,
      values: [
        [1, 1, 1, 6],
        [2, -1, 1, 3],
        [1, 2, -1, 3],
      ],
    );
  }

  @override
  AugmentedMatrixModel copyWith({
    int? rows,
    int? columns,
    List<List<double>>? values,
    int? coefficientColumns,
  }) {
    return AugmentedMatrixModel(
      rows: rows ?? this.rows,
      columns: columns ?? this.columns,
      values: values ?? deepCopyValues(),
      coefficientColumns: coefficientColumns ?? this.coefficientColumns,
    );
  }
}
