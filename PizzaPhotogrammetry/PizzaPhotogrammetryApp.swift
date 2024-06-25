//
//  PizzaPhotogrammetryApp.swift
//  PizzaPhotogrammetry
//
//  Created by Mikhail Rubanov on 11.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import SwiftData
import SceneKit

@main
struct PizzaPhotogrammetryApp: App {
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        // TODO: Write to strange location. Maybe broke when have disabled app's sandbox file:///Users/mikhail/Library/Application%20Support/default.store
        
        do {
            let container = try ModelContainer(for: schema, configurations: [modelConfiguration])
            
            return container
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            ItemsToModelSplitView()
        }
        .modelContainer(sharedModelContainer)
    }
}

extension ModelContainer {
    @MainActor
    func removeLastItem() throws {
        let lastItem = try mainContext.fetch(FetchDescriptor<Item>()).last!
        
        mainContext.delete(lastItem)
        try mainContext.save()
    }
    
    @MainActor
    func printLastItem() throws {
        let lastItem = try mainContext.fetch(FetchDescriptor<Item>()).last!
        
        print(lastItem.boundingBox)
        print(lastItem.boundingBoxOrientation)
        print(lastItem.transform)
        try mainContext.save()
    }
}

extension ModelContext {
    var sqliteCommand: String {
        if let url = container.configurations.first?.url.path(percentEncoded: false) {
            "sqlite3 \"\(url)\""
        } else {
            "No SQLite database found."
        }
    }
}
