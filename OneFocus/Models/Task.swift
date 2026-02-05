//
//  Task.swift
//  OneFocus
//
//  Task data model representing a user's task or intention
//

import Foundation
import SwiftUI

struct Task: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var isCompleted: Bool
    var createdDate: Date
    var completedDate: Date?
    var dueDate: Date?
    var priority: Priority
    var notes: String?
    
    // MARK: - Priority Levels
    enum Priority: String, Codable, CaseIterable {
        case low = "Low"
        case medium = "Medium"
        case high = "High"
        
        var color: Color {
            switch self {
            case .low:
                return AppConstants.Colors.textTertiary
            case .medium:
                return AppConstants.Colors.warning
            case .high:
                return AppConstants.Colors.error
            }
        }
        
        var icon: String {
            switch self {
            case .low:
                return "circle"
            case .medium:
                return "circle.fill"
            case .high:
                return "exclamationmark.circle.fill"
            }
        }
    }
    
    // MARK: - Initializer
    init(
        id: UUID = UUID(),
        title: String,
        isCompleted: Bool = false,
        createdDate: Date = Date(),
        completedDate: Date? = nil,
        dueDate: Date? = nil,
        priority: Priority = .medium,
        notes: String? = nil
    ) {
        self.id = id
        self.title = title
        self.isCompleted = isCompleted
        self.createdDate = createdDate
        self.completedDate = completedDate
        self.dueDate = dueDate
        self.priority = priority
        self.notes = notes
    }
    
    // MARK: - Computed Properties
    var isOverdue: Bool {
        guard !isCompleted, let dueDate = dueDate else { return false }
        return dueDate < Date()
    }
    
    var isDueToday: Bool {
        guard let dueDate = dueDate else { return false }
        return Calendar.current.isDateInToday(dueDate)
    }
    
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: createdDate)
    }
    
    var formattedCompletedDate: String? {
        guard let completedDate = completedDate else { return nil }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: completedDate)
    }
    
    var formattedDueDate: String {
        guard let dueDate = dueDate else { return "No due date" }
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .none
        return formatter.string(from: dueDate)
    }
    
    // MARK: - Methods
    mutating func toggleCompletion() {
        isCompleted.toggle()
        completedDate = isCompleted ? Date() : nil
    }
    
    mutating func complete() {
        isCompleted = true
        completedDate = Date()
    }
    
    mutating func uncomplete() {
        isCompleted = false
        completedDate = nil
    }
    
   
}

// MARK: - Task Array Extensions
extension Array where Element == Task {
    var completed: [Task] {
        filter { $0.isCompleted }
    }
    
    var incomplete: [Task] {
        filter { !$0.isCompleted }
    }
    
    var dueToday: [Task] {
        filter { $0.isDueToday && !$0.isCompleted }
    }
    
    var overdue: [Task] {
        filter { $0.isOverdue }
    }
    
    var sortedByPriority: [Task] {
        sorted { task1, task2 in
            let priorityOrder: [Task.Priority] = [.high, .medium, .low]
            let index1 = priorityOrder.firstIndex(of: task1.priority) ?? 0
            let index2 = priorityOrder.firstIndex(of: task2.priority) ?? 0
            return index1 < index2
        }
    }
    
    var sortedByDate: [Task] {
        sorted { $0.createdDate > $1.createdDate }
    }
}
