//
//  HapticManager.swift
//  OneFocus
//
//  Pure SwiftUI haptic feedback helper
//

import SwiftUI

struct HapticManager {
    
    // For SwiftUI, haptics are best handled via .sensoryFeedback() modifier
    // This struct provides empty implementations for compatibility
    // Use .sensoryFeedback(.impact, trigger:) in SwiftUI views instead
    
    static func impact(_ style: ImpactStyle) {
        // No-op: Use .sensoryFeedback(.impact, trigger:) in SwiftUI
    }
    
    static func notification(_ type: NotificationType) {
        // No-op: Use .sensoryFeedback(.success, trigger:) in SwiftUI
    }
    
    static func selection() {
        // No-op: Use .sensoryFeedback(.selection, trigger:) in SwiftUI
    }
    
    enum ImpactStyle {
        case light, medium, heavy
    }
    
    enum NotificationType {
        case success, warning, error
    }
}
