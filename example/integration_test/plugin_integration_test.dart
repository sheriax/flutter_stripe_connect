import 'package:flutter_test/flutter_test.dart';
import 'package:integration_test/integration_test.dart';
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();

  testWidgets('StripeConnect singleton test', (WidgetTester tester) async {
    // Verify StripeConnect singleton pattern works
    final instance1 = StripeConnect.instance;
    final instance2 = StripeConnect.instance;
    expect(identical(instance1, instance2), true);
  });
}
