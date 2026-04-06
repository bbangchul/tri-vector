import 'package:flutter/material.dart';
import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_result.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_scene.dart';
import 'package:todoey/features/triangle_intersection/models/vector3.dart';
import 'package:todoey/features/triangle_intersection/glass_card.dart';

class GeometryResultsCard extends StatelessWidget {
  const GeometryResultsCard({
    super.key,
    required this.a,
    required this.b,
    required this.c,
    required this.p1,
    required this.p2,
    required this.result,
    required this.errorMessage,
    required this.scenePoints,
    required this.selectedPointId,
  });

  final Vector3 a;
  final Vector3 b;
  final Vector3 c;
  final Vector3 p1;
  final Vector3 p2;
  final GeometryResult? result;
  final String? errorMessage;
  final List<GeometryScenePoint> scenePoints;
  final String? selectedPointId;

  @override
  Widget build(BuildContext context) {
    final selectedPoint = findScenePointById(scenePoints, selectedPointId);

    return GlassCard(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            'Computed Output',
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
          ),
          const SizedBox(height: 8),
          Text(
            '기본 예제는 math_tri.cpp 와 동일하게 A=(0,0,0), B=(1,0,0), C=(0,1,0), P1=(0.3,0.3,2), P2=(0.3,0.3,-2) 입니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.45,
            ),
          ),
          const SizedBox(height: 20),
          if (result == null)
            Text(
              errorMessage ?? '유효한 값을 입력하면 결과가 표시됩니다.',
              style: const TextStyle(fontSize: 16),
            )
          else ...[
            Wrap(
              spacing: 16,
              runSpacing: 16,
              children: [
                _MetricCard(
                  title: 'Intersection Q',
                  value: result!.intersectionPoint?.format() ?? 'No Intersection',
                ),
                _MetricCard(
                  title: 't',
                  value: result!.parameterT == null ? '-' : formatDouble(result!.parameterT!, 4),
                ),
                _MetricCard(
                  title: 'On Segment',
                  value: result!.isOnSegment ? 'YES' : 'NO',
                ),
                _MetricCard(
                  title: 'Inside Triangle',
                  value: result!.isInsideTriangle ? 'YES' : 'NO',
                ),
              ],
            ),
            const SizedBox(height: 20),
            if (selectedPoint != null) ...[
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white.withValues(alpha: 0.035),
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
                ),
                child: Text(
                  'Selected Point: ${selectedPoint.label}  |  ${selectedPoint.description}',
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    height: 1.5,
                  ),
                ),
              ),
              const SizedBox(height: 20),
            ],
            SelectableText(
              [
                'math_tri.cpp 기준 식',
                'D = P2 - P1',
                'normal = (B - A) x (C - A)',
                'denom = D · normal',
                't = ((A - P1) · normal) / denom',
                'Q = P1 + D * t',
                '',
                '입력',
                'A = ${a.format()}',
                'B = ${b.format()}',
                'C = ${c.format()}',
                'P1 = ${p1.format()}',
                'P2 = ${p2.format()}',
                '',
                '출력',
                'Plane normal = ${result!.planeNormal.format()}',
                'Q = ${result!.intersectionPoint?.format() ?? 'parallel'}',
                't = ${result!.parameterT == null ? '-' : formatDouble(result!.parameterT!, 4)}',
                'Line parallel to plane = ${result!.isParallel ? 'YES' : 'NO'}',
                'Intersection on segment = ${result!.isOnSegment ? 'YES' : 'NO'}',
                'Q inside triangle = ${result!.isInsideTriangle ? 'YES' : 'NO'}',
              ].join('\n'),
              style: TextStyle(
                fontSize: 15,
                height: 1.6,
                color: Colors.white.withValues(alpha: 0.9),
              ),
            ),
          ],
        ],
      ),
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({
    required this.title,
    required this.value,
  });

  final String title;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.035),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.7),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            value,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
