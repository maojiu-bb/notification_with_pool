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

        eventChannel.setStreamHandler(NotificationEventStream())
    }

    public func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {

        switch call.method {
        case MethodKeys.initilize:
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

            NotificationManager.shared.initilize(
                contentPool: notificationContents
            )

            result(true)

        case MethodKeys.createScheduledNotificationWithContentPool:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let scheduledTime = args["scheduledTime"] as? Double,
                let intervalSeconds = args["interval"] as? Int
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.createScheduledNotificationWithContentPool(
                identifier: identifier,
                scheduledTime: Date(timeIntervalSince1970: scheduledTime),
                interval: TimeInterval(intervalSeconds)
            )

            result(true)

        case MethodKeys.createNotificationWithContentPool:
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

        case MethodKeys.createNotification:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let contentJson = args["content"] as? [String: Any],
                let content = NotificationContent.fromJson(json: contentJson)
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.createNotification(
                identifier: identifier,
                content: content
            )

            result(true)

        case MethodKeys.createScheduledNotification:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let contentJson = args["content"] as? [String: Any],
                let scheduledTime = args["scheduledTime"] as? Double,
                let intervalSeconds = args["interval"] as? Int,
                let content = NotificationContent.fromJson(json: contentJson)
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.createScheduledNotification(
                identifier: identifier,
                content: content,
                scheduledTime: Date(timeIntervalSince1970: scheduledTime),
                interval: TimeInterval(intervalSeconds)
            )

            result(true)

        case MethodKeys.updateContentPool:
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

        case MethodKeys.updateScheduled:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String,
                let scheduledTime = args["scheduledTime"] as? Double,
                let intervalSeconds = args["interval"] as? Int
            else {
                result(self.invalidArgs())
                return
            }

            NotificationManager.shared.updateScheduled(
                identifier: identifier,
                scheduledTime: Date(timeIntervalSince1970: scheduledTime),
                interval: TimeInterval(intervalSeconds)
            )

            result(true)

        case MethodKeys.cancel:
            guard
                let args = call.arguments as? [String: Any],
                let identifier = args["identifier"] as? String
            else {
                result(self.invalidArgs("identifier"))
                return
            }

            NotificationManager.shared.cancel(identifier: identifier)
            result(true)

        case MethodKeys.cancelAll:
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
