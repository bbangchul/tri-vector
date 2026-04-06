import 'package:flutter/material.dart';
import 'package:todoey/features/matrix_rref/models/matrix_scope.dart';
import 'package:todoey/features/matrix_rref/models/matrix.dart';

class MatrixScopeCard extends StatelessWidget {
  const MatrixScopeCard({
    super.key,
    required this.scope,
  });

  final MatrixFeatureScope scope;

  String _labelForKind(MatrixInputKind kind) {
    switch (kind) {
      case MatrixInputKind.square2x2:
        return '2x2 matrix';
      case MatrixInputKind.square3x3:
        return '3x3 matrix';
      case MatrixInputKind.augmented3x4:
        return '3x4 augmented matrix';
    }
  }

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
            '1차 구현 범위',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 18),
          Text(
            '지원 입력',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: scope.supportedInputs
                .map(
                  (kind) => _TagChip(
                    label: _labelForKind(kind),
                    color: const Color(0xFF4DA1FF),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          Text(
            '포함 기능',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: scope.supportedFeatures
                .map(
                  (feature) => _TagChip(
                    label: feature,
                    color: const Color(0xFFFF8A3D),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          Text(
            '제외 기능',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: scope.excludedFeatures
                .map(
                  (feature) => _TagChip(
                    label: feature,
                    color: const Color(0xFFFB7185),
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _TagChip extends StatelessWidget {
  const _TagChip({
    required this.label,
    required this.color,
  });

  final String label;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: color.withValues(alpha: 0.38),
        ),
      ),
      child: Text(
        label,
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}
