import SwiftUI

struct DetailView: View {
    @EnvironmentObject var item: Item
    
    var retryAction: (_ item: Item) -> Void
    
    var body: some View {
        switch item.status {
        case .finished:
            Button("Show in Finder") {
                NSWorkspace.shared.activateFileViewerSelecting([item.previewDestination])
            }
            
            Text(item.previewDestination.pathComponents.suffix(3).joined(separator: "/"))
            
            // Will be available in macOS Sequoia
            //                            RealityView { content in
            //                                if let model = try? await ModelEntity(url: item.destination) {
            //                                    content.add(model)
            //                                }
            //                            }
            
        case .failed:
            Text("Failed")
            Button("Retry") {
                retryAction(item)
            }
            
        case .processing:
            ProcesssingView(status: item.progress)
        case .waiting:
            Text("Waiting")
        }
    }
}
