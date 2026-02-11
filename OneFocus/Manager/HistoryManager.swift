//
//  HistoryManager.swift
//  OneFocus
//
//  Created by Noah McClung on 2/6/26.
//

//
//  HistoryManager.swift
//  OneFocus
//
//  Manages history items for completed tasks and focus sessions
//

import Foundation
import SwiftUI
import Combine

class HistoryManager: ObservableObject {
    @Published var historyItems: [HistoryItem] = []
    
    // MARK: - Initialization
    init() {
        loadHistory()
    }
    
    // MARK: - Add History Items
    
    /// Add a generic history item
    func addItem(_ item: HistoryItem) {
        historyItems.append(item)
        saveHistory()
    }
    
    /// Add a completed task to history
    func addCompletedTask(_ task: Task) {
        let historyItem = HistoryItem(from: task)
        addItem(historyItem)
    }
    
    /// Add a completed focus session to history
    func addCompletedSession(_ session: FocusSession) {
        let historyItem = HistoryItem(from: session)
        addItem(historyItem)
    }
    
    // MARK: - Remove History Items
    
    /// Remove a specific history item
    func removeItem(_ item: HistoryItem) {
        historyItems.removeAll { $0.id == item.id }
        saveHistory()
    }
    
    /// Clear all history
    func clearAllHistory() {
        historyItems.removeAll()
        saveHistory()
    }
    
    // MARK: - Persistence
    
    private var historyFileURL: URL {
        let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first!
        return documentsDirectory.appendingPathComponent("history.json")
    }
    
    /// Save history to disk
    private func saveHistory() {
        do {
            let data = try JSONEncoder().encode(historyItems)
            try data.write(to: historyFileURL)
        } catch {
            print("Failed to save history: \(error.localizedDescription)")
        }
    }
    
    /// Load history from disk
    private func loadHistory() {
        guard FileManager.default.fileExists(atPath: historyFileURL.path) else {
            return
        }
        
        do {
            let data = try Data(contentsOf: historyFileURL)
            historyItems = try JSONDecoder().decode([HistoryItem].self, from: data)
        } catch {
            print("Failed to load history: \(error.localizedDescription)")
        }
    }
}
