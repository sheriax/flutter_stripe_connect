/// Configuration for WebView-based component rendering
///
/// When provided to [StripeConnect.initialize()], components will render
/// via WebView using the hosted web app instead of native platform views.
class WebViewConfig {
  /// Base URL of your hosted Stripe Connect web app
  /// Example: 'https://connect.example.com'
  final String baseUrl;

  /// Theme mode for the components ('light' or 'dark')
  final String? theme;

  /// Primary brand color (hex string, e.g., '#635BFF')
  final String? primaryColor;

  /// The URL query parameter name for the publishable key.
  /// Defaults to 'publishableKey'.
  ///
  /// Use this if your hosted web app expects a different parameter name,
  /// e.g., 'pk' instead of 'publishableKey'.
  final String publishableKeyParam;

  /// The URL query parameter name for the client secret.
  /// Defaults to 'clientSecret'.
  ///
  /// Use this if your hosted web app expects a different parameter name,
  /// e.g., 'secret' instead of 'clientSecret'.
  final String clientSecretParam;

  const WebViewConfig({
    required this.baseUrl,
    this.theme,
    this.primaryColor,
    this.publishableKeyParam = 'publishableKey',
    this.clientSecretParam = 'clientSecret',
  });

  /// Builds the full URL for a component
  Uri buildUrl({
    required String componentPath,
    required String publishableKey,
    required String clientSecret,
    Map<String, String>? extraParams,
  }) {
    final queryParams = <String, String>{
      publishableKeyParam: publishableKey,
      clientSecretParam: clientSecret,
      if (theme != null) 'theme': theme!,
      if (primaryColor != null) 'primaryColor': primaryColor!,
      ...?extraParams,
    };

    return Uri.parse(baseUrl).replace(
      path: componentPath,
      queryParameters: queryParams,
    );
  }
}
