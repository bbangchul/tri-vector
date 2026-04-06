import 'package:flutter_test/flutter_test.dart';

import 'package:todoey/main.dart';

void main() {
  testWidgets('geometry visualizer shows example inputs and results', (WidgetTester tester) async {
    await tester.pumpWidget(const MyApp());
    await tester.pumpAndSettle();

    expect(find.text('Triangle / Line Intersection'), findsOneWidget);
    expect(find.text('Input Controls'), findsOneWidget);
    expect(find.text('3D Points Preview'), findsOneWidget);
    expect(find.text('Computed Output'), findsOneWidget);
    expect(find.textContaining('Q = (0.3, 0.3, 0)'), findsWidgets);
    expect(find.textContaining('Intersection on segment = YES'), findsOneWidget);
  });
}
