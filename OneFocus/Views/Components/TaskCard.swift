//
//  TaskCard.swift
//  OneFocus
//
//  Reusable task card component
//

import SwiftUI

struct TaskCard: View {
    
    // MARK: - Properties
    let task: Task
    let onToggle: () -> Void
    let onTap: (() -> Void)?
    
    @EnvironmentObject var userSettings: UserSettings
    
    // MARK: - Initializer
    init(task: Task, onToggle: @escaping () -> Void, onTap: (() -> Void)? = nil) {
        self.task = task
        self.onToggle = onToggle
        self.onTap = onTap
    }
    
    // MARK: - Body
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            // Completion button
            Button(action: {
                onToggle()
            }) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 24))
                    .foregroundColor(task.isCompleted ? AppConstants.Colors.success : AppConstants.Colors.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
            
            // Task content
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(task.title)
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundColor(task.isCompleted ? AppConstants.Colors.textSecondary : AppConstants.Colors.textPrimary)
                    .strikethrough(task.isCompleted)
                
                HStack(spacing: AppConstants.Spacing.sm) {
                    // Priority indicator
                    HStack(spacing: 4) {
                        Image(systemName: task.priority.icon)
                            .font(.system(size: 12))
                        Text(task.priority.rawValue)
                            .font(.system(size: AppConstants.FontSize.caption))
                    }
                    .foregroundColor(task.priority.color)
                    
                    // Due date if exists
                    if let dueDate = task.dueDate {
                        Text("•")
                            .foregroundColor(AppConstants.Colors.textTertiary)
                        
                        Text(task.formattedDueDate)
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(task.isOverdue ? AppConstants.Colors.error : AppConstants.Colors.textSecondary)
                    }
                    
                    // Completed date
                    if task.isCompleted, let completedDate = task.completedDate {
                        Text("•")
                            .foregroundColor(AppConstants.Colors.textTertiary)
                        
                        Text("Completed \(task.formattedCompletedDate)")
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                }
            }
            
            Spacer()
            
            // Chevron for detail view
            if onTap != nil {
                Image(systemName: "chevron.right")
                    .font(.system(size: 14))
                    .foregroundColor(AppConstants.Colors.textTertiary)
            }
        }
        .padding(AppConstants.Spacing.md)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.medium)
        .shadow(color: Color.black.opacity(0.02), radius: 4, x: 0, y: 1)
        .contentShape(Rectangle())
        .onTapGesture {
            onTap?()
        }
    }
}

// MARK: - Compact Task Card
struct CompactTaskCard: View {
    let task: Task
    let onToggle: () -> Void
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.sm) {
            Button(action: onToggle) {
                Image(systemName: task.isCompleted ? "checkmark.circle.fill" : "circle")
                    .font(.system(size: 20))
                    .foregroundColor(task.isCompleted ? AppConstants.Colors.success : AppConstants.Colors.textTertiary)
            }
            .buttonStyle(PlainButtonStyle())
            
            Text(task.title)
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(task.isCompleted ? AppConstants.Colors.textSecondary : AppConstants.Colors.textPrimary)
                .strikethrough(task.isCompleted)
                .lineLimit(1)
            
            Spacer()
            
            Image(systemName: task.priority.icon)
                .font(.system(size: 12))
                .foregroundColor(task.priority.color)
        }
        .padding(.vertical, AppConstants.Spacing.xs)
    }
}

// MARK: - Preview
struct TaskCard_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            TaskCard(
                task: Task(title: "Write documentation", isCompleted: false, dueDate: Date().addingTimeInterval(3600 * 24), priority: .medium),
                onToggle: {},
                onTap: {}
            )
            
            TaskCard(
                task: Task(title: "Completed task", isCompleted: true, completedDate: Date(), priority: .high),
                onToggle: {},
                onTap: {}
            )
            
            CompactTaskCard(
                task: Task(title: "Quick task", isCompleted: false, dueDate: nil, priority: .low),
                onToggle: {}
            )
        }
        .padding()
        .background(AppConstants.Colors.backgroundPrimary)
        .environmentObject(UserSettings.sample)
    }
}
