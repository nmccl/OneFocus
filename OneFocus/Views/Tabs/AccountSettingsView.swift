//
//  AccountSettingsView.swift
//  OneFocus
//
//  Created by Noah McClung on 12/31/25.
//


//
//  AccountSettingsView.swift
//  OneFocus
//
//  Account + profile settings (UI-first, consistent with OneFocus card layout)
//

import SwiftUI

struct AccountSettingsView: View {

    // MARK: - Environment
    @EnvironmentObject private var userSettings: UserSettings
    @EnvironmentObject private var authManager: AuthManager
    @Environment(\.dismiss) private var dismiss

    // MARK: - Draft (applies on Save)
    @State private var draft: Draft
    @State private var isSaving = false

    init() {
        _draft = State(initialValue: Draft(from: UserSettings()))
    }

    var body: some View {
        ZStack {
            AppConstants.Colors.backgroundPrimary.ignoresSafeArea()

            VStack(spacing: 0) {
                header

                ScrollView {
                    VStack(spacing: AppConstants.Spacing.lg) {
                        profileCard
                        securityCard
                        preferencesCard
                        dangerCard
                    }
                    .padding(AppConstants.Spacing.xl)
                }

                footer
            }
        }
        .onAppear { draft = Draft(from: userSettings) }
        .toolbar {
            ToolbarItem(placement: toolbarPlacement) {
                Button("Close") { dismiss() }
                    .keyboardShortcut(.cancelAction)
            }
        }
        #if os(macOS)
        .frame(minWidth: 560, idealWidth: 620, maxWidth: 720,
               minHeight: 640, idealHeight: 720, maxHeight: 860)
        #endif
    }

    // MARK: - Header
    private var header: some View {
        VStack(spacing: 6) {
            Text("Account Settings")
                .font(.system(size: 22, weight: .semibold))
                .foregroundColor(AppConstants.Colors.textPrimary)

            Text("Profile, security, and account actions.")
                .font(.system(size: AppConstants.FontSize.subheadline))
                .foregroundColor(AppConstants.Colors.textSecondary)
        }
        .padding(.top, AppConstants.Spacing.xl)
        .padding(.horizontal, AppConstants.Spacing.xl)
        .padding(.bottom, AppConstants.Spacing.lg)
    }

    // MARK: - Footer
    private var footer: some View {
        VStack(spacing: 0) {
            Divider().background(AppConstants.Colors.divider)

            HStack(spacing: AppConstants.Spacing.md) {
                Button("Cancel") {
                    dismiss()
                }
                .buttonStyle(.plain)
                .foregroundColor(AppConstants.Colors.textSecondary)
                .keyboardShortcut(.cancelAction)

                Spacer()

                Button(action: saveAndClose) {
                    HStack(spacing: 8) {
                        if isSaving { ProgressView().controlSize(.small) }
                        Text("Save")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    }
                    .foregroundColor(.white)
                    .frame(width: 120)
                    .padding(.vertical, 12)
                    .background(AppConstants.Colors.primaryAccent)
                    .cornerRadius(AppConstants.CornerRadius.medium)
                }
                .buttonStyle(.plain)
                .keyboardShortcut(.defaultAction)
                .disabled(isSaving)
            }
            .padding(.horizontal, AppConstants.Spacing.xl)
            .padding(.vertical, AppConstants.Spacing.lg)
            .background(AppConstants.Colors.backgroundPrimary)
        }
    }

    // MARK: - Cards
    private var profileCard: some View {
        SettingsCard(title: "Profile", subtitle: "How you appear in the app") {
            VStack(spacing: AppConstants.Spacing.md) {
                HStack(spacing: AppConstants.Spacing.md) {
                    Image(systemName: "person.crop.circle.fill")
                        .font(.system(size: 52))
                        .foregroundColor(AppConstants.Colors.textSecondary)

                    VStack(alignment: .leading, spacing: 6) {
                        TextField("Display Name", text: $draft.displayName)
                            .textFieldStyle(.plain)
                            .padding(.horizontal, AppConstants.Spacing.md)
                            .padding(.vertical, 10)
                            .background(AppConstants.Colors.backgroundSecondary)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                            .overlay(
                                RoundedRectangle(cornerRadius: AppConstants.CornerRadius.medium)
                                    .stroke(AppConstants.Colors.cardBorder, lineWidth: 0.5)
                            )

                        Text("This name is used across the app UI.")
                            .font(.system(size: AppConstants.FontSize.caption))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }

                    Spacer()
                }

                Divider().background(AppConstants.Colors.divider)

                ToggleRow(
                    title: "Show in Profile Menu",
                    subtitle: "Display your name in the bottom profile menu.",
                    isOn: $draft.showNameInMenu
                )
            }
        }
    }

    private var securityCard: some View {
        SettingsCard(title: "Security", subtitle: "Sign-in and access") {
            VStack(spacing: AppConstants.Spacing.md) {
                ToggleRow(
                    title: "Require Sign-In",
                    subtitle: "Keep OneFocus locked behind authentication.",
                    isOn: $draft.requireAuth
                )

                Divider().background(AppConstants.Colors.divider)

                ToggleRow(
                    title: "Biometric Unlock",
                    subtitle: "Use Face ID / Touch ID when available.",
                    isOn: $draft.biometricUnlock
                )
                .disabled(!draft.requireAuth)
                .opacity(draft.requireAuth ? 1 : 0.55)

                Divider().background(AppConstants.Colors.divider)

                Button(action: {}) {
                    HStack {
                        Text("Change Password")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textPrimary)
                        Spacer()
                        Image(systemName: "chevron.right")
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(AppConstants.Colors.textTertiary)
                    }
                    .padding(.vertical, 8)
                }
                .buttonStyle(.plain)
                .disabled(true) // UI stub; wire later
                .opacity(0.55)
            }
        }
    }

    private var preferencesCard: some View {
        SettingsCard(title: "Preferences", subtitle: "Small account behaviors") {
            VStack(spacing: AppConstants.Spacing.md) {
                ToggleRow(
                    title: "Email Updates",
                    subtitle: "Receive feature updates and tips.",
                    isOn: $draft.emailUpdates
                )

                Divider().background(AppConstants.Colors.divider)

                ToggleRow(
                    title: "Analytics",
                    subtitle: "Help improve OneFocus by sending anonymous usage data.",
                    isOn: $draft.analytics
                )
            }
        }
    }

    private var dangerCard: some View {
        SettingsCard(title: "Account Actions", subtitle: "Be careful") {
            VStack(spacing: AppConstants.Spacing.md) {
                Button(role: .destructive) {
                    authManager.signOut()
                    dismiss()
                } label: {
                    HStack {
                        Text("Sign Out")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                        Spacer()
                        Image(systemName: "rectangle.portrait.and.arrow.right")
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)

                Divider().background(AppConstants.Colors.divider)

                Button(role: .destructive) {
                    // UI stub; wire to real delete flow later
                } label: {
                    HStack {
                        Text("Delete Account")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                        Spacer()
                        Image(systemName: "trash")
                    }
                    .foregroundColor(.red)
                    .padding(.vertical, 10)
                }
                .buttonStyle(.plain)
                .disabled(true) // UI stub
                .opacity(0.55)
            }
        }
    }

    // MARK: - Save
    private func saveAndClose() {
        isSaving = true

        let trimmed = draft.displayName.trimmingCharacters(in: .whitespacesAndNewlines)
        userSettings.userName = trimmed.isEmpty ? "Friend" : trimmed

        // These are UI-only for now. Keep them in draft until you add persistence fields.
        // Later you can store them in UserDefaults / Keychain as needed.

        DispatchQueue.main.asyncAfter(deadline: .now() + 0.05) {
            isSaving = false
            dismiss()
        }
    }

    private var toolbarPlacement: ToolbarItemPlacement {
        #if os(macOS)
        return .primaryAction
        #else
        return .topBarTrailing
        #endif
    }
}

// MARK: - Draft Model
private struct Draft {
    var displayName: String

    // UI-only toggles (wire later)
    var showNameInMenu: Bool
    var requireAuth: Bool
    var biometricUnlock: Bool
    var emailUpdates: Bool
    var analytics: Bool

    init(from settings: UserSettings) {
        displayName = settings.userName

        showNameInMenu = true
        requireAuth = true
        biometricUnlock = true
        emailUpdates = false
        analytics = false
    }
}

// MARK: - Reusable UI (same as SettingsView)
private struct SettingsCard<Content: View>: View {
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

private struct ToggleRow: View {
    let title: String
    let subtitle: String
    @Binding var isOn: Bool

    var body: some View {
        HStack(alignment: .top, spacing: AppConstants.Spacing.md) {
            VStack(alignment: .leading, spacing: 4) {
                Text(title)
                    .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                    .foregroundColor(AppConstants.Colors.textPrimary)

                Text(subtitle)
                    .font(.system(size: AppConstants.FontSize.caption))
                    .foregroundColor(AppConstants.Colors.textSecondary)
            }

            Spacer()

            Toggle("", isOn: $isOn)
                .labelsHidden()
        }
    }
}