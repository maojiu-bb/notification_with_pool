//
//  NotificationWithPoolPlugin.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/1/27.
//

import Flutter
import UIKit

public class NotificationWithPoolPlugin: NSObject, FlutterPlugin {

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "notification_with_pool",
            binaryMessenger: registrar.messenger()
        )

        let instance = NotificationWithPoolPlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)

        let eventChannel = FlutterEventChannel(
            name: "notification_with_pool/events",
            binaryMessenger: registrar.messenger()
        )

        eventChannel.setStreamHandler(NotificationEventStreamHandler())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case MethodKeys.INITIALIZE:
            guard let args = call.arguments as? [String: Any] else {
                result(self.invalidArgs())
                return
            }

            let contentPool = args["contentPool"] as? [[String: Any]] ?? []
            let notificationContents = contentPool.compactMap {
                NotificationContent.fromJson(json: $0)
            }

            let contents = notificationContents.isEmpty ? nil : notificationContents
            NotificationManager.shared.initialize(contentPool: contents)

            result(true)

        case MethodKeys.CREATE_DAILY_NOTIFICATION_WITH_CONTENT_POOL:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let hour = args["hour"] as? Int,
                let minute = args["minute"] as? Int,
                let second = args["second"] as? Int
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.createDailyNotificationWithContentPool(
                identifier: identifier,
                hour: hour,
                minute: minute,
                second: second
            )

            result(true)

        case MethodKeys.CREATE_NOTIFICATION_WITH_CONTENT_POOL:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.createNotificationWithContentPool(
                identifier: identifier
            )

            result(true)

        case MethodKeys.CREATE_DELAYED_NOTIFICATION_WITH_CONTENT_POOL:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let delaySeconds = args["delay"] as? Int
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.createDelayedNotificationWithContentPool(
                identifier: identifier,
                delay: TimeInterval(delaySeconds)
            )

            result(true)

        case MethodKeys.UPDATE_CONTENT_POOL:
            guard
                let args = call.arguments as? [String: Any],
                let contentPool = args["contentPool"] as? [[String: Any]]
            else {
                result(self.invalidArgs("contentPool"))
                return
            }

            let notificationContents = contentPool.compactMap {
                NotificationContent.fromJson(json: $0)
            }

            NotificationManager.shared.updateContentPool(
                contentPool: notificationContents
            )

            result(true)

        case MethodKeys.CANCEL:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String
            else {
                result(self.invalidArgs("identifier"))
                return
            }

            NotificationManager.shared.cancel(identifier: identifier)
            result(true)

        case MethodKeys.CANCEL_ALL:
            NotificationManager.shared.cancelAll()
            result(true)

        default:
            result(FlutterMethodNotImplemented)
        }
    }
}

private extension NotificationWithPoolPlugin {

    func invalidArgs(_ key: String? = nil) -> FlutterError {
        FlutterError(
            code: "INVALID_ARGUMENT",
            message: key != nil ? "\(key!) is required" : "Invalid arguments",
            details: nil
        )
    }
}
