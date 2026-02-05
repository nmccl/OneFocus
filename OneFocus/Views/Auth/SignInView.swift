//
//  SignInView.swift
//  OneFocus
//
//  Sign in screen for user authentication
//

import SwiftUI

struct SignInView: View {
    
    // MARK: - Environment
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userSettings: UserSettings
    
    
    // MARK: - State
    @State private var email = ""
    @State private var password = ""
    @State private var name = ""
    @State private var isSignUpMode = false
    @State private var showingError = false
    @State private var errorMessage = ""
    @State private var currentPage: Int = 0
    
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
    
    // MARK: - Body
    var body: some View {
        ZStack {
            AppConstants.Colors.backgroundPrimary.ignoresSafeArea()
            
            VStack(spacing: AppConstants.Spacing.xxl) {
                Spacer()
                
                // Logo and title
                VStack(spacing: AppConstants.Spacing.md) {
                    
                    Text("OneFocus")
                        .font(.system(size: 40, weight: .semibold))
                        .foregroundColor(AppConstants.Colors.textPrimary)
                    
                    Text("Focus on what matters")
                        .font(.system(size: AppConstants.FontSize.body))
                        .foregroundColor(AppConstants.Colors.textSecondary)
                }
                
                // Sign in/up form
                VStack(spacing: AppConstants.Spacing.lg) {
                    if isSignUpMode {
                        TextField("Name", text: $name)
                            .textFieldStyle(.plain)
                            .font(.system(size: AppConstants.FontSize.body))
                            .padding(AppConstants.Spacing.md)
                            .background(AppConstants.Colors.backgroundSecondary)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                            .frame(width: 320)
                    }
                    
                    //TabView(selection: $currentPage) {
                      //  ForEach(0..<pages.count, id: \.self) { index in
                        //    OnboardingPageView(page: pages[index])
                          //      .tag(index)
                        //}
                    //}
                    //#if os(iOS)
                    //.tabViewStyle(.page)
                    //.indexViewStyle(.page(backgroundDisplayMode: .always))
                   // #endif
                  //  .frame(height: 400)
                    
                    SecureField("Password", text: $password)
                        .textFieldStyle(.plain)
                        .font(.system(size: AppConstants.FontSize.body))
                        .padding(AppConstants.Spacing.md)
                        .background(AppConstants.Colors.backgroundSecondary)
                        .cornerRadius(AppConstants.CornerRadius.medium)
                        .frame(width: 320)
                    
                    Button(action: handleAuth) {
                        Text(isSignUpMode ? "Sign Up" : "Sign In")
                            .font(.system(size: AppConstants.FontSize.body, weight: .medium))
                            .foregroundColor(.white)
                            .frame(width: 320)
                            .padding(.vertical, 14)
                            .background(isFormValid ? AppConstants.Colors.primaryAccent : AppConstants.Colors.textTertiary)
                            .cornerRadius(AppConstants.CornerRadius.medium)
                    }
                    .buttonStyle(.plain)
                    
                    
                    Button(action: {
                        withAnimation {
                            isSignUpMode.toggle()
                        }
                    }) {
                        Text(isSignUpMode ? "Already have an account? Sign In" : "Don't have an account? Sign Up")
                            .font(.system(size: AppConstants.FontSize.subheadline))
                            .foregroundColor(AppConstants.Colors.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                
                Spacer()
            }
            .padding(AppConstants.Spacing.xl)
        }
        .alert("Error", isPresented: $showingError) {
            Button("OK", role: .cancel) { }
        } message: {
            Text(errorMessage)
        }
    }
    
    // MARK: - Computed Properties
    private var isFormValid: Bool {
        if isSignUpMode {
            return !email.isEmpty && !password.isEmpty && !name.isEmpty && password.count >= 6
        } else {
            return !email.isEmpty && !password.isEmpty
        }
    }
    
    // MARK: - Methods
    private func handleAuth() {
        if isSignUpMode {
            authManager.signUp(email: email, password: password, name: name)
            userSettings.userName = name
        } else {
            authManager.signIn(email: email, password: password)
            if let user = authManager.currentUser {
                userSettings.userName = user.name
            }
        }
    }
}

// MARK: - Preview
struct SignInView_Previews: PreviewProvider {
    static var previews: some View {
        SignInView()
            .environmentObject(AuthManager())
            .environmentObject(UserSettings.sample)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
