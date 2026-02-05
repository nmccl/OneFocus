//
//  AuthManager.swift
//  OneFocus
//
//  Authentication manager for user sign-in/sign-out
//

import Foundation
import SwiftUI
import Combine

class AuthManager: ObservableObject {
    
    // MARK: - Published Properties
    @Published var isAuthenticated: Bool = false
    @Published var currentUser: User?
    @Published var hasCompletedOnboarding: Bool = false
    
    // MARK: - Initializer
    init() {
        loadAuthState()
    }
    
    // MARK: - Methods
    func signIn(email: String, password: String) {
        // Simulate authentication
        // In a real app, this would connect to a backend service
        currentUser = User(id: UUID(), email: email, name: extractName(from: email), profileImageURL: nil)
        isAuthenticated = true
        saveAuthState()
    }
    
    func signUp(email: String, password: String, name: String) {
        // Simulate sign up
        currentUser = User(id: UUID(), email: email, name: name, profileImageURL: nil)
        isAuthenticated = true
        hasCompletedOnboarding = false
        saveAuthState()
    }
    
    func signOut() {
        currentUser = nil
        isAuthenticated = false
        hasCompletedOnboarding = false
        saveAuthState()
    }
    
    func completeOnboarding() {
        hasCompletedOnboarding = true
        saveAuthState()
    }
    
    // MARK: - Private Methods
    private func loadAuthState() {
        isAuthenticated = UserDefaults.standard.bool(forKey: "isAuthenticated")
        hasCompletedOnboarding = UserDefaults.standard.bool(forKey: "hasCompletedOnboarding")
        
        if isAuthenticated,
           let email = UserDefaults.standard.string(forKey: "userEmail"),
           let name = UserDefaults.standard.string(forKey: "userName") {
            currentUser = User(id: UUID(), email: email, name: name, profileImageURL: nil)
        }
    }
    
    private func saveAuthState() {
        UserDefaults.standard.set(isAuthenticated, forKey: "isAuthenticated")
        UserDefaults.standard.set(hasCompletedOnboarding, forKey: "hasCompletedOnboarding")
        
        if let user = currentUser {
            UserDefaults.standard.set(user.email, forKey: "userEmail")
            UserDefaults.standard.set(user.name, forKey: "userName")
        } else {
            UserDefaults.standard.removeObject(forKey: "userEmail")
            UserDefaults.standard.removeObject(forKey: "userName")
        }
    }
    
    private func extractName(from email: String) -> String {
        let components = email.components(separatedBy: "@")
        guard let firstPart = components.first else { return "User" }
        return firstPart.capitalized
    }
}

// MARK: - User Model
struct User: Identifiable, Codable {
    let id: UUID
    let email: String
    let name: String
    let profileImageURL: String?
}
