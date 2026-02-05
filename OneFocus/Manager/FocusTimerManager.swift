//
//  FocusTimerManager.swift
//  OneFocus
//

import Foundation
import SwiftUI
import UserNotifications
import Combine

@MainActor
final class FocusTimerManager: ObservableObject {

    enum TimerState {
        case idle
        case running
        case paused
    }

    enum SessionType: String, CaseIterable, Hashable {
        case focus
        case shortBreak
        case longBreak

        var title: String {
            switch self {
            case .focus: return "Focus Time"
            case .shortBreak: return "Short Break"
            case .longBreak: return "Long Break"
            }
        }
    }

    private let userSettings: UserSettings

    @Published private(set) var timerState: TimerState = .idle
    @Published private(set) var currentSessionType: SessionType = .focus
    @Published private(set) var timeRemaining: TimeInterval = 0
    @Published private(set) var totalTime: TimeInterval = 0
    @Published private(set) var completedFocusSessions: Int = 0

    private var timer: Foundation.Timer?
    private var lastTickDate: Date?

    init(userSettings: UserSettings) {
        self.userSettings = userSettings
        setupInitialTime(resetRemaining: true)
    }

    deinit {
        timer?.invalidate()
    }

    // Compatibility aliases (keep your existing views working)
    var sessionType: SessionType { currentSessionType }
    var completedSessions: Int { completedFocusSessions }

    var formattedTime: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    var progress: Double {
        guard totalTime > 0 else { return 0 }
        return max(0, min(1, 1.0 - (timeRemaining / totalTime)))
    }

    var menuBarTitle: String {
        switch timerState {
        case .running, .paused: return formattedTime
        case .idle: return "OneFocus"
        }
    }

    func configureForUserSettings(_ settings: UserSettings) {
        setupInitialTime(resetRemaining: timerState == .idle)
    }

    func start(userSettings: UserSettings? = nil) {
        guard timerState != .running else { return }

        if totalTime <= 0 || timeRemaining <= 0 {
            setupInitialTime(resetRemaining: true)
        }

        timerState = .running
        lastTickDate = Date()

        timer?.invalidate()
        timer = Foundation.Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true) { [weak self] _ in
            guard let self else { return }
            DispatchQueue.main.async {
                self.tick()
            }
        }

        if let timer {
            RunLoop.main.add(timer, forMode: .common)
        }
    }

    func pause(userSettings: UserSettings? = nil) {
        guard timerState == .running else { return }
        timerState = .paused
        timer?.invalidate()
        timer = nil
        // keep lastTickDate so we can catch up on resume if needed
    }

    func reset(userSettings: UserSettings? = nil) {
        timerState = .idle
        timer?.invalidate()
        timer = nil
        lastTickDate = nil
        timeRemaining = totalTime
    }

    func switchSession(_ type: SessionType, userSettings: UserSettings? = nil) {
        timer?.invalidate()
        timer = nil
        lastTickDate = nil

        timerState = .idle
        currentSessionType = type
        setupInitialTime(resetRemaining: true)
    }

    func switchToSession(_ type: SessionType) {
        switchSession(type, userSettings: nil)
    }

    func handleScenePhase(_ phase: ScenePhase, userSettings: UserSettings? = nil) {
        guard timerState == .running else { return }

        switch phase {
        case .active:
            catchUpIfNeeded()
            if timer == nil { start() }
        case .inactive, .background:
            if lastTickDate == nil { lastTickDate = Date() }
        @unknown default:
            break
        }
    }

    // MARK: - Internals

    private func setupInitialTime(resetRemaining: Bool) {
        switch currentSessionType {
        case .focus:
            totalTime = userSettings.focusDuration
        case .shortBreak:
            totalTime = userSettings.breakDuration
        case .longBreak:
            totalTime = userSettings.longBreakDuration
        }

        if resetRemaining {
            timeRemaining = totalTime
        } else {
            timeRemaining = min(timeRemaining, totalTime)
        }
    }

    private func catchUpIfNeeded() {
        guard let last = lastTickDate else {
            lastTickDate = Date()
            return
        }

        let now = Date()
        let elapsed = Int(now.timeIntervalSince(last))
        guard elapsed > 0 else { return }

        timeRemaining = max(0, timeRemaining - TimeInterval(elapsed))
        lastTickDate = now

        if timeRemaining <= 0 {
            timerCompleted()
        }
    }

    private func tick() {
        guard timerState == .running else { return }

        catchUpIfNeeded()

        if timeRemaining > 0 {
            timeRemaining = max(0, timeRemaining - 1)
            lastTickDate = Date()
        }

        if timeRemaining <= 0 {
            timerCompleted()
        }
    }

    private func timerCompleted() {
        timer?.invalidate()
        timer = nil
        lastTickDate = nil
        timerState = .idle

        notifyTimerCompletedIfEnabled()

        if currentSessionType == .focus {
            completedFocusSessions += 1

            if userSettings.autoStartBreaks {
                if completedFocusSessions % userSettings.sessionsBeforeLongBreak == 0 {
                    switchSession(.longBreak)
                } else {
                    switchSession(.shortBreak)
                }
                start()
            }
        } else {
            if userSettings.autoStartFocus {
                switchSession(.focus)
                start()
            }
        }
    }

    private func notifyTimerCompletedIfEnabled() {
        // Check current notification settings and post a simple local notification if authorized
        UNUserNotificationCenter.current().getNotificationSettings { settings in
            guard settings.authorizationStatus == .authorized || settings.authorizationStatus == .provisional else { return }
            let content = UNMutableNotificationContent()
            switch self.currentSessionType {
            case .focus:
                content.title = "Focus session complete"
                content.body = "Time for a break."
            case .shortBreak, .longBreak:
                content.title = "Break finished"
                content.body = "Let's get back to focusing."
            }
            content.sound = .default

            // Fire immediately
            let request = UNNotificationRequest(identifier: UUID().uuidString,
                                                content: content,
                                                trigger: nil)
            UNUserNotificationCenter.current().add(request, withCompletionHandler: nil)
        }
    }
}

