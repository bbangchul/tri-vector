import 'package:flutter/material.dart';
import 'package:todoey/features/matrix_rref/models/matrix_entry_mode.dart';
import 'package:todoey/features/matrix_rref/models/matrix_scope.dart';
import 'package:todoey/features/matrix_rref/widgets/matrix_input_card.dart';
import 'package:todoey/features/matrix_rref/widgets/matrix_result_overview.dart';
import 'package:todoey/features/matrix_rref/widgets/matrix_scope_card.dart';
import 'package:todoey/features/matrix_rref/engine/linear_system_solver.dart';
import 'package:todoey/features/matrix_rref/engine/rref_engine.dart';
import 'package:todoey/features/matrix_rref/models/matrix.dart';
import 'package:todoey/features/matrix_rref/models/rref_step.dart';

class MatrixRrefHomePage extends StatefulWidget {
  const MatrixRrefHomePage({super.key});

  @override
  State<MatrixRrefHomePage> createState() => _MatrixRrefHomePageState();
}

class _MatrixRrefHomePageState extends State<MatrixRrefHomePage> {
  MatrixEntryMode _mode = MatrixEntryMode.axb;
  int _rows = 3;
  int _columns = 4;
  late List<List<TextEditingController>> _controllers;

  bool get _isAugmentedMode => _mode == MatrixEntryMode.axb;

  @override
  void initState() {
    super.initState();
    _controllers = _createControllers(values: _sampleValuesForCurrentMode());
  }

  @override
  void dispose() {
    _disposeControllers();
    super.dispose();
  }

  List<List<double>> _sampleValuesForCurrentMode() {
    if (_isAugmentedMode) {
      return AugmentedMatrixModel.sample3x4().values;
    }

    return MatrixModel.sample(MatrixInputKind.square3x3).values;
  }

  List<List<TextEditingController>> _createControllers({
    required List<List<double>> values,
  }) {
    return values
        .map(
          (row) => row
              .map(
                (value) => TextEditingController(
                  text: value == 0 ? '0' : value.toString(),
                ),
              )
              .toList(growable: false),
        )
        .toList(growable: false);
  }

  List<List<String>> _currentTextValues() {
    return _controllers
        .map(
          (row) =>
              row.map((controller) => controller.text).toList(growable: false),
        )
        .toList(growable: false);
  }

  void _disposeControllers() {
    for (final row in _controllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
  }

  void _replaceControllers(List<List<String>> values) {
    _disposeControllers();
    _controllers = values
        .map(
          (row) => row
              .map((value) => TextEditingController(text: value))
              .toList(growable: false),
        )
        .toList(growable: false);
  }

  List<List<String>> _resizedValues({required int rows, required int columns}) {
    final current = _currentTextValues();
    return List.generate(
      rows,
      (rowIndex) => List.generate(columns, (columnIndex) {
        if (rowIndex < current.length &&
            columnIndex < current[rowIndex].length) {
          return current[rowIndex][columnIndex];
        }
        return '0';
      }),
      growable: false,
    );
  }

  void _handleModeChanged(MatrixEntryMode mode) {
    setState(() {
      _mode = mode;
      if (_isAugmentedMode) {
        _rows = 3;
        _columns = 4;
      } else {
        _rows = 3;
        _columns = 3;
      }
      _replaceControllers(
        _sampleValuesForCurrentMode()
            .map(
              (row) =>
                  row.map((value) => value.toString()).toList(growable: false),
            )
            .toList(growable: false),
      );
    });
  }

  void _handleRowsChanged(int rows) {
    setState(() {
      _rows = rows;
      _replaceControllers(_resizedValues(rows: _rows, columns: _columns));
    });
  }

  void _handleColumnsChanged(int columns) {
    setState(() {
      _columns = columns;
      _replaceControllers(_resizedValues(rows: _rows, columns: _columns));
    });
  }

  void _loadSample() {
    setState(() {
      if (_isAugmentedMode) {
        _rows = 3;
        _columns = 4;
      } else {
        _rows = 3;
        _columns = 3;
      }
      _replaceControllers(
        _sampleValuesForCurrentMode()
            .map(
              (row) =>
                  row.map((value) => value.toString()).toList(growable: false),
            )
            .toList(growable: false),
      );
    });
  }

  void _clearValues() {
    setState(() {
      _replaceControllers(
        List.generate(
          _rows,
          (_) => List.generate(_columns, (_) => '0', growable: false),
          growable: false,
        ),
      );
    });
  }

  _MatrixComputationState _buildComputationState() {
    final errors = <String>[];

    if (_isAugmentedMode) {
      if (_rows != 3 || _columns != 4) {
        errors.add('Ax=b 모드는 현재 3x4 augmented matrix만 지원합니다.');
      }
    } else if (!((_rows == 2 && _columns == 2) ||
        (_rows == 3 && _columns == 3))) {
      errors.add('일반 행렬 모드는 현재 2x2 또는 3x3만 지원합니다.');
    }

    final parsedValues = <List<double>>[];
    for (int row = 0; row < _rows; row++) {
      final parsedRow = <double>[];
      for (int column = 0; column < _columns; column++) {
        final raw = _controllers[row][column].text.trim();
        if (raw.isEmpty) {
          errors.add('(${row + 1}, ${column + 1}) 셀 값이 비어 있습니다.');
          parsedRow.add(0);
          continue;
        }

        final value = double.tryParse(raw);
        if (value == null) {
          errors.add('(${row + 1}, ${column + 1}) 셀에 올바른 숫자를 입력하세요.');
          parsedRow.add(0);
          continue;
        }

        parsedRow.add(value);
      }
      parsedValues.add(parsedRow);
    }

    if (errors.isNotEmpty) {
      return _MatrixComputationState(errors: errors);
    }

    if (_isAugmentedMode) {
      final matrix = AugmentedMatrixModel(
        rows: _rows,
        columns: _columns,
        coefficientColumns: _columns - 1,
        values: parsedValues,
      );
      final solution = LinearSystemSolver.solve(matrix);
      return _MatrixComputationState(
        matrix: matrix,
        reducedMatrix: solution.reducedMatrix,
        solution: solution,
        steps: solution.steps,
      );
    }

    final matrix = MatrixModel(
      rows: _rows,
      columns: _columns,
      values: parsedValues,
    );
    final steps = RrefEngine.reduce(matrix);
    final reducedMatrix = steps.last.matrix;
    return _MatrixComputationState(
      matrix: matrix,
      reducedMatrix: reducedMatrix,
      steps: steps,
      solution: LinearSystemSolution(
        type: LinearSystemSolutionType.notApplicable,
        reducedMatrix: reducedMatrix,
        steps: steps,
        explanation: '일반 행렬 모드에서는 Ax=b 해석 대신 RREF 단계와 최종 형태만 제공합니다.',
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final computation = _buildComputationState();

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFF0B1220), Color(0xFF070B14), Color(0xFF111827)],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      '행렬 연산 + Ax=b + RREF\n시각화',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '행렬 크기 선택, 셀 단위 입력, Ax=b 전용 모드, RREF 단계 시각화를 한 페이지에서 확인할 수 있습니다.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        height: 1.55,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                    const MatrixScopeCard(scope: matrixRrefV1Scope),
                    const SizedBox(height: 20),
                    MatrixInputCard(
                      mode: _mode,
                      rows: _rows,
                      columns: _columns,
                      controllers: _controllers,
                      errors: computation.errors,
                      onModeChanged: _handleModeChanged,
                      onRowsChanged: _handleRowsChanged,
                      onColumnsChanged: _handleColumnsChanged,
                      onLoadSample: _loadSample,
                      onClear: _clearValues,
                      onValuesChanged: () => setState(() {}),
                    ),
                    if (computation.hasResult) ...[
                      const SizedBox(height: 20),
                      MatrixResultOverview(
                        inputMatrix: computation.matrix!,
                        reducedMatrix: computation.reducedMatrix!,
                        solution: computation.solution!,
                        steps: computation.steps,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _MatrixComputationState {
  const _MatrixComputationState({
    this.matrix,
    this.reducedMatrix,
    this.solution,
    this.steps = const [],
    this.errors = const [],
  });

  final MatrixModel? matrix;
  final MatrixModel? reducedMatrix;
  final LinearSystemSolution? solution;
  final List<RrefStep> steps;
  final List<String> errors;

  bool get hasResult =>
      matrix != null &&
      reducedMatrix != null &&
      solution != null &&
      steps.isNotEmpty;
}
