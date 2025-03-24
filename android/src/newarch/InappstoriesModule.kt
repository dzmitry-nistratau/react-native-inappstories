package com.inappstories

import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.Promise
import com.facebook.react.module.annotations.ReactModule

@ReactModule(name = InappstoriesModuleImpl.NAME)
class InappstoriesModule(reactContext: ReactApplicationContext) :
    NativeInappstoriesSpec(reactContext) {

    private val moduleImpl = InappstoriesModuleImpl(reactContext)

    override fun getName(): String {
        return InappstoriesModuleImpl.NAME
    }

    override fun callSomeNativeFunction(promise: Promise) {
        moduleImpl.callSomeNativeFunction(promise)
    }

    override fun addListener(eventName: String) {
        // Required for RN event emitter
    }

    override fun removeListeners(count: Double) {
        // Required for RN event emitter
    }
}