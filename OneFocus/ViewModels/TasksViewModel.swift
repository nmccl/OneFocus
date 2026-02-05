//
//  TasksViewModel.swift
//  OneFocus
//
//  View model for task management
//

import Foundation
import SwiftUI
import Combine

class TasksViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var tasks: [Task] = []
    
    // MARK: - Init
    init() {
        loadTasks()
    }
    
    // MARK: - Methods
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].toggleCompletion()
            saveTasks()
        }
    }
    
    private func saveTasks() {
        // Persist tasks to UserDefaults or Core Data
        // Implementation would go here
    }
    
    private func loadTasks() {
        // Load tasks from UserDefaults or Core Data
        // Implementation would go here
    }
}

