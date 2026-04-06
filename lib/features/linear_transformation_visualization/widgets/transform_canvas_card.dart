import 'package:flutter/material.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_palette.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_scene.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';
import 'package:todoey/features/linear_transformation_visualization/painters/transform_painter.dart';

class TransformCanvasCard extends StatelessWidget {
  const TransformCanvasCard({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gridLines,
    required this.basisVectors,
    required this.vectors,
    required this.viewportExtent,
    this.aspectRatio = 1,
    this.onTap,
  });

  final String title;
  final String subtitle;
  final List<GridLine> gridLines;
  final List<TransformVector> basisVectors;
  final List<TransformVector> vectors;
  final double viewportExtent;
  final double aspectRatio;
  final VoidCallback? onTap;

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(28),
        child: Container(
          width: double.infinity,
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            color: TransformPalette.cardSurface,
            borderRadius: BorderRadius.circular(28),
            border: Border.all(
              color: TransformPalette.cardBorder,
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          title,
                          style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                                fontWeight: FontWeight.w800,
                              ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          subtitle,
                          style: TextStyle(
                            color: Colors.white.withValues(alpha: 0.72),
                            height: 1.45,
                          ),
                        ),
                      ],
                    ),
                  ),
                  if (onTap != null) ...[
                    const SizedBox(width: 12),
                    Icon(
                      Icons.open_in_full_rounded,
                      color: Colors.white.withValues(alpha: 0.72),
                    ),
                  ],
                ],
              ),
              const SizedBox(height: 16),
              AspectRatio(
                aspectRatio: aspectRatio,
                child: CustomPaint(
                  painter: TransformPainter(
                    gridLines: gridLines,
                    basisVectors: basisVectors,
                    vectors: vectors,
                    viewportExtent: viewportExtent,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
