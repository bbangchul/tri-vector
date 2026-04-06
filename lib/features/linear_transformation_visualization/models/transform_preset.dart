import 'package:todoey/features/linear_transformation_visualization/models/transformation_matrix.dart';

class TransformPreset {
  const TransformPreset({
    required this.id,
    required this.title,
    required this.description,
    required this.matrix,
  });

  final String id;
  final String title;
  final String description;
  final TransformationMatrix matrix;

  static const identity = TransformPreset(
    id: 'identity',
    title: 'Identity',
    description: '원본 격자와 벡터를 그대로 유지합니다.',
    matrix: TransformationMatrix.identity,
  );

  static const scale = TransformPreset(
    id: 'scale',
    title: 'Scale',
    description: 'x와 y를 각각 다른 비율로 확대합니다.',
    matrix: TransformationMatrix(
      a11: 2,
      a12: 0,
      a21: 0,
      a22: 0.75,
    ),
  );

  static const shear = TransformPreset(
    id: 'shear',
    title: 'Shear',
    description: 'x축 방향으로 기울어지는 선형변환입니다.',
    matrix: TransformationMatrix(
      a11: 1,
      a12: 1,
      a21: 0,
      a22: 1,
    ),
  );

  static const rotation90 = TransformPreset(
    id: 'rotation_90',
    title: 'Rotation 90°',
    description: '벡터와 격자를 원점 기준으로 반시계 90도 회전합니다.',
    matrix: TransformationMatrix(
      a11: 0,
      a12: -1,
      a21: 1,
      a22: 0,
    ),
  );

  static const reflectionX = TransformPreset(
    id: 'reflection_x',
    title: 'Reflect X',
    description: 'x축 대칭으로 뒤집습니다.',
    matrix: TransformationMatrix(
      a11: 1,
      a12: 0,
      a21: 0,
      a22: -1,
    ),
  );

  static const presets = [
    identity,
    scale,
    shear,
    rotation90,
    reflectionX,
  ];
}
