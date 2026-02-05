//
//  PersistenceService.swift
//  OneFocus
//
//  Service for persisting app data using UserDefaults and JSON
//

import Foundation

class PersistenceService {
    
    static let shared = PersistenceService()
    
    private let defaults = UserDefaults.standard
    
    // MARK: - Keys
    private enum Keys {
        static let tasks = "onefocus_tasks"
        static let focusSessions = "onefocus_focus_sessions"
        static let historyItems = "onefocus_history_items"
    }
    
    private init() {}
    
    // MARK: - Tasks
    func saveTasks(_ tasks: [Task]) {
        if let encoded = try? JSONEncoder().encode(tasks) {
            defaults.set(encoded, forKey: Keys.tasks)
        }
    }
    
    func loadTasks() -> [Task] {
        guard let data = defaults.data(forKey: Keys.tasks),
              let tasks = try? JSONDecoder().decode([Task].self, from: data) else {
            return []
        }
        return tasks
    }
    
    func saveTask(_ task: Task) {
        var tasks = loadTasks()
        if let index = tasks.firstIndex(where: { $0.id == task.id }) {
            tasks[index] = task
        } else {
            tasks.append(task)
        }
        saveTasks(tasks)
    }
    
    func deleteTask(_ task: Task) {
        var tasks = loadTasks()
        tasks.removeAll { $0.id == task.id }
        saveTasks(tasks)
    }
    
    func deleteTask(withID id: UUID) {
        var tasks = loadTasks()
        tasks.removeAll { $0.id == id }
        saveTasks(tasks)
    }
    
    // MARK: - Focus Sessions
    func saveFocusSessions(_ sessions: [FocusSession]) {
        if let encoded = try? JSONEncoder().encode(sessions) {
            defaults.set(encoded, forKey: Keys.focusSessions)
        }
    }
    
    func loadFocusSessions() -> [FocusSession] {
        guard let data = defaults.data(forKey: Keys.focusSessions),
              let sessions = try? JSONDecoder().decode([FocusSession].self, from: data) else {
            return []
        }
        return sessions
    }
    
    func saveFocusSession(_ session: FocusSession) {
        var sessions = loadFocusSessions()
        if let index = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[index] = session
        } else {
            sessions.append(session)
        }
        saveFocusSessions(sessions)
    }
    
    func deleteFocusSession(_ session: FocusSession) {
        var sessions = loadFocusSessions()
        sessions.removeAll { $0.id == session.id }
        saveFocusSessions(sessions)
    }
    
    func loadSessions() -> [FocusSession] {
        return loadFocusSessions()
    }
    
    func saveSession(_ session: FocusSession) {
        saveFocusSession(session)
    }
    
    func deleteSession(_ session: FocusSession) {
        deleteFocusSession(session)
    }
    
    // MARK: - History Items
    func saveHistoryItems(_ items: [HistoryItem]) {
        if let encoded = try? JSONEncoder().encode(items) {
            defaults.set(encoded, forKey: Keys.historyItems)
        }
    }
    
    func loadHistoryItems() -> [HistoryItem] {
        guard let data = defaults.data(forKey: Keys.historyItems),
              let items = try? JSONDecoder().decode([HistoryItem].self, from: data) else {
            return []
        }
        return items
    }
    
    func saveHistoryItem(_ item: HistoryItem) {
        var items = loadHistoryItems()
        if let index = items.firstIndex(where: { $0.id == item.id }) {
            items[index] = item
        } else {
            items.append(item)
        }
        saveHistoryItems(items)
    }
    
    func deleteHistoryItem(_ item: HistoryItem) {
        var items = loadHistoryItems()
        items.removeAll { $0.id == item.id }
        saveHistoryItems(items)
    }
    
    func clearHistory() {
        defaults.removeObject(forKey: Keys.historyItems)
    }
    
    // MARK: - Bulk Operations
    func deleteAllData() {
        defaults.removeObject(forKey: Keys.tasks)
        defaults.removeObject(forKey: Keys.focusSessions)
        defaults.removeObject(forKey: Keys.historyItems)
    }
    
    func clearAllData() {
        deleteAllData()
    }
    
    // MARK: - Export/Import
    func exportData() -> Data? {
        let exportData: [String: Any] = [
            "tasks": loadTasks().map { try? JSONEncoder().encode($0) }.compactMap { $0 },
            "sessions": loadFocusSessions().map { try? JSONEncoder().encode($0) }.compactMap { $0 },
            "history": loadHistoryItems().map { try? JSONEncoder().encode($0) }.compactMap { $0 }
        ]
        return try? JSONSerialization.data(withJSONObject: exportData)
    }
}
