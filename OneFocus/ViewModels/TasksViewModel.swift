//
//  TasksViewModel.swift
//  OneFocus
//
//  View model for task management with JSON persistence
//

import Foundation
import SwiftUI
import Combine

class TasksViewModel: ObservableObject {
    
    // MARK: - Published Properties
    @Published var tasks: [Task] = []
    
    // MARK: - File URL
    private var tasksFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("tasks.json")
    }
    
    // MARK: - Init
    init() {
        loadTasks()
    }
    
    // MARK: - Public Methods
    
    /// Add a new task
    func addTask(_ task: Task) {
        tasks.append(task)
        saveTasks()
    }
    
    /// Delete a task
    func deleteTask(_ task: Task) {
        tasks.removeAll { $0.id == task.id }
        saveTasks()
    }
    
    /// Update an existing task
    func updateTask(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
            saveTasks()
        }
    }
    
    /// Toggle task completion status
    func toggleTaskCompletion(_ task: Task) {
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index].toggleCompletion()
            saveTasks()
        }
    }
    
    // MARK: - Persistence Methods
    
    /// Save tasks to JSON file
    private func saveTasks() {
        do {
            let encoder = JSONEncoder()
            encoder.dateEncodingStrategy = .iso8601
            let data = try encoder.encode(tasks)
            try data.write(to: tasksFileURL, options: [.atomic, .completeFileProtection])
            print("✅ Tasks saved successfully to: \(tasksFileURL.path)")
        } catch {
            print("❌ Failed to save tasks: \(error.localizedDescription)")
        }
    }
    
    /// Load tasks from JSON file
    private func loadTasks() {
        // Check if file exists
        guard FileManager.default.fileExists(atPath: tasksFileURL.path) else {
            print("ℹ️ No tasks file found, starting with empty list")
            return
        }
        
        do {
            let data = try Data(contentsOf: tasksFileURL)
            let decoder = JSONDecoder()
            decoder.dateDecodingStrategy = .iso8601
            tasks = try decoder.decode([Task].self, from: data)
            print("✅ Loaded \(tasks.count) tasks from: \(tasksFileURL.path)")
        } catch {
            print("❌ Failed to load tasks: \(error.localizedDescription)")
            tasks = []
        }
    }
    
    /// Clear all tasks (useful for debugging)
    func clearAllTasks() {
        tasks.removeAll()
        saveTasks()
    }
}

