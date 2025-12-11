# flutter_stripe_connect

A Flutter plugin for Stripe Connect embedded components. Easily integrate account onboarding, account management, payouts, and payments UI into your Flutter app.

[![pub package](https://img.shields.io/pub/v/flutter_stripe_connect.svg)](https://pub.dev/packages/flutter_stripe_connect)
[![License: MIT](https://img.shields.io/badge/License-MIT-blue.svg)](https://opensource.org/licenses/MIT)

## Features

- **Account Onboarding** - Collect connected account information with a pre-built UI
- **Account Management** - Let connected accounts manage their account settings
- **Payouts** - Display payout history and status for connected accounts
- **Payments** - Show payment history for connected accounts
- **Customizable Appearance** - Configure colors, fonts, and corner radius

## Platform Support

| Android | iOS |
|:-------:|:---:|
|    ✅    |  ✅  |

### Platform-Specific Limitations

| Component | Android | iOS |
|-----------|:-------:|:---:|
| Account Onboarding | ✅ | ✅ |
| Account Management | ❌ | ✅ |
| Payouts | ✅ | ✅ |
| Payments | ✅ | ✅ |

> **Note**: Account Management is not available in the Stripe Connect Android SDK. It works on iOS and Web only.

## Android Setup

**Important**: Your `MainActivity` must extend `FlutterFragmentActivity` (not `FlutterActivity`) for the Stripe Connect components to work properly.

Update your `android/app/src/main/kotlin/.../MainActivity.kt`:

```kotlin
package com.example.yourapp

import io.flutter.embedding.android.FlutterFragmentActivity

class MainActivity : FlutterFragmentActivity()
```

## Installation

Add `flutter_stripe_connect` to your `pubspec.yaml`:

```yaml
dependencies:
  flutter_stripe_connect: ^0.0.1
```

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

#### Payouts

```dart
StripePayouts(
  onLoaded: () => print('Payouts loaded'),
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
      payouts: { enabled: true },
      payments: { enabled: true },
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

## License

MIT License - see [LICENSE](LICENSE) for details.
