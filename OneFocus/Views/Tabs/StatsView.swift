//
//  StatsView.swift
//  OneFocus
//
//  Created by Noah McClung on 12/31/25.
//

//
//  StatsView.swift
//  OneFocus
//
//  UI-first stats screen (no data logic)
//

import SwiftUI

struct StatsView: View {

    // MARK: - Environment
    @EnvironmentObject private var userSettings: UserSettings

    // MARK: - UI State (stub)
    @State private var range: RangeSelection = .week

    enum RangeSelection: String, CaseIterable, Hashable {
        case day = "Day"
        case week = "Week"
        case month = "Month"
        case year = "Year"
    }

    var body: some View {
        ZStack {
            AppConstants.Colors.backgroundPrimary.ignoresSafeArea()

            ScrollView {
                VStack(spacing: AppConstants.Spacing.lg) {
                    header

                    rangePicker

                    summaryGrid

                    focusTrendCard

                    productivityBreakdownCard

                    goalsCard
                }
                .padding(AppConstants.Spacing.xl)
            }
        }
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("Stats")
                .font(.system(size: 28, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)

            Text("Your focus and productivity overview.")
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .center)
        .padding(.top, AppConstants.Spacing.sm)
    }

    // MARK: - Range Picker
    private var rangePicker: some View {
        CardContainer(title: "Range", subtitle: "Choose a window to review") {
            HStack(spacing: AppConstants.Spacing.sm) {
                ForEach(RangeSelection.allCases, id: \.self) { item in
                    StatsFilterChip(
                        title: item.rawValue,
                        isSelected: range == item
                    ) {
                        range = item
                    }
                }
                Spacer()
            }
        }
    }

    // MARK: - Summary Grid
    private var summaryGrid: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            Text("Summary")
                .font(.system(size: 18, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)

            AdaptiveGrid(minItemWidth: 240, spacing: AppConstants.Spacing.md) {
                StatTile(
                    title: "Total Focus",
                    value: placeholderValue(for: range, kind: .totalFocus),
                    footnote: "Time spent in focus sessions",
                    icon: "timer"
                )

                StatTile(
                    title: "Sessions",
                    value: placeholderValue(for: range, kind: .sessions),
                    footnote: "Completed focus sessions",
                    icon: "checkmark.circle"
                )

                StatTile(
                    title: "Streak",
                    value: placeholderValue(for: range, kind: .streak),
                    footnote: "Days in a row you focused",
                    icon: "flame"
                )

                StatTile(
                    title: "Task Completion",
                    value: placeholderValue(for: range, kind: .tasks),
                    footnote: "Completed vs created",
                    icon: "checklist"
                )
            }
        }
    }

    // MARK: - Cards
    private var focusTrendCard: some View {
        CardContainer(title: "Focus Trend", subtitle: "Visualize how you’ve been doing") {
            VStack(spacing: AppConstants.Spacing.md) {
                PlaceholderChart(height: 140)

                HStack {
                    Text("Avg / day")
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    Spacer()
                    Text(placeholderValue(for: range, kind: .avgPerDay))
                        .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                }
            }
        }
    }

    private var productivityBreakdownCard: some View {
        CardContainer(title: "Breakdown", subtitle: "Where your time goes") {
            VStack(spacing: AppConstants.Spacing.md) {
                HStack(spacing: AppConstants.Spacing.md) {
                    BreakdownRow(label: "Focus", percent: 0.62)
                    BreakdownRow(label: "Short Break", percent: 0.23)
                    BreakdownRow(label: "Long Break", percent: 0.15)
                }

                Divider().background(AppConstants.Colors.divider)

                VStack(spacing: AppConstants.Spacing.sm) {
                    MetricRow(title: "Most productive time", value: "Morning (placeholder)")
                    MetricRow(title: "Best day", value: "Tuesday (placeholder)")
                    MetricRow(title: "Average session length", value: "25 min (placeholder)")
                }
            }
        }
    }

    private var goalsCard: some View {
        CardContainer(title: "Goals", subtitle: "Daily focus target") {
            VStack(spacing: AppConstants.Spacing.md) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text("Daily Goal")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textPrimary)

                        Text("Based on your settings")
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }

                    Spacer()

                    Text(formattedDailyGoal(userSettings: userSettings))
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                }

                Divider().background(AppConstants.Colors.divider)

                VStack(alignment: .leading, spacing: 10) {
                    Text("Progress (placeholder)")
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)

                    ProgressView(value: 0.35)
                        .progressViewStyle(.linear)
                }
            }
        }
    }

    // MARK: - Placeholder Values
    private enum ValueKind {
        case totalFocus, sessions, streak, tasks, avgPerDay
    }

    private func placeholderValue(for range: RangeSelection, kind: ValueKind) -> String {
        switch (range, kind) {
        case (.day, .totalFocus): return "1h 15m"
        case (.week, .totalFocus): return "8h 40m"
        case (.month, .totalFocus): return "34h 10m"
        case (.year, .totalFocus): return "212h"

        case (.day, .sessions): return "3"
        case (.week, .sessions): return "22"
        case (.month, .sessions): return "91"
        case (.year, .sessions): return "610"

        case (.day, .streak): return "4 days"
        case (.week, .streak): return "9 days"
        case (.month, .streak): return "18 days"
        case (.year, .streak): return "32 days"

        case (.day, .tasks): return "7 / 10"
        case (.week, .tasks): return "42 / 58"
        case (.month, .tasks): return "168 / 220"
        case (.year, .tasks): return "—"

        case (.day, .avgPerDay): return "1h 15m"
        case (.week, .avgPerDay): return "1h 14m"
        case (.month, .avgPerDay): return "1h 06m"
        case (.year, .avgPerDay): return "0h 41m"
        }
    }

    private func formattedDailyGoal(userSettings: UserSettings) -> String {
        // Fallback formatting: focus minutes per session * sessionsBeforeLongBreak as a rough daily goal.
        let minutes = max(1, userSettings.focusMinutes)
        let sessions = max(1, userSettings.sessionsBeforeLongBreak)
        let total = minutes * sessions
        let hours = total / 60
        let mins = total % 60
        if hours > 0 {
            return mins > 0 ? "\(hours)h \(mins)m" : "\(hours)h"
        } else {
            return "\(mins)m"
        }
    }
}

// MARK: - Reusable UI Components

private struct CardContainer<Content: View>: View {
    let title: String
    let subtitle: String
    @ViewBuilder var content: Content

    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)

                Text(subtitle)
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            content
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

private struct StatTile: View {
    let title: String
    let value: String
    let footnote: String
    let icon: String

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text(title)
                        .font(.system(size: AppConstants.FontSize.caption, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textSecondary)

                    Text(value)
                        .font(.system(size: 22, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                }

                Spacer()

                Image(systemName: icon)
                    .font(.system(size: 18, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textTertiary)
            }

            Text(footnote)
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundColor(AppConstants.Colors.textSecondary)
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

private struct StatsFilterChip: View {
    let title: String
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: AppConstants.FontSize.subheadline, weight: isSelected ? .medium : .regular))
                .foregroundColor(isSelected ? AppConstants.Colors.textPrimary : AppConstants.Colors.textSecondary)
                .padding(.horizontal, AppConstants.Spacing.md)
                .padding(.vertical, 8)
                .background(isSelected ? AppConstants.Colors.backgroundTertiary : AppConstants.Colors.backgroundSecondary)
                .cornerRadius(AppConstants.CornerRadius.medium)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                        .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
                )
        }
        .buttonStyle(.plain)
    }
}

private struct PlaceholderChart: View {
    let height: CGFloat

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                .fill(AppConstants.Colors.backgroundSecondary)
                .overlay(
                    RoundedRectangle(cornerRadius: AppConstants.CornerRadius.large)
                        .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
                )

            HStack(alignment: .bottom, spacing: 10) {
                ForEach(0..<8, id: \.self) { idx in
                    RoundedRectangle(cornerRadius: 6)
                        .fill(AppConstants.Colors.textTertiary.opacity(0.25))
                        .frame(width: 14, height: CGFloat(20 + (idx * 10 % 70)))
                }
            }
        }
        .frame(height: height)
    }
}

private struct BreakdownRow: View {
    let label: String
    let percent: Double

    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(label)
                .font(.system(size: AppConstants.FontSize.caption, weight: .medium))
                .foregroundColor(AppConstants.Colors.textSecondary)

            ZStack(alignment: .leading) {
                RoundedRectangle(cornerRadius: 10)
                    .fill(AppConstants.Colors.backgroundSecondary)
                    .frame(height: 10)

                RoundedRectangle(cornerRadius: 10)
                    .fill(AppConstants.Colors.textPrimary.opacity(0.65))
                    .frame(width: max(10, CGFloat(percent) * 220), height: 10)
            }

            Text("\(Int(percent * 100))%")
                .font(.system(size: AppConstants.FontSize.caption))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
    }
}

private struct MetricRow: View {
    let title: String
    let value: String

    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)

            Spacer()

            Text(value)
                .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
        }
    }
}

private struct AdaptiveGrid<Content: View>: View {
    let minItemWidth: CGFloat
    let spacing: CGFloat
    @ViewBuilder let content: Content

    init(minItemWidth: CGFloat, spacing: CGFloat, @ViewBuilder content: () -> Content) {
        self.minItemWidth = minItemWidth
        self.spacing = spacing
        self.content = content()
    }

    var body: some View {
        GeometryReader { proxy in
            let totalWidth = proxy.size.width
            let columns = max(1, Int((totalWidth + spacing) / (minItemWidth + spacing)))
            let gridItems = Array(repeating: GridItem(.flexible(), spacing: spacing), count: columns)

            LazyVGrid(columns: gridItems, spacing: spacing) {
                content
            }
        }
        .frame(minHeight: 10)
    }
}

// MARK: - Preview
struct StatsView_Previews: PreviewProvider {
    static var previews: some View {
        StatsView()
            .environmentObject(UserSettings.sample)
            .frame(width: 1200, height: 800)
    }
}
