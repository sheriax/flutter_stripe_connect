import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';

void main() {
  group('StripeConnect', () {
    test('StripeConnect instance is singleton', () {
      final instance1 = StripeConnect.instance;
      final instance2 = StripeConnect.instance;
      expect(identical(instance1, instance2), true);
    });
  });

  group('ConnectAppearance', () {
    test('toMap returns correct values', () {
      const appearance = ConnectAppearance(
        fontFamily: 'Roboto',
        cornerRadius: 8.0,
        colors: ConnectColors(
          primary: '#6366f1',
          background: '#ffffff',
        ),
      );

      final map = appearance.toMap();
      expect(map['fontFamily'], 'Roboto');
      expect(map['cornerRadius'], 8.0);
      expect(map['colors'], isA<Map>());
    });

    test('toMap excludes null values', () {
      const appearance = ConnectAppearance(fontFamily: 'Roboto');
      final map = appearance.toMap();
      expect(map.containsKey('fontFamily'), true);
      expect(map.containsKey('colors'), false);
      expect(map.containsKey('cornerRadius'), false);
    });
  });

  group('ConnectColors', () {
    test('toMap returns correct values', () {
      const colors = ConnectColors(
        primary: '#6366f1',
        background: '#ffffff',
        text: '#000000',
      );

      final map = colors.toMap();
      expect(map['primary'], '#6366f1');
      expect(map['background'], '#ffffff');
      expect(map['text'], '#000000');
    });
  });
}
