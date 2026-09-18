import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';
import 'package:flutter_stripe_connect/src/connect_js_mapping.dart';

void main() {
  group('connectAppearanceVariables', () {
    test('uses the variable names Connect.js documents', () {
      final variables = connectAppearanceVariables(
        const ConnectAppearance(
          fontFamily: 'Roboto',
          cornerRadius: 12.0,
          colors: ConnectColors(
            primary: '#635BFF',
            background: '#FFFFFF',
            text: '#1A1A1A',
            secondaryText: '#717171',
            border: '#D7D7D7',
            actionPrimaryText: '#0074D4',
            actionSecondaryText: '#444444',
            formBackground: '#FAFAFA',
            formHighlightBorder: '#CCCCCC',
          ),
        ),
      );

      expect(variables, {
        'fontFamily': 'Roboto',
        'colorPrimary': '#635BFF',
        'colorBackground': '#FFFFFF',
        'colorText': '#1A1A1A',
        'colorSecondaryText': '#717171',
        'colorBorder': '#D7D7D7',
        'actionPrimaryColorText': '#0074D4',
        'actionSecondaryColorText': '#444444',
        'formBackgroundColor': '#FAFAFA',
        'formHighlightColorBorder': '#CCCCCC',
        'borderRadius': '12.0px',
      });
    });

    test('carries every colour ConnectColors declares', () {
      // A colour the host app can set and the mapping forgets is dropped
      // silently, which is how four of them went missing before.
      const colors = ConnectColors(
        primary: '#111111',
        background: '#222222',
        text: '#333333',
        secondaryText: '#444444',
        border: '#555555',
        actionPrimaryText: '#666666',
        actionSecondaryText: '#777777',
        formBackground: '#888888',
        formHighlightBorder: '#999999',
      );

      final variables =
          connectAppearanceVariables(const ConnectAppearance(colors: colors));

      expect(variables.length, colors.toMap().length);
      expect(variables.values.toSet(), colors.toMap().values.toSet());
    });

    test('gives the corner radius the pixel unit Connect.js requires', () {
      expect(
        connectAppearanceVariables(
            const ConnectAppearance(cornerRadius: 8))['borderRadius'],
        '8.0px',
      );
      expect(
        connectAppearanceVariables(
            const ConnectAppearance(cornerRadius: 12.5))['borderRadius'],
        '12.5px',
      );
    });

    test('leaves out what the host app did not set', () {
      expect(connectAppearanceVariables(const ConnectAppearance()), isEmpty);
    });

    test('leaves out the unset colours of a partly filled ConnectColors', () {
      final variables = connectAppearanceVariables(
        const ConnectAppearance(colors: ConnectColors(primary: '#635BFF')),
      );

      expect(variables, {'colorPrimary': '#635BFF'});
    });
  });

  group('connectComponentName', () {
    test('maps every view type to the name Connect.js serves', () {
      expect(
        {
          for (final type in StripeConnectViewType.values)
            type: connectComponentName(type)
        },
        {
          StripeConnectViewType.accountOnboarding: 'account-onboarding',
          StripeConnectViewType.accountManagement: 'account-management',
          StripeConnectViewType.payouts: 'payouts',
          StripeConnectViewType.payments: 'payments',
          StripeConnectViewType.notificationBanner: 'notification-banner',
          StripeConnectViewType.balances: 'balances',
          StripeConnectViewType.documents: 'documents',
          StripeConnectViewType.taxSettings: 'tax-settings',
          StripeConnectViewType.taxRegistrations: 'tax-registrations',
          StripeConnectViewType.payoutsList: 'payouts-list',
          StripeConnectViewType.paymentDetails: 'payment-details',
          StripeConnectViewType.payoutDetails: 'payout-details',
          StripeConnectViewType.disputesList: 'disputes-list',
        },
      );
    });

    test('gives every view type a distinct name', () {
      final names = StripeConnectViewType.values.map(connectComponentName);

      expect(names.toSet().length, StripeConnectViewType.values.length);
    });
  });
}
