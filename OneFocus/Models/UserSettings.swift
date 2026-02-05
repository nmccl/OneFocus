// OneFocus/Settings/UserSettings.swift
import SwiftUI
import Combine

@MainActor
final class UserSettings: ObservableObject {

    enum AppearanceMode: String, CaseIterable, Identifiable {
        case system, light, dark
        var id: String { rawValue }

        var displayName: String {
            switch self {
            case .system: return "System"
            case .light:  return "Light"
            case .dark:   return "Dark"
            }
        }

        // Use with `.preferredColorScheme(...)`
        var preferredColorScheme: ColorScheme? {
            switch self {
            case .system: return nil
            case .light:  return .light
            case .dark:   return .dark
            }
        }

        // Backwards-compat with older call sites
        var colorScheme: ColorScheme? { preferredColorScheme }
    }

    private enum Key {
        static let appearanceMode = "appearanceMode"
        static let notificationsEnabled = "notificationsEnabled"
        static let doNotDisturbPref = "doNotDisturbPref"
        static let focusMinutes = "focusMinutes"
        static let shortBreakMinutes = "shortBreakMinutes"
        static let longBreakMinutes = "longBreakMinutes"
        static let clipboardLimit = "clipboardLimit"
        static let userName = "userName"
    }

    @Published var userName: String {
        didSet { UserDefaults.standard.set(userName, forKey: Key.userName) }
    }

    @Published var appearanceMode: AppearanceMode {
        didSet { UserDefaults.standard.set(appearanceMode.rawValue, forKey: Key.appearanceMode) }
    }

    @Published var notificationsEnabled: Bool {
        didSet { UserDefaults.standard.set(notificationsEnabled, forKey: Key.notificationsEnabled) }
    }

    @Published var doNotDisturbPref: Bool {
        didSet { UserDefaults.standard.set(doNotDisturbPref, forKey: Key.doNotDisturbPref) }
    }

    @Published var focusMinutes: Int {
        didSet { UserDefaults.standard.set(focusMinutes, forKey: Key.focusMinutes) }
    }

    @Published var shortBreakMinutes: Int {
        didSet { UserDefaults.standard.set(shortBreakMinutes, forKey: Key.shortBreakMinutes) }
    }

    @Published var longBreakMinutes: Int {
        didSet { UserDefaults.standard.set(longBreakMinutes, forKey: Key.longBreakMinutes) }
    }

    @Published var clipboardLimit: Int {
        didSet { UserDefaults.standard.set(clipboardLimit, forKey: Key.clipboardLimit) }
    }
    @Published var sessionsBeforeLongBreak: Int {
        didSet { UserDefaults.standard.set(sessionsBeforeLongBreak, forKey: "sessionsBeforeLongBreak") }
    }
    var focusDuration: TimeInterval { TimeInterval(focusMinutes * 60) }
    var breakDuration: TimeInterval { TimeInterval(shortBreakMinutes * 60) }
    var longBreakDuration: TimeInterval { TimeInterval(longBreakMinutes * 60) }

    // If your timer expects toggles:
    @Published var autoStartBreaks: Bool {
        didSet { UserDefaults.standard.set(autoStartBreaks, forKey: "autoStartBreaks") }
    }

    @Published var autoStartFocus: Bool {
        didSet { UserDefaults.standard.set(autoStartFocus, forKey: "autoStartFocus") }
    }

    // Onboarding flag expected by OnboardingView:
    @Published var hasCompletedOnboarding: Bool {
        didSet { UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding") }
    }

    init() {
        let d = UserDefaults.standard

        self.userName = d.string(forKey: Key.userName) ?? "Noah"

        let savedAppearance = d.string(forKey: Key.appearanceMode)
        self.appearanceMode = AppearanceMode(rawValue: savedAppearance ?? "system") ?? .system

        self.notificationsEnabled = d.object(forKey: Key.notificationsEnabled) as? Bool ?? true
        self.doNotDisturbPref = d.object(forKey: Key.doNotDisturbPref) as? Bool ?? false

        let savedFocus = d.integer(forKey: Key.focusMinutes)
        self.focusMinutes = (savedFocus == 0) ? 25 : savedFocus

        let savedShort = d.integer(forKey: Key.shortBreakMinutes)
        self.shortBreakMinutes = (savedShort == 0) ? 5 : savedShort

        let savedLong = d.integer(forKey: Key.longBreakMinutes)
        self.longBreakMinutes = (savedLong == 0) ? 15 : savedLong

        let savedLimit = d.integer(forKey: Key.clipboardLimit)
        self.clipboardLimit = (savedLimit == 0) ? 50 : savedLimit
        
        self.autoStartBreaks = UserDefaults.standard.object(forKey: "autoStartBreaks") as? Bool ?? false
        self.autoStartFocus = UserDefaults.standard.object(forKey: "autoStartFocus") as? Bool ?? false
        self.hasCompletedOnboarding = UserDefaults.standard.object(forKey: "hasCompletedOnboarding") as? Bool ?? false
        
        let saved = UserDefaults.standard.integer(forKey: "sessionsBeforeLongBreak")
        self.sessionsBeforeLongBreak = (saved == 0) ? 4 : saved
    }

    // For previews / any view referencing `UserSettings.sample`
    static let sample: UserSettings = {
        let s = UserSettings()
        s.userName = "Noah"
        s.appearanceMode = .system
        s.notificationsEnabled = true
        s.doNotDisturbPref = false
        s.focusMinutes = 25
        s.shortBreakMinutes = 5
        s.longBreakMinutes = 15
        s.clipboardLimit = 50
        return s
    }()
}
