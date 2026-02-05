//
//  TimerService.swift
//  OneFocus
//
//  Service for managing focus/break timers
//

import Foundation
import Combine

class TimerService: ObservableObject {
    
    static let shared = TimerService()
    
    @Published var isRunning = false
    @Published var isPaused = false
    @Published var timeRemaining: TimeInterval = 0
    @Published var totalDuration: TimeInterval = 0
    
    private var timer: Timer?
    private var startTime: Date?
    private var pausedTime: TimeInterval = 0
    
    private init() {}
    
    // MARK: - Timer Control
    func start(duration: TimeInterval) {
        stop()
        
        totalDuration = duration
        timeRemaining = duration
        startTime = Date()
        isRunning = true
        isPaused = false
        pausedTime = 0
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func pause() {
        guard isRunning, !isPaused else { return }
        
        isPaused = true
        pausedTime = timeRemaining
        timer?.invalidate()
        timer = nil
    }
    
    func resume() {
        guard isRunning, isPaused else { return }
        
        isPaused = false
        startTime = Date().addingTimeInterval(-( totalDuration - pausedTime))
        
        timer = Timer.scheduledTimer(withTimeInterval: 0.1, repeats: true) { [weak self] _ in
            self?.tick()
        }
    }
    
    func stop() {
        isRunning = false
        isPaused = false
        timeRemaining = 0
        totalDuration = 0
        startTime = nil
        pausedTime = 0
        timer?.invalidate()
        timer = nil
    }
    
    // MARK: - Private Methods
    private func tick() {
        guard let startTime = startTime else { return }
        
        let elapsed = Date().timeIntervalSince(startTime)
        timeRemaining = max(0, totalDuration - elapsed)
        
        if timeRemaining <= 0 {
            complete()
        }
    }
    
    private func complete() {
        stop()
        NotificationCenter.default.post(name: .timerCompleted, object: nil)
    }
    
    // MARK: - Computed Properties
    var progress: Double {
        guard totalDuration > 0 else { return 0 }
        return 1.0 - (timeRemaining / totalDuration)
    }
    
    var elapsedTime: TimeInterval {
        return totalDuration - timeRemaining
    }
    
    var canStart: Bool {
        return !isRunning
    }
    
    var canPause: Bool {
        return isRunning && !isPaused
    }
    
    var canResume: Bool {
        return isRunning && isPaused
    }
    
    var canStop: Bool {
        return isRunning
    }
    
    // MARK: - Formatting
    func formattedTime(_ time: TimeInterval) -> String {
        let minutes = Int(time) / 60
        let seconds = Int(time) % 60
        return String(format: "%02d:%02d", minutes, seconds)
    }
    
    var formattedTimeRemaining: String {
        return formattedTime(timeRemaining)
    }
    
    var formattedElapsedTime: String {
        return formattedTime(elapsedTime)
    }
}

// MARK: - Notification Names
extension Notification.Name {
    static let timerCompleted = Notification.Name("timerCompleted")
}
