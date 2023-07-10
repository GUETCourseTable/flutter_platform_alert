package net.zonble.flutter_platform_alert

import android.app.Activity
import android.app.AlertDialog
import android.content.Context
import android.graphics.Bitmap
import android.graphics.BitmapFactory
import android.graphics.drawable.BitmapDrawable
import android.graphics.drawable.Drawable
import android.media.RingtoneManager
import android.os.Build
import android.util.Base64
import androidx.annotation.NonNull
import androidx.annotation.RequiresApi
import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.embedding.engine.plugins.activity.ActivityAware
import io.flutter.embedding.engine.plugins.activity.ActivityPluginBinding
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

class FlutterPlatformAlertPlugin : FlutterPlugin, MethodCallHandler, ActivityAware {
  private var activity: Activity? = null
  private var context: Context? = null
  private lateinit var channel: MethodChannel

  @Suppress("UNCHECKED_CAST")
  @RequiresApi(Build.VERSION_CODES.N)
  override fun onMethodCall(@NonNull call: MethodCall, @NonNull result: Result): Unit =
    when (call.method) {
      "playAlertSound" -> {
        val notification = RingtoneManager.getDefaultUri(RingtoneManager.TYPE_NOTIFICATION)
        val ringTone =
          RingtoneManager.getRingtone(this.context, notification)
        ringTone.play()
        result.success(null)
      }

      "showAlert" -> {
        val args = call.arguments as? HashMap<String, *>
        if (args == null) {
          result.error("No args", "Args is a null object.", "")
        } else {
          val windowTitle = args.get("windowTitle") as? String ?: ""
          val text = args.get("text") as? String ?: ""
          val alertStyle = args.get("alertStyle") as? String ?: "ok"
          val isDismissible = args.get("isDismissible") as? Boolean ?: true

          var hasReturned = false

          AlertDialog.Builder(
            this.activity,
            R.style.AlertDialogCustom
          )
            .setTitle(windowTitle)
            .setMessage(text).apply {
              when (alertStyle) {
                "abortRetryIgnore" ->
                  setPositiveButton(R.string.retry) { _, _ ->
                    result.success("retry")
                    hasReturned = true
                  }
                    .setNeutralButton(R.string.ignore) { _, _ ->
                      result.success("ignore")
                      hasReturned = true
                    }
                    .setNegativeButton(R.string.abort) { _, _ ->
                      result.success("abort")
                      hasReturned = true
                    }

                "cancelTryContinue" ->
                  setPositiveButton(R.string.try_again) { _, _ ->
                    result.success("try_again")
                    hasReturned = true
                  }
                    .setNeutralButton(R.string.continue_button) { _, _ ->
                      result.success("continue")
                      hasReturned = true
                    }
                    .setNegativeButton(R.string.cancel) { _, _ ->
                      result.success("cancel")
                      hasReturned = true
                    }

                "okCancel" ->
                  setPositiveButton(R.string.ok) { _, _ ->
                    result.success("ok")
                    hasReturned = true
                  }
                    .setNegativeButton(R.string.cancel) { _, _ ->
                      result.success("cancel")
                      hasReturned = true
                    }

                "retryCancel" ->
                  setPositiveButton(R.string.retry) { _, _ ->
                    result.success("retry")
                    hasReturned = true
                  }
                    .setNegativeButton(R.string.cancel) { _, _ ->
                      result.success("cancel")
                      hasReturned = true
                    }

                "yesNo" ->
                  setPositiveButton(R.string.yes) { _, _ ->
                    result.success("yes")
                    hasReturned = true
                  }
                    .setNegativeButton(R.string.no) { _, _ ->
                      result.success("no")
                      hasReturned = true
                    }

                "yesNoCancel" ->
                  setPositiveButton(R.string.yes) { _, _ ->
                    result.success("yes")
                    hasReturned = true
                  }
                    .setNeutralButton(R.string.cancel) { _, _ ->
                      result.success("cancel")
                      hasReturned = true
                    }
                    .setNegativeButton(R.string.no) { _, _ ->
                      result.success("no")
                      hasReturned = true
                    }

                else -> setPositiveButton(R.string.ok) { _, _ ->
                  result.success("ok")
                  hasReturned = true
                }
              }
            }
            .setCancelable(isDismissible)
            .create()
            .apply {
              setOnDismissListener {
                if (!hasReturned) {
                  when (alertStyle) {
                    "abortRetryIgnore" -> result.success("ignore")
                    "cancelTryContinue" -> result.success("cancel")
                    "okCancel" -> result.success("cancel")
                    "retryCancel" -> result.success("cancel")
                    "yesNoCancel" -> result.success("cancel")
                    "yesNo" -> result.success("no")
                    else -> result.success("ok")
                  }
                }
              }
            }
            .show()
        }
      }

      "showCustomAlert" -> {
        val args = call.arguments as? HashMap<String, *>
        if (args == null) {
          result.error("No args", "Args is a null object.", "")
        } else {
          val windowTitle = args.get("windowTitle") as? String ?: ""
          val text = args.get("text") as? String ?: ""
          val positiveButtonTitle = args.get("positiveButtonTitle") as? String ?: ""
          val negativeButtonTitle = args.get("negativeButtonTitle") as? String ?: ""
          val neutralButtonTitle = args.get("neutralButtonTitle") as? String ?: ""
          val base64Icon = args.get("base64Icon") as? String ?: ""
          val isDismissible = args.get("isDismissible") as? Boolean ?: true

          val builder = AlertDialog.Builder(
            this.activity,
            R.style.AlertDialogCustom
          )
            .setTitle(windowTitle)
            .setMessage(text)
            .setCancelable(isDismissible)

          var hasReturned = false

          var buttonCount = 0
          if (positiveButtonTitle.isNotEmpty()) {
            builder.setPositiveButton(positiveButtonTitle) { _, _ ->
              result.success("positive_button")
              hasReturned = true
            }
            buttonCount += 1
          }
          if (negativeButtonTitle.isNotEmpty()) {
            builder.setNegativeButton(negativeButtonTitle) { _, _ ->
              result.success("negative_button")
              hasReturned = true
            }
            buttonCount += 1
          }
          if (negativeButtonTitle.isNotEmpty()) {
            builder.setNeutralButton(neutralButtonTitle) { _, _ ->
              result.success("neutral_button")
              hasReturned = true
            }
            buttonCount += 1
          }
          if (buttonCount == 0) {
            builder.setPositiveButton("OK") { _, _ ->
              result.success("other")
              hasReturned = true
            }
            buttonCount += 1
          }

          if (base64Icon.isNotEmpty()) {
            val decodedString = Base64.decode(base64Icon, Base64.DEFAULT)
            val decodedByte: Bitmap = BitmapFactory.decodeByteArray(decodedString, 0, decodedString.size)
            val icon: Drawable = BitmapDrawable(activity?.resources, decodedByte)
            builder.setIcon(icon)
          }

          builder.create()
            .apply {
              setOnDismissListener {
                if (!hasReturned) {
                  result.success("other")
                }
              }
            }
            .show()
        }
      }

      else -> result.notImplemented()
    }

  override fun onAttachedToEngine(@NonNull flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_platform_alert")
    channel.setMethodCallHandler(this)
    context = flutterPluginBinding.applicationContext
  }


  override fun onDetachedFromEngine(@NonNull binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
    context = null
  }

  //region ActivityAware

  override fun onAttachedToActivity(binding: ActivityPluginBinding) {
    activity = binding.activity
  }

  override fun onDetachedFromActivityForConfigChanges() {
  }

  override fun onReattachedToActivityForConfigChanges(binding: ActivityPluginBinding) {
  }

  override fun onDetachedFromActivity() {
  }

  //endregion
}
