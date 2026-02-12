//
//  HistoryView.swift
//  OneFocus
//
//  History screen showing completed tasks and focus sessions
//

import SwiftUI
import Combine
import Foundation

struct HistoryView: View {
    
    // MARK: - Environment
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var historyManager: HistoryManager
    
    // MARK: - State
    //@State private var historyItems: HistoryManager
    @State private var selectedFilter: HistoryFilter = .all
    
    // MARK: - Filter Enum
    enum HistoryFilter: String, CaseIterable {
        case all = "All"
        case tasks = "Tasks"
        case sessions = "Sessions"
    }
    
    // MARK: - Computed Properties
    private var filteredItems: [HistoryItem] {
        let filtered: [HistoryItem]
        
        switch selectedFilter {
        case .all:
            filtered = historyManager.historyItems  // Use historyManager instance
        case .tasks:
            filtered = historyManager.historyItems.filter { $0.type == .task }  
        case .sessions:
            filtered = historyManager.historyItems.filter { $0.type == .focusSession || $0.type == .breakSession }
        }
        
        return filtered.sortedByDate
    }

    private var groupedItems: [Date: [HistoryItem]] {
        filteredItems.groupedByDate
    }
    
    private var sortedDates: [Date] {
        groupedItems.keys.sorted(by: >)
    }
    
    // MARK: - Body
    var body: some View {
        VStack(spacing: 0) {
                // Filter bar
                filterBar
                
                Divider()
                    .background(AppConstants.Colors.divider)
                
                // History list
                if filteredItems.isEmpty {
                    emptyState
                } else {
                    historyList
                }
            }
            .background(AppConstants.Colors.backgroundPrimary.ignoresSafeArea())
    }
    
    // MARK: - Filter Bar
    private var filterBar: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            ForEach(HistoryFilter.allCases, id: \.self) { filter in
                Button(action: {
                    withAnimation(.easeInOut(duration: AppConstants.Animation.fast)) {
                        selectedFilter = filter
                    }
                    
                    if userSettings.hapticEnabled {
                        HapticManager.impact(.light)
                    }
                }) {
                    Text(filter.rawValue)
                        .font(.system(size: AppConstants.FontSize.subheadline, weight: selectedFilter == filter ? .medium : .regular))
                        .foregroundColor(selectedFilter == filter ? .white : AppConstants.Colors.textPrimary)
                        .padding(.horizontal, AppConstants.Spacing.md)
                        .padding(.vertical, AppConstants.Spacing.sm)
                        .background(selectedFilter == filter ? AppConstants.Colors.primaryAccent : AppConstants.Colors.backgroundSecondary)
                        .cornerRadius(AppConstants.CornerRadius.pill)
                        .overlay(
                            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.pill)
                                .stroke(selectedFilter == filter ? Color.clear : AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
                        )
                }.buttonStyle(.plain) 
            }
            Spacer()
        }
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.md)
        .background(AppConstants.Colors.backgroundPrimary)
    }
    
    // MARK: - History List
    private var historyList: some View {
        ScrollView {
            LazyVStack(spacing: AppConstants.Spacing.xl, pinnedViews: [.sectionHeaders]) {
                ForEach(sortedDates, id: \.self) { date in
                    Section(header: sectionHeader(for: date)) {
                        VStack(spacing: AppConstants.Spacing.sm) {
                            ForEach(groupedItems[date] ?? []) { item in
                                HistoryItemRow(item: item)
                                    .transition(.opacity)
                            }
                        }
                    }
                }
            }
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, AppConstants.Spacing.lg)
        }
    }
    
    // MARK: - Section Header
    private func sectionHeader(for date: Date) -> some View {
        HStack {
            Text(relativeDateString(for: date))
                .font(.system(size: AppConstants.FontSize.headline, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Spacer()
        }
        .padding(.vertical, AppConstants.Spacing.sm)
        .background(AppConstants.Colors.backgroundPrimary)
    }
    
    private func relativeDateString(for date: Date) -> String {
        if Calendar.current.isDateInToday(date) {
            return "Today"
        } else if Calendar.current.isDateInYesterday(date) {
            return "Yesterday"
        } else {
            let formatter = DateFormatter()
            formatter.dateStyle = .medium
            formatter.timeStyle = .none
            return formatter.string(from: date)
        }
    }
    
    // MARK: - Empty State
    private var emptyState: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            Spacer()
            
            Text("No History Yet")
                .font(.system(size: AppConstants.FontSize.title, weight: .medium))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Text("Complete tasks and focus sessions to see them here")
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xl)
            
            Spacer()
        }
        .frame(maxWidth: .infinity)
    }
}

// MARK: - History Item Row
struct HistoryItemRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            // Icon
            Image(systemName: item.type.icon)
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .frame(width: 32, height: 32)
            
            // Content
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(item.title)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                    .lineLimit(2)
                
                HStack(spacing: AppConstants.Spacing.sm) {
                    Text(item.formattedTime)
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    if let duration = item.formattedDuration {
                        Text("•")
                            .foregroundColor(AppConstants.Colors.textTertiary)
                        
                        Text(duration)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                }
            }
            
            Spacer()
        }
        .padding(AppConstants.Spacing.lg)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.medium)
        .overlay(
            RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                .stroke(AppConstants.Colors.cardBorder, lineWidth: AppConstants.Card.borderWidth)
        )
    }
}
