//
//  OnboardingView.swift
//  OneFocus
//
//  Onboarding flow to showcase app features
//

import SwiftUI

// MARK: - Onboarding Page Model
struct OnboardingPage {
    let icon: String
    let title: String
    let description: String
}

struct OnboardingView: View {

    // MARK: - Environment
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userSettings: UserSettings

    // MARK: - State
    @State private var currentPage = 0

    // MARK: - Onboarding Pages
    private let pages: [OnboardingPage] = [
        OnboardingPage(
            icon: "brain.head.profile",
            title: "Focus Sessions",
            description: "Use Pomodoro-style focus sessions to boost your productivity and maintain deep concentration."
        ),
        OnboardingPage(
            icon: "checklist",
            title: "Task Management",
            description: "Organize your tasks with priorities, due dates, and notes to stay on top of your work."
        ),
        OnboardingPage(
            icon: "note.text",
            title: "Quick Notes",
            description: "Capture ideas instantly with auto-saving notes and rich text editing tools."
        ),
        OnboardingPage(
            icon: "doc.on.clipboard",
            title: "Clipboard History",
            description: "Never lose copied text again. Access your clipboard history anytime."
        ),
        OnboardingPage(
            icon: "chart.bar",
            title: "Track Progress",
            description: "Monitor your focus time and productivity with detailed statistics and insights."
        )
    ]

    var body: some View {
        ZStack {
            // Full-screen background
            AppConstants.Colors.backgroundPrimary
                .ignoresSafeArea()

            // FULL-SCREEN pages
            GeometryReader { proxy in
                TabView(selection: $currentPage) {
                    ForEach(pages.indices, id: \.self) { index in
                        OnboardingPageView(page: pages[index])
                            .tag(index)
                            .frame(width: proxy.size.width, height: proxy.size.height)
                            .contentShape(Rectangle())
                    }
                }
                .frame(width: proxy.size.width, height: proxy.size.height)
                .pageTabViewStyleIfAvailable()
                .frame(width: proxy.size.width, height: proxy.size.height)
            }

            // TOP overlay (Skip)
            VStack {
                HStack {
                    Spacer()
                    Button("Skip", action: completeOnboarding)
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                        .buttonStyle(.plain)
                        .padding(.horizontal, AppConstants.Spacing.xl)
                        .padding(.top, AppConstants.Spacing.xl)
                }
                Spacer()
            }

            // BOTTOM overlay (Back / Next)
            VStack {
                Spacer()
                HStack(spacing: AppConstants.Spacing.lg) {
                    if currentPage > 0 {
                        Button {
                            withAnimation { currentPage -= 1 }
                        } label: {
                            Text("Back")
                                .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                                .foregroundColor(AppConstants.Colors.textPrimary)
                                .frame(width: 120)
                                .padding(.vertical, 14)
                                .background(AppConstants.Colors.backgroundSecondary)
                                .cornerRadius(AppConstants.CornerRadius.medium)
                        }
                        .buttonStyle(.plain)
                    }

                    Spacer()

                    Button {
                        if currentPage < pages.count - 1 {
                            withAnimation { currentPage += 1 }
                        } else {
                            completeOnboarding()
                        }
                    } label: {
                        Text(currentPage == pages.count - 1 ? "Get Started" : "Next")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 120)
                            .padding(.vertical, 14)
                            .background(AppConstants.Colors.primaryAccent)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, AppConstants.Spacing.xl)
                .padding(.bottom, AppConstants.Spacing.xl)
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    private func completeOnboarding() {
        authManager.completeOnboarding()
        userSettings.hasCompletedOnboarding = true
    }
}

// MARK: - Helper Modifier Wrappers
private struct PageTabViewStyleModifier: ViewModifier {
    func body(content: Content) -> some View {
        #if os(iOS)
        if #available(iOS 14.0, *) {
            return AnyView(content.tabViewStyle(.page(indexDisplayMode: .always)))
        } else {
            return AnyView(content)
        }
        #else
        return AnyView(content)
        #endif
    }
}

private extension View {
    func pageTabViewStyleIfAvailable() -> some View {
        modifier(PageTabViewStyleModifier())
    }
}

// MARK: - Onboarding Page View
struct OnboardingPageView: View {
    let page: OnboardingPage

    var body: some View {
        VStack(spacing: AppConstants.Spacing.xl) {
            Spacer(minLength: 0)

            Image(systemName: page.icon)
                .font(.system(size: 80, weight: .regular))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .frame(height: 120)

            Text(page.title)
                .font(.system(size: 32, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)
                .multilineTextAlignment(.center)

            Text(page.description)
                .font(.system(size: AppConstants.FontSize.body))
                .foregroundColor(AppConstants.Colors.textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, AppConstants.Spacing.xxl)
                .lineSpacing(4)

            Spacer(minLength: 0)
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.backgroundPrimary.ignoresSafeArea())
    }
}

// MARK: - Preview
struct OnboardingView_Previews: PreviewProvider {
    static var previews: some View {
        OnboardingView()
            .environmentObject(AuthManager())
            .environmentObject(UserSettings.sample)
    }
}

