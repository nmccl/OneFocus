//
//  HistoryItem.swift
//  OneFocus
//
//  History item model representing completed tasks and focus sessions
//

import Foundation
import SwiftUI

struct HistoryItem: Identifiable, Codable, Equatable {
    let id: UUID
    var type: ItemType
    var date: Date
    var referenceID: UUID
    var title: String
    var duration: TimeInterval?
    var metadata: [String: String]?
    
    // MARK: - Item Types
    enum ItemType: String, Codable {
        case task = "Task"
        case focusSession = "Focus Session"
        case breakSession = "Break"
        
        var icon: String {
            switch self {
            case .task:
                return "checkmark.circle.fill"
            case .focusSession:
                return "brain.head.profile"
            case .breakSession:
                return "cup.and.saucer.fill"
            }
        }
        
        var color: Color {
            switch self {
            case .task:
                return AppConstants.Colors.success
            case .focusSession:
                return AppConstants.Colors.primaryAccent
            case .breakSession:
                return AppConstants.Colors.secondaryAccent
            }
        }
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        type: ItemType,
        date: Date = Date(),
        referenceID: UUID,
        title: String,
        duration: TimeInterval? = nil,
        metadata: [String: String]? = nil
    ) {
        self.id = id
        self.type = type
        self.date = date
        self.referenceID = referenceID
        self.title = title
        self.duration = duration
        self.metadata = metadata
    }
    
    // MARK: - Convenience Initializers
    init(from task: Task) {
        self.id = UUID()
        self.type = .task
        self.date = task.completedDate ?? Date()
        self.referenceID = task.id
        self.title = task.title
        self.duration = nil
        self.metadata = [
            "priority": task.priority.rawValue,
            "createdDate": ISO8601DateFormatter().string(from: task.createdDate)
        ]
    }
    
    init(from session: FocusSession) {
        self.id = UUID()
        self.type = session.sessionType == .focus ? .focusSession : .breakSession
        self.date = session.endTime ?? Date()
        self.referenceID = session.id
        self.title = session.sessionType.rawValue
        self.duration = session.actualDuration
        self.metadata = [
            "startTime": ISO8601DateFormatter().string(from: session.startTime),
            "wasCompleted": session.wasCompleted ? "true" : "false"
        ]
    }
    
    // MARK: - Computed Properties
    var formattedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: date)
    }
    
    var formattedTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .none
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDateTime: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }
    
    var formattedDuration: String? {
        guard let duration = duration else { return nil }
        let hours = Int(duration) / 3600
        let minutes = Int(duration) / 60 % 60
        
        if hours > 0 {
            return String(format: "%dh %dm", hours, minutes)
        } else {
            return String(format: "%dm", minutes)
        }
    }
    
    var isToday: Bool {
        Calendar.current.isDateInToday(date)
    }
    
    var isYesterday: Bool {
        Calendar.current.isDateInYesterday(date)
    }
    
    var relativeDateString: String {
        if isToday {
            return "Today"
        } else if isYesterday {
            return "Yesterday"
        } else {
            return formattedDate
        }
    }
}

// MARK: - HistoryItem Array Extensions
extension Array where Element == HistoryItem {
    var tasks: [HistoryItem] {
        filter { $0.type == .task }
    }
    
    var focusSessions: [HistoryItem] {
        filter { $0.type == .focusSession }
    }
    
    var breakSessions: [HistoryItem] {
        filter { $0.type == .breakSession }
    }
    
    var today: [HistoryItem] {
        filter { $0.isToday }
    }
    
    var yesterday: [HistoryItem] {
        filter { $0.isYesterday }
    }
    
    var thisWeek: [HistoryItem] {
        let calendar = Calendar.current
        let weekAgo = calendar.date(byAdding: .day, value: -7, to: Date()) ?? Date()
        return filter { $0.date >= weekAgo }
    }
    
    var sortedByDate: [HistoryItem] {
        sorted { $0.date > $1.date }
    }
    
    var groupedByDate: [Date: [HistoryItem]] {
        let calendar = Calendar.current
        return Dictionary(grouping: self) { item in
            calendar.startOfDay(for: item.date)
        }
    }
    
    var totalFocusTime: TimeInterval {
        focusSessions.compactMap { $0.duration }.reduce(0, +)
    }
}
