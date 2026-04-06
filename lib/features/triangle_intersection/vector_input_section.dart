import 'package:flutter/material.dart';

class VectorInputSection extends StatelessWidget {
  const VectorInputSection({
    super.key,
    required this.title,
    required this.accent,
    required this.xController,
    required this.yController,
    required this.zController,
    required this.onSubmitted,
  });

  final String title;
  final Color accent;
  final TextEditingController xController;
  final TextEditingController yController;
  final TextEditingController zController;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.03),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: accent.withValues(alpha: 0.32)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 12,
                height: 12,
                decoration: BoxDecoration(color: accent, shape: BoxShape.circle),
              ),
              const SizedBox(width: 10),
              Text(
                title,
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              Expanded(
                child: _NumberField(
                  controller: xController,
                  label: 'x',
                  onSubmitted: onSubmitted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: yController,
                  label: 'y',
                  onSubmitted: onSubmitted,
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: _NumberField(
                  controller: zController,
                  label: 'z',
                  onSubmitted: onSubmitted,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _NumberField extends StatelessWidget {
  const _NumberField({
    required this.controller,
    required this.label,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final String label;
  final VoidCallback onSubmitted;

  @override
  Widget build(BuildContext context) {
    return TextField(
      controller: controller,
      keyboardType: const TextInputType.numberWithOptions(decimal: true, signed: true),
      style: const TextStyle(fontFeatures: [FontFeature.tabularFigures()]),
      onSubmitted: (_) => onSubmitted(),
      decoration: InputDecoration(labelText: label),
    );
  }
}
