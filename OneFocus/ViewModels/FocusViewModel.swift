//
//  FocusViewModel.swift
//  OneFocus
//
//  View model for focus timer management
//

import Foundation
import SwiftUI
import Combine

final class FocusViewModel: ObservableObject {

    // MARK: - Published Properties
    @Published var isSessionActive: Bool = false
    @Published var timeRemaining: TimeInterval = 1500
    @Published var sessionType: SessionType = .focus

    // MARK: - Session Type
    enum SessionType {
        case focus
        case shortBreak
        case longBreak
    }

    // MARK: - Computed Properties
    var formattedTimeRemaining: String {
        let minutes = Int(timeRemaining) / 60
        let seconds = Int(timeRemaining) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }

    // MARK: - Methods
    func startSession() {
        isSessionActive = true
    }

    func pauseSession() {
        isSessionActive = false
    }

    func endSession() {
        isSessionActive = false
        timeRemaining = 1500
    }
}
