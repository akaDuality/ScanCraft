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
        
//        WindowGroup("3D Model", id: "openModel", for: URL.self) { $url in
//            if let url, let item = item(for: url) {
//                ModelView(
//                    url: item.destination,
//                    boundingBox: $item.boundingBox! // TODO: Remove !
//                )
//            } else {
//                Text("Can't find model at \(url)")
//            }
//        }
    }
    
//    @Query
//    private var items: [Item]
//    
//    func item(for url: URL) -> Item? {
//        items.last { item in
//            item.destination == url
//        }
//    }
}
