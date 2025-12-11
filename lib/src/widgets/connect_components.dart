import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../stripe_connect.dart';

// Conditional import for web support
import 'connect_components_stub.dart'
    if (dart.library.html) 'web_components.dart' as web_impl;

/// Callback for when a component finishes loading
typedef OnLoadCallback = void Function();

/// Callback for component errors
typedef OnLoadErrorCallback = void Function(String error);

/// Callback for when onboarding exits
typedef OnExitCallback = void Function();

/// Callback for when a component is closed
typedef OnCloseCallback = void Function();

/// Account Onboarding component for collecting connected account information
class StripeAccountOnboarding extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final OnExitCallback? onExit;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeAccountOnboarding({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeAccountOnboardingWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        onExit: onExit,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_account_onboarding',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      onExit: onExit,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Account Management component for connected accounts to manage their account
class StripeAccountManagement extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final bool? collectionOptions;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeAccountManagement({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.collectionOptions,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeAccountManagementWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_account_management',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
      extraParams: {
        if (collectionOptions != null) 'collectionOptions': collectionOptions,
      },
    );
  }
}

/// Payouts component for connected accounts to view and manage payouts
class StripePayouts extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripePayouts({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripePayoutsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_payouts',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Payments component for connected accounts to view payments
class StripePayments extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripePayments({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripePaymentsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_payments',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Notification Banner component for showing required actions
///
/// Web only - not available on iOS/Android
class StripeNotificationBanner extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeNotificationBanner({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeNotificationBannerWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_notification_banner',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Balances component for showing balance information
class StripeBalances extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeBalances({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeBalancesWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_balances',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Documents component for showing available documents
///
/// Web only - limited support on iOS/Android
class StripeDocuments extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeDocuments({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeDocumentsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_documents',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Tax Settings component for managing tax configuration
///
/// Web only - not available on iOS/Android
class StripeTaxSettings extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeTaxSettings({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeTaxSettingsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    // Not available on mobile - show error
    onLoadError?.call('Tax Settings is only available on Web platform');
    return const Center(
      child: Text('Tax Settings is only available on Web'),
    );
  }
}

/// Tax Registrations component for managing tax registrations
///
/// Web only - not available on iOS/Android
class StripeTaxRegistrations extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeTaxRegistrations({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeTaxRegistrationsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    // Not available on mobile - show error
    onLoadError?.call('Tax Registrations is only available on Web platform');
    return const Center(
      child: Text('Tax Registrations is only available on Web'),
    );
  }
}

/// Payouts List component for showing filterable payout list
class StripePayoutsList extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripePayoutsList({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripePayoutsListWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_payouts_list',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Payment Details component for showing payment details overlay
class StripePaymentDetails extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final OnCloseCallback? onClose;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The payment intent or charge ID to display
  final String? paymentId;

  const StripePaymentDetails({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onClose,
    this.appearance,
    this.gestureRecognizers,
    this.paymentId,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripePaymentDetailsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        onClose: onClose,
        appearance: appearance,
        paymentId: paymentId,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_payment_details',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
      extraParams: paymentId != null ? {'paymentId': paymentId} : null,
    );
  }
}

/// Payout Details component for showing payout details overlay
class StripePayoutDetails extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final OnCloseCallback? onClose;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  /// The payout ID to display
  final String? payoutId;

  const StripePayoutDetails({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.onClose,
    this.appearance,
    this.gestureRecognizers,
    this.payoutId,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripePayoutDetailsWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        onClose: onClose,
        appearance: appearance,
        payoutId: payoutId,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_payout_details',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
      extraParams: payoutId != null ? {'payoutId': payoutId} : null,
    );
  }
}

/// Disputes List component for showing and managing disputes
class StripeDisputesList extends StatelessWidget {
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final ConnectAppearance? appearance;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const StripeDisputesList({
    super.key,
    this.onLoaded,
    this.onLoadError,
    this.appearance,
    this.gestureRecognizers,
  });

  @override
  Widget build(BuildContext context) {
    if (kIsWeb) {
      return web_impl.StripeDisputesListWeb(
        onLoaded: onLoaded,
        onLoadError: onLoadError,
        appearance: appearance,
      );
    }
    return _StripeConnectPlatformView(
      viewType: 'stripe_disputes_list',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Internal platform view widget for iOS/Android
class _StripeConnectPlatformView extends StatefulWidget {
  final String viewType;
  final OnLoadCallback? onLoaded;
  final OnLoadErrorCallback? onLoadError;
  final OnExitCallback? onExit;
  final ConnectAppearance? appearance;
  final Map<String, dynamic>? extraParams;
  final Set<Factory<OneSequenceGestureRecognizer>>? gestureRecognizers;

  const _StripeConnectPlatformView({
    required this.viewType,
    this.onLoaded,
    this.onLoadError,
    this.onExit,
    this.appearance,
    this.extraParams,
    this.gestureRecognizers,
  });

  @override
  State<_StripeConnectPlatformView> createState() =>
      _StripeConnectPlatformViewState();
}

class _StripeConnectPlatformViewState
    extends State<_StripeConnectPlatformView> {
  late MethodChannel _channel;

  @override
  void initState() {
    super.initState();
  }

  void _onPlatformViewCreated(int viewId) {
    _channel = MethodChannel(
      'flutter_stripe_connect/${widget.viewType}_$viewId',
    );
    _channel.setMethodCallHandler(_handleMethodCall);
  }

  Future<dynamic> _handleMethodCall(MethodCall call) async {
    switch (call.method) {
      case 'onLoaded':
        widget.onLoaded?.call();
        break;
      case 'onLoadError':
        widget.onLoadError?.call(call.arguments as String? ?? 'Unknown error');
        break;
      case 'onExit':
        widget.onExit?.call();
        break;
    }
  }

  Map<String, dynamic> get _creationParams => {
        if (widget.appearance != null) 'appearance': widget.appearance!.toMap(),
        ...?widget.extraParams,
      };

  @override
  Widget build(BuildContext context) {
    const viewType = 'flutter_stripe_connect_view';
    final params = {'componentType': widget.viewType, ..._creationParams};

    switch (defaultTargetPlatform) {
      case TargetPlatform.android:
        return AndroidView(
          viewType: viewType,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
        );
      case TargetPlatform.iOS:
        return UiKitView(
          viewType: viewType,
          creationParams: params,
          creationParamsCodec: const StandardMessageCodec(),
          onPlatformViewCreated: _onPlatformViewCreated,
          gestureRecognizers: widget.gestureRecognizers,
        );
      default:
        return Center(
          child: Text('${defaultTargetPlatform.name} is not supported'),
        );
    }
  }
}
