//
//  FocusSession.swift
//  OneFocus
//
//  Focus session data model representing a completed or active focus period
//

import Foundation

struct FocusSession: Identifiable, Codable, Equatable {
    let id: UUID
    var startTime: Date
    var endTime: Date?
    var duration: TimeInterval
    var actualDuration: TimeInterval
    var associatedTaskID: UUID?
    var sessionType: SessionType
    var wasCompleted: Bool
    var notes: String?
    
    // MARK: - Session Types
    enum SessionType: String, Codable, CaseIterable {
        case focus = "Focus"
        case shortBreak = "Short Break"
        case longBreak = "Long Break"
        
        var icon: String {
            switch self {
            case .focus:
                return "brain.head.profile"
            case .shortBreak:
                return "cup.and.saucer.fill"
            case .longBreak:
                return "moon.stars.fill"
            }
        }
        
        var defaultDuration: TimeInterval {
            switch self {
            case .focus:
                return AppConstants.Timer.defaultFocusDuration
            case .shortBreak:
                return AppConstants.Timer.defaultBreakDuration
            case .longBreak:
                return AppConstants.Timer.defaultLongBreakDuration
            }
        }
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        startTime: Date = Date(),
        endTime: Date? = nil,
        duration: TimeInterval = AppConstants.Timer.defaultFocusDuration,
        actualDuration: TimeInterval = 0,
        associatedTaskID: UUID? = nil,
        sessionType: SessionType = .focus,
        wasCompleted: Bool = false,
        notes: String? = nil
    ) {
        self.id = id
        self.startTime = startTime
        self.endTime = endTime
        self.duration = duration
        self.actualDuration = actualDuration
        self.associatedTaskID = associatedTaskID
        self.sessionType = sessionType
        self.wasCompleted = wasCompleted
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    var isActive: Bool {
        return endTime == nil
    }
    
    var calculatedDuration: TimeInterval {
        guard let endTime = endTime else {
            return Date().timeIntervalSince(startTime)
        }
        return endTime.timeIntervalSince(startTime)
    }
    
    var formattedStartTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: startTime)
    }
    
    var formattedEndTime: String? {
        guard let endTime = endTime else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: endTime)
    }
    
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: startTime)
    }
    
    var formattedDuration: String {
        let hours = Int(actualDuration) / 3600
        let minutes = Int(actualDuration) / 60 % 60
        let seconds = Int(actualDuration) % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else if minutes > 0 {
            return String(format: "%dm %ds", minutes, seconds)
        } else {
            return String(format: "%ds", seconds)
        }
    }
    
    var formattedPlannedDuration: String {
        let minutes = Int(duration) / 60
        return "\(minutes) min"
    }
    
    var completionPercentage: Double {
        guard duration > 0 else { return 0 }
        return min(actualDuration / duration, 1.0)
    }
    
    // MARK: - Methods
    mutating func complete() {
        endTime = Date()
        wasCompleted = true
    }
    
    mutating func end() {
        endTime = Date()
    }
    
    mutating func associateTask(_ taskID: UUID) {
        associatedTaskID = taskID
    }
    
    // MARK: - Sample Data for Previews
    static var sample: FocusSession {
        FocusSession(
            startTime: Date().addingTimeInterval(-1200), // 20 minutes ago
            duration: 25 * 60,
            sessionType: .focus
        )
    }
    
    static var sampleCompleted: FocusSession {
        FocusSession(
            startTime: Date().addingTimeInterval(-1800), // 30 minutes ago
            endTime: Date().addingTimeInterval(-300),    // 5 minutes ago
            duration: 25 * 60,
            sessionType: .focus,
            wasCompleted: true
        )
    }
    
    static var sampleWithTask: FocusSession {
        FocusSession(
            startTime: Date().addingTimeInterval(-600),
            duration: 25 * 60,
            associatedTaskID: UUID(),
            sessionType: .focus
        )
    }
    
    static var sampleList: [FocusSession] {
        [
            FocusSession(
                startTime: Date().addingTimeInterval(-7200),
                endTime: Date().addingTimeInterval(-5700),
                duration: 25 * 60,
                sessionType: .focus,
                wasCompleted: true
            ),
            FocusSession(
                startTime: Date().addingTimeInterval(-5400),
                endTime: Date().addingTimeInterval(-5100),
                duration: 5 * 60,
                sessionType: .shortBreak,
                wasCompleted: true
            ),
            FocusSession(
                startTime: Date().addingTimeInterval(-4800),
                endTime: Date().addingTimeInterval(-3300),
                duration: 25 * 60,
                sessionType: .focus,
                wasCompleted: true
            ),
            FocusSession(
                startTime: Date().addingTimeInterval(-3000),
                duration: 25 * 60,
                sessionType: .focus,
                wasCompleted: false
            )
        ]
    }
}

// MARK: - FocusSession Array Extensions
extension Array where Element == FocusSession {
    var completed: [FocusSession] {
        filter { $0.wasCompleted }
    }
    
    var active: FocusSession? {
        first { $0.isActive }
    }
    
    var totalFocusTime: TimeInterval {
        filter { $0.sessionType == .focus && $0.wasCompleted }
            .reduce(0) { $0 + $1.actualDuration }
    }
    
    var totalBreakTime: TimeInterval {
        filter { ($0.sessionType == .shortBreak || $0.sessionType == .longBreak) && $0.wasCompleted }
            .reduce(0) { $0 + $1.actualDuration }
    }
    
    var todaySessions: [FocusSession] {
        filter { Calendar.current.isDateInToday($0.startTime) }
    }
    
    var thisWeekSessions: [FocusSession] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return filter { $0.startTime >= weekAgo }
    }
    
    var sortedByDate: [FocusSession] {
        sorted { $0.startTime > $1.startTime }
    }
}
