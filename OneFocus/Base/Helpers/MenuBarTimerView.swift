//
//  MenuBarTimerView.swift
//  OneFocus
//
//  Created by Noah McClung on 12/31/25.
//
//  MenuBarTimerView.swift xx
//  OneFocus (macOS)
//

import SwiftUI

#if os(macOS)
struct MenuBarTimerView: View {
    @EnvironmentObject private var focusTimer: FocusTimerManager
    @EnvironmentObject private var userSettings: UserSettings

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text(focusTimer.currentSessionType.title)
                .font(.headline)

            Text(focusTimer.formattedTime)
                .font(.system(size: 28, weight: .semibold))
                .monospacedDigit()

            HStack {
                Button(focusTimer.timerState == .running ? "Pause" : "Start") {
                    if focusTimer.timerState == .running { focusTimer.pause() }
                    else { focusTimer.start() }
                }

                Button("Reset") { focusTimer.reset() }
            }
        }
        .padding(12)
        .frame(width: 220)
    }
}
#endif
