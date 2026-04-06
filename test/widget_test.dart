import 'package:flutter_test/flutter_test.dart';

import 'package:todoey/main.dart';

void main() {
  testWidgets('geometry visualizer shows example inputs and results', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Triangle /\nLine Intersection'), findsOneWidget);
    expect(find.text('Input Controls'), findsOneWidget);
    expect(find.text('3D Points Preview'), findsOneWidget);
    expect(find.text('Computed Output'), findsOneWidget);
    expect(find.textContaining('Q = (0.3, 0.3, 0)'), findsWidgets);
    expect(find.textContaining('Intersection on segment = YES'), findsOneWidget);
  });

  testWidgets('menu opens and navigates to linear transformation page', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    await tester.tap(find.byTooltip('Menu'));
    await tester.pumpAndSettle();

    expect(find.text('선형변환 시각화'), findsOneWidget);

    await tester.tap(find.text('선형변환 시각화').last);
    await tester.pumpAndSettle();

    expect(find.text('Before'), findsOneWidget);
    expect(find.text('After'), findsOneWidget);
  });
}
