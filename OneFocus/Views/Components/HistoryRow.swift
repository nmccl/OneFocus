//
//  HistoryRow.swift
//  OneFocus
//
//  Reusable history item row component
//

import SwiftUI

struct HistoryRow: View {
    
    // MARK: - Properties
    let item: HistoryItem
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            // Icon
            ZStack {
                Circle()
                    .fill(iconBackgroundColor)
                    .frame(width: 44, height: 44)
                
                Image(systemName: item.type.icon)
                    .font(.system(size: 18))
                    .foregroundColor(iconColor)
            }
            
            // Content
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(item.title)
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                HStack(spacing: AppConstants.Spacing.sm) {
                    Text(item.formattedTime)
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    
                    if let duration = item.formattedDuration {
                        Text("•")
                            .foregroundColor(AppConstants.Colors.textTertiary)
                        
                        HStack(spacing: 4) {
                            Image(systemName: "clock")
                                .font(.system(size: 10))
                            Text(duration)
                        }
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                    
                    // Metadata
                    if let priority = item.metadata?["priority"] {
                        Text("•")
                            .foregroundColor(AppConstants.Colors.textTertiary)
                        
                        Text(priority)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(priorityColor(priority))
                    }
                }
            }
            
            Spacer()
        }
        .padding(AppConstants.Spacing.md)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
    }
    
    // MARK: - Computed Properties
    private var iconColor: Color {
        switch item.type {
        case .task:
            return AppConstants.Colors.success
        case .focusSession:
            return AppConstants.Colors.primaryAccent
        case .breakSession:
            return AppConstants.Colors.secondaryAccent
        }
    }
    
    private var iconBackgroundColor: Color {
        iconColor.opacity(0.15)
    }
    
    private func priorityColor(_ priority: String) -> Color {
        switch priority {
        case "High":
            return AppConstants.Colors.error
        case "Medium":
            return AppConstants.Colors.warning
        case "Low":
            return AppConstants.Colors.success
        default:
            return AppConstants.Colors.textSecondary
        }
    }
}

// MARK: - Compact History Row
struct CompactHistoryRow: View {
    let item: HistoryItem
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            Image(systemName: item.type.icon)
                .font(.system(size: 16))
                .foregroundColor(iconColor)
                .frame(width: 24)
            
            Text(item.title)
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .lineLimit(1)
            
            Spacer()
            
            if let duration = item.formattedDuration {
                Text(duration)
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
        }
        .padding(.vertical, AppConstants.Spacing.xs)
    }
    
    private var iconColor: Color {
        switch item.type {
        case .task:
            return AppConstants.Colors.success
        case .focusSession:
            return AppConstants.Colors.primaryAccent
        case .breakSession:
            return AppConstants.Colors.secondaryAccent
        }
    }
}

// MARK: - Preview
struct HistoryRow_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            HistoryRow(item: HistoryItem.sample)
            
            HistoryRow(item: HistoryItem(
                type: .focusSession,
                date: Date(),
                referenceID: UUID(),
                title: "Focus Session",
                duration: 1500
            ))
            
            CompactHistoryRow(item: HistoryItem.sample)
        }
        .padding()
        .background(AppConstants.Colors.backgroundPrimary)
    }
}
