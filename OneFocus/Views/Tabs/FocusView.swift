//
//  FocusView.swift
//  OneFocus
//

import SwiftUI

struct FocusView: View {

    @EnvironmentObject private var focusTimer: FocusTimerManager
    @EnvironmentObject private var userSettings: UserSettings

    var body: some View {
        GeometryReader { geometry in
            ZStack {
                AppConstants.Colors.backgroundPrimary.ignoresSafeArea()

                VStack(spacing: 0) {
                    Spacer()

                    Text(focusTimer.currentSessionType.title)
                        .font(.system(size: 28, weight: .regular))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .padding(.bottom, geometry.size.height * 0.05)

                    let availableHeight = geometry.size.height * 0.5
                    let availableWidth = geometry.size.width * 0.6
                    let maxSize = min(availableHeight, availableWidth)
                    let circleSize = min(max(maxSize, 200), 400)
                    
                    ZStack {
                        Circle()
                            .stroke(AppConstants.Colors.divider, lineWidth: 2)
                            .frame(width: circleSize, height: circleSize)

                        Circle()
                            .trim(from: 0, to: focusTimer.progress)
                            .stroke(
                                AppConstants.Colors.textPrimary,
                                style: StrokeStyle(lineWidth: 8, lineCap: .round)
                            )
                            .frame(width: circleSize, height: circleSize)
                            .rotationEffect(.degrees(-90))
                            .animation(.linear(duration: 0.15), value: focusTimer.progress)

                        Text(focusTimer.formattedTime)
                            .font(.system(size: circleSize * 0.22, weight: .regular, design: .default))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                            .monospacedDigit()
                    }
                    .shadow(color: Color.black.opacity(0.03), radius: 8, x: 0, y: 2)
                    .padding(.bottom, geometry.size.height * 0.05)

                    HStack(spacing: 80) {
                        Button {
                            if focusTimer.timerState == .running {
                                focusTimer.pause()
                                if userSettings.hapticEnabled { HapticManager.impact(.light) }
                            } else {
                                focusTimer.start()
                                if userSettings.hapticEnabled { HapticManager.impact(.light) }
                            }
                        } label: {
                            Text(focusTimer.timerState == .running ? "Pause" : "Start")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(AppConstants.Colors.textPrimary)
                        }
                        .buttonStyle(.plain)

                        Button {
                            focusTimer.reset()
                            if userSettings.hapticEnabled { HapticManager.impact(.medium) }
                        } label: {
                            Text("Reset")
                                .font(.system(size: 24, weight: .regular))
                                .foregroundColor(AppConstants.Colors.textPrimary)
                        }
                        .buttonStyle(.plain)
                    }
                    .padding(.bottom, 20)

                    HStack(spacing: AppConstants.Spacing.md) {
                        sessionTypeButton(.focus, "Focus")
                        sessionTypeButton(.shortBreak, "Break")
                        sessionTypeButton(.longBreak, "Long Break")
                    }
                    .padding(.bottom, 26)

                    HStack(spacing: 16) {
                        ForEach(0..<4, id: \.self) { index in
                            Circle()
                                .fill(index < focusTimer.completedSessions ? AppConstants.Colors.textPrimary : Color.clear)
                                .frame(width: 12, height: 12)
                                .overlay(
                                    Circle().stroke(AppConstants.Colors.textPrimary, lineWidth: 1.5)
                                )
                        }
                    }

                    Spacer()
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    } // this is a test change to test the repository

    private func sessionTypeButton(_ type: FocusTimerManager.SessionType, _ label: String) -> some View {
        Button {
            focusTimer.switchToSession(type)
            if userSettings.hapticEnabled { HapticManager.impact(.light) }
        } label: {
            Text(label)
                .font(
                    .system(
                        size: AppConstants.FontSize.subheadline,
                        weight: focusTimer.currentSessionType == type ? .medium : .regular
                    )
                )
                .foregroundColor(
                    focusTimer.currentSessionType == type
                    ? AppConstants.Colors.textPrimary
                    : AppConstants.Colors.textSecondary
                )
                .padding(.horizontal, AppConstants.Spacing.md)
                .padding(.vertical, AppConstants.Spacing.sm)
                .background(
                    focusTimer.currentSessionType == type ? AppConstants.Colors.backgroundTertiary : Color.clear
                )
                .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}
