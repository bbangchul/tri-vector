import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoey/features/matrix_rref/models/matrix_entry_mode.dart';

class MatrixInputCard extends StatelessWidget {
  const MatrixInputCard({
    super.key,
    required this.mode,
    required this.rows,
    required this.columns,
    required this.controllers,
    required this.errors,
    required this.onModeChanged,
    required this.onRowsChanged,
    required this.onColumnsChanged,
    required this.onLoadSample,
    required this.onClear,
    required this.onValuesChanged,
  });

  final MatrixEntryMode mode;
  final int rows;
  final int columns;
  final List<List<TextEditingController>> controllers;
  final List<String> errors;
  final ValueChanged<MatrixEntryMode> onModeChanged;
  final ValueChanged<int> onRowsChanged;
  final ValueChanged<int> onColumnsChanged;
  final VoidCallback onLoadSample;
  final VoidCallback onClear;
  final VoidCallback onValuesChanged;

  bool get _isAugmentedMode => mode == MatrixEntryMode.axb;

  @override
  Widget build(BuildContext context) {
    final dividerIndex = _isAugmentedMode ? columns - 1 : null;

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
            'Matrix Input',
            style: Theme.of(
              context,
            ).textTheme.headlineSmall?.copyWith(fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 8),
          Text(
            '행렬 크기와 모드를 선택하고 각 셀에 숫자를 입력하면 아래 결과와 RREF 단계가 즉시 갱신됩니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          SegmentedButton<MatrixEntryMode>(
            segments: const [
              ButtonSegment<MatrixEntryMode>(
                value: MatrixEntryMode.general,
                icon: Icon(Icons.grid_view_rounded),
                label: Text('일반 행렬'),
              ),
              ButtonSegment<MatrixEntryMode>(
                value: MatrixEntryMode.axb,
                icon: Icon(Icons.functions_rounded),
                label: Text('Ax=b'),
              ),
            ],
            selected: {mode},
            onSelectionChanged: (selection) => onModeChanged(selection.first),
          ),
          const SizedBox(height: 18),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<int>(
                  value: rows,
                  decoration: const InputDecoration(labelText: 'Rows'),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                  ],
                  onChanged: _isAugmentedMode
                      ? null
                      : (value) {
                          if (value != null) {
                            onRowsChanged(value);
                          }
                        },
                ),
              ),
              SizedBox(
                width: 140,
                child: DropdownButtonFormField<int>(
                  value: columns,
                  decoration: const InputDecoration(labelText: 'Columns'),
                  items: const [
                    DropdownMenuItem(value: 2, child: Text('2')),
                    DropdownMenuItem(value: 3, child: Text('3')),
                    DropdownMenuItem(value: 4, child: Text('4')),
                  ],
                  onChanged: _isAugmentedMode
                      ? null
                      : (value) {
                          if (value != null) {
                            onColumnsChanged(value);
                          }
                        },
                ),
              ),
              if (_isAugmentedMode)
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 14,
                    vertical: 10,
                  ),
                  decoration: BoxDecoration(
                    color: const Color(0xFF38BDF8).withValues(alpha: 0.12),
                    borderRadius: BorderRadius.circular(999),
                    border: Border.all(
                      color: const Color(0xFF38BDF8).withValues(alpha: 0.24),
                    ),
                  ),
                  child: const Text(
                    'Ax=b 모드는 3x4 augmented matrix만 지원',
                    style: TextStyle(
                      color: Color(0xFFBAE6FD),
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onLoadSample,
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('Load Sample'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onClear,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Clear'),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: _EditableMatrixGrid(
              rows: rows,
              columns: columns,
              controllers: controllers,
              dividerIndex: dividerIndex,
              onValuesChanged: onValuesChanged,
            ),
          ),
          if (errors.isNotEmpty) ...[
            const SizedBox(height: 16),
            Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: const Color(0xFFFB7185).withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(18),
                border: Border.all(
                  color: const Color(0xFFFB7185).withValues(alpha: 0.24),
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    '입력 오류',
                    style: TextStyle(
                      fontWeight: FontWeight.w800,
                      color: Color(0xFFFECDD3),
                    ),
                  ),
                  const SizedBox(height: 8),
                  ...errors.map(
                    (error) => Padding(
                      padding: const EdgeInsets.only(bottom: 6),
                      child: Text(
                        '• $error',
                        style: const TextStyle(
                          color: Colors.white,
                          height: 1.45,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _EditableMatrixGrid extends StatelessWidget {
  const _EditableMatrixGrid({
    required this.rows,
    required this.columns,
    required this.controllers,
    required this.onValuesChanged,
    this.dividerIndex,
  });

  final int rows;
  final int columns;
  final List<List<TextEditingController>> controllers;
  final int? dividerIndex;
  final VoidCallback onValuesChanged;

  @override
  Widget build(BuildContext context) {
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
          const _BracketSide(isLeft: true),
          const SizedBox(width: 10),
          Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(columns, (columnIndex) {
                  final isDivider =
                      dividerIndex != null && columnIndex == dividerIndex;
                  final label =
                      dividerIndex != null && columnIndex == dividerIndex
                          ? 'b'
                          : 'x${columnIndex + 1}';
                  return Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (isDivider)
                        Container(
                          width: 1,
                          height: 22,
                          margin: const EdgeInsets.symmetric(horizontal: 8),
                          color: Colors.white.withValues(alpha: 0.22),
                        ),
                      SizedBox(
                        width: 84,
                        child: Center(
                          child: Text(
                            label,
                            style: TextStyle(
                              color: Colors.white.withValues(alpha: 0.72),
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ),
                      ),
                    ],
                  );
                }),
              ),
              const SizedBox(height: 10),
              ...List.generate(rows, (rowIndex) {
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: rowIndex == rows - 1 ? 0 : 8,
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: List.generate(columns, (columnIndex) {
                      final isDivider =
                          dividerIndex != null && columnIndex == dividerIndex;
                      return Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isDivider)
                            Container(
                              width: 1,
                              height: 44,
                              margin: const EdgeInsets.symmetric(horizontal: 8),
                              color: Colors.white.withValues(alpha: 0.22),
                            ),
                          SizedBox(
                            width: 84,
                            child: TextField(
                              key: ValueKey(
                                'cell-$rowIndex-$columnIndex-$rows-$columns',
                              ),
                              controller: controllers[rowIndex][columnIndex],
                              onChanged: (_) => onValuesChanged(),
                              keyboardType:
                                  const TextInputType.numberWithOptions(
                                    decimal: true,
                                    signed: true,
                                  ),
                              inputFormatters: [
                                FilteringTextInputFormatter.allow(
                                  RegExp(r'[-0-9.]'),
                                ),
                              ],
                              textAlign: TextAlign.center,
                              decoration: InputDecoration(
                                isDense: true,
                                contentPadding: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 12,
                                ),
                                hintText: '0',
                                fillColor: Colors.white.withValues(alpha: 0.05),
                              ),
                            ),
                          ),
                        ],
                      );
                    }),
                  ),
                );
              }),
            ],
          ),
          const SizedBox(width: 10),
          const _BracketSide(isLeft: false),
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
      size: const Size(12, 160),
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
