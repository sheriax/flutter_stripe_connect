import Flutter
import UIKit
import StripeConnect
@_spi(STP) import StripeCore
@_spi(PreviewConnect) import StripeConnect
@_spi(DashboardOnly) import StripeConnect

public class FlutterStripeConnectPlugin: NSObject, FlutterPlugin, AccountOnboardingControllerDelegate {
    private static var channel: FlutterMethodChannel?
    private static var embeddedComponentManager: EmbeddedComponentManager?
    private static weak var registrar: FlutterPluginRegistrar?
    private var accountOnboardingController: AccountOnboardingController?
    
    public static func register(with registrar: FlutterPluginRegistrar) {
        self.registrar = registrar
        channel = FlutterMethodChannel(
            name: "flutter_stripe_connect",
            binaryMessenger: registrar.messenger()
        )
        
        let instance = FlutterStripeConnectPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel!)
        
        // Register the platform view factory
        let factory = StripeConnectViewFactory(
            messenger: registrar.messenger(),
            plugin: instance
        )
        registrar.register(factory, withId: "flutter_stripe_connect_view")
    }
    
    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        switch call.method {
        case "initialize":
            handleInitialize(call, result: result)
        case "logout":
            handleLogout(result: result)
        case "presentAccountOnboarding":
            handlePresentAccountOnboarding(result: result)
        default:
            result(FlutterMethodNotImplemented)
        }
    }
    
    private func handleInitialize(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        guard let args = call.arguments as? [String: Any],
              let publishableKey = args["publishableKey"] as? String else {
            result(FlutterError(code: "INVALID_ARGS", message: "Missing publishableKey", details: nil))
            return
        }
        
        // Configure the Stripe API client with the publishable key
        STPAPIClient.shared.publishableKey = publishableKey
        
        // Create the embedded component manager
        FlutterStripeConnectPlugin.embeddedComponentManager = EmbeddedComponentManager(
            fetchClientSecret: { [weak self] in
                await self?.fetchClientSecret()
            }
        )
        result(nil)
    }
    
    private func handleLogout(result: @escaping FlutterResult) {
        FlutterStripeConnectPlugin.embeddedComponentManager = nil
        result(nil)
    }
    
    private func fetchClientSecret() async -> String? {
        return await withCheckedContinuation { continuation in
            DispatchQueue.main.async {
                FlutterStripeConnectPlugin.channel?.invokeMethod("fetchClientSecret", arguments: nil) { response in
                    if let secret = response as? String {
                        continuation.resume(returning: secret)
                    } else {
                        continuation.resume(returning: nil)
                    }
                }
            }
        }
    }
    
    static func getEmbeddedComponentManager() -> EmbeddedComponentManager? {
        return embeddedComponentManager
    }
    
    static func getTopViewController() -> UIViewController? {
        guard let window = UIApplication.shared.connectedScenes
            .compactMap({ $0 as? UIWindowScene })
            .flatMap({ $0.windows })
            .first(where: { $0.isKeyWindow }) else {
            return nil
        }
        
        var topController = window.rootViewController
        while let presentedController = topController?.presentedViewController {
            topController = presentedController
        }
        return topController
    }
    
    private func handlePresentAccountOnboarding(result: @escaping FlutterResult) {
        guard let manager = FlutterStripeConnectPlugin.embeddedComponentManager else {
            result(FlutterError(code: "NOT_INITIALIZED", message: "EmbeddedComponentManager not initialized. Call StripeConnect.initialize() first.", details: nil))
            return
        }
        
        guard let topVC = FlutterStripeConnectPlugin.getTopViewController() else {
            result(FlutterError(code: "NO_VIEW_CONTROLLER", message: "Could not find top view controller", details: nil))
            return
        }
        
        let controller = manager.createAccountOnboardingController()
        controller.delegate = self
        self.accountOnboardingController = controller
        controller.present(from: topVC)
        result(nil)
    }
    
    // MARK: - AccountOnboardingControllerDelegate (for presentAccountOnboarding)
    public func accountOnboarding(_ accountOnboarding: AccountOnboardingController, didFailLoadWithError error: Error) {
        FlutterStripeConnectPlugin.channel?.invokeMethod("onAccountOnboardingLoadError", arguments: error.localizedDescription)
    }
    
    public func accountOnboardingDidExit(_ accountOnboarding: AccountOnboardingController) {
        FlutterStripeConnectPlugin.channel?.invokeMethod("onAccountOnboardingExit", arguments: nil)
    }
}

// MARK: - Platform View Factory
class StripeConnectViewFactory: NSObject, FlutterPlatformViewFactory {
    private let messenger: FlutterBinaryMessenger
    private weak var plugin: FlutterStripeConnectPlugin?
    
    init(messenger: FlutterBinaryMessenger, plugin: FlutterStripeConnectPlugin) {
        self.messenger = messenger
        self.plugin = plugin
        super.init()
    }
    
    func create(
        withFrame frame: CGRect,
        viewIdentifier viewId: Int64,
        arguments args: Any?
    ) -> FlutterPlatformView {
        return StripeConnectPlatformView(
            frame: frame,
            viewId: viewId,
            args: args as? [String: Any] ?? [:],
            messenger: messenger
        )
    }
    
    func createArgsCodec() -> FlutterMessageCodec & NSObjectProtocol {
        return FlutterStandardMessageCodec.sharedInstance()
    }
}

// MARK: - Platform View
class StripeConnectPlatformView: NSObject, FlutterPlatformView {
    private let containerView: UIView
    private let channel: FlutterMethodChannel
    private var componentController: UIViewController?
    private var accountOnboardingController: AccountOnboardingController?
    private var loadingView: UIActivityIndicatorView?
    
    init(frame: CGRect, viewId: Int64, args: [String: Any], messenger: FlutterBinaryMessenger) {
        containerView = UIView(frame: frame)
        containerView.backgroundColor = .systemBackground
        
        let componentType = args["componentType"] as? String ?? ""
        channel = FlutterMethodChannel(
            name: "flutter_stripe_connect/\(componentType)_\(viewId)",
            binaryMessenger: messenger
        )
        
        super.init()
        
        // Show loading indicator while component loads
        showLoading()
        
        setupComponent(type: componentType, args: args)
    }
    
    func view() -> UIView {
        return containerView
    }
    
    private func showLoading() {
        let indicator = UIActivityIndicatorView(style: .large)
        indicator.center = CGPoint(x: containerView.bounds.midX, y: containerView.bounds.midY)
        indicator.autoresizingMask = [.flexibleLeftMargin, .flexibleRightMargin, .flexibleTopMargin, .flexibleBottomMargin]
        indicator.startAnimating()
        containerView.addSubview(indicator)
        loadingView = indicator
    }
    
    private func hideLoading() {
        loadingView?.stopAnimating()
        loadingView?.removeFromSuperview()
        loadingView = nil
    }
    
    private func setupComponent(type: String, args: [String: Any]) {
        guard let manager = FlutterStripeConnectPlugin.getEmbeddedComponentManager() else {
            hideLoading()
            channel.invokeMethod("onLoadError", arguments: "EmbeddedComponentManager not initialized. Call StripeConnect.initialize() first.")
            return
        }
        
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            
            switch type {
            case "stripe_account_onboarding":
                self.setupOnboarding(manager: manager)
                
            case "stripe_account_management":
                self.setupAccountManagement(manager: manager)
                
            case "stripe_payouts":
                self.setupPayouts(manager: manager)
                
            case "stripe_payments":
                self.setupPayments(manager: manager)
                
            default:
                self.hideLoading()
                self.channel.invokeMethod("onLoadError", arguments: "Unknown component type: \(type)")
            }
        }
    }
    
    private func setupOnboarding(manager: EmbeddedComponentManager) {
        hideLoading()
        
        let controller = manager.createAccountOnboardingController()
        controller.delegate = self
        self.accountOnboardingController = controller
        
        // Create a button to present the onboarding flow
        let button = UIButton(type: .system)
        button.setTitle("Start Account Onboarding", for: .normal)
        button.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .semibold)
        button.backgroundColor = UIColor.systemBlue
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.translatesAutoresizingMaskIntoConstraints = false
        button.addTarget(self, action: #selector(presentOnboarding), for: .touchUpInside)
        
        containerView.addSubview(button)
        NSLayoutConstraint.activate([
            button.centerXAnchor.constraint(equalTo: containerView.centerXAnchor),
            button.centerYAnchor.constraint(equalTo: containerView.centerYAnchor),
            button.widthAnchor.constraint(equalToConstant: 250),
            button.heightAnchor.constraint(equalToConstant: 50)
        ])
        
        channel.invokeMethod("onLoaded", arguments: nil)
    }
    
    @objc private func presentOnboarding() {
        guard let controller = accountOnboardingController,
              let topVC = FlutterStripeConnectPlugin.getTopViewController() else {
            return
        }
        controller.present(from: topVC)
    }
    
    private func setupAccountManagement(manager: EmbeddedComponentManager) {
        let controller = manager.createAccountManagementViewController()
        controller.delegate = self
        self.componentController = controller
        embedViewController(controller)
        channel.invokeMethod("onLoaded", arguments: nil)
    }
    
    private func setupPayouts(manager: EmbeddedComponentManager) {
        let controller = manager.createPayoutsViewController()
        controller.delegate = self
        self.componentController = controller
        embedViewController(controller)
        channel.invokeMethod("onLoaded", arguments: nil)
    }
    
    private func setupPayments(manager: EmbeddedComponentManager) {
        let controller = manager.createPaymentsViewController()
        controller.delegate = self
        self.componentController = controller
        embedViewController(controller)
        channel.invokeMethod("onLoaded", arguments: nil)
    }
    
    private func embedViewController(_ controller: UIViewController) {
        hideLoading()
        controller.view.frame = containerView.bounds
        controller.view.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        containerView.addSubview(controller.view)
    }
}

// MARK: - Delegate Extensions
extension StripeConnectPlatformView: AccountOnboardingControllerDelegate {
    func accountOnboarding(_ accountOnboarding: AccountOnboardingController, didFailLoadWithError error: Error) {
        channel.invokeMethod("onLoadError", arguments: error.localizedDescription)
    }
    
    func accountOnboardingDidExit(_ accountOnboarding: AccountOnboardingController) {
        channel.invokeMethod("onExit", arguments: nil)
    }
}

extension StripeConnectPlatformView: AccountManagementViewControllerDelegate {
    func accountManagement(_ accountManagement: AccountManagementViewController, didFailLoadWithError error: Error) {
        hideLoading()
        channel.invokeMethod("onLoadError", arguments: error.localizedDescription)
    }
}

extension StripeConnectPlatformView: PayoutsViewControllerDelegate {
    func payouts(_ payouts: PayoutsViewController, didFailLoadWithError error: Error) {
        hideLoading()
        channel.invokeMethod("onLoadError", arguments: error.localizedDescription)
    }
}

extension StripeConnectPlatformView: PaymentsViewControllerDelegate {
    func payments(_ payments: PaymentsViewController, didFailLoadWithError error: Error) {
        hideLoading()
        channel.invokeMethod("onLoadError", arguments: error.localizedDescription)
    }
}