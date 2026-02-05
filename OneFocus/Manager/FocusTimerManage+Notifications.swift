import Foundation
import UserNotifications

extension FocusTimerManager {

    func scheduleCompletionNotification(for sessionType: SessionType, soundEnabled: Bool) {
        let content = UNMutableNotificationContent()

        switch sessionType {
        case .focus:
            content.title = "Focus Complete!"
            content.body  = "Great work! Time for a break."
        case .shortBreak, .longBreak:
            content.title = "Break Over!"
            content.body  = "Ready to focus again?"
        }

        content.sound = soundEnabled ? .default : nil

        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 1, repeats: false)

        let request = UNNotificationRequest(
            identifier: "onefocus.timer.complete.\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )

        UNUserNotificationCenter.current().add(request) { error in
            if let error = error {
                print("OneFocus: Failed to schedule completion notification: \(error.localizedDescription)")
            } else {
                print("OneFocus: Scheduled completion notification: \(request.identifier)")
            }
        }

        UNUserNotificationCenter.current().getPendingNotificationRequests { requests in
            let ids = requests.map { $0.identifier }
            print("OneFocus: Pending notifications count: \(requests.count)")
            if let last = ids.last {
                print("OneFocus: Last pending id: \(last)")
            }
        }
    }

    func notifyTimerCompletedIfEnabled() {
        // If you rely on userSettings here, ensure FocusTimerManager has access.
        // This extension assumes it does.
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            if settings.authorizationStatus == .denied {
                print("OneFocus: Notification authorization denied.")
            } else if settings.authorizationStatus == .notDetermined {
                print("OneFocus: Notification authorization not determined.")
            } else {
                print("OneFocus: Notification authorization status ok: \(settings.authorizationStatus.rawValue)")
            }
        }

        // Fallback to default sound true if you don't have userSettings here.
        // But in your project, FocusTimerManager has userSettings, so this reads it.
        scheduleCompletionNotification(for: currentSessionType, soundEnabled: (try? userSettings.soundEnabled) ?? true)
    }
}
