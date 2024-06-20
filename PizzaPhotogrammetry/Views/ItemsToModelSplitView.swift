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

struct ItemsToModelSplitView: View {
    @Environment(\.modelContext) private var modelContext
    
    @Query 
    private var items: [Item]
    
    @State private var selectedItem: Item?
    
    var body: some View {
        NavigationSplitView {
            List(selection: $selectedItem) {
                ForEach(items) { item in
                    NavigationLink(value: item) {
                        NavigationCell(
                            item: item,
                            retryAction: { item in
                                // TODO: Ask permission for url
                                item.status = .waiting
                                processIfSessionIsNotBusy(item)
                            }, renderAction: { item in
                                render(item: item)
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
            if let selectedItem {
                // TODO: Show 3d view if preview has been made
                if selectedItem.status == .finished {
                    @Bindable var item = selectedItem
                    DetaliView(url: item.currentDestination,
                              boundingBox: $item.boundingBox,
                              transform: $item.transform,
                              renderAction: {
                        render(item: selectedItem)
                    })
                } else {
                    ModelProgressView(item: selectedItem, retryAction: { _ in })
                }
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
            Task {
                failProcessingItem()
                processNextItem()
            }
        }
    }
    
    private func render(item: Item) {
//        item.progress.reset()
        item.mode = .result
        processIfSessionIsNotBusy(item)
    }
    
    private func add(_ urls: [URL]) {
        for url in urls {
            add(url)
        }
    }

    private func add(_ url: URL) {
        // TODO: Check is folder
        
        let newItem = Item(sourceFolder: url)
        modelContext.insert(newItem)
        
        processIfSessionIsNotBusy(newItem)
    }
    
    private func failProcessingItem() {
        for item in items {
            if item.status == .processing {
                item.status = .failed
            }
            
            // TODO: Remove and rework detail view
            if item.status == .failed, item.mode == .result {
                item.mode = .preview
                item.status = .finished
            }
        }
    }
    
    private func processNextItem() {
        guard let item = items.first(where: { $0.status ==  .waiting } )
        else {
            print("Can't find next item")
            return
        }
        
        processIfSessionIsNotBusy(item)
        
        // TODO: Recursively take next task
    }
    
    private func processIfSessionIsNotBusy(_ item: Item) {
        guard !session.isProcessing else {
            print("Can't start processing because arleady processing another item")
            return
        }
        
        item.status = .processing
        Task {
            do {
                try await session.run(item, mode: item.mode)
                await MainActor.run {
                    item.status = .finished
                }
            } catch {
                await MainActor.run {
                    item.status = .failed
                }
            }
            
            processNextItem()
        }
    }
    
    var session = Photogrammetry()

    private func deleteItems(offsets: IndexSet) {
        withAnimation {
            for index in offsets {
                modelContext.delete(items[index])
            }
        }
    }
    
    private func delete(item: Item) {
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
        .modelContainer(for: Item.self, inMemory: true)
}
