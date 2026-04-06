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
    return Wrap(
      alignment: WrapAlignment.spaceBetween,
      runSpacing: 16,
      crossAxisAlignment: WrapCrossAlignment.center,
      children: [
        SizedBox(
          width: 720,
          child: Text(
            'Triangle /\nLine Intersection',
            style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
            ),
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
    );
  }
}
