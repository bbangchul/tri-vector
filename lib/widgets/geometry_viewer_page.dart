import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:todoey/models/formatters.dart';
import 'package:todoey/models/geometry_engine.dart';
import 'package:todoey/models/geometry_exception.dart';
import 'package:todoey/models/geometry_result.dart';
import 'package:todoey/models/geometry_scene.dart';
import 'package:todoey/models/geometry_view.dart';
import 'package:todoey/models/vector3.dart';
import 'package:todoey/painters/geometry_painter.dart';

class GeometryViewerResult {
  const GeometryViewerResult({
    required this.a,
    required this.b,
    required this.c,
    required this.p1,
    required this.p2,
    required this.selectedPointId,
  });

  final Vector3 a;
  final Vector3 b;
  final Vector3 c;
  final Vector3 p1;
  final Vector3 p2;
  final String? selectedPointId;
}

class GeometryViewerPage extends StatefulWidget {
  const GeometryViewerPage({
    super.key,
    required this.a,
    required this.b,
    required this.c,
    required this.p1,
    required this.p2,
    required this.result,
    required this.hasError,
    required this.scenePoints,
    required this.initialSelectedPointId,
  });

  final Vector3 a;
  final Vector3 b;
  final Vector3 c;
  final Vector3 p1;
  final Vector3 p2;
  final GeometryResult? result;
  final bool hasError;
  final List<GeometryScenePoint> scenePoints;
  final String? initialSelectedPointId;

  @override
  State<GeometryViewerPage> createState() => _GeometryViewerPageState();
}

class _GeometryViewerPageState extends State<GeometryViewerPage>
    with SingleTickerProviderStateMixin {
  GeometryViewport _viewport = geometryCameraPresets.first.viewport;
  double _scaleStartZoom = geometryCameraPresets.first.viewport.zoom;
  GeometryInteractionMode _interactionMode = GeometryInteractionMode.orbit;
  late final AnimationController _cameraController;
  GeometryViewport? _cameraAnimationStart;
  GeometryViewport? _cameraAnimationEnd;
  String _selectedCameraPresetId = 'iso';
  bool _isTopUiCollapsed = false;
  String? _selectedPointId;
  String? _activeDraggedPointId;
  double? _activeDraggedPointDepth;

  late Vector3 _a;
  late Vector3 _b;
  late Vector3 _c;
  late Vector3 _p1;
  late Vector3 _p2;
  GeometryResult? _result;
  String? _errorMessage;

  List<GeometryCameraPreset> get _cameraPresets => geometryCameraPresets
      .where((preset) => preset.id == 'iso' || preset.id == 'front')
      .toList(growable: false);

  List<GeometryScenePoint> get _scenePoints => buildGeometryScenePoints(
        a: _a,
        b: _b,
        c: _c,
        p1: _p1,
        p2: _p2,
        result: _result,
      );

  @override
  void initState() {
    super.initState();
    _a = widget.a;
    _b = widget.b;
    _c = widget.c;
    _p1 = widget.p1;
    _p2 = widget.p2;
    _result = widget.result;
    _errorMessage = widget.hasError ? '시각화할 수 없는 입력 상태입니다.' : null;
    _selectedPointId = widget.initialSelectedPointId;
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.landscapeLeft,
      DeviceOrientation.landscapeRight,
    ]);
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
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }

  GeometryViewerResult _buildViewerResult() {
    return GeometryViewerResult(
      a: _a,
      b: _b,
      c: _c,
      p1: _p1,
      p2: _p2,
      selectedPointId: _selectedPointId,
    );
  }

  void _closeViewer() {
    Navigator.of(context).pop(_buildViewerResult());
  }

  void _animateToViewport(
    GeometryViewport target, {
    required String presetId,
  }) {
    _cameraController.stop();
    _cameraAnimationStart = _viewport;
    _cameraAnimationEnd = target;
    _selectedCameraPresetId = presetId;
    _cameraController.forward(from: 0);
  }

  void _applyGeometryValues({
    required Vector3 a,
    required Vector3 b,
    required Vector3 c,
    required Vector3 p1,
    required Vector3 p2,
  }) {
    try {
      final result = GeometryEngine.compute(
        a: a,
        b: b,
        c: c,
        p1: p1,
        p2: p2,
      );

      setState(() {
        _a = a;
        _b = b;
        _c = c;
        _p1 = p1;
        _p2 = p2;
        _result = result;
        _errorMessage = null;
        if (_selectedPointId == GeometryPointIds.intersectionQ &&
            result.intersectionPoint == null) {
          _selectedPointId = GeometryPointIds.triangleA;
        }
      });
    } on GeometryException catch (error) {
      setState(() {
        _errorMessage = error.message;
      });
    }
  }

  void _updatePoint(String pointId, Vector3 position) {
    switch (pointId) {
      case GeometryPointIds.triangleA:
        _applyGeometryValues(a: position, b: _b, c: _c, p1: _p1, p2: _p2);
      case GeometryPointIds.triangleB:
        _applyGeometryValues(a: _a, b: position, c: _c, p1: _p1, p2: _p2);
      case GeometryPointIds.triangleC:
        _applyGeometryValues(a: _a, b: _b, c: position, p1: _p1, p2: _p2);
      case GeometryPointIds.lineP1:
        _applyGeometryValues(a: _a, b: _b, c: _c, p1: position, p2: _p2);
      case GeometryPointIds.lineP2:
        _applyGeometryValues(a: _a, b: _b, c: _c, p1: _p1, p2: position);
      case GeometryPointIds.intersectionQ:
        return;
    }
  }

  void _handleScaleStart(ScaleStartDetails details, Size size) {
    _cameraController.stop();
    _scaleStartZoom = _viewport.zoom;
    _activeDraggedPointId = null;
    _activeDraggedPointDepth = null;

    if (_interactionMode != GeometryInteractionMode.editPoint) {
      return;
    }

    final hit = GeometryProjector(_viewport).hitTest(
      offset: details.localFocalPoint,
      size: size,
      scenePoints: _scenePoints.where((point) => point.isEditable).toList(),
    );
    if (hit != null) {
      setState(() {
        _activeDraggedPointId = hit.id;
        _activeDraggedPointDepth = GeometryProjector(_viewport).depthOf(hit.position);
        _selectedPointId = hit.id;
      });
    }
  }

  void _handleScaleUpdate(ScaleUpdateDetails details, Size size) {
    if (_interactionMode == GeometryInteractionMode.editPoint &&
        details.pointerCount == 1 &&
        _activeDraggedPointId != null &&
        _activeDraggedPointDepth != null) {
      final scenePoint = findScenePointById(_scenePoints, _activeDraggedPointId);
      if (scenePoint != null) {
        final projector = GeometryProjector(_viewport);
        final nextPoint = projector.pointFromScreen(
          offset: details.localFocalPoint,
          size: size,
          depth: _activeDraggedPointDepth!,
        );
        _updatePoint(scenePoint.id, nextPoint);
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
      scenePoints: _scenePoints,
    );

    setState(() {
      _selectedPointId = hit?.id;
    });
  }

  void _resetView() {
    _animateToViewport(
      geometryCameraPresets.first.viewport,
      presetId: geometryCameraPresets.first.id,
    );
  }

  void _applyPointFromInputs(String pointId, Vector3 position) {
    _updatePoint(pointId, position);
    setState(() {
      _selectedPointId = pointId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final selectedPoint = findScenePointById(_scenePoints, _selectedPointId);

    return PopScope<GeometryViewerResult>(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) {
          return;
        }
        _closeViewer();
      },
      child: Scaffold(
        body: Stack(
          fit: StackFit.expand,
          children: [
            LayoutBuilder(
              builder: (context, constraints) {
                final size = Size(constraints.maxWidth, constraints.maxHeight);

                return Listener(
                  onPointerSignal: _handlePointerSignal,
                  child: GestureDetector(
                    onTapUp: (details) => _handleTap(details.localPosition, size),
                    onDoubleTap: _resetView,
                    onScaleStart: (details) => _handleScaleStart(details, size),
                    onScaleUpdate: (details) => _handleScaleUpdate(details, size),
                    onScaleEnd: _handleScaleEnd,
                    child: DecoratedBox(
                      decoration: const BoxDecoration(
                        gradient: LinearGradient(
                          begin: Alignment.topLeft,
                          end: Alignment.bottomRight,
                          colors: [
                            Color(0xFF08111F),
                            Color(0xFF0B1324),
                            Color(0xFF060A12),
                          ],
                        ),
                      ),
                      child: CustomPaint(
                        painter: GeometryPainter(
                          a: _a,
                          b: _b,
                          c: _c,
                          p1: _p1,
                          p2: _p2,
                          result: _result,
                          hasError: _errorMessage != null,
                          viewport: _viewport,
                          scenePoints: _scenePoints,
                          selectedPointId: _selectedPointId,
                          interactionMode: _interactionMode,
                          isEditingPoint: _activeDraggedPointId != null,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
            SafeArea(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 16, 88, 0),
                child: Align(
                  alignment: Alignment.topCenter,
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 220),
                    switchInCurve: Curves.easeOutCubic,
                    switchOutCurve: Curves.easeInCubic,
                    child: _isTopUiCollapsed
                        ? _CollapsedTopBar(
                            key: const ValueKey('collapsed-top-bar'),
                            onExpand: () {
                              setState(() {
                                _isTopUiCollapsed = false;
                              });
                            },
                          )
                        : _ExpandedTopBar(
                            key: const ValueKey('expanded-top-bar'),
                            cameraPresets: _cameraPresets,
                            selectedCameraPresetId: _selectedCameraPresetId,
                            interactionMode: _interactionMode,
                            onPresetSelected: (preset) {
                              _animateToViewport(
                                preset.viewport,
                                presetId: preset.id,
                              );
                            },
                            onEditToggled: (selected) {
                              setState(() {
                                _interactionMode = selected
                                    ? GeometryInteractionMode.editPoint
                                    : GeometryInteractionMode.orbit;
                                _activeDraggedPointId = null;
                                _activeDraggedPointDepth = null;
                              });
                            },
                            onCollapse: () {
                              setState(() {
                                _isTopUiCollapsed = true;
                              });
                            },
                          ),
                  ),
                ),
              ),
            ),
            SafeArea(
              child: Align(
                alignment: Alignment.topRight,
                child: Padding(
                  padding: const EdgeInsets.only(top: 16, right: 20),
                  child: IconButton.filledTonal(
                    onPressed: _closeViewer,
                    icon: const Icon(Icons.close_rounded),
                  ),
                ),
              ),
            ),
            if (_errorMessage != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 92),
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: const Color(0xFF7F1D1D).withValues(alpha: 0.88),
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(
                          color: const Color(0xFFFCA5A5).withValues(alpha: 0.4),
                        ),
                      ),
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 16,
                          vertical: 12,
                        ),
                        child: Text(
                          _errorMessage!,
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            if (selectedPoint != null)
              SafeArea(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(bottom: 20),
                    child: _PointCoordinateOverlay(
                      key: ValueKey(
                        '${selectedPoint.id}-${selectedPoint.position.x}-${selectedPoint.position.y}-${selectedPoint.position.z}',
                      ),
                      point: selectedPoint,
                      canEdit: _interactionMode == GeometryInteractionMode.editPoint,
                      onApply: _applyPointFromInputs,
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class _ExpandedTopBar extends StatelessWidget {
  const _ExpandedTopBar({
    super.key,
    required this.cameraPresets,
    required this.selectedCameraPresetId,
    required this.interactionMode,
    required this.onPresetSelected,
    required this.onEditToggled,
    required this.onCollapse,
  });

  final List<GeometryCameraPreset> cameraPresets;
  final String selectedCameraPresetId;
  final GeometryInteractionMode interactionMode;
  final ValueChanged<GeometryCameraPreset> onPresetSelected;
  final ValueChanged<bool> onEditToggled;
  final VoidCallback onCollapse;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(20),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 12,
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text(
              '3D Visualization',
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 16),
            Wrap(
              spacing: 8,
              children: cameraPresets
                  .map(
                    (preset) => ChoiceChip(
                      label: Text(preset.label),
                      selected: selectedCameraPresetId == preset.id,
                      onSelected: (_) => onPresetSelected(preset),
                      backgroundColor: Colors.white.withValues(alpha: 0.08),
                      selectedColor: Colors.white.withValues(alpha: 0.18),
                      side: BorderSide(
                        color: Colors.white.withValues(alpha: 0.14),
                      ),
                      labelStyle: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  )
                  .toList(growable: false),
            ),
            const SizedBox(width: 8),
            FilterChip(
              label: const Text('Edit'),
              selected: interactionMode == GeometryInteractionMode.editPoint,
              onSelected: onEditToggled,
              backgroundColor: Colors.white.withValues(alpha: 0.08),
              selectedColor: Colors.white.withValues(alpha: 0.18),
              side: BorderSide(
                color: Colors.white.withValues(alpha: 0.14),
              ),
              labelStyle: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.w700,
              ),
              avatar: const Icon(
                Icons.edit_location_alt_rounded,
                color: Colors.white,
                size: 18,
              ),
            ),
            const SizedBox(width: 8),
            IconButton(
              onPressed: onCollapse,
              icon: const Icon(Icons.keyboard_arrow_up_rounded),
              color: Colors.white,
              tooltip: 'Collapse',
            ),
          ],
        ),
      ),
    );
  }
}

class _CollapsedTopBar extends StatelessWidget {
  const _CollapsedTopBar({
    super.key,
    required this.onExpand,
  });

  final VoidCallback onExpand;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.18),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: InkWell(
        onTap: onExpand,
        borderRadius: BorderRadius.circular(999),
        child: const Padding(
          padding: EdgeInsets.symmetric(horizontal: 14, vertical: 10),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                Icons.keyboard_arrow_down_rounded,
                color: Colors.white,
              ),
              SizedBox(width: 6),
              Text(
                'Show Controls',
                style: TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PointCoordinateOverlay extends StatelessWidget {
  const _PointCoordinateOverlay({
    super.key,
    required this.point,
    required this.canEdit,
    required this.onApply,
  });

  final GeometryScenePoint point;
  final bool canEdit;
  final void Function(String pointId, Vector3 position) onApply;

  @override
  Widget build(BuildContext context) {
    final isEditable = point.isEditable && canEdit;

    if (!canEdit) {
      return _CompactPointCoordinateOverlay(point: point);
    }

    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.26),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.14),
        ),
      ),
      child: DefaultTextStyle(
        style: const TextStyle(color: Colors.white),
        child: _PointCoordinateEditor(
          point: point,
          isEditable: isEditable,
          canEdit: canEdit,
          onApply: onApply,
        ),
      ),
    );
  }
}

class _CompactPointCoordinateOverlay extends StatelessWidget {
  const _CompactPointCoordinateOverlay({
    required this.point,
  });

  final GeometryScenePoint point;

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 180),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: Colors.black.withValues(alpha: 0.22),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.12),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            width: 8,
            height: 8,
            decoration: const BoxDecoration(
              color: Color(0xFFF4C95D),
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 8),
          Text(
            point.label,
            style: const TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            '(${formatDouble(point.position.x)}, ${formatDouble(point.position.y)}, ${formatDouble(point.position.z)})',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.9),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

class _PointCoordinateEditor extends StatefulWidget {
  const _PointCoordinateEditor({
    required this.point,
    required this.isEditable,
    required this.canEdit,
    required this.onApply,
  });

  final GeometryScenePoint point;
  final bool isEditable;
  final bool canEdit;
  final void Function(String pointId, Vector3 position) onApply;

  @override
  State<_PointCoordinateEditor> createState() => _PointCoordinateEditorState();
}

class _PointCoordinateEditorState extends State<_PointCoordinateEditor> {
  late final TextEditingController _xController;
  late final TextEditingController _yController;
  late final TextEditingController _zController;
  String? _errorText;

  @override
  void initState() {
    super.initState();
    _xController = TextEditingController();
    _yController = TextEditingController();
    _zController = TextEditingController();
    _syncControllers();
  }

  @override
  void didUpdateWidget(covariant _PointCoordinateEditor oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.point != widget.point) {
      _syncControllers();
      _errorText = null;
    }
  }

  @override
  void dispose() {
    _xController.dispose();
    _yController.dispose();
    _zController.dispose();
    super.dispose();
  }

  void _syncControllers() {
    _xController.text = formatDouble(widget.point.position.x, 4);
    _yController.text = formatDouble(widget.point.position.y, 4);
    _zController.text = formatDouble(widget.point.position.z, 4);
  }

  void _submit() {
    final x = double.tryParse(_xController.text.trim());
    final y = double.tryParse(_yController.text.trim());
    final z = double.tryParse(_zController.text.trim());

    if (x == null || y == null || z == null) {
      setState(() {
        _errorText = '좌표는 숫자로 입력해야 합니다.';
      });
      return;
    }

    setState(() {
      _errorText = null;
    });
    widget.onApply(widget.point.id, Vector3(x, y, z));
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                color: Color(0xFFF4C95D),
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 10),
            Text(
              widget.point.label,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w800,
              ),
            ),
            const SizedBox(width: 12),
            Text(
              widget.isEditable
                  ? 'Edit Coordinates'
                  : (widget.point.isEditable ? 'View Coordinates' : 'Computed Point'),
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.76),
                fontWeight: FontWeight.w600,
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 10,
          runSpacing: 10,
          crossAxisAlignment: WrapCrossAlignment.center,
          children: [
            _CoordinateField(
              label: 'x',
              controller: _xController,
              enabled: widget.isEditable,
              onSubmitted: (_) => widget.isEditable ? _submit() : null,
            ),
            _CoordinateField(
              label: 'y',
              controller: _yController,
              enabled: widget.isEditable,
              onSubmitted: (_) => widget.isEditable ? _submit() : null,
            ),
            _CoordinateField(
              label: 'z',
              controller: _zController,
              enabled: widget.isEditable,
              onSubmitted: (_) => widget.isEditable ? _submit() : null,
            ),
            if (widget.isEditable)
              FilledButton(
                onPressed: _submit,
                child: const Text('Apply'),
              ),
          ],
        ),
        if (!widget.isEditable) ...[
          const SizedBox(height: 10),
          Text(
            widget.point.isEditable && !widget.canEdit
                ? '좌표 수정은 Edit 모드에서만 가능합니다.'
                : 'Q는 계산된 점이라 직접 수정할 수 없습니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
            ),
          ),
        ],
        if (_errorText != null) ...[
          const SizedBox(height: 8),
          Text(
            _errorText!,
            style: const TextStyle(
              color: Color(0xFFFCA5A5),
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ],
    );
  }
}

class _CoordinateField extends StatelessWidget {
  const _CoordinateField({
    required this.label,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final String label;
  final TextEditingController controller;
  final bool enabled;
  final ValueChanged<String> onSubmitted;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 108,
      child: TextField(
        controller: controller,
        enabled: enabled,
        onSubmitted: onSubmitted,
        keyboardType: const TextInputType.numberWithOptions(
          signed: true,
          decimal: true,
        ),
        style: const TextStyle(
          color: Colors.white,
          fontWeight: FontWeight.w600,
        ),
        decoration: InputDecoration(
          labelText: label,
          isDense: true,
          filled: true,
          fillColor: Colors.white.withValues(alpha: enabled ? 0.08 : 0.04),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.12),
            ),
          ),
          disabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(14),
            borderSide: BorderSide(
              color: Colors.white.withValues(alpha: 0.08),
            ),
          ),
        ),
      ),
    );
  }
}
