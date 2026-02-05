import SwiftUI

#if os(macOS)
/// A compact menu bar popover view showing the current timer state and remaining time.
/// This view is referenced from OneFocusApp's MenuBarExtra and must remain macOS-only.
struct MenuBarTimerMiniView: View {
    @EnvironmentObject private var focusTimer: FocusTimerManager

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Title / Session type
            Text(focusTimer.currentSessionType.title)
                .font(.headline)

            // Time remaining
            HStack {
                Text("Remaining:")
                Spacer()
                Text(focusTimer.formattedTime)
                    .monospacedDigit()
            }

            Divider()

            // Controls kept read-only in the mini view to avoid accidental changes.
            // You can wire these up later if desired.
            HStack(spacing: 10) {
                Button(focusTimer.timerState == .running ? "Pause" : "Start") {}
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
