import 'package:todoey/features/matrix_rref/models/matrix.dart';

class MatrixFeatureScope {
  const MatrixFeatureScope({
    required this.supportedInputs,
    required this.supportedFeatures,
    required this.excludedFeatures,
  });

  final List<MatrixInputKind> supportedInputs;
  final List<String> supportedFeatures;
  final List<String> excludedFeatures;
}

const matrixRrefV1Scope = MatrixFeatureScope(
  supportedInputs: [
    MatrixInputKind.square2x2,
    MatrixInputKind.square3x3,
    MatrixInputKind.augmented3x4,
  ],
  supportedFeatures: [
    '행렬 입력',
    '기본 행 연산',
    'Ax=b 풀이',
    'RREF 단계 표시',
  ],
  excludedFeatures: [
    'determinant',
    'inverse',
    'eigen',
  ],
);
