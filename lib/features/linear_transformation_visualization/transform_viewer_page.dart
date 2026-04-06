import 'package:flutter/material.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_palette.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_scene.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';
import 'package:todoey/features/linear_transformation_visualization/painters/transform_painter.dart';

class TransformViewerPage extends StatelessWidget {
  const TransformViewerPage({
    super.key,
    required this.title,
    required this.subtitle,
    required this.gridLines,
    required this.basisVectors,
    required this.vectors,
    required this.viewportExtent,
  });

  final String title;
  final String subtitle;
  final List<GridLine> gridLines;
  final List<TransformVector> basisVectors;
  final List<TransformVector> vectors;
  final double viewportExtent;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              TransformPalette.backgroundTop,
              TransformPalette.backgroundMid,
              TransformPalette.backgroundBottom,
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              Positioned.fill(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 76, 16, 16),
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: TransformPalette.cardSurface.withValues(alpha: 0.88),
                      borderRadius: BorderRadius.circular(32),
                      border: Border.all(
                        color: TransformPalette.cardBorder,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(32),
                      child: CustomPaint(
                        painter: TransformPainter(
                          gridLines: gridLines,
                          basisVectors: basisVectors,
                          vectors: vectors,
                          viewportExtent: viewportExtent,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              Positioned(
                top: 16,
                left: 16,
                right: 76,
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 18,
                    vertical: 14,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.28),
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(
                      color: Colors.white.withValues(alpha: 0.12),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        title,
                        style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w800,
                            ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.76),
                          height: 1.45,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              Positioned(
                top: 16,
                right: 16,
                child: IconButton.filledTonal(
                  tooltip: 'Close viewer',
                  onPressed: () => Navigator.of(context).pop(),
                  icon: const Icon(Icons.close_rounded),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
