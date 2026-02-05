//
//  EmptyStateView.swift
//  OneFocus
//
//  Reusable empty state component
//

import SwiftUI

// MARK: - Empty State View
struct EmptyStateView: View {
    let icon: String
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        icon: String,
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.icon = icon
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            VStack(spacing: AppConstants.Spacing.sm) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.title, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(message)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
                    .lineLimit(3)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .primaryButtonStyle()
            }
        }
        .padding(AppConstants.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Compact Empty State
struct CompactEmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 48))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            Text(message)
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
        }
        .padding(AppConstants.Spacing.lg)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Inline Empty State
struct InlineEmptyStateView: View {
    let icon: String
    let message: String
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            Image(systemName: icon)
                .font(.system(size: 24))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            Text(message)
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(AppConstants.Spacing.md)
        .frame(maxWidth: .infinity)
    }
}

// MARK: - Loading State View
struct LoadingStateView: View {
    let message: String
    
    init(message: String = "Loading...") {
        self.message = message
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            ProgressView()
                .scaleEffect(1.5)
                .tint(AppConstants.Colors.primaryAccent)
            
            Text(message)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Error State View
struct ErrorStateView: View {
    let title: String
    let message: String
    let retryTitle: String
    let onRetry: () -> Void
    
    init(
        title: String = "Something went wrong",
        message: String = "We couldn't load your data. Please try again.",
        retryTitle: String = "Retry",
        onRetry: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.retryTitle = retryTitle
        self.onRetry = onRetry
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            Image(systemName: "exclamationmark.triangle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.error)
            
            VStack(spacing: AppConstants.Spacing.sm) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.title, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(message)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(retryTitle, action: onRetry)
                .primaryButtonStyle()
        }
        .padding(AppConstants.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - No Results View
struct NoResultsView: View {
    let searchQuery: String
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.lg) {
            Image(systemName: "magnifyingglass")
                .font(.system(size: 64))
                .foregroundColor(AppConstants.Colors.textTertiary)
            
            VStack(spacing: AppConstants.Spacing.sm) {
                Text("No results found")
                    .font(.system(size: AppConstants.FontSize.headline, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text("Try adjusting your search for \"\(searchQuery)\"")
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
        }
        .padding(AppConstants.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Success State View
struct SuccessStateView: View {
    let title: String
    let message: String
    let actionTitle: String?
    let action: (() -> Void)?
    
    init(
        title: String,
        message: String,
        actionTitle: String? = nil,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.message = message
        self.actionTitle = actionTitle
        self.action = action
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 80))
                .foregroundColor(AppConstants.Colors.success)
            
            VStack(spacing: AppConstants.Spacing.sm) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.title, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(message)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            if let actionTitle = actionTitle, let action = action {
                Button(actionTitle, action: action)
                    .primaryButtonStyle()
            }
        }
        .padding(AppConstants.Spacing.xl)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

// MARK: - Preview
struct EmptyStateView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.xxl) {
                EmptyStateView(
                    icon: "tray",
                    title: "No Tasks Yet",
                    message: "Create your first task to get started with focused work",
                    actionTitle: "Create Task",
                    action: {}
                )
                .frame(height: 300)
                
                CompactEmptyStateView(
                    icon: "clock",
                    message: "No focus sessions today"
                )
                
                InlineEmptyStateView(
                    icon: "checkmark.circle",
                    message: "All tasks completed!"
                )
                
                LoadingStateView()
                    .frame(height: 200)
                
                ErrorStateView(onRetry: {})
                    .frame(height: 300)
                
                NoResultsView(searchQuery: "meeting")
                    .frame(height: 250)
                
                SuccessStateView(
                    title: "Session Complete!",
                    message: "Great work! You've completed a 25-minute focus session.",
                    actionTitle: "Start Break",
                    action: {}
                )
                .frame(height: 300)
            }
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .environmentObject(UserSettings.sample)
    }
}
