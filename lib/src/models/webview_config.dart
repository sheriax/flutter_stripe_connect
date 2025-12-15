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

  const WebViewConfig({
    required this.baseUrl,
    this.theme,
    this.primaryColor,
  });

  /// Builds the full URL for a component
  Uri buildUrl({
    required String componentPath,
    required String publishableKey,
    required String clientSecret,
    Map<String, String>? extraParams,
  }) {
    final queryParams = <String, String>{
      'publishableKey': publishableKey,
      'clientSecret': clientSecret,
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
