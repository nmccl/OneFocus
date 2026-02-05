//
//  NotificationManager.swift
//  OneFocus
//
//  Created by Noah McClung on 12/31/25.
//


//
//  NotificationManager.swift
//  OneFocus
//

import Foundation
import UserNotifications

final class NotificationManager {
    static let shared = NotificationManager()
    private init() {}

    func requestAuthorization(completion: @escaping (Bool) -> Void) {
        let center = UNUserNotificationCenter.current()

        center.getNotificationSettings { settings in
            switch settings.authorizationStatus {
            case .authorized, .provisional, .ephemeral:
                completion(true)
            case .denied:
                completion(false)
            case .notDetermined:
                center.requestAuthorization(options: [.alert, .sound, .badge]) { granted, _ in
                    completion(granted)
                }
            @unknown default:
                completion(false)
            }
        }
    }

    func scheduleTimerComplete(sessionTitle: String, body: String, sound: Bool) {
        let content = UNMutableNotificationContent()
        content.title = sessionTitle
        content.body  = body
        content.sound = sound ? .default : nil

        // ✅ Never use a nil trigger. Use 1s.
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "focus.timer.complete.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request)
    }
}