/// Flutter Stripe Connect - A Flutter plugin for Stripe Connect embedded components
library;

export 'src/stripe_connect.dart';
export 'src/widgets/connect_components.dart';
export 'src/models/webview_config.dart';
export 'src/models/account_collection_options.dart';
export 'src/widgets/webview_components.dart'
    if (dart.library.js_interop) 'src/widgets/webview_components_stub.dart'
    show StripeConnectWebView, StripeConnectPaths;
