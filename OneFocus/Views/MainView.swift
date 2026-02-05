//
//  MainView.swift
//  OneFocus
//

import SwiftUI
import AppKit
struct MainView: View {

    // MARK: - Environment
    @EnvironmentObject var userSettings: UserSettings
    @EnvironmentObject var authManager: AuthManager

    // MARK: - State
    @State private var selectedTab: NavigationTab = .home

    @State private var showingSettings = false
    @State private var showingStats = false
    @State private var showingAccount = false

    // MARK: - Navigation Tab Enum
    enum NavigationTab: String, CaseIterable, Hashable {
        case home = "Home"
        case focus = "Focus"
        case tasks = "Tasks"
        case history = "History"
        case notes = "Quick Notes"
        case clipboard = "Clipboard"

        var icon: String {
            switch self {
            case .home: return "house"
            case .focus: return "brain.head.profile"
            case .tasks: return "checklist"
            case .history: return "clock.arrow.circlepath"
            case .notes: return "note.text"
            case .clipboard: return "doc.on.clipboard"
            }
        }

        var iconFilled: String {
            switch self {
            case .home: return "house.fill"
            case .focus: return "brain.head.profile"
            case .tasks: return "checklist"
            case .history: return "clock.arrow.circlepath"
            case .notes: return "note.text"
            case .clipboard: return "doc.on.clipboard.fill"
            }
        }
    }

    // MARK: - Body
    var body: some View {
        Group {
            #if os(iOS)
            iOSRoot
            #else
            macOSRoot
            #endif
        }
        // This edits the size constraints - adjust width and height values to match your reference image size
        .frame(minWidth: 650, minHeight: 400) // Prevents window from being resized smaller than these dimensions
        .sheet(isPresented: $showingSettings) {
            SettingsView()
                .environmentObject(userSettings)
        }
        .sheet(isPresented: $showingStats) {
            StatsView()
                .environmentObject(userSettings)
        }
        .sheet(isPresented: $showingAccount) {
            AccountSettingsView()
                .environmentObject(userSettings)
                .environmentObject(authManager)
        }
    }
    

    // MARK: - macOS Root (Sidebar + Detail)
    private var macOSRoot: some View {
        NavigationSplitView {
            sidebarContent
        } detail: {
            detailContent
        }
        .navigationSplitViewStyle(.balanced)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }

    // MARK: - iOS Root (Tab Bar)
    private var iOSRoot: some View {
        TabView(selection: $selectedTab) {
            HomeView(selectedTab: $selectedTab)
                .tag(NavigationTab.home)
                .tabItem { Label(NavigationTab.home.rawValue, systemImage: selectedTab == .home ? NavigationTab.home.iconFilled : NavigationTab.home.icon) }

            FocusView()
                .tag(NavigationTab.focus)
                .tabItem { Label(NavigationTab.focus.rawValue, systemImage: selectedTab == .focus ? NavigationTab.focus.iconFilled : NavigationTab.focus.icon) }

            TasksView()
                .tag(NavigationTab.tasks)
                .tabItem { Label(NavigationTab.tasks.rawValue, systemImage: selectedTab == .tasks ? NavigationTab.tasks.iconFilled : NavigationTab.tasks.icon) }

            QuickNotesView()
                .tag(NavigationTab.notes)
                .tabItem { Label(NavigationTab.notes.rawValue, systemImage: selectedTab == .notes ? NavigationTab.notes.iconFilled : NavigationTab.notes.icon) }

            ClipboardHistoryView()
                .tag(NavigationTab.clipboard)
                .tabItem { Label(NavigationTab.clipboard.rawValue, systemImage: selectedTab == .clipboard ? NavigationTab.clipboard.iconFilled : NavigationTab.clipboard.icon) }

            HistoryView()
                .tag(NavigationTab.history)
                .tabItem { Label(NavigationTab.history.rawValue, systemImage: selectedTab == .history ? NavigationTab.history.iconFilled : NavigationTab.history.icon) }
        }
        .tint(AppConstants.Colors.primaryAccent)
        .background(AppConstants.Colors.backgroundPrimary.ignoresSafeArea())
    }

    // MARK: - Sidebar Content (macOS)
    private var sidebarContent: some View {
        VStack(spacing: 0) {
            VStack(spacing: AppConstants.Spacing.xs) {
                Text("OneFocus")
                    .font(.system(size: 20, weight: .semibold))
                    .foregroundColor(AppConstants.Colors.textPrimary)
            }
            .frame(maxWidth: .infinity)
            .padding(.vertical, AppConstants.Spacing.lg)
            .padding(.horizontal, AppConstants.Spacing.md)

            Divider()
                .background(AppConstants.Colors.divider)

            ScrollView {
                VStack(spacing: AppConstants.Spacing.xs) {
                    ForEach(NavigationTab.allCases, id: \.self) { tab in
                        SidebarNavigationButton(
                            tab: tab,
                            isSelected: selectedTab == tab
                        ) {
                            selectedTab = tab
                            if userSettings.hapticEnabled {
                                HapticManager.impact(.light)
                            }
                        }
                    }
                }
                .padding(.vertical, AppConstants.Spacing.md)
                .padding(.horizontal, AppConstants.Spacing.sm)
            }

            Spacer()

            Divider()
                .background(AppConstants.Colors.divider)

            userProfileButton
                .padding(AppConstants.Spacing.md)
        }
        .frame(minWidth: 220, idealWidth: 240, maxWidth: 260)
        .background(AppConstants.Colors.backgroundSecondary)
    }

    // MARK: - Detail Content (macOS)
    @ViewBuilder
    private var detailContent: some View {
        Group {
            switch selectedTab {
            case .home:
                HomeView(selectedTab: $selectedTab)
            case .focus:
                FocusView()
            case .tasks:
                TasksView()
            case .history:
                HistoryView()
            case .notes:
                QuickNotesView()
            case .clipboard:
                ClipboardHistoryView()
            }
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(AppConstants.Colors.backgroundPrimary)
    }

    // MARK: - User Profile Button (macOS)
    private var userProfileButton: some View {
        Menu {
            Button {
                showingAccount = true
            } label: {
                Label("Account Settings", systemImage: "person.circle")
            }

            Button {
                showingStats = true
            } label: {
                Label("Statistics", systemImage: "chart.bar")
            }

            Button {
                showingSettings = true
            } label: {
                Label("App Settings", systemImage: "gearshape")
            }

            Divider()

            Button {
                authManager.signOut()
            } label: {
                Label("Sign Out", systemImage: "rectangle.portrait.and.arrow.right")
            }
        } label: {
            HStack(spacing: AppConstants.Spacing.sm) {
                Image(systemName: "person.crop.circle.fill")
                    .font(.system(size: 32))
                    .foregroundColor(AppConstants.Colors.textSecondary)

                VStack(alignment: .leading, spacing: 2) {
                    Text(userSettings.userName)
                        .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                        .foregroundColor(AppConstants.Colors.textPrimary)

                    Text("View Profile")
                        .font(.system(size: AppConstants.FontSize.caption))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }

                Spacer()

                Image(systemName: "chevron.up")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textTertiary)
            }
            .padding(AppConstants.Spacing.sm)
            .background(AppConstants.Colors.cardBackground)
            .cornerRadius(AppConstants.CornerRadius.medium)
            .overlay(
                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                    .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
            )
        }
        .menuStyle(.borderlessButton)
        .buttonStyle(.plain)
    }
}

// MARK: - Sidebar Navigation Button (macOS)
struct SidebarNavigationButton: View {
    let tab: MainView.NavigationTab
    let isSelected: Bool
    let action: () -> Void

    var body: some View {
        Button(action: action) {
            HStack(spacing: AppConstants.Spacing.sm) {
                Image(systemName: isSelected ? tab.iconFilled : tab.icon)
                    .font(.system(size: 16, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? AppConstants.Colors.textPrimary : AppConstants.Colors.textSecondary)
                    .frame(width: 20)

                Text(tab.rawValue)
                    .font(.system(size: AppConstants.FontSize.body, weight: isSelected ? .medium : .regular))
                    .foregroundColor(isSelected ? AppConstants.Colors.textPrimary : AppConstants.Colors.textSecondary)

                Spacer()
            }
            .padding(.horizontal, AppConstants.Spacing.md)
            .padding(.vertical, AppConstants.Spacing.sm)
            .background(isSelected ? AppConstants.Colors.backgroundTertiary : Color.clear)
            .cornerRadius(AppConstants.CornerRadius.medium)
        }
        .buttonStyle(.plain)
    }
}
