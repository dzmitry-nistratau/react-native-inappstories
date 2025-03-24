package com.inappstories

import android.graphics.Color
import android.view.View
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.bridge.ReadableArray
import com.facebook.react.common.MapBuilder
import com.facebook.react.module.annotations.ReactModule
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ThemedReactContext
import com.facebook.react.uimanager.UIManagerHelper
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.uimanager.annotations.ReactProp
import com.blazeapp.android.main.home.SomeNativeView

@ReactModule(name = InappstoriesViewManager.NAME)
class InappstoriesViewManager(
    private val reactContext: ReactApplicationContext
) : SimpleViewManager<SomeNativeView>(), SomeNativeView.SomeNativeViewDelegate {

    private val moduleImpl = InappstoriesModuleImpl(reactContext)

    override fun getName(): String {
        return NAME
    }

    override fun createViewInstance(reactContext: ThemedReactContext): SomeNativeView {
        return SomeNativeView(reactContext).apply {
            delegate = this@InappstoriesViewManager
        }
    }

    @ReactProp(name = "color")
    fun setColor(view: SomeNativeView, color: String?) {
        if (color != null) {
            try {
                view.setBackgroundColor(Color.parseColor(color))
            } catch (e: Exception) {
                // Default fallback color if parsing fails
                view.setBackgroundColor(Color.TRANSPARENT)
            }
        } else {
            view.setBackgroundColor(Color.TRANSPARENT)
        }
    }

    // Handle commands from JavaScript
    override fun getCommandsMap(): Map<String, Int>? {
        return MapBuilder.of("load", COMMAND_LOAD)
    }

    override fun receiveCommand(root: SomeNativeView, commandId: Int, args: ReadableArray?) {
        when (commandId) {
            COMMAND_LOAD -> {
                val colorStr = args?.getString(0)
                val color = if (colorStr != null) {
                    try {
                        Color.parseColor(colorStr)
                    } catch (e: Exception) {
                        null
                    }
                } else null

                root.load(color)
            }
        }
    }

    // SomeNativeViewDelegate implementation
    override fun someNativeView(view: SomeNativeView, didChangeState: SomeNativeView.State) {
        moduleImpl.handleViewStateChange(view, didChangeState)
    }

    companion object {
        const val NAME = "InappstoriesView"
        private const val COMMAND_LOAD = 1
    }
}
