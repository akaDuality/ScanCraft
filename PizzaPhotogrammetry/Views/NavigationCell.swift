import SwiftUI

struct NavigationCell: View {
    @State var item: Item
    
    var retryAction: (_ item: Item) -> Void
    var renderAction: (_ item: Item) -> Void
    
    @Environment(\.openWindow) var openWindow

    @State var isPopover: Bool = false
    var body: some View {
        HStack(spacing: 8) {
            VStack {
                Text(item.sourceFolder.pathTrailing)
//                Text(item.destination.pathTrailing)
                
                if item.status == .processing {
                    if item.progress.fractionCompleted < 1 {
                        ProgressView(value: item.progress.fractionCompleted)
                            .progressViewStyle(.linear)
                            .controlSize(.small)
                    }
                }
                
                Spacer()
                
                switch item.status {
                case .waiting:
                    Text("In queue")
                case .processing:
                    
                    if let remainingTime = item.progress.estimatedRemainingTime {
                        Text(timeFormatter.localizedString(fromTimeInterval: remainingTime))
                    }
                    
                    if let stage = item.progress.stage?.description {
                        Text("Stage: \(stage)")
                    }
                    
                case .failed, .finished:
                    EmptyView()
                }
            }
            
            switch item.status {
            case .waiting, .processing:
                EmptyView()
            case .failed:
                HStack {
                    Button("Retry", systemImage: "exclamationmark.triangle") {
                        retryAction(item)
                    }
                }
            case .finished:
                HStack {
                    VStack {
                        Button("Show in Finder", systemImage: "eye") {
                            NSWorkspace.shared.activateFileViewerSelecting([item.resultDestination])
                        }
                        
                        Button("Open file") {
//                            openWindow(id: "openModel", value: item)
                            isPopover = true
                        }.popover(isPresented: self.$isPopover) {
                            ModelView(url: item.previewDestination,
                                      boundingBox: $item.boundingBox) // TODO: Remove !
                        }
                        
                        Button("Render") {
                            renderAction(item)
                        }
                    }
                }
            }
        }
    }
    
    let timeFormatter = RelativeDateTimeFormatter()
}

extension URL {
    var pathTrailing: String {
        pathComponents
            .suffix(3)
            .joined(separator: "/")
    }
}
