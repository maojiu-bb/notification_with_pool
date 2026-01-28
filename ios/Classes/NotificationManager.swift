//
//  NotificationManager.swift
//  notification_with_pool
//
//  Created by zhongyu on 2026/01/27.
//

import Foundation
import UserNotifications

struct ScheduleConfig {
    let interval: TimeInterval
    let useContentPool: Bool
}

class NotificationManager: NSObject {
    static let shared = NotificationManager()

    private override init() {
        super.init()
        UNUserNotificationCenter.current().delegate = self
    }

    private var contentPool: [NotificationContent] = []

    private var hasPermission = false

    private var listeners = NSHashTable<AnyObject>.weakObjects()

    private var scheduleConfigs: [String: ScheduleConfig] = [:]


    func initilize(contentPool: [NotificationContent]? = nil) {
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
                }
            } else {
                self.hasPermission = true
                print("[NotificationWithPool]: Notification permission already granted")
            }
        }
    }


    func createScheduledNotificationWithContentPool(
        identifier: String,
        scheduledTime: Date,
        interval: TimeInterval
    ) {
        guard let content = randomContent() else {
            print("[NotificationWithPool]: Failed to get random content from pool")
            return
        }

        scheduleConfigs[identifier] = ScheduleConfig(
            interval: interval,
            useContentPool: true
        )

        createScheduledNotification(
            identifier: identifier,
            content: content,
            scheduledTime: scheduledTime,
            interval: 0
        )
    }


    func createNotificationWithContentPool(identifier: String) {
        guard let content = randomContent() else { return }
        createNotification(identifier: identifier, content: content)
    }


    func createNotification(identifier: String, content: NotificationContent) {
        guard hasPermission else { return }

        buildNotificationContent(from: content) { notificationContent in
            let trigger = UNTimeIntervalNotificationTrigger(
                timeInterval: 1,
                repeats: false
            )

            let request = UNNotificationRequest(
                identifier: identifier,
                content: notificationContent,
                trigger: trigger
            )

            UNUserNotificationCenter.current().add(request) { [weak self] error in
                if error == nil {
                    DispatchQueue.main.async {
                        self?.notify(.scheduled(identifier: identifier))
                    }
                }
            }
        }
    }


    func createScheduledNotification(
        identifier: String,
        content: NotificationContent,
        scheduledTime: Date,
        interval: TimeInterval
    ) {
        guard hasPermission else {
            print("[NotificationWithPool]: No notification permission! Cannot schedule notification")
            return
        }

        let trigger = makeTrigger(date: scheduledTime, interval: interval)

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


    func updateContentPool(contentPool: [NotificationContent]) {
        self.contentPool = contentPool
    }


    func updateScheduled(
        identifier: String,
        scheduledTime: Date,
        interval: TimeInterval
    ) {
        UNUserNotificationCenter.current()
            .getPendingNotificationRequests { requests in
                guard let oldRequest = requests.first(where: { $0.identifier == identifier }),
                      let oldContent = oldRequest.content as? UNMutableNotificationContent
                else { return }

                let trigger = self.makeTrigger(
                    date: scheduledTime,
                    interval: interval
                )

                let newRequest = UNNotificationRequest(
                    identifier: identifier,
                    content: oldContent,
                    trigger: trigger
                )

                UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
                UNUserNotificationCenter.current().add(newRequest) { [weak self] error in
                    if error == nil {
                        DispatchQueue.main.async {
                            self?.notify(.scheduled(identifier: identifier))
                        }
                    }
                }
            }
    }

    func cancel(identifier: String) {
        UNUserNotificationCenter.current().removePendingNotificationRequests(withIdentifiers: [identifier])
        scheduleConfigs.removeValue(forKey: identifier)
    }

    func cancelAll() {
        UNUserNotificationCenter.current().removeAllPendingNotificationRequests()
        scheduleConfigs.removeAll()
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

    func makeTrigger(date: Date, interval: TimeInterval) -> UNNotificationTrigger {
        if interval > 0 {
            return UNTimeIntervalNotificationTrigger(
                timeInterval: interval,
                repeats: true
            )
        } else {
            let timeIntervalFromNow = date.timeIntervalSinceNow

            let triggerInterval = max(1, timeIntervalFromNow)

            return UNTimeIntervalNotificationTrigger(
                timeInterval: triggerInterval,
                repeats: false
            )
        }
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

        if let config = scheduleConfigs[identifier], config.useContentPool {
            print("[NotificationWithPool]: Auto-rescheduling enabled for: \(identifier)")
            rescheduleNotification(identifier: identifier, config: config)
        }

        completionHandler([.banner, .sound, .badge])
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        notify(.opened(identifier: response.notification.request.identifier))

        UNUserNotificationCenter.current().setBadgeCount(0)

        completionHandler()
    }

    private func rescheduleNotification(identifier: String, config: ScheduleConfig) {
        guard config.interval > 0 else { return }
        guard let content = randomContent() else {
            print("[NotificationWithPool]: Failed to get random content for rescheduling")
            return
        }

        let nextTriggerDate = Date().addingTimeInterval(config.interval)

        createScheduledNotification(
            identifier: identifier,
            content: content,
            scheduledTime: nextTriggerDate,
            interval: 0
        )
    }

}
