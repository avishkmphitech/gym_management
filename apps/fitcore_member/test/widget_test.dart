import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:fitcore_member/main.dart';

void main() {
  testWidgets('FitCore Member renders splash', (WidgetTester tester) async {
    await tester.pumpWidget(const ProviderScope(child: FitCoreMemberApp()));
    await tester.pump();
    expect(find.textContaining('FitCore'), findsWidgets);
    await tester.pump(const Duration(milliseconds: 3900));
  });
}
