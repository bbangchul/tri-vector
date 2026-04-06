import 'package:flutter/material.dart';
import 'package:todoey/features/linear_transformation_visualization/engine/transform_scene_builder.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_palette.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_preset.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_scene.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transform_vector.dart';
import 'package:todoey/features/linear_transformation_visualization/models/transformation_matrix.dart';
import 'package:todoey/features/linear_transformation_visualization/transform_viewer_page.dart';
import 'package:todoey/features/linear_transformation_visualization/widgets/transform_canvas_card.dart';
import 'package:todoey/features/linear_transformation_visualization/widgets/transform_input_card.dart';
import 'package:todoey/features/shared/formatters.dart';

class LinearTransformationHomePage extends StatefulWidget {
  const LinearTransformationHomePage({super.key});

  @override
  State<LinearTransformationHomePage> createState() =>
      _LinearTransformationHomePageState();
}

class _LinearTransformationHomePageState extends State<LinearTransformationHomePage>
    with SingleTickerProviderStateMixin {
  late List<List<TextEditingController>> _matrixControllers;
  late List<TransformVectorInputBinding> _vectorBindings;
  late AnimationController _animationController;
  String _selectedPresetId = TransformPreset.shear.id;
  String _selectedVectorId = 'v1';
  double _animationProgress = 1;

  @override
  void initState() {
    super.initState();
    _matrixControllers = _createMatrixControllers(TransformPreset.shear.matrix);
    _vectorBindings = _createVectorBindings(
      const [
        TransformVector(id: 'v1', label: 'v1', x: 2, y: 1),
        TransformVector(id: 'v2', label: 'v2', x: -1, y: 2),
      ],
    );
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1600),
      value: 1,
    )..addListener(() {
        setState(() {
          _animationProgress = _animationController.value;
        });
      });
  }

  @override
  void dispose() {
    for (final row in _matrixControllers) {
      for (final controller in row) {
        controller.dispose();
      }
    }
    for (final binding in _vectorBindings) {
      binding.xController.dispose();
      binding.yController.dispose();
    }
    _animationController.dispose();
    super.dispose();
  }

  List<List<TextEditingController>> _createMatrixControllers(
    TransformationMatrix matrix,
  ) {
    return [
      [
        TextEditingController(text: formatDouble(matrix.a11)),
        TextEditingController(text: formatDouble(matrix.a12)),
      ],
      [
        TextEditingController(text: formatDouble(matrix.a21)),
        TextEditingController(text: formatDouble(matrix.a22)),
      ],
    ];
  }

  List<TransformVectorInputBinding> _createVectorBindings(
    List<TransformVector> vectors,
  ) {
    return List.generate(vectors.length, (index) {
      final vector = vectors[index];
      return TransformVectorInputBinding(
        id: vector.id.isEmpty ? 'v${index + 1}' : vector.id,
        label: vector.label.isEmpty ? 'v${index + 1}' : vector.label,
        color: _vectorColorForIndex(index),
        xController: TextEditingController(text: formatDouble(vector.x)),
        yController: TextEditingController(text: formatDouble(vector.y)),
      );
    }, growable: false);
  }

  void _setMatrixControllers(TransformPreset preset) {
    final values = [
      [preset.matrix.a11, preset.matrix.a12],
      [preset.matrix.a21, preset.matrix.a22],
    ];

    for (int row = 0; row < 2; row++) {
      for (int column = 0; column < 2; column++) {
        _matrixControllers[row][column].text = formatDouble(values[row][column]);
      }
    }
  }

  Color _vectorColorForIndex(int index) {
    const colors = [
      TransformPalette.vectorA,
      TransformPalette.vectorB,
      TransformPalette.vectorC,
    ];
    return colors[index % colors.length];
  }

  void _disposeVectorBindings(List<TransformVectorInputBinding> bindings) {
    for (final binding in bindings) {
      binding.xController.dispose();
      binding.yController.dispose();
    }
  }

  void _replaceVectorBindings(List<TransformVector> vectors) {
    final previous = _vectorBindings;
    _vectorBindings = _createVectorBindings(vectors);
    _disposeVectorBindings(previous);
    _selectedVectorId = _vectorBindings.first.id;
  }

  void _reindexVectorBindings() {
    final rebound = <TransformVectorInputBinding>[];
    for (int index = 0; index < _vectorBindings.length; index++) {
      final old = _vectorBindings[index];
      rebound.add(
        TransformVectorInputBinding(
          id: 'v${index + 1}',
          label: 'v${index + 1}',
          color: _vectorColorForIndex(index),
          xController: old.xController,
          yController: old.yController,
        ),
      );
    }
    _vectorBindings = rebound;
    if (!_vectorBindings.any((binding) => binding.id == _selectedVectorId)) {
      _selectedVectorId = _vectorBindings.first.id;
    }
  }

  void _applyPreset(TransformPreset preset) {
    setState(() {
      _selectedPresetId = preset.id;
      _setMatrixControllers(preset);
    });
    _stopAnimation();
  }

  void _loadSample() {
    setState(() {
      const preset = TransformPreset.shear;
      _selectedPresetId = preset.id;
      _setMatrixControllers(preset);
      _replaceVectorBindings(
        const [
          TransformVector(id: 'v1', label: 'v1', x: 2, y: 1),
          TransformVector(id: 'v2', label: 'v2', x: -1, y: 2),
        ],
      );
    });
    _stopAnimation();
  }

  void _reset() {
    setState(() {
      const preset = TransformPreset.identity;
      _selectedPresetId = preset.id;
      _setMatrixControllers(preset);
      _replaceVectorBindings(
        const [
          TransformVector(id: 'v1', label: 'v1', x: 1, y: 1),
        ],
      );
    });
    _stopAnimation();
  }

  void _selectVector(String vectorId) {
    setState(() {
      _selectedVectorId = vectorId;
    });
  }

  void _addVector() {
    if (_vectorBindings.length >= 3) {
      return;
    }

    setState(() {
      final nextIndex = _vectorBindings.length;
      final newBinding = TransformVectorInputBinding(
        id: 'v${nextIndex + 1}',
        label: 'v${nextIndex + 1}',
        color: _vectorColorForIndex(nextIndex),
        xController: TextEditingController(text: '0'),
        yController: TextEditingController(text: '0'),
      );
      _vectorBindings = [..._vectorBindings, newBinding];
      _selectedVectorId = newBinding.id;
    });
    _stopAnimation();
  }

  void _deleteVector(String vectorId) {
    if (_vectorBindings.length <= 1) {
      return;
    }

    setState(() {
      final target = _vectorBindings.firstWhere((binding) => binding.id == vectorId);
      _vectorBindings = _vectorBindings
          .where((binding) => binding.id != vectorId)
          .toList(growable: false);
      target.xController.dispose();
      target.yController.dispose();
      _reindexVectorBindings();
    });
    _stopAnimation();
  }

  void _stopAnimation() {
    _animationController.stop();
    setState(() {
      _animationProgress = _animationController.value;
    });
  }

  void _toggleAnimation() {
    if (_animationController.isAnimating) {
      _stopAnimation();
      return;
    }

    if (_animationProgress >= 0.999) {
      _animationController.value = 0;
    }
    _animationController.forward();
  }

  void _restartAnimation() {
    _animationController
      ..value = 0
      ..forward();
  }

  void _setAnimationProgress(double value) {
    _animationController.stop();
    setState(() {
      _animationProgress = value;
      _animationController.value = value;
    });
  }

  Future<void> _openTransformViewer({
    required String title,
    required String subtitle,
    required List<GridLine> gridLines,
    required List<TransformVector> basisVectors,
    required List<TransformVector> vectors,
    required double viewportExtent,
  }) {
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => TransformViewerPage(
          title: title,
          subtitle: subtitle,
          gridLines: gridLines,
          basisVectors: basisVectors,
          vectors: vectors,
          viewportExtent: viewportExtent,
        ),
      ),
    );
  }

  _TransformPageState _buildPageState() {
    final errors = <String>[];

    final entries = <double>[];
    for (int row = 0; row < 2; row++) {
      for (int column = 0; column < 2; column++) {
        final raw = _matrixControllers[row][column].text.trim();
        if (raw.isEmpty) {
          errors.add('a${row + 1}${column + 1} 값이 비어 있습니다.');
          entries.add(0);
          continue;
        }
        final value = double.tryParse(raw);
        if (value == null) {
          errors.add('a${row + 1}${column + 1} 에 올바른 숫자를 입력하세요.');
          entries.add(0);
          continue;
        }
        entries.add(value);
      }
    }

    final vectors = <TransformVector>[];
    for (int index = 0; index < _vectorBindings.length; index++) {
      final binding = _vectorBindings[index];
      final rawX = binding.xController.text.trim();
      final rawY = binding.yController.text.trim();
      if (rawX.isEmpty) {
        errors.add('${binding.label}x 값이 비어 있습니다.');
      }
      if (rawY.isEmpty) {
        errors.add('${binding.label}y 값이 비어 있습니다.');
      }

      final parsedX = double.tryParse(rawX);
      final parsedY = double.tryParse(rawY);
      if (parsedX == null) {
        errors.add('${binding.label}x 에 올바른 숫자를 입력하세요.');
      }
      if (parsedY == null) {
        errors.add('${binding.label}y 에 올바른 숫자를 입력하세요.');
      }
      if (parsedX != null && parsedY != null) {
        vectors.add(
          TransformVector(
            id: binding.id,
            label: binding.label,
            x: parsedX,
            y: parsedY,
          ),
        );
      }
    }

    if (errors.isNotEmpty) {
      return _TransformPageState(errors: errors);
    }

    final matrix = TransformationMatrix(
      a11: entries[0],
      a12: entries[1],
      a21: entries[2],
      a22: entries[3],
    );
    final scene = TransformSceneBuilder.build(
      matrix: matrix,
      vectors: vectors,
    );
    final selectedIndex = scene.originalVectors.indexWhere(
      (vector) => vector.id == _selectedVectorId,
    );
    final resolvedIndex = selectedIndex >= 0 ? selectedIndex : 0;

    return _TransformPageState(
      scene: scene,
      selectedVectorIndex: resolvedIndex,
    );
  }

  @override
  Widget build(BuildContext context) {
    final pageState = _buildPageState();
    final animatedGridLines = pageState.scene?.lerpGridLines(_animationProgress);
    final animatedBasis = pageState.scene?.lerpBasis(_animationProgress);
    final animatedVectors = pageState.scene?.lerpVectors(_animationProgress);
    final animatedViewportExtent = pageState.scene == null
        ? null
        : TransformScene.computeViewportExtent(
            vectors: [
              ...animatedBasis!,
              ...animatedVectors!,
            ],
            lines: animatedGridLines!,
            fallbackExtent: pageState.scene!.gridExtent,
          );

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
          child: LayoutBuilder(
            builder: (context, viewportConstraints) {
              final horizontalPadding = viewportConstraints.maxWidth < 700
                  ? 16.0
                  : viewportConstraints.maxWidth < 1100
                      ? 20.0
                      : 24.0;
              final isWide = viewportConstraints.maxWidth >= 1180;
              final canvasAspectRatio = viewportConstraints.maxWidth < 700
                  ? 1.05
                  : viewportConstraints.maxWidth < 1180
                      ? 1.12
                      : 1.18;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  horizontalPadding,
                  20,
                  horizontalPadding,
                  24,
                ),
                child: Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 1320),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                    Text(
                      '선형변환 시각화',
                      style: Theme.of(context).textTheme.headlineMedium?.copyWith(
                            fontWeight: FontWeight.w800,
                            letterSpacing: -0.5,
                          ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      '2x2 선형변환 행렬과 벡터 v를 직접 입력하고, preset을 선택해 before / after 캔버스를 비교할 수 있습니다.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        height: 1.55,
                        fontSize: 16,
                      ),
                    ),
                    const SizedBox(height: 24),
                        if (isWide && pageState.scene != null)
                          Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Expanded(
                                flex: 11,
                                child: TransformInputCard(
                                  presets: TransformPreset.presets,
                                  selectedPresetId: _selectedPresetId,
                                  matrixControllers: _matrixControllers,
                                  vectorBindings: _vectorBindings,
                                  selectedVectorId: _selectedVectorId,
                                  errors: pageState.errors,
                                  onPresetSelected: _applyPreset,
                                  onLoadSample: _loadSample,
                                  onReset: _reset,
                                  onVectorSelected: _selectVector,
                                  onAddVector: _addVector,
                                  onDeleteVector: _deleteVector,
                                  onValuesChanged: _stopAnimation,
                                ),
                              ),
                              const SizedBox(width: 20),
                              Expanded(
                                flex: 9,
                                child: _TransformInsightCard(
                                  presetTitle: _selectedPresetTitle(),
                                  scene: pageState.scene!,
                                  selectedVectorIndex: pageState.selectedVectorIndex!,
                                ),
                              ),
                            ],
                          )
                        else ...[
                          TransformInputCard(
                            presets: TransformPreset.presets,
                            selectedPresetId: _selectedPresetId,
                            matrixControllers: _matrixControllers,
                            vectorBindings: _vectorBindings,
                            selectedVectorId: _selectedVectorId,
                            errors: pageState.errors,
                            onPresetSelected: _applyPreset,
                            onLoadSample: _loadSample,
                            onReset: _reset,
                            onVectorSelected: _selectVector,
                            onAddVector: _addVector,
                            onDeleteVector: _deleteVector,
                            onValuesChanged: _stopAnimation,
                          ),
                          if (pageState.scene != null) ...[
                            const SizedBox(height: 24),
                            _TransformInsightCard(
                              presetTitle: _selectedPresetTitle(),
                              scene: pageState.scene!,
                              selectedVectorIndex: pageState.selectedVectorIndex!,
                            ),
                          ],
                        ],
                        if (pageState.scene != null) ...[
                          const SizedBox(height: 20),
                          _TransformAnimationCard(
                            progress: _animationProgress,
                            isAnimating: _animationController.isAnimating,
                            onTogglePlayback: _toggleAnimation,
                            onRestart: _restartAnimation,
                            onProgressChanged: _setAnimationProgress,
                          ),
                          const SizedBox(height: 20),
                          LayoutBuilder(
                            builder: (context, constraints) {
                              final showSideBySide = constraints.maxWidth >= 980;
                              final beforeCard = TransformCanvasCard(
                                title: 'Before',
                                subtitle: '원본 격자, basis e1/e2, 입력 벡터들',
                                gridLines: pageState.scene!.originalGridLines,
                                basisVectors: pageState.scene!.originalBasis,
                                vectors: pageState.scene!.originalVectors,
                                viewportExtent: pageState.scene!.originalViewportExtent,
                                aspectRatio: canvasAspectRatio,
                                onTap: () => _openTransformViewer(
                                  title: 'Before',
                                  subtitle: '원본 격자, basis e1/e2, 입력 벡터들',
                                  gridLines: pageState.scene!.originalGridLines,
                                  basisVectors: pageState.scene!.originalBasis,
                                  vectors: pageState.scene!.originalVectors,
                                  viewportExtent: pageState.scene!.originalViewportExtent,
                                ),
                              );
                              final afterCard = TransformCanvasCard(
                                title: 'After',
                                subtitle:
                                    't=${formatDouble(_animationProgress, 2)} 보간 상태의 격자와 Avi',
                                gridLines: animatedGridLines!,
                                basisVectors: animatedBasis!,
                                vectors: animatedVectors!,
                                viewportExtent: animatedViewportExtent!,
                                aspectRatio: canvasAspectRatio,
                                onTap: () => _openTransformViewer(
                                  title: 'After',
                                  subtitle:
                                      't=${formatDouble(_animationProgress, 2)} 보간 상태의 격자와 Avi',
                                  gridLines: animatedGridLines,
                                  basisVectors: animatedBasis,
                                  vectors: animatedVectors,
                                  viewportExtent: animatedViewportExtent,
                                ),
                              );

                              if (showSideBySide) {
                                return Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Expanded(child: beforeCard),
                                    const SizedBox(width: 20),
                                    Expanded(child: afterCard),
                                  ],
                                );
                              }

                              return Column(
                                children: [
                                  beforeCard,
                                  const SizedBox(height: 20),
                                  afterCard,
                                ],
                              );
                            },
                          ),
                        ],
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  String _selectedPresetTitle() {
    return TransformPreset.presets
        .firstWhere(
          (preset) => preset.id == _selectedPresetId,
          orElse: () => TransformPreset.identity,
        )
        .title;
  }
}

class _TransformInsightCard extends StatelessWidget {
  const _TransformInsightCard({
    required this.presetTitle,
    required this.scene,
    required this.selectedVectorIndex,
  });

  final String presetTitle;
  final TransformScene scene;
  final int selectedVectorIndex;

  String _formatVector(TransformVector vector) {
    return '(${formatDouble(vector.x)}, ${formatDouble(vector.y)})';
  }

  String _orientationDescription(double determinant) {
    if (determinant.abs() < 1e-9) {
      return 'det(A)=0 이므로 면적이 0으로 붕괴되고 orientation은 정의되지 않습니다.';
    }
    if (determinant < 0) {
      return 'det(A)<0 이므로 orientation이 뒤집힙니다. 반사 성분이 포함된 변환입니다.';
    }
    return 'det(A)>0 이므로 orientation은 유지됩니다. 회전/기울임/스케일이 있어도 방향성은 보존됩니다.';
  }

  String _matrixText() {
    final matrix = scene.matrix;
    return '[${formatDouble(matrix.a11)} ${formatDouble(matrix.a12)}]\n'
        '[${formatDouble(matrix.a21)} ${formatDouble(matrix.a22)}]';
  }

  List<_CaseBadgeData> _caseBadges() {
    final badges = <_CaseBadgeData>[];
    final determinant = scene.matrix.determinant;
    final singular = determinant.abs() < 1e-9;
    final reflection = determinant < 0;
    final flippedAxes = _flippedAxes();

    if (singular) {
      badges.add(
        const _CaseBadgeData(
          label: 'Singular Matrix',
          detail: 'det(A)=0',
          color: TransformPalette.roseAccent,
        ),
      );
      badges.add(
        const _CaseBadgeData(
          label: 'Area Collapse',
          detail: '면적이 0으로 붕괴',
          color: TransformPalette.warmAccent,
        ),
      );
    }

    if (reflection) {
      badges.add(
        const _CaseBadgeData(
          label: 'Reflection',
          detail: 'orientation 반전',
          color: TransformPalette.primaryAccent,
        ),
      );
    }

    if (flippedAxes.isNotEmpty) {
      badges.add(
        _CaseBadgeData(
          label: 'Axis Flip',
          detail: flippedAxes.join(' / '),
          color: TransformPalette.axisY,
        ),
      );
    }

    if (badges.isEmpty) {
      badges.add(
        const _CaseBadgeData(
          label: 'Regular Transform',
          detail: '특수 경고 없음',
          color: TransformPalette.secondaryAccent,
        ),
      );
    }

    return badges;
  }

  List<String> _flippedAxes() {
    final flipped = <String>[];
    final ae1 = scene.transformedBasis[0];
    final ae2 = scene.transformedBasis[1];

    if (ae1.x < 0) {
      flipped.add('X-axis flipped');
    }
    if (ae2.y < 0) {
      flipped.add('Y-axis flipped');
    }

    return flipped;
  }

  List<String> _caseMessages() {
    final determinant = scene.matrix.determinant;
    final messages = <String>[];

    if (determinant.abs() < 1e-9) {
      messages.add('singular matrix: 두 basis가 한 직선 또는 한 점으로 눌리며 가역성이 사라집니다.');
      messages.add('area collapse: 단위 정사각형의 면적이 0으로 붕괴됩니다.');
    }

    if (determinant < 0) {
      messages.add('reflection: orientation이 반전되어 시계/반시계 방향성이 뒤집힙니다.');
    }

    for (final axis in _flippedAxes()) {
      messages.add('축 뒤집힘 안내: $axis');
    }

    if (messages.isEmpty) {
      messages.add('현재 변환은 singular/reflection/axis flip 경고 없이 regular한 선형변환입니다.');
    }

    return messages;
  }

  @override
  Widget build(BuildContext context) {
    final caseBadges = _caseBadges();
    final caseMessages = _caseMessages();

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '해석 카드',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            children: [
              _MetricChip(
                label: 'Preset',
                value: presetTitle,
              ),
              _MetricChip(
                label: 'det(A)',
                value: formatDouble(scene.matrix.determinant),
              ),
              _MetricChip(
                label: 'Viewport',
                value: formatDouble(scene.viewportExtent),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            children: caseBadges
                .map(
                  (badge) => Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                    decoration: BoxDecoration(
                      color: badge.color.withValues(alpha: 0.12),
                      borderRadius: BorderRadius.circular(999),
                      border: Border.all(
                        color: badge.color.withValues(alpha: 0.28),
                      ),
                    ),
                    child: Text(
                      '${badge.label}: ${badge.detail}',
                      style: const TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                )
                .toList(growable: false),
          ),
          const SizedBox(height: 18),
          Text(
            'A',
            style: Theme.of(context).textTheme.titleMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Text(
              _matrixText(),
              style: const TextStyle(
                fontFamily: 'monospace',
                height: 1.5,
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          const SizedBox(height: 18),
          Text(
            'e1 -> Ae1: ${_formatVector(scene.originalBasis[0])} -> ${_formatVector(scene.transformedBasis[0])}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'e2 -> Ae2: ${_formatVector(scene.originalBasis[1])} -> ${_formatVector(scene.transformedBasis[1])}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            '${scene.originalVectors[selectedVectorIndex].label} -> A${scene.originalVectors[selectedVectorIndex].label}: ${_formatVector(scene.originalVectors[selectedVectorIndex])} -> ${_formatVector(scene.transformedVectors[selectedVectorIndex])}',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.76),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: const Color(0xFF38BDF8).withValues(alpha: 0.1),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: const Color(0xFF38BDF8).withValues(alpha: 0.24),
              ),
            ),
            child: Text(
              _orientationDescription(scene.matrix.determinant),
              style: const TextStyle(
                color: Color(0xFFE0F2FE),
                height: 1.5,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          const SizedBox(height: 12),
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.04),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(
                color: Colors.white.withValues(alpha: 0.08),
              ),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  '특수 케이스 안내',
                  style: TextStyle(
                    fontWeight: FontWeight.w800,
                  ),
                ),
                const SizedBox(height: 10),
                ...caseMessages.map(
                  (message) => Padding(
                    padding: const EdgeInsets.only(bottom: 6),
                    child: Text(
                      '• $message',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.76),
                        height: 1.45,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _CaseBadgeData {
  const _CaseBadgeData({
    required this.label,
    required this.detail,
    required this.color,
  });

  final String label;
  final String detail;
  final Color color;
}

class _TransformAnimationCard extends StatelessWidget {
  const _TransformAnimationCard({
    required this.progress,
    required this.isAnimating,
    required this.onTogglePlayback,
    required this.onRestart,
    required this.onProgressChanged,
  });

  final double progress;
  final bool isAnimating;
  final VoidCallback onTogglePlayback;
  final VoidCallback onRestart;
  final ValueChanged<double> onProgressChanged;

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.05),
        borderRadius: BorderRadius.circular(28),
        border: Border.all(
          color: Colors.white.withValues(alpha: 0.08),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Animation',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                ),
          ),
          const SizedBox(height: 8),
          Text(
            't 보간으로 원본 격자와 벡터가 변환 결과로 이동합니다. slider로 직접 scrub 하거나 play로 자동 재생할 수 있습니다.',
            style: TextStyle(
              color: Colors.white.withValues(alpha: 0.72),
              height: 1.5,
            ),
          ),
          const SizedBox(height: 16),
          Wrap(
            spacing: 12,
            runSpacing: 12,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              FilledButton.icon(
                onPressed: onTogglePlayback,
                icon: Icon(isAnimating ? Icons.pause_rounded : Icons.play_arrow_rounded),
                label: Text(isAnimating ? 'Pause' : 'Play'),
              ),
              const SizedBox(width: 12),
              OutlinedButton.icon(
                onPressed: onRestart,
                icon: const Icon(Icons.replay_rounded),
                label: const Text('Restart'),
              ),
              _MetricChip(
                label: 't',
                value: formatDouble(progress, 2),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Slider(
            key: const ValueKey('animation-progress-slider'),
            value: progress,
            onChanged: onProgressChanged,
          ),
        ],
      ),
    );
  }
}

class _MetricChip extends StatelessWidget {
  const _MetricChip({
    required this.label,
    required this.value,
  });

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: TransformPalette.primaryAccent.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(
          color: TransformPalette.primaryAccent.withValues(alpha: 0.24),
        ),
      ),
      child: Text(
        '$label: $value',
        style: const TextStyle(
          color: TransformPalette.secondaryAccent,
          fontWeight: FontWeight.w700,
        ),
      ),
    );
  }
}

class _TransformPageState {
  const _TransformPageState({
    this.scene,
    this.selectedVectorIndex,
    this.errors = const [],
  });

  final TransformScene? scene;
  final int? selectedVectorIndex;
  final List<String> errors;
}
