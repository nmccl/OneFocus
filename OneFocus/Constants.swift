//
//  Constants.swift
//  OneFocus
//
//  App-wide constants for colors, spacing, durations, and configuration
//

import SwiftUI

struct AppConstants {
    
    // MARK: - App Info
    static let appName = "OneFocus"
    static let appVersion = "1.0.0"
    
    // MARK: - Colors (Minimalist Apple Design)
    struct Colors {
        // Primary palette - clean black and white with subtle grays
        static let primaryAccent = Color.black                      // Pure black
        static let secondaryAccent = Color.gray                     // System gray
        
        // Backgrounds
        static let backgroundPrimary = Color.white                  // Pure white
        static let backgroundSecondary = Color(white: 0.98)         // Off-white
        static let backgroundTertiary = Color(white: 0.95)          // Light gray
        
        // Card and surface colors
        static let cardBackground = Color.white
        static let cardBorder = Color(white: 0.9)                   // Subtle border
        static let cardShadow = Color.black.opacity(0.05)           // Very subtle shadow
        
        // Text colors
        static let textPrimary = Color.black                        // Pure black
        static let textSecondary = Color.gray                       // System gray
        static let textTertiary = Color(white: 0.6)                 // Light gray
        
        // Status colors (subtle grays instead of colors)
        static let success = Color(white: 0.3)                      // Dark gray
        static let warning = Color(white: 0.5)                      // Medium gray
        static let error = Color(white: 0.4)                        // Medium-dark gray
        
        // Dividers and separators
        static let divider = Color(white: 0.9)
        static let separator = Color(white: 0.85)
    }
    
    // MARK: - Spacing
    struct Spacing {
        static let xs: CGFloat = 4
        static let sm: CGFloat = 8
        static let md: CGFloat = 16
        static let lg: CGFloat = 24
        static let xl: CGFloat = 32
        static let xxl: CGFloat = 48
    }
    
    // MARK: - Corner Radius
    struct CornerRadius {
        static let small: CGFloat = 6
        static let medium: CGFloat = 8
        static let large: CGFloat = 12
        static let extraLarge: CGFloat = 16
        static let pill: CGFloat = 999
        static let circle: CGFloat = 999
    }
    
    // MARK: - Font Sizes
    struct FontSize {
        static let caption: CGFloat = 12
        static let body: CGFloat = 16
        static let subheadline: CGFloat = 14
        static let headline: CGFloat = 18
        static let title: CGFloat = 24
        static let largeTitle: CGFloat = 34
        static let timer: CGFloat = 56
    }
    
    // MARK: - Focus Timer Defaults
    struct Timer {
        static let defaultFocusDuration: TimeInterval = 25 * 60        // 25 minutes
        static let defaultBreakDuration: TimeInterval = 5 * 60         // 5 minutes
        static let defaultLongBreakDuration: TimeInterval = 15 * 60    // 15 minutes
        static let sessionsBeforeLongBreak: Int = 4
        
        // Timer ring dimensions
        static let timerRingSize: CGFloat = 280
        static let timerRingLineWidth: CGFloat = 2                     // Thin line
    }
    
    // MARK: - Animation Durations
    struct Animation {
        static let fast: Double = 0.2
        static let normal: Double = 0.3
        static let slow: Double = 0.5
        static let timerTick: Double = 1.0
    }
    
    // MARK: - Card Dimensions
    struct Card {
        static let shadowRadius: CGFloat = 4
        static let shadowOpacity: Double = 0.05
        static let shadowOffset = CGSize(width: 0, height: 1)
        static let minHeight: CGFloat = 80
        static let borderWidth: CGFloat = 0.5
    }
    
    // MARK: - Tab Bar
    struct TabBar {
        static let height: CGFloat = 80
        static let iconSize: CGFloat = 22
    }
    
    // MARK: - Notifications
    struct Notifications {
        static let focusEndTitle = "Focus Session Complete"
        static let focusEndBody = "Great work! Time for a break."
        static let breakEndTitle = "Break Over"
        static let breakEndBody = "Ready to focus again?"
        static let reminderTitle = "Time to Focus"
        static let reminderBody = "Your daily focus session awaits."
    }
    
    // MARK: - User Defaults Keys
    struct UserDefaultsKeys {
        static let focusDuration = "focusDuration"
        static let breakDuration = "breakDuration"
        static let notificationsEnabled = "notificationsEnabled"
        static let appearanceMode = "appearanceMode"
        static let userName = "userName"
        static let hasCompletedOnboarding = "hasCompletedOnboarding"
    }
    
    // MARK: - Haptics
    // Note: Haptic feedback should be triggered using SensoryFeedback in SwiftUI
    // or by creating generators on-demand in iOS 13+
}

// MARK: - Color Extension for Hex Support
extension Color {
    init(hex: String) {
        let hex = hex.trimmingCharacters(in: CharacterSet.alphanumerics.inverted)
        var int: UInt64 = 0
        Scanner(string: hex).scanHexInt64(&int)
        let a, r, g, b: UInt64
        switch hex.count {
        case 3: // RGB (12-bit)
            (a, r, g, b) = (255, (int >> 8) * 17, (int >> 4 & 0xF) * 17, (int & 0xF) * 17)
        case 6: // RGB (24-bit)
            (a, r, g, b) = (255, int >> 16, int >> 8 & 0xFF, int & 0xFF)
        case 8: // ARGB (32-bit)
            (a, r, g, b) = (int >> 24, int >> 16 & 0xFF, int >> 8 & 0xFF, int & 0xFF)
        default:
            (a, r, g, b) = (255, 0, 0, 0)
        }
        
        self.init(
            .sRGB,
            red: Double(r) / 255,
            green: Double(g) / 255,
            blue:  Double(b) / 255,
            opacity: Double(a) / 255
        )
    }
}
