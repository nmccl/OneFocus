// ===============================
// FIX 1: HotkeyManager.swift
// - Fixes: “Call to main actor-isolated stop() in deinit”
// ===============================

#if os(macOS)
import AppKit
#endif
import Combine

final class HotkeyManager: ObservableObject {

    enum Action: String {
        case newQuickNote
        case addQuickTask
        case startStopTimer
        case openClipboard
    }

    let actions = PassthroughSubject<Action, Never>()
    @Published private(set) var isRunning: Bool = false

    private var monitor: Any?

    deinit {
        // deinit is nonisolated; do not call actor-isolated methods here.
        if let monitor {
            NSEvent.removeMonitor(monitor)
        }
    }

    func start() {
        // NSEvent monitors must be installed on main thread.
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in self?.start() }
            return
        }

        guard monitor == nil else { return }
        isRunning = true

        monitor = NSEvent.addLocalMonitorForEvents(matching: .keyDown) { [weak self] event in
            guard let self else { return event }

            // Cmd+Shift+N
            if event.modifierFlags.contains([.command, .shift]), event.keyCode == 45 {
                self.actions.send(.newQuickNote)
                return nil
            }
            // Cmd+Shift+T
            if event.modifierFlags.contains([.command, .shift]), event.keyCode == 17 {
                self.actions.send(.startStopTimer)
                return nil
            }
            // Cmd+Shift+A
            if event.modifierFlags.contains([.command, .shift]), event.keyCode == 0 {
                self.actions.send(.addQuickTask)
                return nil
            }
            // Cmd+Shift+V
            if event.modifierFlags.contains([.command, .shift]), event.keyCode == 9 {
                self.actions.send(.openClipboard)
                return nil
            }

            return event
        }
    }

    func stop() {
        if !Thread.isMainThread {
            DispatchQueue.main.async { [weak self] in self?.stop() }
            return
        }

        if let monitor {
            NSEvent.removeMonitor(monitor)
            self.monitor = nil
        }
        isRunning = false
    }
}
