//  SettingsWorkingCopy.swift
//  OneFocus
//


import Foundation

struct SettingsWorkingCopy: Equatable {

    init(
        appearanceMode: UserSettings.AppearanceMode,
        focusMinutes: Int,
        breakMinutes: Int,
        longBreakMinutes: Int,
        sessionsBeforeLongBreak: Int,
        autoStartBreaks: Bool,
        autoStartFocus: Bool,
        hapticEnabled: Bool,
        notificationsEnabled: Bool,
        soundEnabled: Bool
    ) {
        self.appearanceMode = appearanceMode
        self.focusMinutes = focusMinutes
        self.breakMinutes = breakMinutes
        self.longBreakMinutes = longBreakMinutes
        self.sessionsBeforeLongBreak = sessionsBeforeLongBreak
        self.autoStartBreaks = autoStartBreaks
        self.autoStartFocus = autoStartFocus
        self.hapticEnabled = hapticEnabled
        self.notificationsEnabled = notificationsEnabled
        self.soundEnabled = soundEnabled
    }

    // Appearance
    var appearanceMode: UserSettings.AppearanceMode

    // Timer
    var focusMinutes: Int
    var breakMinutes: Int
    var longBreakMinutes: Int
    var sessionsBeforeLongBreak: Int

    // Behavior
    var autoStartBreaks: Bool
    var autoStartFocus: Bool
    var hapticEnabled: Bool

    // Notifications
    var notificationsEnabled: Bool
    var soundEnabled: Bool

    // MARK: Defaults (real product defaults)
    static let defaults = SettingsWorkingCopy(
        appearanceMode: UserSettings.AppearanceMode.system,
        focusMinutes: 25,
        breakMinutes: 5,
        longBreakMinutes: 15,
        sessionsBeforeLongBreak: 4,
        autoStartBreaks: false,
        autoStartFocus: false,
        hapticEnabled: true,
        notificationsEnabled: true,
        soundEnabled: true
    )

    // MARK: Load from live settings
    init(from settings: UserSettings) {
        self.appearanceMode = settings.appearanceMode

        self.focusMinutes = settings.focusMinutes
        self.breakMinutes = settings.breakMinutes
        self.longBreakMinutes = settings.longBreakMinutes
        self.sessionsBeforeLongBreak = settings.sessionsBeforeLongBreak

        self.autoStartBreaks = settings.autoStartBreaks
        self.autoStartFocus = settings.autoStartFocus
        self.hapticEnabled = settings.hapticEnabled

        self.notificationsEnabled = settings.notificationsEnabled
        self.soundEnabled = settings.soundEnabled
    }

    // MARK: Apply back to live settings
    func apply(to settings: UserSettings) {
        settings.appearanceMode = appearanceMode

        settings.focusMinutes = focusMinutes
        settings.breakMinutes = breakMinutes
        settings.longBreakMinutes = longBreakMinutes
        settings.sessionsBeforeLongBreak = sessionsBeforeLongBreak

        settings.autoStartBreaks = autoStartBreaks
        settings.autoStartFocus = autoStartFocus
        settings.hapticEnabled = hapticEnabled

        settings.notificationsEnabled = notificationsEnabled
        settings.soundEnabled = soundEnabled
    }

    mutating func resetToDefaults() {
        self = .defaults
    }
}

