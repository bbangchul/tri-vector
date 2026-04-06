import 'package:flutter/material.dart';
import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_result.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_scene.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_view.dart';
import 'package:todoey/features/triangle_intersection/models/vector3.dart';
import 'package:todoey/features/triangle_intersection/painters/geometry_painter.dart';
import 'package:todoey/features/triangle_intersection/glass_card.dart';

class GeometryPreviewCard extends StatelessWidget {
  const GeometryPreviewCard({
    super.key,
    required this.a,
    required this.b,
    required this.c,
    required this.p1,
    required this.p2,
    required this.result,
    required this.hasError,
    required this.scenePoints,
    required this.selectedPointId,
    required this.onOpenViewer,
  });

  final Vector3 a;
  final Vector3 b;
  final Vector3 c;
  final Vector3 p1;
  final Vector3 p2;
  final GeometryResult? result;
  final bool hasError;
  final List<GeometryScenePoint> scenePoints;
  final String? selectedPointId;
  final VoidCallback onOpenViewer;

  @override
  Widget build(BuildContext context) {
    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '3D Points Preview',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '여기서는 점 위치만 빠르게 확인합니다. 캔버스를 누르면 전용 3D 화면으로 이동합니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 16),
          InkWell(
            onTap: onOpenViewer,
            borderRadius: BorderRadius.circular(24),
            child: AspectRatio(
              aspectRatio: 1.35,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(24),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            const Color(0xFF08111F),
                            const Color(0xFF0B1324),
                            const Color(0xFF060A12).withValues(alpha: 0.95),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: GeometryPainter(
                          a: a,
                          b: b,
                          c: c,
                          p1: p1,
                          p2: p2,
                          result: result,
                          hasError: hasError,
                          viewport: geometryCameraPresets.first.viewport,
                          scenePoints: scenePoints,
                          selectedPointId: selectedPointId,
                          interactionMode: GeometryInteractionMode.orbit,
                          isEditingPoint: false,
                          showOnlyPoints: true,
                        ),
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FilledButton.tonalIcon(
                      onPressed: onOpenViewer,
                      icon: const Icon(Icons.open_in_full_rounded),
                      label: const Text('Open 3D View'),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: scenePoints
                .map(
                  (point) => _PointChip(
                    point: point,
                    isSelected: point.id == selectedPointId,
                  ),
                )
                .toList(growable: false),
          ),
        ],
      ),
    );
  }
}

class _PointChip extends StatelessWidget {
  const _PointChip({
    required this.point,
    required this.isSelected,
  });

  final GeometryScenePoint point;
  final bool isSelected;

  @override
  Widget build(BuildContext context) {
    final color = GeometryPainter.colorForPointId(point.id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: isSelected
            ? color.withValues(alpha: 0.16)
            : Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isSelected
              ? color.withValues(alpha: 0.5)
              : Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '${point.label} ${_formatPosition(point.position)}',
            style: const TextStyle(fontWeight: FontWeight.w600),
          ),
        ],
      ),
    );
  }

  String _formatPosition(Vector3 position) {
    return '(${formatDouble(position.x)}, ${formatDouble(position.y)}, ${formatDouble(position.z)})';
  }
}
