
//
//  FocusTimer.swift
//  OneFocus
//
//  Reusable circular timer component
//

import SwiftUI

struct FocusTimer: View {

    // MARK: - Properties
    let progress: Double
    let timeRemaining: String
    let isRunning: Bool
    let isPaused: Bool

    // MARK: - Body
    var body: some View {
        ZStack {

            // Background circle
            Circle()
                .stroke(AppConstants.Colors.backgroundTertiary, lineWidth: 20)

            // Progress circle
            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    LinearGradient(
                        gradient: Gradient(colors: [
                            AppConstants.Colors.primaryAccent,
                            AppConstants.Colors.secondaryAccent
                        ]),
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    ),
                    style: StrokeStyle(
                        lineWidth: 20,
                        lineCap: .round
                    )
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            // Time display
            VStack(spacing: AppConstants.Spacing.sm) {
                Text(timeRemaining)
                    .font(.system(size: 64, weight: .bold, design: .rounded))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .monospacedDigit()

                if isRunning {
                    Text(isPaused ? "Paused" : "Focusing")
                        .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
            }
        }
        .frame(width: 280, height: 280)
    }
}

// MARK: - Compact Focus Timer
struct CompactFocusTimer: View {

    let progress: Double
    let timeRemaining: String

    var body: some View {
        ZStack {

            Circle()
                .stroke(AppConstants.Colors.backgroundTertiary, lineWidth: 8)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    AppConstants.Colors.primaryAccent,
                    style: StrokeStyle(lineWidth: 8, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Text(timeRemaining)
                .font(.system(size: 24, weight: .semibold, design: .rounded))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .monospacedDigit()
        }
        .frame(width: 100, height: 100)
    }
}

// MARK: - Mini Focus Timer
struct MiniFocusTimer: View {

    let progress: Double
    let timeRemaining: String

    var body: some View {
        ZStack {

            Circle()
                .stroke(AppConstants.Colors.backgroundTertiary, lineWidth: 4)

            Circle()
                .trim(from: 0, to: max(0, min(1, progress)))
                .stroke(
                    AppConstants.Colors.primaryAccent,
                    style: StrokeStyle(lineWidth: 4, lineCap: .round)
                )
                .rotationEffect(.degrees(-90))
                .animation(.easeInOut(duration: 0.5), value: progress)

            Text(timeRemaining)
                .font(.system(size: 14, weight: .semibold, design: .rounded))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .monospacedDigit()
        }
        .frame(width: 60, height: 60)
    }
}

// MARK: - Preview
struct FocusTimer_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppConstants.Spacing.xl) {

            FocusTimer(
                progress: 0.65,
                timeRemaining: "16:25",
                isRunning: true,
                isPaused: false
            )

            HStack(spacing: AppConstants.Spacing.lg) {
                CompactFocusTimer(
                    progress: 0.4,
                    timeRemaining: "15:00"
                )

                MiniFocusTimer(
                    progress: 0.75,
                    timeRemaining: "6:15"
                )
            }
        }
        .padding()
        .background(AppConstants.Colors.backgroundPrimary)
    }
}
