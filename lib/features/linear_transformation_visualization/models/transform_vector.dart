class TransformVector {
  const TransformVector({
    required this.x,
    required this.y,
    this.id = '',
    this.label = '',
  });

  final String id;
  final String label;
  final double x;
  final double y;

  static const zero = TransformVector(x: 0, y: 0);
  static const basisX = TransformVector(x: 1, y: 0, id: 'e1', label: 'e1');
  static const basisY = TransformVector(x: 0, y: 1, id: 'e2', label: 'e2');

  TransformVector copyWith({
    String? id,
    String? label,
    double? x,
    double? y,
  }) {
    return TransformVector(
      id: id ?? this.id,
      label: label ?? this.label,
      x: x ?? this.x,
      y: y ?? this.y,
    );
  }

  static TransformVector lerp(
    TransformVector from,
    TransformVector to,
    double t,
  ) {
    return TransformVector(
      id: to.id.isNotEmpty ? to.id : from.id,
      label: to.label.isNotEmpty ? to.label : from.label,
      x: from.x + ((to.x - from.x) * t),
      y: from.y + ((to.y - from.y) * t),
    );
  }

  @override
  bool operator ==(Object other) {
    return other is TransformVector &&
        other.id == id &&
        other.label == label &&
        other.x == x &&
        other.y == y;
  }

  @override
  int get hashCode => Object.hash(id, label, x, y);
}
