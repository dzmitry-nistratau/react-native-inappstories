package com.blazeapp.android.main.home

import android.content.Context
import android.graphics.Color
import android.os.Handler
import android.os.Looper
import android.util.AttributeSet
import android.view.Gravity
import android.widget.FrameLayout
import android.widget.ProgressBar
import android.widget.TextView
import androidx.annotation.ColorInt

class SomeNativeView @JvmOverloads constructor(
    context: Context, attrs: AttributeSet? = null, defStyleAttr: Int = 0
) : FrameLayout(context, attrs, defStyleAttr) {

    sealed class State {
        object Initial : State()
        object Loading : State()
        data class Loaded(@ColorInt val color: Int) : State()
    }

    private var state: State = State.Initial
        set(value) {
            field = value
            updateUI()
            delegate?.someNativeView(this, state)
        }

    private val activityIndicator: ProgressBar = ProgressBar(context).apply {
        isIndeterminate = true
        visibility = GONE
    }

    private val loadedLabel: TextView = TextView(context).apply {
        text = "Loaded"
        setTextColor(Color.BLACK)
        textSize = 18f
        gravity = Gravity.CENTER
        visibility = GONE
    }

    var delegate: SomeNativeViewDelegate? = null

    init {
        setupUI()
    }

    private fun setupUI() {
        setBackgroundColor(Color.TRANSPARENT)
        addView(activityIndicator)
        addView(loadedLabel)

        // LayoutParams for centering the views
        val params = LayoutParams(LayoutParams.WRAP_CONTENT, LayoutParams.WRAP_CONTENT).apply {
            gravity = Gravity.CENTER
        }
        activityIndicator.layoutParams = params
        loadedLabel.layoutParams = params

        updateUI()
    }

    fun load(@ColorInt color: Int? = null) {
        if (state == State.Loading) return

        state = State.Loading

        // Simulate async loading
        Handler(Looper.getMainLooper()).postDelayed({
            state = State.Loaded(color = color ?: Color.BLUE)
        }, 2000)  // Simulate delay of 2 seconds
    }

    private fun updateUI() {
      android.util.Log.d("SomeNativeView", "updateUI called with state: $state, view size: ${width}x${height}")

      when (val state = state) {
        State.Initial -> {
          setBackgroundColor(Color.TRANSPARENT)
          activityIndicator.visibility = GONE
          loadedLabel.visibility = GONE
          android.util.Log.d("SomeNativeView", "Initial state set")
        }
        State.Loading -> {
          setBackgroundColor(Color.LTGRAY)
          activityIndicator.visibility = VISIBLE
          loadedLabel.visibility = GONE
          android.util.Log.d("SomeNativeView", "Loading state set, indicator visible=${activityIndicator.visibility == VISIBLE}")
        }
        is State.Loaded -> {
          setBackgroundColor(state.color)
          activityIndicator.visibility = GONE
          loadedLabel.visibility = VISIBLE
          android.util.Log.d("SomeNativeView", "Loaded state set with color ${state.color}")
        }
      }
    }

    interface SomeNativeViewDelegate {
        fun someNativeView(view: SomeNativeView, didChangeState: State)
    }
}
