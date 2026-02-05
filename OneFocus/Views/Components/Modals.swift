//
//  Modals.swift
//  OneFocus
//
//  Reusable modal and alert components
//

import SwiftUI

// MARK: - Confirmation Modal
struct ConfirmationModal: View {
    let title: String
    let message: String
    let confirmTitle: String
    let cancelTitle: String
    let isDestructive: Bool
    let onConfirm: () -> Void
    let onCancel: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    init(
        title: String,
        message: String,
        confirmTitle: String = "Confirm",
        cancelTitle: String = "Cancel",
        isDestructive: Bool = false,
        onConfirm: @escaping () -> Void,
        onCancel: @escaping () -> Void
    ) {
        self.title = title
        self.message = message
        self.confirmTitle = confirmTitle
        self.cancelTitle = cancelTitle
        self.isDestructive = isDestructive
        self.onConfirm = onConfirm
        self.onCancel = onCancel
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            VStack(spacing: AppConstants.Spacing.md) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.title, weight: .bold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(message)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            VStack(spacing: AppConstants.Spacing.sm) {
                if isDestructive {
                    Button(confirmTitle) {
                        onConfirm()
                        dismiss()
                    }
                    .buttonStyle(DestructiveButtonStyle())
                    .frame(maxWidth: .infinity)
                } else {
                    Button(confirmTitle) {
                        onConfirm()
                        dismiss()
                    }
                    .buttonStyle(PrimaryButtonStyle())
                    .frame(maxWidth: .infinity)
                }
                
                Button(cancelTitle) {
                    onCancel()
                    dismiss()
                }
                .buttonStyle(SecondaryButtonStyle())
                .frame(maxWidth: .infinity)
            }
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        .padding(AppConstants.Spacing.lg)
    }
}

// MARK: - Success Modal
struct SuccessModal: View {
    let title: String
    let message: String
    let buttonTitle: String
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    init(
        title: String = "Success!",
        message: String,
        buttonTitle: String = "Done",
        onDismiss: @escaping () -> Void = {}
    ) {
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            Image(systemName: "checkmark.circle.fill")
                .font(.system(size: 64))
                .foregroundColor(AppConstants.Colors.success)
            
            VStack(spacing: AppConstants.Spacing.md) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.title, weight: .bold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(message)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(buttonTitle) {
                onDismiss()
                dismiss()
            }
            .primaryButtonStyle()
            .frame(maxWidth: .infinity)
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        .padding(AppConstants.Spacing.lg)
    }
}

// MARK: - Info Modal
struct InfoModal: View {
    let icon: String
    let iconColor: Color
    let title: String
    let message: String
    let buttonTitle: String
    let onDismiss: () -> Void
    
    @Environment(\.dismiss) var dismiss
    
    init(
        icon: String = "info.circle.fill",
        iconColor: Color = AppConstants.Colors.primaryAccent,
        title: String,
        message: String,
        buttonTitle: String = "Got it",
        onDismiss: @escaping () -> Void = {}
    ) {
        self.icon = icon
        self.iconColor = iconColor
        self.title = title
        self.message = message
        self.buttonTitle = buttonTitle
        self.onDismiss = onDismiss
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            Image(systemName: icon)
                .font(.system(size: 64))
                .foregroundColor(iconColor)
            
            VStack(spacing: AppConstants.Spacing.md) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.title, weight: .bold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
                
                Text(message)
                    .font(.system(size: AppConstants.FontSize.body))
                    .foregroundColor(AppConstants.Colors.textSecondary)
                    .multilineTextAlignment(.center)
            }
            
            Button(buttonTitle) {
                onDismiss()
                dismiss()
            }
            .primaryButtonStyle()
            .frame(maxWidth: .infinity)
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
        .padding(AppConstants.Spacing.lg)
    }
}

// MARK: - Loading Modal
struct LoadingModal: View {
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
                .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(AppConstants.Spacing.xl)
        .background(AppConstants.Colors.cardBackground)
        .cornerRadius(AppConstants.CornerRadius.large)
        .shadow(color: Color.black.opacity(0.04), radius: 12, x: 0, y: 4)
    }
}

// MARK: - Action Sheet Item
struct ActionSheetItem: Identifiable {
    let id = UUID()
    let title: String
    let icon: String?
    let isDestructive: Bool
    let action: () -> Void
    
    init(
        title: String,
        icon: String? = nil,
        isDestructive: Bool = false,
        action: @escaping () -> Void
    ) {
        self.title = title
        self.icon = icon
        self.isDestructive = isDestructive
        self.action = action
    }
}

// MARK: - Custom Action Sheet
struct CustomActionSheet: View {
    let title: String?
    let message: String?
    let items: [ActionSheetItem]
    let cancelTitle: String
    
    @Environment(\.dismiss) var dismiss
    
    init(
        title: String? = nil,
        message: String? = nil,
        items: [ActionSheetItem],
        cancelTitle: String = "Cancel"
    ) {
        self.title = title
        self.message = message
        self.items = items
        self.cancelTitle = cancelTitle
    }
    
    var body: some View {
        VStack(spacing: AppConstants.Spacing.md) {
            if let title = title {
                VStack(spacing: AppConstants.Spacing.xs) {
                    Text(title)
                        .font(.system(size: AppConstants.FontSize.headline, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                    
                    if let message = message {
                        Text(message)
                            .font(.system(size: AppConstants.FontSize.subheadline))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                            .multilineTextAlignment(.center)
                    }
                }
                .padding(.top, AppConstants.Spacing.md)
            }
            
            VStack(spacing: 0) {
                ForEach(items) { item in
                    Button(action: {
                        item.action()
                        dismiss()
                    }) {
                        HStack(spacing: AppConstants.Spacing.md) {
                            if let icon = item.icon {
                                Image(systemName: icon)
                                    .font(.system(size: 18))
                                    .foregroundColor(item.isDestructive ? AppConstants.Colors.error : AppConstants.Colors.primaryAccent)
                                    .frame(width: 24)
                            }
                            
                            Text(item.title)
                                .font(.system(size: AppConstants.FontSize.body))
                                .foregroundColor(item.isDestructive ? AppConstants.Colors.error : AppConstants.Colors.textPrimary)
                            
                            Spacer()
                        }
                        .padding(AppConstants.Spacing.md)
                        .background(AppConstants.Colors.cardBackground)
                    }
                    
                    if item.id != items.last?.id {
                        Divider()
                    }
                }
            }
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.CornerRadius.medium)
            
            Button(cancelTitle) {
                dismiss()
            }
            .secondaryButtonStyle()
            .frame(maxWidth: .infinity)
        }
        .padding(AppConstants.Spacing.lg)
        .background(Color.black.opacity(0.001))
    }
}

// MARK: - Preview
struct Modals_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            ConfirmationModal(
                title: "Delete Task",
                message: "Are you sure you want to delete this task? This action cannot be undone.",
                confirmTitle: "Delete",
                isDestructive: true,
                onConfirm: {},
                onCancel: {}
            )
            
            SuccessModal(
                message: "Your focus session has been completed successfully!",
                onDismiss: {}
            )
            
            InfoModal(
                title: "Focus Tips",
                message: "Eliminate distractions and focus on one task at a time for better productivity.",
                onDismiss: {}
            )
            
            LoadingModal()
        }
        .background(AppConstants.Colors.backgroundPrimary)
    }
}
