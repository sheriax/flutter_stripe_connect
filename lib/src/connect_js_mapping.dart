/// The names Connect.js knows, kept apart from the interop that hands them
/// over.
///
/// Connect.js ignores an appearance variable it does not recognise and throws
/// nothing for a component name it does not serve, so a wrong name here fails
/// the same silent way a missing one does. Holding the mapping in plain Dart
/// is what lets it be tested without a browser.
library;

import 'stripe_connect.dart';
import 'widgets/connect_components.dart';

/// The `appearance.variables` object Connect.js takes, as plain values.
///
/// A value the host app left unset is left out rather than sent as null, so
/// the Connect.js default stands.
///
/// Names come from Stripe's supported appearance options:
/// https://docs.stripe.com/connect/embedded-appearance-options
Map<String, String> connectAppearanceVariables(ConnectAppearance appearance) {
  final colors = appearance.colors;

  return {
    if (appearance.fontFamily != null) 'fontFamily': appearance.fontFamily!,
    if (colors?.primary != null) 'colorPrimary': colors!.primary!,
    if (colors?.background != null) 'colorBackground': colors!.background!,
    if (colors?.text != null) 'colorText': colors!.text!,
    if (colors?.secondaryText != null)
      'colorSecondaryText': colors!.secondaryText!,
    if (colors?.border != null) 'colorBorder': colors!.border!,
    if (colors?.actionPrimaryText != null)
      'actionPrimaryColorText': colors!.actionPrimaryText!,
    if (colors?.actionSecondaryText != null)
      'actionSecondaryColorText': colors!.actionSecondaryText!,
    if (colors?.formBackground != null)
      'formBackgroundColor': colors!.formBackground!,
    if (colors?.formHighlightBorder != null)
      'formHighlightColorBorder': colors!.formHighlightBorder!,
    // Connect.js only accepts pixel values here; a bare number is ignored.
    if (appearance.cornerRadius != null)
      'borderRadius': '${appearance.cornerRadius}px',
  };
}

/// The Connect.js component name for [type].
String connectComponentName(StripeConnectViewType type) {
  switch (type) {
    case StripeConnectViewType.accountOnboarding:
      return 'account-onboarding';
    case StripeConnectViewType.accountManagement:
      return 'account-management';
    case StripeConnectViewType.payments:
      return 'payments';
    case StripeConnectViewType.payouts:
      return 'payouts';
    case StripeConnectViewType.notificationBanner:
      return 'notification-banner';
    case StripeConnectViewType.balances:
      return 'balances';
    case StripeConnectViewType.documents:
      return 'documents';
    case StripeConnectViewType.taxSettings:
      return 'tax-settings';
    case StripeConnectViewType.taxRegistrations:
      return 'tax-registrations';
    case StripeConnectViewType.payoutsList:
      return 'payouts-list';
    case StripeConnectViewType.paymentDetails:
      return 'payment-details';
    case StripeConnectViewType.payoutDetails:
      return 'payout-details';
    case StripeConnectViewType.disputesList:
      return 'disputes-list';
  }
}
