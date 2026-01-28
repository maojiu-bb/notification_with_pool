//
//  NotificationContent.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/1/27.
//

import Foundation

struct NotificationContent {
    let title: String
    let body: String
    let image: String?

    init(title: String, body: String, image: String?) {
        self.title = title
        self.body = body
        self.image = image
    }

    static func fromJson(json: [String: Any]) -> NotificationContent? {
        guard
            let title = json["title"] as? String,
            let body = json["body"] as? String
        else {
            return nil
        }

        let image = json["image"] as? String

        return NotificationContent(
            title: title,
            body: body,
            image: image
        )
    }
}
