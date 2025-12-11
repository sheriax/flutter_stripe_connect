package com.sheriax.flutter_stripe_connect

import android.content.Context
import android.view.View
import android.widget.FrameLayout
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
import com.stripe.android.connect.FetchClientSecretCallback
import com.stripe.android.connect.PrivateBetaConnectSDK
import com.stripe.android.connect.appearance.Appearance
import kotlinx.coroutines.*
import kotlin.coroutines.resume
import kotlin.coroutines.suspendCoroutine

@OptIn(PrivateBetaConnectSDK::class)
class FlutterStripeConnectPlugin : FlutterPlugin, MethodChannel.MethodCallHandler, ActivityAware {
    private lateinit var channel: MethodChannel
    private lateinit var context: Context
    private var activity: FragmentActivity? = null
    
    companion object {
        var embeddedComponentManager: EmbeddedComponentManager? = null
            private set
        var pluginInstance: FlutterStripeConnectPlugin? = null
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
    }

    override fun onDetachedFromActivity() {
        activity = null
    }

    override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
        activity = binding.activity as? FragmentActivity
    }

    override fun onDetachedFromActivityForConfigChanges() {
        activity = null
    }

    override fun onMethodCall(call: MethodCall, result: MethodChannel.Result) {
        when (call.method) {
            "initialize" -> handleInitialize(call, result)
            "logout" -> handleLogout(result)
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
                activity = activity ?: throw IllegalStateException("Activity not available"),
                publishableKey = publishableKey,
                fetchClientSecretCallback = object : FetchClientSecretCallback {
                    override fun fetchClientSecret(resultCallback: FetchClientSecretCallback.ClientSecretResultCallback) {
                        fetchClientSecretFromFlutter { secret ->
                            if (secret != null) {
                                resultCallback.onResult(secret)
                            } else {
                                resultCallback.onError()
                            }
                        }
                    }
                }
            )
            result.success(null)
        } catch (e: Exception) {
            result.error("INIT_ERROR", e.message, null)
        }
    }

    private fun handleLogout(result: MethodChannel.Result) {
        embeddedComponentManager?.logout()
        result.success(null)
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
@OptIn(PrivateBetaConnectSDK::class)
class StripeConnectViewFactory(
    private val messenger: io.flutter.plugin.common.BinaryMessenger
) : PlatformViewFactory(StandardMessageCodec.INSTANCE) {
    
    override fun create(context: Context, viewId: Int, args: Any?): PlatformView {
        val params = args as? Map<String, Any?> ?: emptyMap()
        return StripeConnectPlatformView(context, viewId, params, messenger)
    }
}

// Platform View Implementation
@OptIn(PrivateBetaConnectSDK::class)
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
    
    private fun setupComponent() {
        val manager = FlutterStripeConnectPlugin.embeddedComponentManager
        if (manager == null) {
            channel.invokeMethod("onLoadError", "EmbeddedComponentManager not initialized")
            return
        }
        
        try {
            val componentView: View = when (componentType) {
                "stripe_account_onboarding" -> {
                    manager.createAccountOnboardingView(
                        context = context,
                        listener = object : com.stripe.android.connect.AccountOnboardingListener {
                            override fun onExit() {
                                channel.invokeMethod("onExit", null)
                            }
                            override fun onLoadError(error: Throwable) {
                                channel.invokeMethod("onLoadError", error.message)
                            }
                            override fun onLoaded() {
                                channel.invokeMethod("onLoaded", null)
                            }
                        }
                    )
                }
                "stripe_account_management" -> {
                    manager.createAccountManagementView(
                        context = context,
                        listener = object : com.stripe.android.connect.AccountManagementListener {
                            override fun onLoadError(error: Throwable) {
                                channel.invokeMethod("onLoadError", error.message)
                            }
                            override fun onLoaded() {
                                channel.invokeMethod("onLoaded", null)
                            }
                        }
                    )
                }
                "stripe_payouts" -> {
                    manager.createPayoutsView(
                        context = context,
                        listener = object : com.stripe.android.connect.PayoutsListener {
                            override fun onLoadError(error: Throwable) {
                                channel.invokeMethod("onLoadError", error.message)
                            }
                            override fun onLoaded() {
                                channel.invokeMethod("onLoaded", null)
                            }
                        }
                    )
                }
                "stripe_payments" -> {
                    manager.createPaymentsView(
                        context = context,
                        listener = object : com.stripe.android.connect.PaymentsListener {
                            override fun onLoadError(error: Throwable) {
                                channel.invokeMethod("onLoadError", error.message)
                            }
                            override fun onLoaded() {
                                channel.invokeMethod("onLoaded", null)
                            }
                        }
                    )
                }
                else -> {
                    channel.invokeMethod("onLoadError", "Unknown component type: $componentType")
                    return
                }
            }
            
            containerView.addView(
                componentView,
                FrameLayout.LayoutParams(
                    FrameLayout.LayoutParams.MATCH_PARENT,
                    FrameLayout.LayoutParams.MATCH_PARENT
                )
            )
        } catch (e: Exception) {
            channel.invokeMethod("onLoadError", e.message)
        }
    }
    
    override fun getView(): View = containerView
    
    override fun dispose() {
        containerView.removeAllViews()
    }
}
