//
//  NotificationService.swift
//  OneFocus
//
//  Service for managing local notifications
//

import Foundation
import SwiftUI
import Combine
import UserNotifications

@MainActor
class NotificationService: NSObject, ObservableObject {
    
    static let shared = NotificationService()
    
    // MARK: - Published Properties
    @Published var authorizationStatus: UNAuthorizationStatus = .notDetermined
    @Published var isEnabled = false
    
    // MARK: - Properties
    private let notificationCenter = UNUserNotificationCenter.current()
    
    // MARK: - Initializer
    private override init() {
        super.init()
        notificationCenter.delegate = self
    }
    
    // MARK: - Authorization
    func requestAuthorization() async -> Bool {
        do {
            let granted = try await notificationCenter.requestAuthorization(options: [.alert, .sound])
            
            await MainActor.run {
                self.isEnabled = granted
            }
            
            return granted
        } catch {
            print("Notification authorization error: \(error.localizedDescription)")
            return false
        }
    }
    
    func checkAuthorizationStatus() async {
        let settings = await notificationCenter.notificationSettings()
        
        await MainActor.run {
            self.authorizationStatus = settings.authorizationStatus
            self.isEnabled = settings.authorizationStatus == .authorized
        }
    }
    
    func openSettings() {
        // Settings opening requires platform-specific code
        // Implement in view layer if needed
    }
    
    // MARK: - Schedule Notifications
    func scheduleFocusCompleteNotification(in seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Focus Session Complete!"
        content.body = "Great work! Time for a break."
        content.sound = .default
        content.categoryIdentifier = "FOCUS_SESSION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "focus_complete_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleBreakCompleteNotification(in seconds: TimeInterval) {
        let content = UNMutableNotificationContent()
        content.title = "Break Complete!"
        content.body = "Ready to focus again?"
        content.sound = .default
        content.categoryIdentifier = "BREAK_SESSION"
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: seconds, repeats: false)
        let request = UNNotificationRequest(
            identifier: "break_complete_\(UUID().uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling notification: \(error.localizedDescription)")
            }
        }
    }
    
    func scheduleTaskReminderNotification(for task: Task, at date: Date) {
        let content = UNMutableNotificationContent()
        content.title = "Task Reminder"
        content.body = task.title
        content.sound = .default
        content.categoryIdentifier = "TASK_REMINDER"
        content.userInfo = ["taskID": task.id.uuidString]
        
        let calendar = Calendar.current
        let components = calendar.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        let trigger = UNCalendarNotificationTrigger(dateMatching: components, repeats: false)
        
        let request = UNNotificationRequest(
            identifier: "task_\(task.id.uuidString)",
            content: content,
            trigger: trigger
        )
        
        notificationCenter.add(request) { error in
            if let error = error {
                print("Error scheduling task reminder: \(error.localizedDescription)")
            }
        }
    }
    
    // MARK: - Cancel Notifications
    func cancelAllNotifications() {
        notificationCenter.removeAllPendingNotificationRequests()
    }
    
    func cancelNotification(withIdentifier identifier: String) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: [identifier])
    }
    
    func cancelTaskNotification(for taskID: UUID) {
        notificationCenter.removePendingNotificationRequests(withIdentifiers: ["task_\(taskID.uuidString)"])
    }
    
    // MARK: - Get Pending Notifications
    func getPendingNotifications() async -> [UNNotificationRequest] {
        return await notificationCenter.pendingNotificationRequests()
    }
}

// MARK: - UNUserNotificationCenterDelegate
extension NotificationService: UNUserNotificationCenterDelegate {
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification,
        withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void
    ) {
        // Show notification even when app is in foreground
        completionHandler([.banner, .sound])
    }
    
    nonisolated func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        didReceive response: UNNotificationResponse,
        withCompletionHandler completionHandler: @escaping () -> Void
    ) {
        let actionIdentifier = response.actionIdentifier
        let categoryIdentifier = response.notification.request.content.categoryIdentifier
        
        // Handle notification actions
        handleNotificationAction(actionIdentifier: actionIdentifier, categoryIdentifier: categoryIdentifier)
        
        completionHandler()
    }
    
    nonisolated private func handleNotificationAction(actionIdentifier: String, categoryIdentifier: String) {
        switch actionIdentifier {
        case "START_BREAK":
            // Navigate to Focus tab and start break
            NotificationCenter.default.post(name: .startBreak, object: nil)
            
        case "START_FOCUS":
            // Navigate to Focus tab and start focus session
            NotificationCenter.default.post(name: .startFocus, object: nil)
            
        case "SKIP_BREAK":
            // Skip break and return to home
            NotificationCenter.default.post(name: .skipBreak, object: nil)
            
        case UNNotificationDefaultActionIdentifier:
            // User tapped the notification
            if categoryIdentifier == "FOCUS_SESSION" {
                NotificationCenter.default.post(name: .openFocusTab, object: nil)
            } else if categoryIdentifier == "TASK_REMINDER" {
                NotificationCenter.default.post(name: .openTasksTab, object: nil)
            }
            
        default:
            break
        }
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let startBreak = Notification.Name("startBreak")
    static let startFocus = Notification.Name("startFocus")
    static let skipBreak = Notification.Name("skipBreak")
    static let openFocusTab = Notification.Name("openFocusTab")
    static let openTasksTab = Notification.Name("openTasksTab")
}
