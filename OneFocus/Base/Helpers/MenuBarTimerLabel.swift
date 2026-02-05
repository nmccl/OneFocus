//
//  MenuBarTimerLabel.swift
//  OneFocus
//
//  Created by Noah McClung on 12/31/25.
//


//
//  MenuBarTimerLabel.swift
//  OneFocus (macOS)
//

import SwiftUI

#if os(macOS)
struct MenuBarTimerLabel: View {
    @EnvironmentObject private var focusTimer: FocusTimerManager

    var body: some View {
        // ✅ Keep it short in the menubar.
        Text(focusTimer.menuBarTitle)
            .monospacedDigit()
    }
}
#endif