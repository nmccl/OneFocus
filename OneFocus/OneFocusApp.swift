//
//  OneFocusApp.swift
//  OneFocus
//

import SwiftUI
import UserNotifications

#if os(iOS)
import UIKit
#endif

@main
struct OneFocusApp: App {

    @StateObject private var userSettings: UserSettings
    @StateObject private var authManager: AuthManager
    @StateObject private var focusTimer: FocusTimerManager

    #if os(iOS)
    @UIApplicationDelegateAdaptor(AppDelegate.self) private var appDelegate
    #endif

    init() {
        let settings = UserSettings()
        let auth = AuthManager()
        let timer = FocusTimerManager(userSettings: settings)

        _userSettings = StateObject(wrappedValue: settings)
        _authManager  = StateObject(wrappedValue: auth)
        _focusTimer   = StateObject(wrappedValue: timer)

        #if os(macOS)
        UNUserNotificationCenter.current().delegate = NotificationDelegate.shared
        #endif
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if !authManager.isAuthenticated {
                    SignInView()
                } else if !authManager.hasCompletedOnboarding {
                    OnboardingView()
                } else {
                    MainView()
                }
                   
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .environmentObject(userSettings)
            .environmentObject(authManager)
            .environmentObject(focusTimer)
            .preferredColorScheme(userSettings.appearanceMode.preferredColorScheme)
            .tint(AppConstants.Colors.primaryAccent)
            .onAppear {
                NotificationManager.shared.requestAuthorization { granted in
                    DispatchQueue.main.async {
                        if !granted { userSettings.notificationsEnabled = false }
                    }
                }
            }
        
        }
           

        #if os(macOS)
        MenuBarExtra {
            MenuBarTimerMiniView()
                .environmentObject(userSettings)
                .environmentObject(focusTimer)
        } label: {
            MenuBarTimerLabel()
                .environmentObject(focusTimer)
        }
        .menuBarExtraStyle(.window)
        #endif
    }
}

#if os(iOS)
final class AppDelegate: NSObject, UIApplicationDelegate, UNUserNotificationCenterDelegate {

    func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey : Any]? = nil
    ) -> Bool {
        UNUserNotificationCenter.current().delegate = self
        return true
    }

    func userNotificationCenter(
        _ center: UNUserNotificationCenter,
        willPresent notification: UNNotification
    ) async -> UNNotificationPresentationOptions {
        return [.banner, .sound]
    }
}
#endif
