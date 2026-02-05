//
//  AnalyticsService.swift
//  OneFocus
//
//  Service for tracking analytics and generating insights
//

import Foundation
import Combine

@MainActor
class AnalyticsService: ObservableObject {
    
    // MARK: - Singleton
    static let shared = AnalyticsService()
    
    // MARK: - Published Properties
    @Published var events: [AnalyticsEvent] = []
    
    // MARK: - Private Properties
    private let persistenceService = PersistenceService.shared
    
    // MARK: - Initializer
    private init() {
        loadEvents()
    }
    
    // MARK: - Event Tracking
    func trackEvent(_ event: AnalyticsEvent) {
        events.append(event)
        saveEvent(event)
    }
    
    func trackFocusSessionStarted(duration: TimeInterval, taskID: UUID? = nil) {
        let event = AnalyticsEvent(
            type: .focusSessionStarted,
            timestamp: Date(),
            metadata: [
                "duration": String(duration),
                "taskID": taskID?.uuidString ?? "none"
            ]
        )
        trackEvent(event)
    }
    
    func trackFocusSessionCompleted(duration: TimeInterval, actualDuration: TimeInterval, taskID: UUID? = nil) {
        let event = AnalyticsEvent(
            type: .focusSessionCompleted,
            timestamp: Date(),
            metadata: [
                "duration": String(duration),
                "actualDuration": String(actualDuration),
                "taskID": taskID?.uuidString ?? "none",
                "completionRate": String(actualDuration / duration)
            ]
        )
        trackEvent(event)
    }
    
    func trackFocusSessionCancelled(duration: TimeInterval, elapsedTime: TimeInterval) {
        let event = AnalyticsEvent(
            type: .focusSessionCancelled,
            timestamp: Date(),
            metadata: [
                "duration": String(duration),
                "elapsedTime": String(elapsedTime),
                "percentComplete": String((elapsedTime / duration) * 100)
            ]
        )
        trackEvent(event)
    }
    
    func trackBreakStarted(duration: TimeInterval, isLongBreak: Bool) {
        let event = AnalyticsEvent(
            type: .breakStarted,
            timestamp: Date(),
            metadata: [
                "duration": String(duration),
                "isLongBreak": String(isLongBreak)
            ]
        )
        trackEvent(event)
    }
    
    func trackBreakCompleted(duration: TimeInterval, isLongBreak: Bool) {
        let event = AnalyticsEvent(
            type: .breakCompleted,
            timestamp: Date(),
            metadata: [
                "duration": String(duration),
                "isLongBreak": String(isLongBreak)
            ]
        )
        trackEvent(event)
    }
    
    func trackTaskCreated(priority: Task.Priority) {
        let event = AnalyticsEvent(
            type: .taskCreated,
            timestamp: Date(),
            metadata: ["priority": priority.rawValue]
        )
        trackEvent(event)
    }
    
    func trackTaskCompleted(priority: Task.Priority, daysToComplete: Int?) {
        let event = AnalyticsEvent(
            type: .taskCompleted,
            timestamp: Date(),
            metadata: [
                "priority": priority.rawValue,
                "daysToComplete": daysToComplete != nil ? String(daysToComplete!) : "unknown"
            ]
        )
        trackEvent(event)
    }
    
    func trackTaskDeleted(wasCompleted: Bool) {
        let event = AnalyticsEvent(
            type: .taskDeleted,
            timestamp: Date(),
            metadata: ["wasCompleted": String(wasCompleted)]
        )
        trackEvent(event)
    }
    
    func trackGoalReached(goalHours: Double, actualHours: Double) {
        let event = AnalyticsEvent(
            type: .dailyGoalReached,
            timestamp: Date(),
            metadata: [
                "goalHours": String(goalHours),
                "actualHours": String(actualHours)
            ]
        )
        trackEvent(event)
    }
    
    func trackStreakMilestone(streakDays: Int) {
        let event = AnalyticsEvent(
            type: .streakMilestone,
            timestamp: Date(),
            metadata: ["streakDays": String(streakDays)]
        )
        trackEvent(event)
    }
    
    func trackAppOpened() {
        let event = AnalyticsEvent(
            type: .appOpened,
            timestamp: Date()
        )
        trackEvent(event)
    }
    
    func trackSettingsChanged(setting: String, value: String) {
        let event = AnalyticsEvent(
            type: .settingsChanged,
            timestamp: Date(),
            metadata: [
                "setting": setting,
                "value": value
            ]
        )
        trackEvent(event)
    }
    
    // MARK: - Statistics
    func getTotalFocusTime(in period: TimePeriod = .allTime) -> TimeInterval {
        let filteredEvents = eventsInPeriod(period)
            .filter { $0.type == .focusSessionCompleted }
        
        return filteredEvents.reduce(0) { total, event in
            if let durationString = event.metadata?["actualDuration"],
               let duration = TimeInterval(durationString) {
                return total + duration
            }
            return total
        }
    }
    
    func getTotalSessions(in period: TimePeriod = .allTime) -> Int {
        eventsInPeriod(period)
            .filter { $0.type == .focusSessionCompleted }
            .count
    }
    
    func getCompletedTasks(in period: TimePeriod = .allTime) -> Int {
        eventsInPeriod(period)
            .filter { $0.type == .taskCompleted }
            .count
    }
    
    func getAverageSessionDuration(in period: TimePeriod = .allTime) -> TimeInterval {
        let sessions = eventsInPeriod(period)
            .filter { $0.type == .focusSessionCompleted }
        
        guard !sessions.isEmpty else { return 0 }
        
        let totalDuration = sessions.reduce(0.0) { total, event in
            if let durationString = event.metadata?["actualDuration"],
               let duration = TimeInterval(durationString) {
                return total + duration
            }
            return total
        }
        
        return totalDuration / Double(sessions.count)
    }
    
    func getSessionCompletionRate(in period: TimePeriod = .allTime) -> Double {
        let filtered = eventsInPeriod(period)
        let started = filtered.filter { $0.type == .focusSessionStarted }.count
        let completed = filtered.filter { $0.type == .focusSessionCompleted }.count
        
        guard started > 0 else { return 0 }
        return Double(completed) / Double(started)
    }
    
    func getMostProductiveHour() -> Int? {
        let completedSessions = events.filter { $0.type == .focusSessionCompleted }
        
        let hourCounts = Dictionary(grouping: completedSessions) { event in
            Calendar.current.component(.hour, from: event.timestamp)
        }.mapValues { $0.count }
        
        return hourCounts.max(by: { $0.value < $1.value })?.key
    }
    
    func getMostProductiveDay() -> Int? {
        let completedSessions = events.filter { $0.type == .focusSessionCompleted }
        
        let dayCounts = Dictionary(grouping: completedSessions) { event in
            Calendar.current.component(.weekday, from: event.timestamp)
        }.mapValues { $0.count }
        
        return dayCounts.max(by: { $0.value < $1.value })?.key
    }
    
    func getCurrentStreak() -> Int {
        let calendar = Calendar.current
        let completedSessions = events.filter { $0.type == .focusSessionCompleted }
        
        guard !completedSessions.isEmpty else { return 0 }
        
        let uniqueDays = Set(completedSessions.map { calendar.startOfDay(for: $0.timestamp) })
        let sortedDays = uniqueDays.sorted(by: >)
        
        var streak = 0
        var currentDate = calendar.startOfDay(for: Date())
        
        for day in sortedDays {
            if day == currentDate || day == calendar.date(byAdding: .day, value: -1, to: currentDate) {
                streak += 1
                currentDate = calendar.date(byAdding: .day, value: -1, to: day) ?? day
            } else {
                break
            }
        }
        
        return streak
    }
    
    func getLongestStreak() -> Int {
        let calendar = Calendar.current
        let completedSessions = events.filter { $0.type == .focusSessionCompleted }
        
        guard !completedSessions.isEmpty else { return 0 }
        
        let uniqueDays = Set(completedSessions.map { calendar.startOfDay(for: $0.timestamp) })
        let sortedDays = uniqueDays.sorted()
        
        var longestStreak = 0
        var currentStreak = 1
        
        for i in 1..<sortedDays.count {
            let dayDiff = calendar.dateComponents([.day], from: sortedDays[i-1], to: sortedDays[i]).day ?? 0
            
            if dayDiff == 1 {
                currentStreak += 1
                longestStreak = max(longestStreak, currentStreak)
            } else {
                currentStreak = 1
            }
        }
        
        return max(longestStreak, currentStreak)
    }
    
    // MARK: - Insights
    func generateInsights() -> [String] {
        var insights: [String] = []
        
        // Streak insight
        let streak = getCurrentStreak()
        if streak >= 7 {
            insights.append("🔥 Amazing! You're on a \(streak)-day streak!")
        } else if streak >= 3 {
            insights.append("💪 Keep it up! \(streak) days in a row!")
        }
        
        // Productivity time
        if let hour = getMostProductiveHour() {
            let formatter = DateFormatter()
            formatter.dateFormat = "ha"
            let date = Calendar.current.date(bySettingHour: hour, minute: 0, second: 0, of: Date()) ?? Date()
            insights.append("⏰ You're most productive around \(formatter.string(from: date))")
        }
        
        // Completion rate
        let completionRate = getSessionCompletionRate(in: .week)
        if completionRate >= 0.9 {
            insights.append("⭐ Excellent focus! \(Int(completionRate * 100))% session completion rate")
        }
        
        // Total focus time
        let totalTime = getTotalFocusTime(in: .week)
        let hours = Int(totalTime) / 3600
        if hours >= 20 {
            insights.append("🎯 Incredible! \(hours) hours of deep work this week")
        }
        
        return insights
    }
    
    // MARK: - Period Filtering
    enum TimePeriod {
        case today
        case week
        case month
        case year
        case allTime
        
        var startDate: Date? {
            let calendar = Calendar.current
            let now = Date()
            
            switch self {
            case .today:
                return calendar.startOfDay(for: now)
            case .week:
                return calendar.date(byAdding: .day, value: -7, to: now)
            case .month:
                return calendar.date(byAdding: .month, value: -1, to: now)
            case .year:
                return calendar.date(byAdding: .year, value: -1, to: now)
            case .allTime:
                return nil
            }
        }
    }
    
    private func eventsInPeriod(_ period: TimePeriod) -> [AnalyticsEvent] {
        guard let startDate = period.startDate else {
            return events
        }
        
        return events.filter { $0.timestamp >= startDate }
    }
    
    // MARK: - Data Management
    private func saveEvent(_ event: AnalyticsEvent) {
        // Save to UserDefaults or persistence service
        // For now, just keep in memory
    }
    
    private func loadEvents() {
        // Load from UserDefaults or persistence service
        // For now, start with empty array
        events = []
    }
    
    func clearEvents() {
        events.removeAll()
    }
    
    func exportEvents() -> String {
        var csv = "Type,Timestamp,Metadata\n"
        
        for event in events {
            let metadataString = event.metadata?.map { "\($0.key):\($0.value)" }.joined(separator: ";") ?? ""
            csv += "\(event.type.rawValue),\(event.timestamp),\(metadataString)\n"
        }
        
        return csv
    }
}

// MARK: - Analytics Event
struct AnalyticsEvent: Identifiable, Codable {
    let id: UUID
    let type: EventType
    let timestamp: Date
    let metadata: [String: String]?
    
    init(id: UUID = UUID(), type: EventType, timestamp: Date, metadata: [String: String]? = nil) {
        self.id = id
        self.type = type
        self.timestamp = timestamp
        self.metadata = metadata
    }
    
    enum EventType: String, Codable {
        case focusSessionStarted
        case focusSessionCompleted
        case focusSessionCancelled
        case breakStarted
        case breakCompleted
        case taskCreated
        case taskCompleted
        case taskDeleted
        case dailyGoalReached
        case streakMilestone
        case appOpened
        case settingsChanged
    }
}
