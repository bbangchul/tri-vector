import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:todoey/models/geometry_result.dart';
import 'package:todoey/models/geometry_scene.dart';
import 'package:todoey/models/geometry_view.dart';
import 'package:todoey/models/vector3.dart';
import 'package:todoey/painters/geometry_painter.dart';
import 'package:todoey/widgets/glass_card.dart';

class GeometryCanvasCard extends StatefulWidget {
  const GeometryCanvasCard({
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
    required this.onPointSelected,
    required this.onPointEdited,
    this.enablePointEditing = true,
    this.allowedPresetIds,
    this.compactLayout = false,
    this.showLegend = true,
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
  final ValueChanged<String?> onPointSelected;
  final void Function(String pointId, Vector3 position) onPointEdited;
  final bool enablePointEditing;
  final List<String>? allowedPresetIds;
  final bool compactLayout;
  final bool showLegend;

  @override
  State<GeometryCanvasCard> createState() => _GeometryCanvasCardState();
}

class _GeometryCanvasCardState extends State<GeometryCanvasCard>
    with SingleTickerProviderStateMixin {
  GeometryViewport _viewport = const GeometryViewport();
  double _scaleStartZoom = 34;
  GeometryInteractionMode _interactionMode = GeometryInteractionMode.orbit;
  late final AnimationController _cameraController;
  GeometryViewport? _cameraAnimationStart;
  GeometryViewport? _cameraAnimationEnd;
  String _selectedCameraPresetId = geometryCameraPresets.first.id;
  String? _activeDraggedPointId;
  double? _activeDraggedPointDepth;

  List<GeometryCameraPreset> get _cameraPresets {
    final allowedPresetIds = widget.allowedPresetIds;
    if (allowedPresetIds == null || allowedPresetIds.isEmpty) {
      return geometryCameraPresets;
    }

    return geometryCameraPresets
        .where((preset) => allowedPresetIds.contains(preset.id))
        .toList(growable: false);
  }

  @override
  void initState() {
    super.initState();
    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    )
      ..addListener(() {
        final start = _cameraAnimationStart;
        final end = _cameraAnimationEnd;
        if (start == null || end == null) {
          return;
        }
        setState(() {
          _viewport = lerpGeometryViewport(
            start,
            end,
            Curves.easeInOutCubic.transform(_cameraController.value),
          );
        });
      });
  }

  @override
  void dispose() {
    _cameraController.dispose();
    super.dispose();
  }

  void _animateToViewport(
    GeometryViewport target, {
    String? presetId,
  }) {
    _cameraController.stop();
    _cameraAnimationStart = _viewport;
    _cameraAnimationEnd = target;
    if (presetId != null) {
      _selectedCameraPresetId = presetId;
    }
    _cameraController.forward(from: 0);
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _cameraController.stop();
    _scaleStartZoom = _viewport.zoom;
    _activeDraggedPointId = null;
    _activeDraggedPointDepth = null;

    if (!widget.enablePointEditing ||
        _interactionMode != GeometryInteractionMode.editPoint) {
      return;
    }

    final hit = GeometryProjector(_viewport).hitTest(
      offset: details.localFocalPoint,
      size: size,
      scenePoints: widget.scenePoints.where((point) => point.isEditable).toList(),
    );
    if (hit != null) {
      _activeDraggedPointId = hit.id;
      _activeDraggedPointDepth = GeometryProjector(_viewport).depthOf(hit.position);
      widget.onPointSelected(hit.id);
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_interactionMode == GeometryInteractionMode.editPoint &&
        widget.enablePointEditing &&
        details.pointerCount == 1 &&
        _activeDraggedPointId != null &&
        _activeDraggedPointDepth != null) {
      final scenePoint = findScenePointById(widget.scenePoints, _activeDraggedPointId);
      if (scenePoint != null) {
        final projector = GeometryProjector(_viewport);
        final nextPoint = projector.pointFromScreen(
          offset: details.localFocalPoint,
          size: size,
          depth: _activeDraggedPointDepth!,
        );
        widget.onPointEdited(scenePoint.id, nextPoint);
      }
      return;
    }

    setState(() {
      final orbitFactor = details.pointerCount > 1 ? 0.0075 : 0.011;
      var nextViewport = _viewport.orbit(
        deltaYaw: details.focalPointDelta.dx * orbitFactor,
        deltaPitch: details.focalPointDelta.dy * orbitFactor,
      );

      if (details.scale != 1.0) {
        final scaleFactor = (_scaleStartZoom * details.scale) / _viewport.zoom;
        nextViewport = nextViewport.zoomByFactor(scaleFactor);
      }

      _viewport = nextViewport;
      _selectedCameraPresetId = 'custom';
    });
  }

  void _handleScaleEnd(ScaleEndDetails details) {
    _activeDraggedPointId = null;
    _activeDraggedPointDepth = null;
  }

  void _handlePointerSignal(PointerSignalEvent signal) {
    if (signal is! PointerScrollEvent) {
      return;
    }

    setState(() {
      final zoomFactor = math.exp(-signal.scrollDelta.dy * 0.0012);
      _viewport = _viewport.zoomByFactor(zoomFactor);
      _selectedCameraPresetId = 'custom';
    });
  }

  void _handleTap(Offset localPosition, Size size) {
    final projector = GeometryProjector(_viewport);
    final hit = projector.hitTest(
      offset: localPosition,
      size: size,
      scenePoints: widget.scenePoints,
    );
    widget.onPointSelected(hit?.id);
  }

  void _resetView() {
    _animateToViewport(
      geometryCameraPresets.first.viewport,
      presetId: geometryCameraPresets.first.id,
    );
  }

  String _modeLabel(GeometryInteractionMode mode) {
    switch (mode) {
      case GeometryInteractionMode.orbit:
        return 'Orbit';
      case GeometryInteractionMode.editPoint:
        return 'Edit Point';
    }
  }

  IconData _modeIcon(GeometryInteractionMode mode) {
    switch (mode) {
      case GeometryInteractionMode.orbit:
        return Icons.threed_rotation;
      case GeometryInteractionMode.editPoint:
        return Icons.edit_location_alt_rounded;
    }
  }

  String _interactionHelpText() {
    if (!widget.enablePointEditing) {
      return '드래그로 회전, 마우스 휠 또는 핀치로 확대/축소, 점 탭으로 선택할 수 있습니다.';
    }

    switch (_interactionMode) {
      case GeometryInteractionMode.orbit:
        return '드래그로 회전, 마우스 휠 또는 핀치로 확대/축소, 점 탭으로 선택할 수 있습니다.';
      case GeometryInteractionMode.editPoint:
        return '점 선택 후 드래그하면 A, B, C, P1, P2 를 화면 기준으로 직접 이동할 수 있습니다.';
    }
  }

  @override
  Widget build(BuildContext context) {
    final isEditingPoint = _activeDraggedPointId != null;

    return GlassCard(
      padding: const EdgeInsets.all(16),
      child: LayoutBuilder(
        builder: (context, constraints) {
          final isHeightBounded = constraints.maxHeight.isFinite;
          final compactLayout =
              widget.compactLayout || (isHeightBounded && constraints.maxHeight < 760);

          final children = <Widget>[
            Text(
              '3D Visualization',
              style: TextStyle(
                fontSize: compactLayout ? 20 : 22,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              _interactionHelpText(),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.72),
                height: 1.45,
                fontSize: compactLayout ? 13 : 14,
              ),
            ),
            SizedBox(height: compactLayout ? 12 : 16),
            Wrap(
              spacing: 12,
              runSpacing: 12,
              children: [
                if (widget.enablePointEditing)
                  SegmentedButton<GeometryInteractionMode>(
                    segments: GeometryInteractionMode.values
                        .map(
                          (mode) => ButtonSegment<GeometryInteractionMode>(
                            value: mode,
                            icon: Icon(_modeIcon(mode)),
                            label: Text(_modeLabel(mode)),
                          ),
                        )
                        .toList(growable: false),
                    selected: {_interactionMode},
                    onSelectionChanged: (selection) {
                      setState(() {
                        _interactionMode = selection.first;
                        _activeDraggedPointId = null;
                      });
                    },
                  ),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    ..._cameraPresets.map(
                      (preset) => ChoiceChip(
                        label: Text(preset.label),
                        selected: _selectedCameraPresetId == preset.id,
                        onSelected: (_) {
                          _animateToViewport(
                            preset.viewport,
                            presetId: preset.id,
                          );
                        },
                      ),
                    ),
                    ChoiceChip(
                      label: const Text('Custom'),
                      selected: _selectedCameraPresetId == 'custom',
                      onSelected: (_) {},
                    ),
                  ],
                ),
              ],
            ),
            SizedBox(height: compactLayout ? 12 : 16),
          ];

          if (isHeightBounded) {
            children.add(
              Expanded(
                child: _CanvasViewport(
                  viewport: _viewport,
                  interactionMode: _interactionMode,
                  isEditingPoint: isEditingPoint,
                  a: widget.a,
                  b: widget.b,
                  c: widget.c,
                  p1: widget.p1,
                  p2: widget.p2,
                  result: widget.result,
                  hasError: widget.hasError,
                  scenePoints: widget.scenePoints,
                  selectedPointId: widget.selectedPointId,
                  selectedCameraPresetId: _selectedCameraPresetId,
                  onPointerSignal: _handlePointerSignal,
                  onTap: _handleTap,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  onResetView: _resetView,
                ),
              ),
            );
          } else {
            children.add(
              AspectRatio(
                aspectRatio: 1.35,
                child: _CanvasViewport(
                  viewport: _viewport,
                  interactionMode: _interactionMode,
                  isEditingPoint: isEditingPoint,
                  a: widget.a,
                  b: widget.b,
                  c: widget.c,
                  p1: widget.p1,
                  p2: widget.p2,
                  result: widget.result,
                  hasError: widget.hasError,
                  scenePoints: widget.scenePoints,
                  selectedPointId: widget.selectedPointId,
                  selectedCameraPresetId: _selectedCameraPresetId,
                  onPointerSignal: _handlePointerSignal,
                  onTap: _handleTap,
                  onScaleStart: _handleScaleStart,
                  onScaleUpdate: _handleScaleUpdate,
                  onScaleEnd: _handleScaleEnd,
                  onResetView: _resetView,
                ),
              ),
            );
          }

          if (widget.showLegend) {
            children.add(SizedBox(height: compactLayout ? 8 : 12));
            children.add(
              Wrap(
                spacing: 16,
                runSpacing: 10,
                children: const [
                  _LegendChip(id: GeometryPointIds.triangleA, label: 'Triangle A'),
                  _LegendChip(id: GeometryPointIds.triangleB, label: 'Triangle B'),
                  _LegendChip(id: GeometryPointIds.triangleC, label: 'Triangle C'),
                  _LegendChip(id: GeometryPointIds.lineP1, label: 'Line P1'),
                  _LegendChip(id: GeometryPointIds.lineP2, label: 'Line P2'),
                  _LegendChip(id: GeometryPointIds.intersectionQ, label: 'Intersection Q'),
                ],
              ),
            );
          }

          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: children,
          );
        },
      ),
    );
  }
}

class _CanvasViewport extends StatelessWidget {
  const _CanvasViewport({
    required this.viewport,
    required this.interactionMode,
    required this.isEditingPoint,
    required this.a,
    required this.b,
    required this.c,
    required this.p1,
    required this.p2,
    required this.result,
    required this.hasError,
    required this.scenePoints,
    required this.selectedPointId,
    required this.selectedCameraPresetId,
    required this.onPointerSignal,
    required this.onTap,
    required this.onScaleStart,
    required this.onScaleUpdate,
    required this.onScaleEnd,
    required this.onResetView,
  });

  final GeometryViewport viewport;
  final GeometryInteractionMode interactionMode;
  final bool isEditingPoint;
  final Vector3 a;
  final Vector3 b;
  final Vector3 c;
  final Vector3 p1;
  final Vector3 p2;
  final GeometryResult? result;
  final bool hasError;
  final List<GeometryScenePoint> scenePoints;
  final String? selectedPointId;
  final String selectedCameraPresetId;
  final ValueChanged<PointerSignalEvent> onPointerSignal;
  final void Function(Offset localPosition, Size size) onTap;
  final void Function(ScaleStartDetails details, Size size) onScaleStart;
  final void Function(ScaleUpdateDetails details, Size size) onScaleUpdate;
  final GestureScaleEndCallback onScaleEnd;
  final VoidCallback onResetView;

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final size = Size(constraints.maxWidth, constraints.maxHeight);

        return ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Listener(
            onPointerSignal: onPointerSignal,
            child: GestureDetector(
              onTapUp: (details) => onTap(details.localPosition, size),
              onDoubleTap: onResetView,
              onScaleStart: (details) => onScaleStart(details, size),
              onScaleUpdate: (details) => onScaleUpdate(details, size),
              onScaleEnd: onScaleEnd,
              child: Stack(
                fit: StackFit.expand,
                children: [
                  DecoratedBox(
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
                        viewport: viewport,
                        scenePoints: scenePoints,
                        selectedPointId: selectedPointId,
                        interactionMode: interactionMode,
                        isEditingPoint: isEditingPoint,
                      ),
                    ),
                  ),
                  Positioned(
                    top: 12,
                    right: 12,
                    child: FilledButton.tonalIcon(
                      onPressed: onResetView,
                      icon: const Icon(Icons.threed_rotation),
                      label: const Text('Reset View'),
                    ),
                  ),
                  Positioned(
                    left: 12,
                    bottom: 12,
                    child: _OverlayInfo(
                      viewport: viewport,
                      interactionMode: interactionMode,
                      selectedPoint: findScenePointById(scenePoints, selectedPointId),
                      selectedCameraPresetId: selectedCameraPresetId,
                      isDraggingPoint: isEditingPoint,
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class _OverlayInfo extends StatelessWidget {
  const _OverlayInfo({
    required this.viewport,
    required this.interactionMode,
    required this.selectedPoint,
    required this.selectedCameraPresetId,
    required this.isDraggingPoint,
  });

  final GeometryViewport viewport;
  final GeometryInteractionMode interactionMode;
  final GeometryScenePoint? selectedPoint;
  final String selectedCameraPresetId;
  final bool isDraggingPoint;

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(maxWidth: 360),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: const Color(0xFF08111F).withValues(alpha: 0.82),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 240),
        switchInCurve: Curves.easeOutCubic,
        switchOutCurve: Curves.easeInCubic,
        child: DefaultTextStyle(
          key: ValueKey('${selectedPoint?.id ?? 'none'}-$selectedCameraPresetId-${interactionMode.name}-$isDraggingPoint'),
          style: TextStyle(
            color: Colors.white.withValues(alpha: 0.9),
            fontSize: 13,
            height: 1.45,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                'Preset $selectedCameraPresetId  |  Yaw ${viewport.yaw.toStringAsFixed(2)}  Pitch ${viewport.pitch.toStringAsFixed(2)}  Zoom ${viewport.zoom.toStringAsFixed(1)}',
                style: const TextStyle(fontWeight: FontWeight.w700),
              ),
              const SizedBox(height: 6),
              Text(
                interactionMode == GeometryInteractionMode.orbit ? 'Mode: Orbit' : 'Mode: Edit Point',
                style: TextStyle(
                  color: Colors.white.withValues(alpha: 0.72),
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                isDraggingPoint
                    ? '선택된 점을 이동 중입니다.'
                    : selectedPoint?.description ?? '선택된 점이 없습니다. 점을 탭하거나 Edit Point 모드에서 드래그할 수 있습니다.',
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _LegendChip extends StatelessWidget {
  const _LegendChip({
    required this.id,
    required this.label,
  });

  final String id;
  final String label;

  @override
  Widget build(BuildContext context) {
    final color = GeometryPainter.colorForPointId(id);

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.04),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(color: color, shape: BoxShape.circle),
          ),
          const SizedBox(width: 10),
          Text(label),
        ],
      ),
    );
  }
}
