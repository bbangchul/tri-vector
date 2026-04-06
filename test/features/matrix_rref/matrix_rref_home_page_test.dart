import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoey/features/matrix_rref/matrix_rref_home_page.dart';

void main() {
  testWidgets('matrix page shows input controls and step viewer', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: MatrixRrefHomePage(),
      ),
    );

    expect(find.text('Matrix Input'), findsOneWidget);
    expect(find.text('일반 행렬'), findsOneWidget);
    expect(find.text('Ax=b'), findsOneWidget);
    expect(find.text('RREF 줄변환'), findsWidgets);
    expect(find.text('Current Matrix'), findsOneWidget);
    expect(find.text('Solution Summary'), findsOneWidget);
  });
}
