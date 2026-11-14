import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:restrorent_partner_app/main.dart';

void main() {
  testWidgets('App smoke test mounts EatoggyPartnerApp', (WidgetTester tester) async {
    await tester.pumpWidget(
      const ProviderScope(
        child: EatoggyPartnerApp(),
      ),
    );
    expect(find.byType(EatoggyPartnerApp), findsOneWidget);

    // Pump forward past splash duration to advance frames without infinite loop
    await tester.pump(const Duration(milliseconds: 3200));
    await tester.pump(const Duration(milliseconds: 500));
  });
}
