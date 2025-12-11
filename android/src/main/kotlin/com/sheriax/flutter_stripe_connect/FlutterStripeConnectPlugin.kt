package com.sheriax.flutter_stripe_connect

import android.content.Context
import android.view.View
import android.widget.FrameLayout
import android.widget.TextView
import android.graphics.Color
import androidx.fragment.app.FragmentActivity
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.StandardMessageCodec
import io.flutter.plugin.platform.PlatformView
import io.flutter.plugin.platform.PlatformViewFactory
import com.stripe.android.connect.EmbeddedComponentManager
import com.stripe.android.connect.AccountOnboardingController
import com.stripe.android.connect.AccountOnboardingProps
import com.stripe.android.connect.PaymentsListener
import com.stripe.android.connect.PayoutsListener
import com.stripe.android.connect.StripeComponentController
import com.stripe.android.connect.PreviewConnectSDK
import com.stripe.android.connect.appearance.Appearance
import kotlinx.coroutines.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

class FlutterStripeConnectPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: FragmentActivity? = null
    private var accountOnboardingController: AccountOnboardingController? = null
    
    companion object {
        var embeddedComponentManager: EmbeddedComponentManager? = null
            private set
        var pluginInstance: FlutterStripeConnectPlugin? = null
            private set
        var currentActivity: FragmentActivity? = null
            private set
    }

    override fun onAttachedToEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel = MethodChannel(binding.binaryMessenger, "flutter_stripe_connect")
        channel.setMethodCallHandler(this)
        context = binding.applicationContext
        pluginInstance = this
        
        // Register platform view factory
        binding.platformViewRegistry.registerViewFactory(
            "flutter_stripe_connect_view",
            StripeConnectViewFactory(binding.binaryMessenger)
        )
    }

    override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
        channel.setMethodCallHandler(null)
        pluginInstance = null
    }

    override fun onAttachedToActivity(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
        currentActivity = activity
        activity?.let { 
            EmbeddedComponentManager.onActivityCreate(it)
        }
    }

    override fun onDetachedFromActivity() {
        activity = null
        currentActivity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
        currentActivity = activity
        activity?.let {
            EmbeddedComponentManager.onActivityCreate(it)
        }
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
        currentActivity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "logout" -> handleLogout(result)
            "showAccountOnboarding" -> handleShowAccountOnboarding(result)
            else -> result.notImplemented()
        }
    }

    private fun handleInitialize(call: MethodCall, result: MethodChannel.Result) {
        val publishableKey = call.argument<String>("publishableKey")
        if (publishableKey == null) {
            result.error("INVALID_ARGS", "Missing publishableKey", null)
            return
        }

        try {
            embeddedComponentManager = EmbeddedComponentManager(
                publishableKey = publishableKey,
                fetchClientSecret = ::fetchClientSecretSuspend,
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun handleLogout(result: MethodChannel.Result) {
        embeddedComponentManager = null
        accountOnboardingController = null
        result.success(null)
    }
    
    private fun handleShowAccountOnboarding(result: MethodChannel.Result) {
        val manager = embeddedComponentManager
        val currentAct = activity
        
        if (manager == null) {
            result.error("NOT_INITIALIZED", "EmbeddedComponentManager not initialized", null)
            return
        }
        
        if (currentAct == null) {
            result.error("NO_ACTIVITY", "Activity not available", null)
            return
        }
        
        try {
            accountOnboardingController = manager.createAccountOnboardingController(
                activity = currentAct,
                title = "Account Onboarding",
                props = AccountOnboardingProps()
            )
            accountOnboardingController?.show()
            result.success(null)
        } catch (e: Exception) {
            result.error("SHOW_ERROR", e.message, null)
        }
    }
    
    private suspend fun fetchClientSecretSuspend(): String? = suspendCoroutine { continuation ->
        fetchClientSecretFromFlutter { secret ->
            continuation.resume(secret)
        }
    }

    fun fetchClientSecretFromFlutter(callback: (String?) -> Unit) {
        channel.invokeMethod("fetchClientSecret", null, object : MethodChannel.Result {
            override fun success(result: Any?) {
                callback(result as? String)
            }
            override fun error(code: String, msg: String?, details: Any?) {
                callback(null)
            }
            override fun notImplemented() {
                callback(null)
            }
        })
    }
}

// Platform View Factory
class StripeConnectViewFactory(
    private val messenger: io.flutter.plugin.common.BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any?> ?: emptyMap()
        return StripeConnectPlatformView(context, viewId, params, messenger)
    }
}

// Platform View Implementation
class StripeConnectPlatformView(
    private val context: Context,
    private val viewId: Int,
    private val params: Map<String, Any?>,
    messenger: io.flutter.plugin.common.BinaryMessenger
) : PlatformView {
    
    private val containerView: FrameLayout = FrameLayout(context)
    private val componentType = params["componentType"] as? String ?: ""
    private val channel = MethodChannel(
        messenger,
        "flutter_stripe_connect/${componentType}_$viewId"
    )
    
    init {
        setupComponent()
    }
    
    @OptIn(PreviewConnectSDK::class)
    private fun setupComponent() {
        val manager = FlutterStripeConnectPlugin.embeddedComponentManager
        if (manager == null) {
            channel.invokeMethod("onLoadError", "EmbeddedComponentManager not initialized")
            return
        }
        
        try {
            val componentView: View? = when (componentType) {
                "stripe_account_onboarding" -> {
                    // Account Onboarding uses a controller, not a view
                    // Show a placeholder and trigger the controller
                    val activity = FlutterStripeConnectPlugin.currentActivity
                    if (activity != null) {
                        val controller = manager.createAccountOnboardingController(
                            activity = activity,
                            title = "Account Onboarding",
                            props = AccountOnboardingProps()
                        ).apply {
                            onDismissListener = StripeComponentController.OnDismissListener {
                                channel.invokeMethod("onExit", null)
                            }
                        }
                        controller.show()
                        channel.invokeMethod("onLoaded", null)
                    }
                    // Return a placeholder view
                    createPlaceholderView("Account Onboarding will open in a modal")
                }
                "stripe_account_management" -> {
                    // Account Management is not available on Android SDK
                    channel.invokeMethod("onLoadError", "Account Management is not available on Android. Use iOS or Web instead.")
                    createPlaceholderView("Account Management is not available on Android")
                }
                "stripe_payouts" -> {
                    manager.createPayoutsView(
                        context = context,
                        listener = object : PayoutsListener {
                            override fun onLoadError(error: Throwable) {
                                channel.invokeMethod("onLoadError", error.message)
                            }
                        }
                    ).also {
                        channel.invokeMethod("onLoaded", null)
                    }
                }
                "stripe_payments" -> {
                    manager.createPaymentsView(
                        context = context,
                        listener = object : PaymentsListener {
                            override fun onLoadError(error: Throwable) {
                                channel.invokeMethod("onLoadError", error.message)
                            }
                        }
                    ).also {
                        channel.invokeMethod("onLoaded", null)
                    }
                }
                else -> {
                    channel.invokeMethod("onLoadError", "Unknown component type: $componentType")
                    null
                }
            }
            
            componentView?.let {
                containerView.addView(
                    it,
                    FrameLayout.LayoutParams(
                        FrameLayout.LayoutParams.MATCH_PARENT,
                        FrameLayout.LayoutParams.MATCH_PARENT
                    )
                )
            }
        } catch (e: Exception) {
            channel.invokeMethod("onLoadError", e.message)
        }
    }
    
    private fun createPlaceholderView(message: String): View {
        return TextView(context).apply {
            text = message
            textSize = 16f
            setTextColor(Color.GRAY)
            textAlignment = View.TEXT_ALIGNMENT_CENTER
            setPadding(32, 32, 32, 32)
        }
    }
    
    override fun getView(): View = containerView
    
    override fun dispose() {
        containerView.removeAllViews()
    }
}
