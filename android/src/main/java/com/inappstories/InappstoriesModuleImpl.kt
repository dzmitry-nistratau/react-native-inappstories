package com.inappstories

import android.graphics.Color
import android.util.Log
import com.facebook.react.bridge.Promise
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContext
import com.facebook.react.bridge.WritableMap
import com.facebook.react.bridge.WritableNativeMap
import com.facebook.react.modules.core.DeviceEventManagerModule
import com.blazeapp.android.main.home.SomeNativeSingleton
import com.blazeapp.android.main.home.SomeNativeView

class InappstoriesModuleImpl(private val reactContext: ReactApplicationContext) : SomeNativeSingleton.Delegate {

    companion object {
        const val NAME = "Inappstories"
    }

    init {
        // Register as delegate to the singleton
        SomeNativeSingleton.delegate = this
    }

    // Call the native singleton function
    fun callSomeNativeFunction(promise: Promise) {
        try {
            Log.d(NAME, "callSomeNativeFunction invoked from JavaScript")
            SomeNativeSingleton.someNativeFunction {
                Log.d(NAME, "Completion block called")
                promise.resolve(true)
            }
        } catch (e: Exception) {
            Log.e(NAME, "Error calling someNativeFunction", e)
            promise.reject("native_error", e.message, e)
        }
    }

    // Implementation of SomeNativeSingleton.Delegate
    override fun someDelegateFunction() {
        Log.d(NAME, "someDelegateFunction called")
        val params = WritableNativeMap().apply {
            putString("type", "someDelegateFunction")
        }
        sendEvent(reactContext, "someDelegateFunction", params)
    }

    // Helper method to send events to JavaScript
    fun sendEvent(reactContext: ReactContext, eventName: String, params: WritableMap) {
        try {
            Log.d(NAME, "Sending event $eventName with params $params")
            reactContext.getJSModule(DeviceEventManagerModule.RCTDeviceEventEmitter::class.java)
                .emit(eventName, params)
        } catch (e: Exception) {
            Log.e(NAME, "Error sending event $eventName", e)
        }
    }

    // Handle view state changes and forward them to JavaScript
    fun handleViewStateChange(view: SomeNativeView, state: SomeNativeView.State) {
        val viewTag = view.id

        val params = WritableNativeMap().apply {
            putInt("viewTag", viewTag)

            when (state) {
                is SomeNativeView.State.Initial -> {
                    putString("state", "initial")
                }
                is SomeNativeView.State.Loading -> {
                    putString("state", "loading")
                }
                is SomeNativeView.State.Loaded -> {
                    putString("state", "loaded")
                    val dataMap = WritableNativeMap().apply {
                        putString("color", String.format("#%06X", 0xFFFFFF and state.color))
                    }
                    putMap("data", dataMap)
                }
            }
        }

        sendEvent(reactContext, "nativeViewStateChange", params)
    }
}

