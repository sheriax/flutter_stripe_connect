Pod::Spec.new do |s|
  s.name             = 'flutter_stripe_connect'
  s.version          = '0.0.1'
  s.summary          = 'Flutter plugin for Stripe Connect embedded components'
  s.description      = <<-DESC
A Flutter plugin that wraps the native Stripe Connect SDKs for iOS and Android,
providing embedded components for account onboarding, management, and payouts.
                       DESC
  s.homepage         = 'https://github.com/your-org/flutter_stripe_connect'
  s.license          = { :file => '../LICENSE' }
  s.author           = { 'Your Company' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency 'Flutter'
  s.dependency 'StripeConnect', '~> 24.0'
  s.platform         = :ios, '15.0'
  s.swift_version    = '5.0'

  # Flutter.framework does not contain a i386 slice.
  s.pod_target_xcconfig = { 'DEFINES_MODULE' => 'YES', 'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'i386' }
end