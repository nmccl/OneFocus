//  SettingsView.swift
//  OneFocus
//
//  ✅ No ".placeholder"
//  ✅ No mockup state
//  ✅ Uses real SettingsWorkingCopy defaults + loads from UserSettings once

import SwiftUI

struct SettingsView: View {

    @EnvironmentObject private var userSettings: UserSettings
    @Environment(\.dismiss) private var dismiss

    // ✅ real default draft (not a placeholder)
    @State private var draft: SettingsWorkingCopy = .defaults
    @State private var didLoadDraft = false

    var body: some View {
        VStack(spacing: 0) {
            header

            Divider().background(AppConstants.Colors.divider)

            ScrollView {
                VStack(spacing: AppConstants.Spacing.lg) {
                    appearanceSection
                    timerSection
                    behaviorSection
                    feedbackSection
                    resetSection
                }
                .padding(AppConstants.Spacing.xl)
                .frame(maxWidth: 760, alignment: .top)
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(AppConstants.Colors.backgroundPrimary)

            Divider().background(AppConstants.Colors.divider)

            footer
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .onAppear {
            guard !didLoadDraft else { return }
            draft = SettingsWorkingCopy(from: userSettings)
            didLoadDraft = true
        }
    }

    private var header: some View {
        HStack(alignment: .center) {
            VStack(alignment: .leading, spacing: 6) {
                Text("Settings")
                    .font(.system(size: 22, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                Text("Customize OneFocus")
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
            Spacer()
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.backgroundPrimary)
    }

    private var footer: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Button("Cancel") { dismiss() }
                .buttonStyle(.plain)
                .foregroundColor(AppConstants.Colors.textSecondary)

            Spacer()

            Button("Save") {
                draft.apply(to: userSettings)
                dismiss()
            }
            .buttonStyle(.plain)
            .foregroundColor(.white)
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, 10)
            .background(AppConstants.Colors.primaryAccent)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.backgroundPrimary)
    }

    private var appearanceSection: some View {
        CardContainer(title: "Appearance") {
            Picker("Theme", selection: $draft.appearanceMode) {
                ForEach(UserSettings.AppearanceMode.allCases) { mode in
                    Text(mode.displayName).tag(mode)
                }
            }
            .pickerStyle(.segmented)
        }
    }

    private var timerSection: some View {
        CardContainer(title: "Pomodoro Timer") {
            StepperRow(title: "Focus", value: $draft.focusMinutes, range: 1...180, suffix: "min")
            StepperRow(title: "Break", value: $draft.breakMinutes, range: 1...60, suffix: "min")
            StepperRow(title: "Long Break", value: $draft.longBreakMinutes, range: 5...90, suffix: "min")
            StepperRow(title: "Sessions before Long Break", value: $draft.sessionsBeforeLongBreak, range: 2...12, suffix: "")
        }
    }

    private var behaviorSection: some View {
        CardContainer(title: "Behavior") {
            ToggleRow(title: "Auto-start Breaks", isOn: $draft.autoStartBreaks)
            ToggleRow(title: "Auto-start Focus", isOn: $draft.autoStartFocus)
            ToggleRow(title: "Haptics", isOn: $draft.hapticEnabled)
        }
    }

    private var feedbackSection: some View {
        CardContainer(title: "Notifications") {
            ToggleRow(title: "Enable Notifications", isOn: $draft.notificationsEnabled)
            ToggleRow(title: "Sound", isOn: $draft.soundEnabled)
        }
    }

    private var resetSection: some View {
        CardContainer(title: "Reset") {
            Button {
                draft.resetToDefaults()
            } label: {
                HStack {
                    Text("Reset to Defaults")
                    Spacer()
                    Image(systemName: "arrow.counterclockwise")
                }
                .foregroundColor(.red)
            }
            .buttonStyle(.plain)
        }
    }
}

// MARK: - Components used by SettingsView

private struct CardContainer<Content: View>: View {
    let title: String
    @ViewBuilder let content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            Text(title)
                .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)

            VStack(spacing: AppConstants.Spacing.sm) {
                content
            }
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
        )
    }
}

private struct ToggleRow: View {
    let title: String
    @Binding var isOn: Bool

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textPrimary)
            Spacer()
            Toggle("", isOn: $isOn).labelsHidden()
        }
        .padding(.vertical, 4)
    }
}

private struct StepperRow: View {
    let title: String
    @Binding var value: Int
    let range: ClosedRange<Int>
    let suffix: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textPrimary)

            Spacer()

            Text("\(value)\(suffix.isEmpty ? "" : " \(suffix)")")
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .frame(minWidth: 88, alignment: .trailing)

            Stepper("", value: $value, in: range).labelsHidden()
        }
        .padding(.vertical, 4)
    }
}
