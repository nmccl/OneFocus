//
//  OneFocusApp.swift
//  OneFocus
//
//  Created by Noah McClung on 12/30/25.
//

import SwiftUI
import CoreData

@main
struct OneFocusApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
