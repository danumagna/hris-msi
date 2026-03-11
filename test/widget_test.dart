import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:hris_msi/app.dart';

void main() {
  testWidgets('App should render without crashing', (
    WidgetTester tester,
  ) async {
    await tester.pumpWidget(
      const ProviderScope(child: App()),
    );
    // Splash screen should be visible initially
    expect(find.text('HRIS MSI'), findsOneWidget);
  });
}
