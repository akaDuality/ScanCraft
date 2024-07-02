//
//  ContentView.swift
//  PizzaPhotogrammetry
//
//  Created by Mikhail Rubanov on 11.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import SwiftUI
import SwiftData
import RealityKit
import Observation

@MainActor
struct ItemsToModelSplitView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query private var items: [PhotogrammetryFolder]
    @State private var selectedItem: PhotogrammetryFolder?
    
    private let queue = RenderQueue()
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        NavigationCell(
                            item: item,
                            progress: progress(for: item),
                            retryAction: { item in
                                // TODO: Ask permission for url
                                item.status = .waiting
                                queue.processIfSessionIsNotBusy(item)
                            }, renderAction: { item in
                                queue.render(item: item)
                            })
                        .contextMenu {
                            Button("Remove task") {
                                delete(item: item)
                                selectedItem = nil
                            }
                        }
                    }
                }
            }.navigationSplitViewColumnWidth(350)
        } detail: {
            if let selectedItem = Binding($selectedItem) {
                DetailView(item: selectedItem,
                           progress: progress(for: self.selectedItem!),
                           scenes: pizzaScenesCache.scenes(for: selectedItem.wrappedValue),
                           renderAction: {
                    queue.render(item: selectedItem.wrappedValue)
                }, previewAction: {
                    queue.makePreview(item: selectedItem.wrappedValue)
                })
            } else {
                Text("Select an item")
            }
        }.navigationSplitViewColumnWidth(350)
        .dropDestination(for: URL.self) { items, location in
            withAnimation {
                add(items)
            }
            return true
        }.onAppear {
            queue.nextItem = {
                self.items.first(where: { $0.status ==  .waiting } )
            }
            
            Task {
                queue.failProcessingItem(items: items)
                queue.processNextItem()
            }
        }
    }
    
    private let pizzaScenesCache = PizzaScenesCache()
    
    @MainActor
    func progress(for item: PhotogrammetryFolder) -> Processing? {
        if queue.progress?.url == item.sourceFolder {
            return queue.progress
        } else {
            return nil
        }
    }
    
    @MainActor
    private func add(_ urls: [URL]) {
        for url in urls {
            add(url)
        }
    }
    
    @MainActor
    private func add(_ url: URL) {
        // TODO: Check is folder
        
        let newItem = PhotogrammetryFolder(sourceFolder: url)
        modelContext.insert(newItem)
        
        queue.processNextItem() // Item can be in `.ready` mode and no need to process
    }

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func delete(item: PhotogrammetryFolder) {
        // TODO: Stop current task
        
        withAnimation {
            modelContext.delete(item)
        }
    }
}



#Preview {
    ItemsToModelSplitView(
//        items: [
//        Item(sourceFolder: URL(string: "/Users/mikhail/Library/CloudStorage/GoogleDrive-m.rubanov@dodobrands.io/Shared drives/Photo Lab /2024/06-June/2024-06-11 TR — 3D — Sujuk/35 thin/jpeg")!,
//             destination: URL(string: "/Users/mikhail/Desktop/3D/Pizzas/Sujuk/Sujuk 35 thin.usdz")!)]
    )
        .modelContainer(for: PhotogrammetryFolder.self, inMemory: true)
}
