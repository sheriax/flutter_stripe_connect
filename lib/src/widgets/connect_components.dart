import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../stripe_connect.dart';

/// Callback for when a component finishes loading
typedef OnLoadCallback = void Function();

/// Callback for component errors
typedef OnLoadErrorCallback = void Function(String error);

/// Callback for when onboarding exits
typedef OnExitCallback = void Function();

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
    return _StripeConnectPlatformView(
      viewType: 'stripe_payments',
      onLoaded: onLoaded,
      onLoadError: onLoadError,
      appearance: appearance,
      gestureRecognizers: gestureRecognizers,
    );
  }
}

/// Internal platform view widget
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
