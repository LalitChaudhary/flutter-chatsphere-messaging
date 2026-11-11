import 'package:chatsphere/main.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('member opens the thread', (tester) async {
    await tester.pumpWidget(const ProviderScope(child: ChatSphereApp()));
    await tester.tap(find.text('Open thread'));
    await tester.pumpAndSettle();
    expect(find.text('Studio'), findsOneWidget);
  });
}
