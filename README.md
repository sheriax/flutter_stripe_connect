# flutter_stripe_connect

A Flutter plugin for Stripe Connect embedded components. Easily integrate account onboarding, account management, payouts, payments, and more into your Flutter app.

[![pub package](https://img.shields.io/pub/v/flutter_stripe_connect.svg)](https://pub.dev/packages/flutter_stripe_connect)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Account Onboarding** - Collect connected account information with a pre-built UI
- **Account Management** - Let connected accounts manage their account settings
- **Payments** - Show payment history for connected accounts
- **Payouts** - Display payout history and status for connected accounts
- **Balances** - Show balance information and payout controls
- **Notification Banner** - Display required actions for compliance
- **Documents** - Show documents available for download
- **Tax Settings** - Allow connected accounts to configure tax settings
- **Tax Registrations** - Manage tax registrations
- **Disputes List** - View and manage disputes
- **Payment Details** - Show detailed payment information
- **Payout Details** - Show detailed payout information
- **Payouts List** - Filterable list of payouts
- **WebView Mode** - Optional self-hosted web rendering for full component access
- **Customizable Appearance** - Configure colors, fonts, and corner radius

## Platform Support

| Platform | Supported |
|:--------:|:---------:|
| Android  |     ✅     |
| iOS      |     ✅     |
| Web      |     ✅     |

### Component Availability by Platform

| Component | iOS | Android | Web | WebView Mode |
|:----------|:---:|:-------:|:---:|:------------:|
| Account Onboarding | ✅ | ✅ | ✅ | ✅ |
| Account Management | ✅ | ❌ | ✅ | ✅ |
| Payments | ✅ | ✅ | ✅ | ✅ |
| Payouts | ✅ | ✅ | ✅ | ✅ |
| Notification Banner | ✅ | ⚠️ | ✅ | ✅ |
| Balances | ✅ | ⚠️ | ✅ | ✅ |
| Documents | ⚠️ | ⚠️ | ✅ | ✅ |
| Tax Settings | ❌ | ❌ | ✅ | ✅ |
| Tax Registrations | ❌ | ❌ | ✅ | ✅ |
| Disputes List | ✅ | ✅ | ✅ | ✅ |
| Payment Details | ✅ | ✅ | ✅ | ✅ |
| Payout Details | ✅ | ✅ | ✅ | ✅ |
| Payouts List | ✅ | ✅ | ✅ | ✅ |

> **Legend:** ✅ Fully Supported | ⚠️ Limited/Preview | ❌ Not Supported
>
> **WebView Mode**: Requires hosting your own web app. See `STRIPE_CONNECT_WEBVIEW_INTEGRATION.md`.

## Installation

Add `flutter_stripe_connect` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_stripe_connect: ^0.2.1
```

## Platform Setup

### Android Setup

**Important**: Your `MainActivity` must extend `FlutterFragmentActivity` (not `FlutterActivity`) for the Stripe Connect components to work properly.

Update your `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
package com.example.yourapp

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

### iOS Setup

No additional setup required. The plugin uses StripeConnect iOS SDK via CocoaPods.

> **Troubleshooting**: If pod install fails on the first try, run:
> ```bash
> cd ios/
> pod install --repo-update
> ```

### Web Setup

Add the Connect.js script to your `web/index.html` inside the `<head>` tag:

```html
<script src="https://connect-js.stripe.com/v1.0/connect.js" async></script>
```

**CSP Requirements**: If you're using Content Security Policy headers, allow these Stripe domains:
- `https://connect-js.stripe.com`
- `https://js.stripe.com`

## Usage

### 1. Initialize the SDK

```dart
import 'package:flutter_stripe_connect/flutter_stripe_connect.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  await StripeConnect.instance.initialize(
    publishableKey: 'pk_test_...',
    clientSecretProvider: () async {
      // Fetch client secret from your server
      final response = await http.post(
        Uri.parse('https://your-server.com/create-account-session'),
      );
      return jsonDecode(response.body)['client_secret'];
    },
  );
  
  runApp(MyApp());
}
```

### 1b. Enable WebView Mode (Optional)

For full component access on mobile (including Tax, Capital, Issuing), use WebView mode:

```dart
await StripeConnect.instance.initialize(
  publishableKey: 'pk_test_...',
  clientSecretProvider: () async {
    final response = await http.post(
      Uri.parse('https://your-server.com/create-account-session'),
    );
    return jsonDecode(response.body)['client_secret'];
  },
  webViewConfig: WebViewConfig(
    baseUrl: 'https://connect.yourapp.com',  // Your hosted web app
    theme: 'light',
    primaryColor: '#635BFF',
  ),
);
```

> **Note**: WebView mode requires hosting your own Next.js app. See `STRIPE_CONNECT_WEBVIEW_INTEGRATION.md` for setup guide.

### 2. Use the Embedded Components

#### Account Onboarding

```dart
StripeAccountOnboarding(
  onLoaded: () => print('Onboarding loaded'),
  onLoadError: (error) => print('Error: $error'),
  onExit: () => print('User exited onboarding'),
)
```

#### Account Management

```dart
StripeAccountManagement(
  onLoaded: () => print('Account management loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Payments

```dart
StripePayments(
  onLoaded: () => print('Payments loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Payouts

```dart
StripePayouts(
  onLoaded: () => print('Payouts loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Balances

```dart
StripeBalances(
  onLoaded: () => print('Balances loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Tax Settings (Web Only)

```dart
StripeTaxSettings(
  onLoaded: () => print('Tax settings loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

#### Disputes List

```dart
StripeDisputesList(
  onLoaded: () => print('Disputes loaded'),
  onLoadError: (error) => print('Error: $error'),
)
```

### 3. Customize Appearance (Optional)

```dart
StripeAccountOnboarding(
  appearance: ConnectAppearance(
    fontFamily: 'Roboto',
    cornerRadius: 12.0,
    colors: ConnectColors(
      primary: '#635BFF',
      background: '#FFFFFF',
      text: '#1A1A1A',
    ),
  ),
)
```

## Server-Side Setup

To use Stripe Connect embedded components, you need to create an Account Session on your server. Here's an example using Node.js:

```javascript
const stripe = require('stripe')('sk_test_...');

app.post('/create-account-session', async (req, res) => {
  const accountSession = await stripe.accountSessions.create({
    account: 'acct_...', // Connected account ID
    components: {
      account_onboarding: { enabled: true },
      account_management: { enabled: true },
      payments: { 
        enabled: true,
        features: {
          refund_management: true,
          dispute_management: true,
          capture_payments: true,
        }
      },
      payouts: { 
        enabled: true,
        features: {
          instant_payouts: true,
          standard_payouts: true,
        }
      },
      balances: { enabled: true },
      tax_settings: { enabled: true },
      tax_registrations: { enabled: true },
      documents: { enabled: true },
      notification_banner: { enabled: true },
    },
  });
  
  res.json({ client_secret: accountSession.client_secret });
});
```

## Requirements

- Flutter SDK `>=3.10.0`
- Dart SDK `>=3.0.0 <4.0.0`
- Android: `minSdk 21`
- iOS: `iOS 15.0+`
- Web: Modern browsers (Chrome, Firefox, Safari, Edge)

## License

MIT License - see [LICENSE](LICENSE) for details.

