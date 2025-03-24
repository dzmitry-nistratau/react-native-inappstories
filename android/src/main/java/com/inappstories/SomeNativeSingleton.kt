package com.blazeapp.android.main.home

import kotlinx.coroutines.DelicateCoroutinesApi
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.GlobalScope
import kotlinx.coroutines.delay
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

object SomeNativeSingleton {

    interface Delegate {
        fun someDelegateFunction()
    }

    var delegate: Delegate? = null

    @OptIn(DelicateCoroutinesApi::class)
    fun someNativeFunction(completion: () -> Unit) {

        GlobalScope.launch(Dispatchers.IO) {
            delay(2000)  // Non-blocking delay for 2 seconds

            withContext(Dispatchers.Main) {
                // Calls the completion on the main thread.
                completion()

                // Report to delegate about this event as well.
                delegate?.someDelegateFunction()
            }
        }

    }

}