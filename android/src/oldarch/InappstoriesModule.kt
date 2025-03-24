package com.inappstories

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReactContextBaseJavaModule
import com.facebook.react.bridge.ReactMethod
import com.facebook.react.bridge.Promise
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = InappstoriesModuleImpl.NAME)
class InappstoriesModule(context: ReactApplicationContext) :
    ReactContextBaseJavaModule(context) {

    private val moduleImpl = InappstoriesModuleImpl(context)

    override fun getName(): String {
        return InappstoriesModuleImpl.NAME
    }

    @ReactMethod
    fun callSomeNativeFunction(promise: Promise) {
        moduleImpl.callSomeNativeFunction(promise)
    }

    @ReactMethod
    fun addListener(eventName: String) {
        // Required for RN event emitter
    }

    @ReactMethod
    fun removeListeners(count: Int) {
        // Required for RN event emitter
    }
}
