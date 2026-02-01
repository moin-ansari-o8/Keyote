import 'package:flutter_test/flutter_test.dart';
import 'package:keyote_apk/main.dart';
import 'package:keyote_apk/services/keyboard_service.dart';
import 'package:keyote_apk/services/storage_service.dart';

void main() {
  testWidgets('App launches successfully', (WidgetTester tester) async {
    final storageService = await StorageService.getInstance();
    final keyboardService = KeyboardService();

    await tester.pumpWidget(
      MyApp(storageService: storageService, keyboardService: keyboardService),
    );

    expect(find.text('Keyote Remote'), findsOneWidget);
  });
}
