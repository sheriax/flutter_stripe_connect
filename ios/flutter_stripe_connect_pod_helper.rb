# This file is automatically detected by Flutter plugin system
# It adds the necessary configurations for flutter_stripe_connect to work properly

def flutter_stripe_connect_post_install(installer)
  installer.pods_project.targets.each do |target|
    # Enable module support for all pods to ensure StripeConnect modules work
    target.build_configurations.each do |config|
      config.build_settings['CLANG_ENABLE_MODULES'] = 'YES'
      
      # For StripeConnect and StripeCore targets
      if target.name.include?('Stripe')
        config.build_settings['BUILD_LIBRARY_FOR_DISTRIBUTION'] = 'YES'
      end
    end
  end
end

# If this file is required directly, extend Pod::Installer
module FlutterStripeConnectPodHelper
  def self.configure(installer)
    flutter_stripe_connect_post_install(installer)
  end
end
