import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_palette.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_preset.dart';

class TransformVectorInputBinding {
  const TransformVectorInputBinding({
    required this.id,
    required this.label,
    required this.color,
    required this.xController,
    required this.yController,
  });

  final String id;
  final String label;
  final Color color;
  final TextEditingController xController;
  final TextEditingController yController;
}

class TransformInputCard extends StatelessWidget {
  const TransformInputCard({
    super.key,
    required this.presets,
    required this.selectedPresetId,
    required this.matrixControllers,
    required this.vectorBindings,
    required this.selectedVectorId,
    required this.errors,
    required this.onPresetSelected,
    required this.onLoadSample,
    required this.onReset,
    required this.onVectorSelected,
    required this.onAddVector,
    required this.onDeleteVector,
    required this.onValuesChanged,
  });

  final List<TransformPreset> presets;
  final String selectedPresetId;
  final List<List<TextEditingController>> matrixControllers;
  final List<TransformVectorInputBinding> vectorBindings;
  final String selectedVectorId;
  final List<String> errors;
  final ValueChanged<TransformPreset> onPresetSelected;
  final VoidCallback onLoadSample;
  final VoidCallback onReset;
  final ValueChanged<String> onVectorSelected;
  final VoidCallback onAddVector;
  final ValueChanged<String> onDeleteVector;
  final VoidCallback onValuesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Transform Input',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            'preset을 선택하거나 2x2 행렬과 벡터들을 직접 입력하면 before / after 캔버스가 즉시 갱신됩니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 20),
          Text(
            'Presets',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: presets
                .map(
                  (preset) => ChoiceChip(
                    label: Text(preset.title),
                    selected: selectedPresetId == preset.id,
                    onSelected: (_) => onPresetSelected(preset),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 20),
          LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;

              if (isWide) {
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: _MatrixEditor(
                        controllers: matrixControllers,
                        onValuesChanged: onValuesChanged,
                      ),
                    ),
                    const SizedBox(width: 20),
                    Expanded(
                      child: _VectorEditor(
                        vectorBindings: vectorBindings,
                        selectedVectorId: selectedVectorId,
                        onVectorSelected: onVectorSelected,
                        onAddVector: onAddVector,
                        onDeleteVector: onDeleteVector,
                        onValuesChanged: onValuesChanged,
                      ),
                    ),
                  ],
                );
              }

              return Column(
                children: [
                  _MatrixEditor(
                    controllers: matrixControllers,
                    onValuesChanged: onValuesChanged,
                  ),
                  const SizedBox(height: 20),
                  _VectorEditor(
                    vectorBindings: vectorBindings,
                    selectedVectorId: selectedVectorId,
                    onVectorSelected: onVectorSelected,
                    onAddVector: onAddVector,
                    onDeleteVector: onDeleteVector,
                    onValuesChanged: onValuesChanged,
                  ),
                ],
              );
            },
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              OutlinedButton.icon(
                onPressed: onLoadSample,
                icon: const Icon(Icons.auto_fix_high_rounded),
                label: const Text('Sample'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restart_alt_rounded),
                label: const Text('Reset'),
              ),
            ],
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

class _MatrixEditor extends StatelessWidget {
  const _MatrixEditor({
    required this.controllers,
    required this.onValuesChanged,
  });

  final List<List<TextEditingController>> controllers;
  final VoidCallback onValuesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '2x2 Matrix A',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: List.generate(2, (rowIndex) {
              return Row(
                mainAxisSize: MainAxisSize.min,
                children: List.generate(2, (columnIndex) {
                  return Padding(
                    padding: EdgeInsets.only(right: columnIndex == 1 ? 0 : 12),
                    child: SizedBox(
                      width: 92,
                      child: TextField(
                        key: ValueKey('matrix-$rowIndex-$columnIndex'),
                        controller: controllers[rowIndex][columnIndex],
                        onChanged: (_) => onValuesChanged(),
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                          signed: true,
                        ),
                        inputFormatters: [
                          FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                        ],
                        textAlign: TextAlign.center,
                        decoration: InputDecoration(
                          labelText: 'a${rowIndex + 1}${columnIndex + 1}',
                          isDense: true,
                        ),
                      ),
                    ),
                  );
                }),
              );
            }),
          ),
        ],
      ),
    );
  }
}

class _VectorEditor extends StatelessWidget {
  const _VectorEditor({
    required this.vectorBindings,
    required this.selectedVectorId,
    required this.onVectorSelected,
    required this.onAddVector,
    required this.onDeleteVector,
    required this.onValuesChanged,
  });

  final List<TransformVectorInputBinding> vectorBindings;
  final String selectedVectorId;
  final ValueChanged<String> onVectorSelected;
  final VoidCallback onAddVector;
  final ValueChanged<String> onDeleteVector;
  final VoidCallback onValuesChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Vectors',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.w800,
                    ),
              ),
              const Spacer(),
              FilledButton.icon(
                onPressed: vectorBindings.length >= 3 ? null : onAddVector,
                icon: const Icon(Icons.add_rounded),
                label: const Text('Add'),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: vectorBindings
                .map(
                  (binding) => ChoiceChip(
                    key: ValueKey('vector-chip-${binding.id}'),
                    label: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Container(
                          width: 10,
                          height: 10,
                          decoration: BoxDecoration(
                            color: binding.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(binding.label),
                      ],
                    ),
                    selected: selectedVectorId == binding.id,
                    onSelected: (_) => onVectorSelected(binding.id),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 14),
          ...vectorBindings.map((binding) {
            final isSelected = selectedVectorId == binding.id;
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 180),
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: isSelected
                      ? binding.color.withValues(alpha: 0.12)
                      : Colors.white.withValues(alpha: 0.02),
                  borderRadius: BorderRadius.circular(18),
                  border: Border.all(
                    color: isSelected
                        ? binding.color.withValues(alpha: 0.45)
                        : Colors.white.withValues(alpha: 0.08),
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: binding.color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          binding.label,
                          style: const TextStyle(fontWeight: FontWeight.w800),
                        ),
                        const Spacer(),
                        TextButton(
                          onPressed: () => onVectorSelected(binding.id),
                          child: const Text('Select'),
                        ),
                        if (vectorBindings.length > 1)
                          IconButton(
                            onPressed: () => onDeleteVector(binding.id),
                            icon: const Icon(Icons.delete_outline_rounded),
                            color: TransformPalette.roseAccent,
                            tooltip: 'Delete vector',
                          ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Wrap(
                      spacing: 12,
                      runSpacing: 12,
                      children: [
                        SizedBox(
                          width: 120,
                          child: TextField(
                            key: ValueKey('vector-x-${binding.id}'),
                            controller: binding.xController,
                            onTap: () => onVectorSelected(binding.id),
                            onChanged: (_) => onValuesChanged(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: '${binding.label}x',
                              isDense: true,
                            ),
                          ),
                        ),
                        SizedBox(
                          width: 120,
                          child: TextField(
                            key: ValueKey('vector-y-${binding.id}'),
                            controller: binding.yController,
                            onTap: () => onVectorSelected(binding.id),
                            onChanged: (_) => onValuesChanged(),
                            keyboardType: const TextInputType.numberWithOptions(
                              decimal: true,
                              signed: true,
                            ),
                            inputFormatters: [
                              FilteringTextInputFormatter.allow(RegExp(r'[-0-9.]')),
                            ],
                            textAlign: TextAlign.center,
                            decoration: InputDecoration(
                              labelText: '${binding.label}y',
                              isDense: true,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          }),
        ],
      ),
    );
  }
}
