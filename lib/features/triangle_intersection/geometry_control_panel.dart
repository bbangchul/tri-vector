import 'package:flutter/material.dart';
import 'package:todoey/features/triangle_intersection/glass_card.dart';
import 'package:todoey/features/triangle_intersection/vector_input_section.dart';

class GeometryControlPanel extends StatelessWidget {
  const GeometryControlPanel({
    super.key,
    required this.controllers,
    required this.onApply,
    required this.onReset,
  });

  final Map<String, TextEditingController> controllers;
  final VoidCallback onApply;
  final VoidCallback onReset;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Input Controls',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '삼각형 A, B, C 와 직선의 두 점 P1, P2 를 바꾸면 math_tri.cpp 와 같은 방식으로 교점 Q 와 내부 판정이 다시 계산됩니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 24),
          VectorInputSection(
            title: 'Triangle A',
            accent: const Color(0xFF4DA1FF),
            xController: controllers['ax']!,
            yController: controllers['ay']!,
            zController: controllers['az']!,
            onSubmitted: onApply,
          ),
          const SizedBox(height: 16),
          VectorInputSection(
            title: 'Triangle B',
            accent: const Color(0xFF38BDF8),
            xController: controllers['bx']!,
            yController: controllers['by']!,
            zController: controllers['bz']!,
            onSubmitted: onApply,
          ),
          const SizedBox(height: 16),
          VectorInputSection(
            title: 'Triangle C',
            accent: const Color(0xFF0EA5E9),
            xController: controllers['cx']!,
            yController: controllers['cy']!,
            zController: controllers['cz']!,
            onSubmitted: onApply,
          ),
          const SizedBox(height: 16),
          VectorInputSection(
            title: 'Line P1',
            accent: const Color(0xFFFF8A3D),
            xController: controllers['p1x']!,
            yController: controllers['p1y']!,
            zController: controllers['p1z']!,
            onSubmitted: onApply,
          ),
          const SizedBox(height: 16),
          VectorInputSection(
            title: 'Line P2',
            accent: const Color(0xFFFB7185),
            xController: controllers['p2x']!,
            yController: controllers['p2y']!,
            zController: controllers['p2z']!,
            onSubmitted: onApply,
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              FilledButton.icon(
                onPressed: onApply,
                icon: const Icon(Icons.play_arrow_rounded),
                label: const Text('Apply'),
              ),
              OutlinedButton.icon(
                onPressed: onReset,
                icon: const Icon(Icons.refresh_rounded),
                label: const Text('Load C++ Example'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
