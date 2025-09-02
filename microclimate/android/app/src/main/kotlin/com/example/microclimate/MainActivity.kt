package com.example.microclimate

import android.app.Activity
import android.content.Intent
import android.os.Bundle
import io.flutter.embedding.android.FlutterActivity
import io.flutter.plugin.common.MethodChannel
import android.speech.RecognizerIntent
import android.widget.Toast

class MainActivity : FlutterActivity() {
    private val CHANNEL = "speech.recognition"
    private val REQ_CODE_SPEECH_INPUT = 100
    private lateinit var speechResult: MethodChannel.Result

    override fun configureFlutterEngine(flutterEngine: io.flutter.embedding.engine.FlutterEngine) {
        super.configureFlutterEngine(flutterEngine)

        MethodChannel(flutterEngine.dartExecutor.binaryMessenger, CHANNEL).setMethodCallHandler {
            call, result ->
            if (call.method == "startListening") {
                speechResult = result
                val intent = Intent(RecognizerIntent.ACTION_RECOGNIZE_SPEECH)
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE_MODEL, RecognizerIntent.LANGUAGE_MODEL_FREE_FORM)
                intent.putExtra(RecognizerIntent.EXTRA_LANGUAGE, "en-IN")
                intent.putExtra(RecognizerIntent.EXTRA_PROMPT, "Speak a command")
                try {
                    startActivityForResult(intent, REQ_CODE_SPEECH_INPUT)
                } catch (e: Exception) {
                    result.error("SpeechError", "Speech recognition not available", null)
                }
            }
        }
    }

    override fun onActivityResult(requestCode: Int, resultCode: Int, data: Intent?) {
        super.onActivityResult(requestCode, resultCode, data)
        if (requestCode == REQ_CODE_SPEECH_INPUT && resultCode == Activity.RESULT_OK) {
            val results = data?.getStringArrayListExtra(RecognizerIntent.EXTRA_RESULTS)
            val spokenText = results?.get(0) ?: ""
            speechResult.success(spokenText)
        }
    }
}
