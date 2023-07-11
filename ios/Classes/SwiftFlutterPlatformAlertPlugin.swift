import Flutter
import UIKit
import AVFoundation

fileprivate enum AlerButton: String {
    case abortButton = "abort"
    case cancelButton = "cancel"
    case continueButton = "continue"
    case ignoreButton = "ignore"
    case noButton = "no"
    case okButton = "ok"
    case retryButton = "retry"
    case tryAgainButton = "try_again"
    case yesButton = "yes"
}

fileprivate enum CustomAlertButton: String {
    case positiveButton = "positive_button"
    case negativeButton = "negative_button"
    case neutralButton = "neutral_button"
    case other = "other"
}

fileprivate enum FlutterPlatformAlertStyle: String {
    case abortRetryIgnore
    case cancelTryContinue
    case ok
    case okCancel
    case retryCancel
    case yesNo
    case yesNoCancel

    var buttons: [String] {
        switch self {
        case .abortRetryIgnore:
            return [NSLocalizedString("Abort", comment: ""),
                    NSLocalizedString("Retry", comment: ""),
                    NSLocalizedString("Ignore", comment: "")]
        case .cancelTryContinue:
            return [NSLocalizedString("Cancel", comment: ""),
                    NSLocalizedString("Try Again", comment: ""),
                    NSLocalizedString("Continue", comment: "")]
        case .ok:
            return [NSLocalizedString("OK", comment: "")]
        case .okCancel:
            return [NSLocalizedString("OK", comment: ""),
                    NSLocalizedString("Cancel", comment: "")]
        case .retryCancel:
            return [NSLocalizedString("Retry", comment: ""),
                    NSLocalizedString("Cancel", comment: "")]
        case .yesNo:
            return [NSLocalizedString("Yes", comment: ""),
                    NSLocalizedString("No", comment: "")]
        case .yesNoCancel:
            return [NSLocalizedString("Yes", comment: ""),
                    NSLocalizedString("No", comment: ""),
                    NSLocalizedString("Cancel", comment: ""),]
        }
    }

    func button(at index: Int) -> AlerButton {
        switch self {
        case .abortRetryIgnore:
            return [AlerButton.abortButton, AlerButton.retryButton, AlerButton.ignoreButton][index]
        case .cancelTryContinue:
            return [AlerButton.cancelButton, AlerButton.tryAgainButton, AlerButton.continueButton][index]
        case .ok:
            return AlerButton.okButton
        case .okCancel:
            return [AlerButton.okButton, AlerButton.cancelButton][index]
        case .retryCancel:
            return [AlerButton.retryButton, AlerButton.cancelButton][index]
        case .yesNo:
            return [AlerButton.yesButton, AlerButton.noButton][index]
        case .yesNoCancel:
            return [AlerButton.yesButton, AlerButton.noButton, AlerButton.cancelButton][index]
        }

    }
}

fileprivate enum FlutterPlatformIconStyle: String {
    case none
    case exclamation
    case warning
    case information
    case asterisk
    case question
    case stop
    case error
    case hand
}

public class SwiftFlutterPlatformAlertPlugin: NSObject, FlutterPlugin, UIGestureRecognizerDelegate {
    var isDismissible = true
    lazy var alertController = UIAlertController()
    var result: FlutterResult?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(name: "flutter_platform_alert", binaryMessenger: registrar.messenger())
        let instance = SwiftFlutterPlatformAlertPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
        self.result = result

        func style(forButtonTitle button:String) -> UIAlertAction.Style {
           switch button {
           case NSLocalizedString("Cancel", comment: ""):
               return .cancel
           case NSLocalizedString("Abort", comment: ""):
               return .destructive
           default:
               return .default
           }
        }

        switch call.method {
        case "playAlertSound":
            let systemSoundID: SystemSoundID = 4095
            AudioServicesPlaySystemSound(systemSoundID)
            result(true)

        case "showAlert":
            guard let root = UIApplication.shared.windows.first?.rootViewController else {
                result(FlutterError(code: "-101", message: "No root view", details: "The root view is nil"))
                return
            }
            guard let args = call.arguments as? [AnyHashable:Any] else {
                result(FlutterError(code: "-100", message: "No arguments", details: "The arguments object is nil"))
                return
            }

            isDismissible = args["isDismissible"] as? Bool ?? true
            let windowTitle = args["windowTitle"] as? String ?? ""
            let text = args["text"] as? String ?? ""
            let alertStyleString = args["alertStyle"] as? String ?? ""
            let alertStyle = FlutterPlatformAlertStyle(rawValue: alertStyleString) ?? FlutterPlatformAlertStyle.ok
            let buttons = alertStyle.buttons

            alertController = UIAlertController(title: windowTitle, message: text, preferredStyle: .alert)
            for i in 0..<buttons.count {
                let button = buttons[i]
                let buttonStyle = style(forButtonTitle: button)
                let action = UIAlertAction(title: button, style: buttonStyle) { action in
                    let actionResult = alertStyle.button(at: i)
                    result(actionResult.rawValue)
                }
                alertController.addAction(action)
            }
            root.present(alertController, animated: true) { [weak self] in
                if let self,
                   let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
                   let subviews = window.subviews.last?.subviews,
                   let backdropView = subviews.filter({ $0.frame.equalTo(window.frame) }).last {
                    backdropView.isUserInteractionEnabled = true
                    backdropView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDismiss(sender:))))
                }
            }

        case "showCustomAlert":
            guard let root = UIApplication.shared.windows.first?.rootViewController else {
                result(FlutterError(code: "-101", message: "No root view", details: "The root view is nil"))
                return
            }
            guard let args = call.arguments as? [AnyHashable:Any] else {
                result(FlutterError(code: "-100", message: "No arguments", details: "The arguments object is nil"))
                return
            }

            isDismissible = args["isDismissible"] as? Bool ?? true
            let windowTitle = args["windowTitle"] as? String ?? ""
            let text = args["text"] as? String ?? ""

            var actions = [UIAlertAction]()
            if let negativeButton = args["negativeButtonTitle"] as? String,
               negativeButton.isEmpty == false {
                let buttonStyle = style(forButtonTitle: negativeButton)
                actions.append(UIAlertAction(title: negativeButton, style: buttonStyle) { action in
                    result(CustomAlertButton.negativeButton.rawValue)
                })
            }
            if let neutralButton = args["neutralButtonTitle"] as? String,
               neutralButton.isEmpty == false {
                let buttonStyle = style(forButtonTitle: neutralButton)
                actions.append(UIAlertAction(title: neutralButton, style: buttonStyle) { action in
                    result(CustomAlertButton.neutralButton.rawValue)
                })
            }
            if let positiveButton = args["positiveButtonTitle"] as? String,
               positiveButton.isEmpty == false {
                let buttonStyle = style(forButtonTitle: positiveButton)
                actions.append(UIAlertAction(title: positiveButton, style: buttonStyle) { action in
                    result(CustomAlertButton.positiveButton.rawValue)
                })
            }
            let preferredStyle: UIAlertController.Style  = .alert
            alertController = UIAlertController(title: windowTitle, message: text, preferredStyle: preferredStyle)

            for action in actions {
                alertController.addAction(action)
            }
            root.present(alertController, animated: true) { [weak self] in
                if let self,
                   let window = UIApplication.shared.windows.filter({ $0.isKeyWindow }).first,
                   let subviews = window.subviews.last?.subviews,
                   let backdropView = subviews.filter({ $0.frame.equalTo(window.frame) }).last {
                    backdropView.isUserInteractionEnabled = true
                    backdropView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(self.handleDismiss(sender:))))
                }
            }


        default:
            result(FlutterMethodNotImplemented)
        }

    }

    @objc
    private func handleDismiss(sender: Any) {
        if isDismissible {
            alertController.dismiss(animated: true)
            result?(CustomAlertButton.other.rawValue)
        }
    }
}

