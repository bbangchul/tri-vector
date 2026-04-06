import 'package:flutter/material.dart';
import 'package:todoey/features/shared/formatters.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_engine.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_exception.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_result.dart';
import 'package:todoey/features/triangle_intersection/models/geometry_scene.dart';
import 'package:todoey/features/triangle_intersection/models/vector3.dart';
import 'package:todoey/features/triangle_intersection/geometry_control_panel.dart';
import 'package:todoey/features/triangle_intersection/geometry_header.dart';
import 'package:todoey/features/triangle_intersection/geometry_preview_card.dart';
import 'package:todoey/features/triangle_intersection/geometry_results_card.dart';
import 'package:todoey/features/triangle_intersection/geometry_viewer_page.dart';

class GeometryHomePage extends StatefulWidget {
  const GeometryHomePage({super.key});

  @override
  State<GeometryHomePage> createState() => _GeometryHomePageState();
}

class _GeometryHomePageState extends State<GeometryHomePage> {
  static const Vector3 _defaultA = Vector3(0, 0, 0);
  static const Vector3 _defaultB = Vector3(1, 0, 0);
  static const Vector3 _defaultC = Vector3(0, 1, 0);
  static const Vector3 _defaultP1 = Vector3(0.3, 0.3, 2);
  static const Vector3 _defaultP2 = Vector3(0.3, 0.3, -2);

  late final Map<String, TextEditingController> _controllers;

  Vector3 _a = _defaultA;
  Vector3 _b = _defaultB;
  Vector3 _c = _defaultC;
  Vector3 _p1 = _defaultP1;
  Vector3 _p2 = _defaultP2;
  GeometryResult? _result;
  String? _errorMessage;
  String? _selectedPointId = GeometryPointIds.intersectionQ;

  @override
  void initState() {
    super.initState();
    _controllers = {
      'ax': TextEditingController(text: _defaultA.x.toString()),
      'ay': TextEditingController(text: _defaultA.y.toString()),
      'az': TextEditingController(text: _defaultA.z.toString()),
      'bx': TextEditingController(text: _defaultB.x.toString()),
      'by': TextEditingController(text: _defaultB.y.toString()),
      'bz': TextEditingController(text: _defaultB.z.toString()),
      'cx': TextEditingController(text: _defaultC.x.toString()),
      'cy': TextEditingController(text: _defaultC.y.toString()),
      'cz': TextEditingController(text: _defaultC.z.toString()),
      'p1x': TextEditingController(text: _defaultP1.x.toString()),
      'p1y': TextEditingController(text: _defaultP1.y.toString()),
      'p1z': TextEditingController(text: _defaultP1.z.toString()),
      'p2x': TextEditingController(text: _defaultP2.x.toString()),
      'p2y': TextEditingController(text: _defaultP2.y.toString()),
      'p2z': TextEditingController(text: _defaultP2.z.toString()),
    };
    _recalculate();
  }

  @override
  void dispose() {
    for (final controller in _controllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  List<GeometryScenePoint> get _scenePoints => buildGeometryScenePoints(
        a: _a,
        b: _b,
        c: _c,
        p1: _p1,
        p2: _p2,
        result: _result,
      );

  void _recalculate() {
    final a = _readVector('a');
    final b = _readVector('b');
    final c = _readVector('c');
    final p1 = _readVector('p1');
    final p2 = _readVector('p2');

    if (a == null || b == null || c == null || p1 == null || p2 == null) {
      setState(() {
        _result = null;
        _errorMessage = '모든 입력값은 유효한 숫자여야 합니다.';
      });
      return;
    }

    _applyGeometryValues(
      a: a,
      b: b,
      c: c,
      p1: p1,
      p2: p2,
      syncControllers: false,
    );
  }

  void _applyGeometryValues({
    required Vector3 a,
    required Vector3 b,
    required Vector3 c,
    required Vector3 p1,
    required Vector3 p2,
    bool syncControllers = true,
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
        _selectedPointId = result.intersectionPoint == null
            ? (_selectedPointId ?? GeometryPointIds.triangleA)
            : (_selectedPointId ?? GeometryPointIds.intersectionQ);
        if (syncControllers) {
          _syncControllers();
        }
      });
    } on GeometryException catch (error) {
      setState(() {
        _result = null;
        _errorMessage = error.message;
        if (syncControllers) {
          _syncControllers();
        }
      });
    }
  }

  void _syncControllers() {
    _controllers['ax']!.text = formatDouble(_a.x);
    _controllers['ay']!.text = formatDouble(_a.y);
    _controllers['az']!.text = formatDouble(_a.z);
    _controllers['bx']!.text = formatDouble(_b.x);
    _controllers['by']!.text = formatDouble(_b.y);
    _controllers['bz']!.text = formatDouble(_b.z);
    _controllers['cx']!.text = formatDouble(_c.x);
    _controllers['cy']!.text = formatDouble(_c.y);
    _controllers['cz']!.text = formatDouble(_c.z);
    _controllers['p1x']!.text = formatDouble(_p1.x);
    _controllers['p1y']!.text = formatDouble(_p1.y);
    _controllers['p1z']!.text = formatDouble(_p1.z);
    _controllers['p2x']!.text = formatDouble(_p2.x);
    _controllers['p2y']!.text = formatDouble(_p2.y);
    _controllers['p2z']!.text = formatDouble(_p2.z);
  }

  Vector3? _readVector(String prefix) {
    final x = double.tryParse(_controllers['${prefix}x']!.text.trim());
    final y = double.tryParse(_controllers['${prefix}y']!.text.trim());
    final z = double.tryParse(_controllers['${prefix}z']!.text.trim());
    if (x == null || y == null || z == null) {
      return null;
    }
    return Vector3(x, y, z);
  }

  void _resetInputs() {
    _applyGeometryValues(
      a: _defaultA,
      b: _defaultB,
      c: _defaultC,
      p1: _defaultP1,
      p2: _defaultP2,
    );
    setState(() {
      _selectedPointId = GeometryPointIds.intersectionQ;
    });
  }

  Future<void> _openViewer() async {
    final viewerResult = await Navigator.of(context).push<GeometryViewerResult>(
      MaterialPageRoute<GeometryViewerResult>(
        builder: (_) => GeometryViewerPage(
          a: _a,
          b: _b,
          c: _c,
          p1: _p1,
          p2: _p2,
          result: _result,
          hasError: _errorMessage != null,
          scenePoints: _scenePoints,
          initialSelectedPointId: _selectedPointId,
        ),
      ),
    );

    if (!mounted || viewerResult == null) {
      return;
    }

    _applyGeometryValues(
      a: viewerResult.a,
      b: viewerResult.b,
      c: viewerResult.c,
      p1: viewerResult.p1,
      p2: viewerResult.p2,
    );
    setState(() {
      _selectedPointId = viewerResult.selectedPointId;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isWide = MediaQuery.of(context).size.width >= 1100;
    final scenePoints = _scenePoints;
    final selectedPointId = findScenePointById(scenePoints, _selectedPointId) == null
        ? (scenePoints.any((point) => point.id == GeometryPointIds.intersectionQ)
            ? GeometryPointIds.intersectionQ
            : GeometryPointIds.triangleA)
        : _selectedPointId;

    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              Color(0xFF0B1220),
              Color(0xFF070B14),
              Color(0xFF111827),
            ],
          ),
        ),
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 1440),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    GeometryHeader(
                      onApply: _recalculate,
                      onReset: _resetInputs,
                    ),
                    const SizedBox(height: 24),
                    if (_errorMessage != null) ...[
                      _ErrorBanner(message: _errorMessage!),
                      const SizedBox(height: 16),
                    ],
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            flex: 4,
                            child: GeometryControlPanel(
                              controllers: _controllers,
                              onApply: _recalculate,
                              onReset: _resetInputs,
                            ),
                          ),
                          const SizedBox(width: 20),
                          Expanded(
                            flex: 6,
                            child: GeometryPreviewCard(
                              a: _a,
                              b: _b,
                              c: _c,
                              p1: _p1,
                              p2: _p2,
                              result: _result,
                              hasError: _errorMessage != null,
                              scenePoints: scenePoints,
                              selectedPointId: selectedPointId,
                              onOpenViewer: _openViewer,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      GeometryControlPanel(
                        controllers: _controllers,
                        onApply: _recalculate,
                        onReset: _resetInputs,
                      ),
                      const SizedBox(height: 20),
                      GeometryPreviewCard(
                        a: _a,
                        b: _b,
                        c: _c,
                        p1: _p1,
                        p2: _p2,
                        result: _result,
                        hasError: _errorMessage != null,
                        scenePoints: scenePoints,
                        selectedPointId: selectedPointId,
                        onOpenViewer: _openViewer,
                      ),
                    ],
                    const SizedBox(height: 20),
                    GeometryResultsCard(
                      a: _a,
                      b: _b,
                      c: _c,
                      p1: _p1,
                      p2: _p2,
                      result: _result,
                      errorMessage: _errorMessage,
                      scenePoints: scenePoints,
                      selectedPointId: selectedPointId,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _ErrorBanner extends StatelessWidget {
  const _ErrorBanner({required this.message});

  final String message;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF7F1D1D).withValues(alpha: 0.48),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: const Color(0xFFFCA5A5).withValues(alpha: 0.4)),
      ),
      child: Row(
        children: [
          const Icon(Icons.warning_amber_rounded, color: Color(0xFFFCA5A5)),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: const TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }
}
