//
//  NotificationEventStream.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/01/27.
//

import Flutter

class NotificationEventStream: NSObject, FlutterStreamHandler, NotificationEventListener {

    private var eventSink: FlutterEventSink?

    func onListen(
        withArguments arguments: Any?,
        eventSink events: @escaping FlutterEventSink
    ) -> FlutterError? {
        self.eventSink = events
        NotificationManager.shared.addListener(self)
        return nil
    }

    func onCancel(withArguments arguments: Any?) -> FlutterError? {
        NotificationManager.shared.removeListener(self)
        eventSink = nil
        return nil
    }

    func onNotificationEvent(_ event: NotificationEvent) {
        guard let sink = eventSink else { return }

        switch event {
        case .scheduled(let id):
            sink([
                "type": "scheduled",
                "identifier": id
            ])

        case .delivered(let id):
            sink([
                "type": "delivered",
                "identifier": id
            ])

        case .opened(let id):
            sink([
                "type": "opened",
                "identifier": id
            ])
        }
    }
}
