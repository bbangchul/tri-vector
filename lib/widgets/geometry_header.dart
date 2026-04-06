import 'package:flutter/material.dart';

class GeometryHeader extends StatelessWidget {
  const GeometryHeader({
    super.key,
    required this.onApply,
    required this.onReset,
  });

  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(28),
        gradient: LinearGradient(
          colors: [
            const Color(0xFF0F172A).withValues(alpha: 0.92),
            const Color(0xFF1E293B).withValues(alpha: 0.72),
          ],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        runSpacing: 16,
        children: [
          SizedBox(
            width: 720,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  'Triangle / Line Intersection',
                  style: Theme.of(context).textTheme.displaySmall?.copyWith(
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                      ),
                ),
                const SizedBox(height: 12),
                Text(
                  'lib/math_tri.cpp 의 Vec3, barycentric 내부 판정, 직선-평면 교점 계산 로직을 Dart 앱과 시각화에 맞게 옮긴 화면입니다.',
                  style: TextStyle(
                    color: Colors.white.withValues(alpha: 0.72),
                    fontSize: 16,
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.tonalIcon(
                onPressed: onApply,
                icon: const Icon(Icons.auto_graph_rounded),
                label: const Text('Recalculate'),
              ),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.restore_rounded),
                label: const Text('Load Example'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
