//
//  HeaderView.swift
//  OneFocus
//
//  Reusable header component
//

import SwiftUI

// MARK: - Standard Header
struct HeaderView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let action: (() -> Void)?
    let actionIcon: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        action: (() -> Void)? = nil,
        actionIcon: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.action = action
        self.actionIcon = actionIcon
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            if let icon = icon {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(AppConstants.Colors.primaryAccent)
            }
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.largeTitle, weight: .bold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: AppConstants.FontSize.subheadline))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if let action = action, let actionIcon = actionIcon {
                Button(action: action) {
                    Image(systemName: actionIcon)
                        .font(.system(size: 20))
                        .foregroundColor(AppConstants.Colors.primaryAccent)
                }
            }
        }
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.md)
    }
}

// MARK: - Section Header
struct SectionHeaderView: View {
    let title: String
    let action: (() -> Void)?
    let actionTitle: String?
    
    init(
        title: String,
        action: (() -> Void)? = nil,
        actionTitle: String? = nil
    ) {
        self.title = title
        self.action = action
        self.actionTitle = actionTitle
    }
    
    var body: some View {
        HStack {
            Text(title)
                .font(.system(size: AppConstants.FontSize.headline, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            Spacer()
            
            if let action = action, let actionTitle = actionTitle {
                Button(action: action) {
                    Text(actionTitle)
                        .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
                        .foregroundColor(AppConstants.Colors.primaryAccent)
                }
            }
        }
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.sm)
    }
}

// MARK: - Card Header
struct CardHeaderView: View {
    let title: String
    let subtitle: String?
    let icon: String?
    let iconColor: Color
    let action: (() -> Void)?
    let actionIcon: String?
    
    init(
        title: String,
        subtitle: String? = nil,
        icon: String? = nil,
        iconColor: Color = AppConstants.Colors.primaryAccent,
        action: (() -> Void)? = nil,
        actionIcon: String? = nil
    ) {
        self.title = title
        self.subtitle = subtitle
        self.icon = icon
        self.iconColor = iconColor
        self.action = action
        self.actionIcon = actionIcon
    }
    
    var body: some View {
        HStack(spacing: AppConstants.Spacing.md) {
            if let icon = icon {
                ZStack {
                    Circle()
                        .fill(iconColor.opacity(0.15))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: icon)
                        .font(.system(size: 20))
                        .foregroundColor(iconColor)
                }
            }
            
            VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                if let subtitle = subtitle {
                    Text(subtitle)
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
            }
            
            Spacer()
            
            if let action = action, let actionIcon = actionIcon {
                Button(action: action) {
                    Image(systemName: actionIcon)
                        .font(.system(size: 16))
                        .foregroundColor(AppConstants.Colors.textTertiary)
                }
            }
        }
        .padding(AppConstants.Spacing.md)
    }
}

// MARK: - Greeting Header
struct GreetingHeaderView: View {
    let greeting: String
    let name: String
    let subtitle: String?
    
    init(greeting: String, name: String, subtitle: String? = nil) {
        self.greeting = greeting
        self.name = name
        self.subtitle = subtitle
    }
    
    var body: some View {
        VStack(alignment: .leading, spacing: AppConstants.Spacing.xs) {
            Text("\(greeting), \(name)")
                .font(.system(size: AppConstants.FontSize.largeTitle, weight: .bold))
                .foregroundColor(AppConstants.Colors.textPrimary)
            
            if let subtitle = subtitle {
                Text(subtitle)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(.horizontal, AppConstants.Spacing.lg)
        .padding(.vertical, AppConstants.Spacing.md)
    }
}

// MARK: - Stats Header
struct StatsHeaderView: View {
    let value: String
    let label: String
    let icon: String?
    let trend: TrendDirection?
    
    enum TrendDirection {
        case up, down, stable
        
        var icon: String {
            switch self {
            case .up: return "arrow.up.right"
            case .down: return "arrow.down.right"
            case .stable: return "arrow.right"
            }
        }
        
        var color: Color {
            switch self {
            case .up: return AppConstants.Colors.success
            case .down: return AppConstants.Colors.error
            case .stable: return AppConstants.Colors.warning
            }
        }
    }
    
    init(
        value: String,
        label: String,
        icon: String? = nil,
        trend: TrendDirection? = nil
    ) {
        self.value = value
        self.label = label
        self.icon = icon
        self.trend = trend
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.sm) {
            HStack(alignment: .firstTextBaseline, spacing: AppConstants.Spacing.sm) {
                if let icon = icon {
                    Image(systemName: icon)
                        .font(.system(size: 24))
                        .foregroundColor(AppConstants.Colors.primaryAccent)
                }
                
                Text(value)
                    .font(.system(size: 48, weight: .bold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                if let trend = trend {
                    Image(systemName: trend.icon)
                        .font(.system(size: 20))
                        .foregroundColor(trend.color)
                }
            }
            
            Text(label)
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .frame(maxWidth: .infinity)
        .padding(AppConstants.Spacing.lg)
    }
}

// MARK: - Preview
struct HeaderView_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.xl) {
                HeaderView(
                    title: "Focus",
                    subtitle: "Stay focused on what matters",
                    icon: "brain.head.profile",
                    action: {},
                    actionIcon: "gearshape"
                )
                
                SectionHeaderView(
                    title: "Today's Tasks",
                    action: {},
                    actionTitle: "View all"
                )
                
                CardHeaderView(
                    title: "Focus Session",
                    subtitle: "25 minutes",
                    icon: "timer",
                    action: {},
                    actionIcon: "ellipsis"
                )
                
                GreetingHeaderView(
                    greeting: "Good morning",
                    name: "Alex",
                    subtitle: "Ready to focus?"
                )
                
                StatsHeaderView(
                    value: "2h 45m",
                    label: "Total Focus Time",
                    icon: "clock.fill",
                    trend: .up
                )
            }
        }
        .background(AppConstants.Colors.backgroundPrimary)
    }
}
