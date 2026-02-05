//  UserSettings+TimerBehaviorCompat.swift
//  OneFocus
//
//  ✅ Add ONLY if these are missing in your existing UserSettings.
//  ✅ This preserves your current codebase + fixes missing-member errors.

import SwiftUI
import Combine

extension UserSettings {
    
    // If you already have `shortBreakMinutes`, keep it.
    // MARK: - REQUIRED stored settings used by SettingsView/SettingsWorkingCopy
    
    // Break minutes (separate from shortBreakMinutes naming mismatches)
    var breakMinutes: Int {
        get { shortBreakMinutes }          // map to your existing property
        set { shortBreakMinutes = newValue }
    }
    
    // Ensure these exist as @Published STORED properties in your UserSettings.
    // If they already exist, DO NOT duplicate—delete the ones below.
    
    // @Published var longBreakMinutes: Int
    // @Published var focusMinutes: Int
    // @Published var shortBreakMinutes: Int
    // @Published var notificationsEnabled: Bool
    // @Published var appearanceMode: AppearanceMode
    
    // Add these if missing:
    var hapticEnabled: Bool {
        get { (UserDefaults.standard.object(forKey: "hapticEnabled") as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "hapticEnabled") }
    }
    
    var soundEnabled: Bool {
        get { (UserDefaults.standard.object(forKey: "soundEnabled") as? Bool) ?? true }
        set { UserDefaults.standard.set(newValue, forKey: "soundEnabled") }
    }
    
}

private extension Int {
    func clamped(default defaultValue: Int, range: ClosedRange<Int>) -> Int {
        if self == 0 { return defaultValue }
        return Swift.min(Swift.max(self, range.lowerBound), range.upperBound)
    }
}
