/// Stub file for non-web platforms
///
/// This file provides placeholder implementations that are never actually
/// used on non-web platforms - the kIsWeb check prevents their use.
library flutter_stripe_connect_components_stub;

import 'package:flutter/widgets.dart';
import '../stripe_connect.dart';

/// Stub for web account onboarding
class StripeAccountOnboardingWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final VoidCallback? onExit;
  final ConnectAppearance? appearance;

  const StripeAccountOnboardingWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web account management
class StripeAccountManagementWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeAccountManagementWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web payments
class StripePaymentsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripePaymentsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web payouts
class StripePayoutsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripePayoutsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web notification banner
class StripeNotificationBannerWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeNotificationBannerWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web balances
class StripeBalancesWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeBalancesWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web documents
class StripeDocumentsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeDocumentsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web tax settings
class StripeTaxSettingsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeTaxSettingsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web tax registrations
class StripeTaxRegistrationsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeTaxRegistrationsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web payouts list
class StripePayoutsListWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripePayoutsListWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web payment details
class StripePaymentDetailsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final VoidCallback? onClose;
  final ConnectAppearance? appearance;
  final String? paymentId;

  const StripePaymentDetailsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onClose,
    this.appearance,
    this.paymentId,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web payout details
class StripePayoutDetailsWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final VoidCallback? onClose;
  final ConnectAppearance? appearance;
  final String? payoutId;

  const StripePayoutDetailsWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onClose,
    this.appearance,
    this.payoutId,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}

/// Stub for web disputes list
class StripeDisputesListWeb extends StatelessWidget {
  final VoidCallback? onLoaded;
  final void Function(String)? onLoadError;
  final ConnectAppearance? appearance;

  const StripeDisputesListWeb({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
  });

  @override
  Widget build(BuildContext context) => throw UnimplementedError();
}
