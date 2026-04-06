import 'package:flutter/material.dart';
import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/matrix_rref/engine/linear_system_solver.dart';
import 'package:todoey/features/matrix_rref/models/matrix.dart';
import 'package:todoey/features/matrix_rref/models/rref_step.dart';

class MatrixResultOverview extends StatelessWidget {
  const MatrixResultOverview({
    super.key,
    required this.inputMatrix,
    required this.reducedMatrix,
    required this.solution,
    required this.steps,
  });

  final MatrixModel inputMatrix;
  final MatrixModel reducedMatrix;
  final LinearSystemSolution solution;
  final List<RrefStep> steps;

  String _solutionTitle() {
    switch (solution.type) {
      case LinearSystemSolutionType.unique:
        return 'Unique Solution';
      case LinearSystemSolutionType.infinite:
        return 'Infinite Solutions';
      case LinearSystemSolutionType.none:
        return 'No Solution';
      case LinearSystemSolutionType.notApplicable:
        return 'Not Applicable';
    }
  }

  String _solutionValue() {
    if (solution.values != null && solution.values!.isNotEmpty) {
      return List.generate(
        solution.values!.length,
        (index) =>
            'x${index + 1} = ${formatDouble(solution.values![index], 4)}',
      ).join('  |  ');
    }

    if (solution.freeVariableColumns.isNotEmpty) {
      return solution.freeVariableColumns
          .map((column) => 'x${column + 1}')
          .join(', ');
    }

    return '-';
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isWide)
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: _MatrixCard(
                  title: 'Current Matrix',
                  subtitle: '입력된 행렬 또는 augmented matrix',
                  matrix: inputMatrix,
                ),
              ),
              const SizedBox(width: 20),
              Expanded(
                child: _MatrixCard(
                  title: 'RREF 결과',
                  subtitle: '기본 행 연산을 모두 적용한 reduced row echelon form',
                  matrix: reducedMatrix,
                ),
              ),
            ],
          )
        else ...[
          _MatrixCard(
            title: 'Current Matrix',
            subtitle: '입력된 행렬 또는 augmented matrix',
            matrix: inputMatrix,
          ),
          const SizedBox(height: 20),
          _MatrixCard(
            title: 'RREF 결과',
            subtitle: '기본 행 연산을 모두 적용한 reduced row echelon form',
            matrix: reducedMatrix,
          ),
        ],
        const SizedBox(height: 20),
        _MatrixStepViewer(steps: steps),
        const SizedBox(height: 20),
        _SolutionSummaryCard(
          solutionTitle: _solutionTitle(),
          solutionValue: _solutionValue(),
          explanation: solution.explanation,
          stepCount: steps.length,
        ),
      ],
    );
  }
}

class _MatrixCard extends StatelessWidget {
  const _MatrixCard({
    required this.title,
    required this.subtitle,
    required this.matrix,
  });

  final String title;
  final String subtitle;
  final MatrixModel matrix;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            subtitle,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _MatrixGrid(matrix: matrix),
          ),
        ],
      ),
    );
  }
}

class _MatrixGrid extends StatelessWidget {
  const _MatrixGrid({
    required this.matrix,
    this.highlightedRows = const <int>{},
  });

  final MatrixModel matrix;
  final Set<int> highlightedRows;

  @override
  Widget build(BuildContext context) {
    final rows = matrix.values;
    final dividerIndex =
        matrix is AugmentedMatrixModel
            ? (matrix as AugmentedMatrixModel).constantColumnIndex
            : null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          _BracketSide(isLeft: true),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: List.generate(rows.length, (rowIndex) {
              final row = rows[rowIndex];
              final isHighlighted = highlightedRows.contains(rowIndex);
              return Padding(
                padding: EdgeInsets.only(
                  bottom: rowIndex == rows.length - 1 ? 0 : 8,
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: List.generate(row.length, (columnIndex) {
                    final isDivider =
                        dividerIndex != null && columnIndex == dividerIndex;
                    return Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        if (isDivider)
                          Container(
                            width: 1,
                            height: 30,
                            margin: const EdgeInsets.symmetric(horizontal: 8),
                            color: Colors.white.withValues(alpha: 0.22),
                          ),
                        Container(
                          width: 72,
                          height: 38,
                          alignment: Alignment.center,
                          margin: EdgeInsets.only(
                            right: columnIndex == row.length - 1 ? 0 : 8,
                          ),
                          decoration: BoxDecoration(
                            color:
                                isHighlighted
                                    ? const Color(
                                      0xFF38BDF8,
                                    ).withValues(alpha: 0.18)
                                    : Colors.white.withValues(alpha: 0.05),
                            borderRadius: BorderRadius.circular(12),
                            border:
                                isHighlighted
                                    ? Border.all(
                                      color: const Color(
                                        0xFF7DD3FC,
                                      ).withValues(alpha: 0.5),
                                    )
                                    : null,
                          ),
                          child: Text(
                            formatDouble(row[columnIndex], 4),
                            style: const TextStyle(fontWeight: FontWeight.w700),
                          ),
                        ),
                      ],
                    );
                  }),
                ),
              );
            }),
          ),
          const SizedBox(width: 10),
          _BracketSide(isLeft: false),
        ],
      ),
    );
  }
}

class _MatrixStepViewer extends StatefulWidget {
  const _MatrixStepViewer({required this.steps});

  final List<RrefStep> steps;

  @override
  State<_MatrixStepViewer> createState() => _MatrixStepViewerState();
}

class _MatrixStepViewerState extends State<_MatrixStepViewer> {
  int _currentStepIndex = 0;

  void _goToStep(int index) {
    setState(() {
      _currentStepIndex = index.clamp(0, widget.steps.length - 1);
    });
  }

  Set<int> _changedRowsFor(int index) {
    if (index <= 0) {
      return <int>{};
    }

    final previous = widget.steps[index - 1].matrix.values;
    final current = widget.steps[index].matrix.values;
    final changedRows = <int>{};

    for (int row = 0; row < current.length; row++) {
      for (int column = 0; column < current[row].length; column++) {
        if ((current[row][column] - previous[row][column]).abs() > 1e-9) {
          changedRows.add(row);
          break;
        }
      }
    }

    return changedRows;
  }

  @override
  Widget build(BuildContext context) {
    final steps = widget.steps;
    final currentStep = steps[_currentStepIndex];
    final changedRows = _changedRowsFor(_currentStepIndex);
    final isInitial = _currentStepIndex == 0;
    final operationLabel =
        currentStep.operation?.describe() ?? '초기 행렬';
    final stepLabel =
        isInitial ? '초기 행렬' : '줄변환 ${currentStep.index}';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'RREF 줄변환',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '초기 행렬부터 각 기본 행 연산 단계를 순서대로 확인할 수 있습니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 14,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: const Color(0xFF38BDF8).withValues(alpha: 0.14),
                  borderRadius: BorderRadius.circular(999),
                ),
                child: Text(
                  stepLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    color: Color(0xFFBAE6FD),
                  ),
                ),
              ),
              Text(
                currentStep.title,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  operationLabel,
                  style: const TextStyle(
                    fontWeight: FontWeight.w800,
                    fontSize: 16,
                    color: Color(0xFFF8FAFC),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentStep.description,
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    height: 1.5,
                  ),
                ),
                if (changedRows.isNotEmpty) ...[
                  const SizedBox(height: 12),
                  Text(
                    '변경된 행: ${changedRows.map((row) => 'R${row + 1}').join(', ')}',
                    style: const TextStyle(
                      color: Color(0xFF7DD3FC),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ],
            ),
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _MatrixGrid(
              matrix: currentStep.matrix,
              highlightedRows: changedRows,
            ),
          ),
          const SizedBox(height: 20),
          Row(
            children: [
              Expanded(
                child: OutlinedButton.icon(
                  onPressed:
                      _currentStepIndex == 0
                          ? null
                          : () => _goToStep(_currentStepIndex - 1),
                  icon: const Icon(Icons.chevron_left),
                  label: const Text('이전'),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: FilledButton.icon(
                  onPressed:
                      _currentStepIndex == steps.length - 1
                          ? null
                          : () => _goToStep(_currentStepIndex + 1),
                  icon: const Icon(Icons.chevron_right),
                  label: const Text('다음'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          SliderTheme(
            data: SliderTheme.of(context).copyWith(
              activeTrackColor: const Color(0xFF38BDF8),
              inactiveTrackColor: Colors.white.withValues(alpha: 0.1),
              thumbColor: const Color(0xFF7DD3FC),
              overlayColor: const Color(0xFF38BDF8).withValues(alpha: 0.12),
            ),
            child: Slider(
              value: _currentStepIndex.toDouble(),
              min: 0,
              max: (steps.length - 1).toDouble(),
              divisions: steps.length - 1,
              label: stepLabel,
              onChanged: (value) => _goToStep(value.round()),
            ),
          ),
        ],
      ),
    );
  }
}

class _BracketSide extends StatelessWidget {
  const _BracketSide({required this.isLeft});

  final bool isLeft;

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      size: const Size(12, 140),
      painter: _BracketPainter(isLeft: isLeft),
    );
  }
}

class _BracketPainter extends CustomPainter {
  const _BracketPainter({required this.isLeft});

  final bool isLeft;

  @override
  void paint(Canvas canvas, Size size) {
    final paint =
        Paint()
          ..color = Colors.white.withValues(alpha: 0.42)
          ..strokeWidth = 2
          ..style = PaintingStyle.stroke;

    final path = Path();
    if (isLeft) {
      path
        ..moveTo(size.width, 0)
        ..lineTo(0, 0)
        ..lineTo(0, size.height)
        ..lineTo(size.width, size.height);
    } else {
      path
        ..moveTo(0, 0)
        ..lineTo(size.width, 0)
        ..lineTo(size.width, size.height)
        ..lineTo(0, size.height);
    }
    canvas.drawPath(path, paint);
  }

  @override
  bool shouldRepaint(covariant _BracketPainter oldDelegate) {
    return isLeft != oldDelegate.isLeft;
  }
}

class _SolutionSummaryCard extends StatelessWidget {
  const _SolutionSummaryCard({
    required this.solutionTitle,
    required this.solutionValue,
    required this.explanation,
    required this.stepCount,
  });

  final String solutionTitle;
  final String solutionValue;
  final String explanation;
  final int stepCount;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Solution Summary',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 16,
            runSpacing: 16,
            children: [
              _MetricTile(title: 'Type', value: solutionTitle),
              _MetricTile(title: 'Value', value: solutionValue),
              _MetricTile(title: '줄변환 단계', value: '$stepCount'),
            ],
          ),
          const SizedBox(height: 18),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
            ),
            child: Text(
              explanation,
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.88),
                height: 1.5,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Text(
            'determinant, rank 같은 보조값은 이후 단계에서 확장합니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.62),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}

class _MetricTile extends StatelessWidget {
  const _MetricTile({required this.title, required this.value});

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.68),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1.4,
            ),
          ),
        ],
      ),
    );
  }
}
