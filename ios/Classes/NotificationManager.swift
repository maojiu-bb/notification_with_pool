//
//  NotificationManager.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/01/27.
//

import Foundation
import UserNotifications

class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    private var contentPool: [NotificationContent] = []

    private var hasPermission = false

    private var listeners = NSHashTable<AnyObject>.weakObjects()

    private let dailyScheduleStorageKey = "notification_with_pool_daily_schedule_times"

    private var dailyScheduleTimes: [String: DateComponents] = [:]

    func initialize(contentPool: [NotificationContent]? = nil) {
        loadDailyScheduleTimes()
        if let pool = contentPool {
            self.contentPool = pool
            print("[NotificationWithPool]: Content pool initialized with \(pool.count) items")
        }

        checkNotificationPermission { [weak self] hasPermission in
            guard let self = self else { return }
            if !hasPermission {
                print("[NotificationWithPool]: Requesting notification permission...")
                self.requestNotificationPermission { granted in
                    self.hasPermission = granted
                    print(granted ? "[NotificationWithPool]: Notification permission granted" : "[NotificationWithPool]: Notification permission denied")
                    if granted {
                        self.ensureDailyNotificationsScheduled()
                    }
                }
            } else {
                self.hasPermission = true
                print("[NotificationWithPool]: Notification permission already granted")
                self.ensureDailyNotificationsScheduled()
            }
        }
    }


    func createDailyNotificationWithContentPool(
        identifier: String,
        hour: Int,
        minute: Int,
        second: Int
    ) {
        guard let content = randomContent() else {
            print("[NotificationWithPool]: Failed to get random content from pool")
            return
        }

        var components = DateComponents()
        components.hour = hour
        components.minute = minute
        components.second = second
        dailyScheduleTimes[identifier] = components
        saveDailyScheduleTimes()

        UNUserNotificationCenter.current().removePendingNotificationRequests(
            withIdentifiers: [identifier]
        )

        let trigger = makeDailyCalendarTrigger(components: components)

        scheduleNotification(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }


    func createNotificationWithContentPool(identifier: String) {
        guard let content = randomContent() else { return }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: 1,
            repeats: false
        )

        scheduleNotification(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }


    func createDelayedNotificationWithContentPool(
        identifier: String,
        delay: TimeInterval
    ) {
        guard let content = randomContent() else {
            print("[NotificationWithPool]: Failed to get random content from pool")
            return
        }

        let trigger = UNTimeIntervalNotificationTrigger(
            timeInterval: max(1, delay),
            repeats: false
        )

        scheduleNotification(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }

    func updateContentPool(contentPool: [NotificationContent]) {
        self.contentPool = contentPool
    }

    func cancel(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        dailyScheduleTimes.removeValue(forKey: identifier)
        saveDailyScheduleTimes()
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        dailyScheduleTimes.removeAll()
        saveDailyScheduleTimes()
    }

}


extension NotificationManager {

    func addListener(_ listener: NotificationEventListener) {
        listeners.add(listener)
    }

    func removeListener(_ listener: NotificationEventListener) {
        listeners.remove(listener)
    }

    private func notify(_ event: NotificationEvent) {
        listeners.allObjects
            .compactMap { $0 as? NotificationEventListener }
            .forEach { $0.onNotificationEvent(event) }
    }

}


extension NotificationManager {

    func randomContent() -> NotificationContent? {
        return contentPool.randomElement()
    }

    private func saveDailyScheduleTimes() {
        let stored = dailyScheduleTimes.mapValues { components in
            [
                "hour": components.hour ?? 0,
                "minute": components.minute ?? 0,
                "second": components.second ?? 0
            ]
        }
        UserDefaults.standard.set(stored, forKey: dailyScheduleStorageKey)
    }

    private func loadDailyScheduleTimes() {
        guard let stored = UserDefaults.standard.dictionary(forKey: dailyScheduleStorageKey)
            as? [String: [String: Int]] else {
            return
        }

        var result: [String: DateComponents] = [:]
        for (identifier, values) in stored {
            var components = DateComponents()
            components.hour = values["hour"]
            components.minute = values["minute"]
            components.second = values["second"]
            result[identifier] = components
        }
        dailyScheduleTimes = result
    }

    private func ensureDailyNotificationsScheduled() {
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { [weak self] requests in
                guard let self = self else { return }
                let pendingIdentifiers = Set(requests.map { $0.identifier })

                for (identifier, components) in self.dailyScheduleTimes
                where !pendingIdentifiers.contains(identifier) {
                    self.rescheduleDailyNotification(
                        identifier: identifier,
                        components: components
                    )
                }
            }
    }

    private func makeDailyCalendarTrigger(
        components: DateComponents
    ) -> UNNotificationTrigger {
        return UNCalendarNotificationTrigger(
            dateMatching: components,
            repeats: true
        )
    }

    private func rescheduleDailyNotification(
        identifier: String,
        components: DateComponents
    ) {
        guard let content = randomContent() else {
            print("[NotificationWithPool]: Failed to get random content from pool")
            return
        }

        let trigger = makeDailyCalendarTrigger(components: components)

        scheduleNotification(
            identifier: identifier,
            content: content,
            trigger: trigger
        )
    }

    func buildNotificationContent(
        from content: NotificationContent,
        completion: @escaping (UNMutableNotificationContent) -> Void
    ) {
        let notificationContent = UNMutableNotificationContent()
        notificationContent.title = content.title
        notificationContent.body = content.body
        notificationContent.sound = .default
        notificationContent.badge = 1

        guard let image = content.image else {
            completion(notificationContent)
            return
        }

        downloadImageAttachment(from: image) { attachment in
            if let attachment = attachment {
                notificationContent.attachments = [attachment]
            }
            completion(notificationContent)
        }
    }

    private func scheduleNotification(
        identifier: String,
        content: NotificationContent,
        trigger: UNNotificationTrigger
    ) {
        guard hasPermission else {
            print("[NotificationWithPool]: No notification permission! Cannot schedule notification")
            return
        }

        buildNotificationContent(from: content) { notificationContent in
            let request = UNNotificationRequest(
                identifier: identifier,
                content: notificationContent,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { [weak self] error in
                if let error = error {
                    print("[NotificationWithPool]: Failed to add notification: \(error.localizedDescription)")
                } else {
                    print("[NotificationWithPool]: Notification scheduled successfully: \(identifier)")
                    DispatchQueue.main.async {
                        self?.notify(.scheduled(identifier: identifier))
                    }
                }
            }
        }
    }

    func downloadImageAttachment(
        from urlString: String,
        completion: @escaping (UNNotificationAttachment?) -> Void
    ) {
        guard let url = URL(string: urlString) else {
            completion(nil)
            return
        }

        URLSession.shared.downloadTask(with: url) { tempUrl, _ , error in
            guard let tempUrl = tempUrl, error == nil else {
                completion(nil)
                return
            }

            let fileManager = FileManager.default
            let ext = url.pathExtension.isEmpty ? "jpg" : url.pathExtension
            let localUrl = fileManager.temporaryDirectory
                .appendingPathComponent(UUID().uuidString)
                .appendingPathExtension(ext)

            do {
                try fileManager.moveItem(at: tempUrl, to: localUrl)
                let attachment = try UNNotificationAttachment(
                    identifier: UUID().uuidString,
                    url: localUrl
                )
                completion(attachment)
            } catch {
                completion(nil)
            }
        }.resume()
    }

}


extension NotificationManager {

    private func requestNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .requestAuthorization(options: [.badge, .alert, .sound]) { granted, error in
                DispatchQueue.main.async {
                    completion(granted)
                }
            }
    }

    private func checkNotificationPermission(completion: @escaping (Bool) -> Void) {
        UNUserNotificationCenter.current()
            .getNotificationSettings { settings in
                DispatchQueue.main.async {
                    completion(settings.authorizationStatus == .authorized)
                }
            }
    }

}


extension NotificationManager: UNUserNotificationCenterDelegate {

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        let identifier = notification.request.identifier
        print("[NotificationWithPool]: Notification delivered: \(identifier)")
        notify(.delivered(identifier: identifier))

        if let components = dailyScheduleTimes[identifier] {
            rescheduleDailyNotification(identifier: identifier, components: components)
        }

        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let identifier = response.notification.request.identifier
        notify(.opened(identifier: identifier))

        if let components = dailyScheduleTimes[identifier] {
            rescheduleDailyNotification(identifier: identifier, components: components)
        }

        UNUserNotificationCenter.current().setBadgeCount(0)

        completionHandler()
    }

}
