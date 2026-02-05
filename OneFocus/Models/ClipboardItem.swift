//
//  ClipboardItem.swift
//  OneFocus
//
//  Model for clipboard history items
//

import Foundation

struct ClipboardItem: Identifiable, Codable, Equatable {
    let id: UUID
    let content: String
    let timestamp: Date
    var isFavorite: Bool
    
    // MARK: - Initializer
    init(id: UUID = UUID(), content: String, timestamp: Date = Date(), isFavorite: Bool = false) {
        self.id = id
        self.content = content
        self.timestamp = timestamp
        self.isFavorite = isFavorite
    }
    
    // MARK: - Computed Properties
    var formattedTimestamp: String {
        let formatter = RelativeDateTimeFormatter()
        formatter.unitsStyle = .abbreviated
        return formatter.localizedString(for: timestamp, relativeTo: Date())
    }
    
    var preview: String {
        let maxLength = 100
        if content.count > maxLength {
            return String(content.prefix(maxLength)) + "..."
        }
        return content
    }
    
    var wordCount: Int {
        content.components(separatedBy: .whitespacesAndNewlines).filter { !$0.isEmpty }.count
    }
    
    var characterCount: Int {
        content.count
    }
    
    // MARK: - Equatable
    static func == (lhs: ClipboardItem, rhs: ClipboardItem) -> Bool {
        lhs.id == rhs.id
    }
    
 
}
