//
//  MenuBarTimerView.swift
//  OneFocus
//
//  Created by Noah McClung on 12/31/25.
//


import SwiftUI

#if os(macOS)
struct MenuBarTimerMiniView: View {
    @EnvironmentObject var focusTimer: FocusTimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("OneFocus Timer")
                .font(.headline)

            HStack {
                Text("Remaining:")
                Spacer()
                Text(focusTimer.formattedTime)
                    .monospacedDigit()
            }

            Divider()

            HStack(spacing: 10) {
                Button(focusTimer.timerState == .running ? "Pause" : "Start") {
                    // No UserSettings in menu bar context here; if you need it,
                    // inject UserSettings here too. For now, keep menu read-only or add env injection.
                }
                .disabled(true)

                Button("Open App") {
                    NSApp.activate(ignoringOtherApps: true)
                }
            }
        }
        .padding(12)
        .frame(width: 240)
    }
}
#endif
