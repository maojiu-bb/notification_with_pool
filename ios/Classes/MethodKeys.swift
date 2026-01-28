//
//  MethodKeys.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/01/27.
//

import Foundation

final class MethodKeys {

    static let INITIALIZE = "initialize"

    static let CREATE_NOTIFICATION_WITH_CONTENT_POOL =
        "createNotificationWithContentPool"

    static let CREATE_DAILY_NOTIFICATION_WITH_CONTENT_POOL =
        "createDailyNotificationWithContentPool"

    static let CREATE_DELAYED_NOTIFICATION_WITH_CONTENT_POOL =
        "createDelayedNotificationWithContentPool"

    static let UPDATE_CONTENT_POOL = "updateContentPool"

    static let CANCEL = "cancel"

    static let CANCEL_ALL = "cancelAll"
}
