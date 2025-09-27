//
//  BudgetMillApp.swift
//  BudgetMill
//
//  Created by 章言韬 on 2025/9/27.
//

import SwiftUI

@main
struct BudgetMillApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
