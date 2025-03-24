package com.inappstories

import android.view.View
import com.facebook.react.bridge.ReactApplicationContext
import com.facebook.react.uimanager.SimpleViewManager
import com.facebook.react.uimanager.ViewManagerDelegate
import com.facebook.react.viewmanagers.InappstoriesViewManagerInterface
import com.facebook.react.viewmanagers.InappstoriesViewManagerDelegate

abstract class InappstoriesViewManagerSpec<T : View> : SimpleViewManager<T>(), 
    InappstoriesViewManagerInterface<T> {

    private val mDelegate: ViewManagerDelegate<T>

    init {
        mDelegate = InappstoriesViewManagerDelegate(this)
    }

    override fun getDelegate(): ViewManagerDelegate<T> {
        return mDelegate
    }

    abstract override fun setColor(view: T?, value: String?)
}
