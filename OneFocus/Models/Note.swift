//
//  Note.swift
//  OneFocus
//
//  Model for Quick Notes
//

import Foundation
import SwiftUI

struct Note: Identifiable, Codable, Equatable {
    let id: UUID
    var title: String
    var content: NSAttributedString
    var createdDate: Date
    var modifiedDate: Date
    
    // MARK: - Initializer
    init(id: UUID = UUID(), title: String = "Untitled", content: NSAttributedString = NSAttributedString(string: ""), createdDate: Date = Date(), modifiedDate: Date = Date()) {
        self.id = id
        self.title = title
        self.content = content
        self.createdDate = createdDate
        self.modifiedDate = modifiedDate
    }
    
    // MARK: - Codable
    enum CodingKeys: String, CodingKey {
        case id, title, contentData, createdDate, modifiedDate
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(UUID.self, forKey: .id)
        title = try container.decode(String.self, forKey: .title)
        let contentData = try container.decode(Data.self, forKey: .contentData)
        content = (try? NSAttributedString(data: contentData, options: [.documentType: NSAttributedString.DocumentType.rtf], documentAttributes: nil)) ?? NSAttributedString(string: "")
        createdDate = try container.decode(Date.self, forKey: .createdDate)
        modifiedDate = try container.decode(Date.self, forKey: .modifiedDate)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(title, forKey: .title)
        let contentData = try content.data(from: NSRange(location: 0, length: content.length), documentAttributes: [.documentType: NSAttributedString.DocumentType.rtf])
        try container.encode(contentData, forKey: .contentData)
        try container.encode(createdDate, forKey: .createdDate)
        try container.encode(modifiedDate, forKey: .modifiedDate)
    }
    
    // MARK: - Computed Properties
    var formattedCreatedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: createdDate)
    }
    
    var formattedModifiedDate: String {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter.string(from: modifiedDate)
    }
    
    var preview: String {
        let plainText = content.string
        let maxLength = 100
        if plainText.count > maxLength {
            return String(plainText.prefix(maxLength)) + "..."
        }
        return plainText
    }
    
    // MARK: - Equatable
    static func == (lhs: Note, rhs: Note) -> Bool {
        lhs.id == rhs.id
    }
    
    // MARK: - Sample Data
    static var sample: Note {
        Note(title: "Sample Note", content: NSAttributedString(string: "This is a sample note with some content."))
    }
    
    static var sampleList: [Note] {
        [
            Note(title: "Meeting Notes", content: NSAttributedString(string: "Discussed project timeline and deliverables.")),
            Note(title: "Ideas", content: NSAttributedString(string: "New feature ideas for the app.")),
            Note(title: "To-Do", content: NSAttributedString(string: "1. Review code\n2. Update documentation\n3. Test features"))
        ]
    }
}
