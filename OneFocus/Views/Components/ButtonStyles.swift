//
//  ButtonStyles.swift
//  OneFocus
//
//  Reusable button styles
//

import SwiftUI

// MARK: - Primary Button Style
struct PrimaryButtonStyle: ButtonStyle {
    @EnvironmentObject var userSettings: UserSettings
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, AppConstants.Spacing.md)
            .background(AppConstants.Colors.primaryAccent)
            .cornerRadius(AppConstants.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Secondary Button Style
struct SecondaryButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
            .foregroundColor(AppConstants.Colors.primaryAccent)
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, AppConstants.Spacing.md)
            .background(AppConstants.Colors.primaryAccent.opacity(0.1))
            .cornerRadius(AppConstants.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Outline Button Style
struct OutlineButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
            .foregroundColor(AppConstants.Colors.primaryAccent)
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, AppConstants.Spacing.md)
            .background(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                    .stroke(AppConstants.Colors.primaryAccent, lineWidth: 2)
            )
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Destructive Button Style
struct DestructiveButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppConstants.FontSize.body, weight: .semibold))
            .foregroundColor(.white)
            .padding(.horizontal, AppConstants.Spacing.lg)
            .padding(.vertical, AppConstants.Spacing.md)
            .background(AppConstants.Colors.error)
            .cornerRadius(AppConstants.CornerRadius.medium)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Icon Button Style
struct IconButtonStyle: ButtonStyle {
    let size: CGFloat
    let backgroundColor: Color
    let foregroundColor: Color
    
    init(
        size: CGFloat = 56,
        backgroundColor: Color = AppConstants.Colors.primaryAccent,
        foregroundColor: Color = .white
    ) {
        self.size = size
        self.backgroundColor = backgroundColor
        self.foregroundColor = foregroundColor
    }
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: size * 0.4))
            .foregroundColor(foregroundColor)
            .frame(width: size, height: size)
            .background(backgroundColor)
            .cornerRadius(size / 2)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
            .shadow(color: Color.black.opacity(0.03), radius: 6, x: 0, y: 2)
    }
}

// MARK: - Floating Action Button Style
struct FloatingActionButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: 24, weight: .semibold))
            .foregroundColor(.white)
            .frame(width: 64, height: 64)
            .background(
                LinearGradient(
                    gradient: Gradient(colors: [
                        AppConstants.Colors.primaryAccent,
                        AppConstants.Colors.secondaryAccent
                    ]),
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
            )
            .cornerRadius(32)
            .scaleEffect(configuration.isPressed ? 0.9 : 1.0)
            .animation(.spring(response: 0.3, dampingFraction: 0.6), value: configuration.isPressed)
            .shadow(color: Color.black.opacity(0.04), radius: 8, x: 0, y: 3)
    }
}

// MARK: - Pill Button Style
struct PillButtonStyle: ButtonStyle {
    let isSelected: Bool
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
            .foregroundColor(isSelected ? .white : AppConstants.Colors.textSecondary)
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.sm)
            .background(isSelected ? AppConstants.Colors.primaryAccent : AppConstants.Colors.backgroundTertiary)
            .cornerRadius(AppConstants.CornerRadius.pill)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - Compact Button Style
struct CompactButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(.system(size: AppConstants.FontSize.subheadline, weight: .medium))
            .foregroundColor(AppConstants.Colors.primaryAccent)
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.sm)
            .background(AppConstants.Colors.primaryAccent.opacity(0.1))
            .cornerRadius(AppConstants.CornerRadius.small)
            .scaleEffect(configuration.isPressed ? 0.95 : 1.0)
            .animation(.easeInOut(duration: 0.2), value: configuration.isPressed)
    }
}

// MARK: - View Extension
extension View {
    func primaryButtonStyle() -> some View {
        self.buttonStyle(PrimaryButtonStyle())
    }
    
    func secondaryButtonStyle() -> some View {
        self.buttonStyle(SecondaryButtonStyle())
    }
    
    func outlineButtonStyle() -> some View {
        self.buttonStyle(OutlineButtonStyle())
    }
    
    func destructiveButtonStyle() -> some View {
        self.buttonStyle(DestructiveButtonStyle())
    }
    
    func iconButtonStyle(size: CGFloat = 56, backgroundColor: Color = AppConstants.Colors.primaryAccent, foregroundColor: Color = .white) -> some View {
        self.buttonStyle(IconButtonStyle(size: size, backgroundColor: backgroundColor, foregroundColor: foregroundColor))
    }
    
    func floatingActionButtonStyle() -> some View {
        self.buttonStyle(FloatingActionButtonStyle())
    }
    
    func pillButtonStyle(isSelected: Bool = false) -> some View {
        self.buttonStyle(PillButtonStyle(isSelected: isSelected))
    }
    
    func compactButtonStyle() -> some View {
        self.buttonStyle(CompactButtonStyle())
    }
}

// MARK: - Preview
struct ButtonStyles_Previews: PreviewProvider {
    static var previews: some View {
        ScrollView {
            VStack(spacing: AppConstants.Spacing.lg) {
                Button("Primary Button") {}
                    .primaryButtonStyle()
                
                Button("Secondary Button") {}
                    .secondaryButtonStyle()
                
                Button("Outline Button") {}
                    .outlineButtonStyle()
                
                Button("Destructive Button") {}
                    .destructiveButtonStyle()
                
                HStack(spacing: AppConstants.Spacing.md) {
                    Button {
                    } label: {
                        Image(systemName: "play.fill")
                    }
                    .iconButtonStyle()
                    
                    Button {
                    } label: {
                        Image(systemName: "pause.fill")
                    }
                    .iconButtonStyle(backgroundColor: AppConstants.Colors.warning)
                    
                    Button {
                    } label: {
                        Image(systemName: "stop.fill")
                    }
                    .iconButtonStyle(backgroundColor: AppConstants.Colors.error)
                }
                
                Button {
                } label: {
                    Image(systemName: "plus")
                }
                .floatingActionButtonStyle()
                
                HStack(spacing: AppConstants.Spacing.sm) {
                    Button("All") {}
                        .pillButtonStyle(isSelected: true)
                    
                    Button("Today") {}
                        .pillButtonStyle(isSelected: false)
                    
                    Button("Completed") {}
                        .pillButtonStyle(isSelected: false)
                }
                
                Button("Compact Button") {}
                    .compactButtonStyle()
            }
            .padding()
        }
        .background(AppConstants.Colors.backgroundPrimary)
        .environmentObject(UserSettings.sample)
    }
}
