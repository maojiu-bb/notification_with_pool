//
//  NotificationEvent.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/1/27.
//

import Foundation

enum NotificationEvent {

    case scheduled(identifier: String)

    case delivered(identifier: String)

    case opened(identifier: String)

}


extension NotificationEvent {

    func toMap() -> [String: Any] {
        switch self {
        case .scheduled(let identifier):
            return [
                "type": "scheduled",
                "identifier": identifier
            ]
        case .delivered(let identifier):
            return [
                "type": "delivered",
                "identifier": identifier
            ]
        case .opened(let identifier):
            return [
                "type": "opened",
                "identifier": identifier
            ]
        }
    }
}


protocol NotificationEventListener: AnyObject {
    func onNotificationEvent(_ event: NotificationEvent)
}
