import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:todoey/features/linear_transformation_visualization/linear_transformation_home_page.dart';

void main() {
  testWidgets('linear transformation page shows input controls and canvases', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LinearTransformationHomePage(),
      ),
    );

    expect(find.text('선형변환 시각화'), findsOneWidget);
    expect(find.text('Transform Input'), findsOneWidget);
    expect(find.text('Sample'), findsOneWidget);
    expect(find.text('Reset'), findsOneWidget);
    expect(find.text('해석 카드'), findsOneWidget);
    expect(find.text('Animation'), findsOneWidget);
    expect(find.text('Play'), findsOneWidget);
    expect(find.text('A'), findsOneWidget);
    expect(find.text('특수 케이스 안내'), findsOneWidget);
    expect(find.textContaining('e1 -> Ae1'), findsOneWidget);
    expect(find.textContaining('e2 -> Ae2'), findsOneWidget);
    expect(find.textContaining('v1 -> Av1'), findsOneWidget);
    expect(find.textContaining('Regular Transform'), findsOneWidget);
    expect(find.byKey(const ValueKey('vector-chip-v1')), findsOneWidget);
    expect(find.byKey(const ValueKey('vector-chip-v2')), findsOneWidget);
    expect(find.byKey(const ValueKey('matrix-0-0')), findsOneWidget);
    expect(find.byKey(const ValueKey('vector-x-v1')), findsOneWidget);
    expect(find.byKey(const ValueKey('vector-x-v2')), findsOneWidget);
    expect(find.byKey(const ValueKey('animation-progress-slider')), findsOneWidget);
    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(2));
  });

  testWidgets('linear transformation page supports select add and delete vector', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LinearTransformationHomePage(),
      ),
    );

    await tester.ensureVisible(find.byKey(const ValueKey('vector-chip-v2')));
    await tester.tap(find.byKey(const ValueKey('vector-chip-v2')));
    await tester.pumpAndSettle();
    expect(find.textContaining('v2 -> Av2'), findsOneWidget);

    await tester.ensureVisible(find.text('Add'));
    await tester.tap(find.text('Add'));
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('vector-chip-v3')), findsOneWidget);
    expect(find.byKey(const ValueKey('vector-x-v3')), findsOneWidget);

    await tester.ensureVisible(find.byTooltip('Delete vector').last);
    await tester.tap(find.byTooltip('Delete vector').last);
    await tester.pumpAndSettle();
    expect(find.byKey(const ValueKey('vector-chip-v3')), findsNothing);
  });

  testWidgets('before canvas opens fullscreen viewer by navigator', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: LinearTransformationHomePage(),
      ),
    );

    await tester.ensureVisible(find.text('Before'));
    await tester.tap(find.text('Before'));
    await tester.pumpAndSettle();

    expect(find.text('Before'), findsWidgets);
    expect(find.byTooltip('Close viewer'), findsOneWidget);
    expect(find.byType(CustomPaint), findsAtLeastNWidgets(1));
  });
}
