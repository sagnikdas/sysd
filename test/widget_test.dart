import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:sysdesign_flash/app.dart';

void main() {
  testWidgets('App launches and shows splash screen', (tester) async {
    await tester.pumpWidget(
      const ProviderScope(child: SysDesignFlashApp()),
    );

    expect(find.text('SysDesign Flash'), findsOneWidget);
    expect(find.text('Master system design visually'), findsOneWidget);

    // Let the splash timer and navigation complete
    await tester.pumpAndSettle(const Duration(seconds: 3));
  });
}
