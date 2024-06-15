import SwiftUI

struct NavigationCell: View {
    @State var item: Item
    
    var retryAction: (_ item: Item) -> Void
    var renderAction: (_ item: Item) -> Void
    
    @Environment(\.openWindow) var openWindow

    @State var isPopover: Bool = false
    var body: some View {
        HStack(alignment: .top, spacing: 8) {
            VStack(alignment: .leading) {
                
                PathView(url: item.sourceFolder)
                
                if item.mode != .processing {
                    PathView(url: item.previewDestination)
                }
                
                if item.mode == .result {
                    PathView(url: item.resultDestination)
                }
                
                if item.status == .processing {
                    if item.progress.fractionCompleted < 1 {
                        ProgressView(value: item.progress.fractionCompleted)
                            .progressViewStyle(.linear)
                            .controlSize(.small)
                    }
                }
                
                switch item.status {
                case .waiting:
                    Text("In queue")
                case .processing:
                    HStack {
                        if let remainingTime = item.progress.estimatedRemainingTime {
                            Text(timeFormatter.localizedString(fromTimeInterval: remainingTime))
                        }
                        
                        if let stage = item.progress.stage?.description {
                            Text("Stage: \(stage)")
                        }
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
                Spacer()
                
                HStack {
                    VStack(alignment: .trailing) {
                        Button("Align model") {
//                            openWindow(id: "openModel", value: item)
                            isPopover = true
                        }.popover(isPresented: self.$isPopover) {
                            ModelView(url: item.currentDestination,
                                      boundingBox: $item.boundingBox) // TODO: Remove !
                        }
                        
                        // TODO: Make it available to rerender (and ask to rewrite file)
                        if item.mode == .preview {
                            Button("Render") {
                                renderAction(item)
                            }
                        }
                    }
                }
            }
        }
    }
    
    let timeFormatter = RelativeDateTimeFormatter()
}

struct PathView: View {
    
    let url: URL
    
    var body: some View {
        HStack(alignment: .firstTextBaseline) {
            Button {
                NSWorkspace.shared.activateFileViewerSelecting([url])
            } label: {
                Image(systemName: "eye")
            }.controlSize(.small)
            
            Text(url.pathTrailing)
        }
    }
}

extension URL {
    var pathTrailing: String {
        pathComponents
            .suffix(3)
            .joined(separator: "/")
    }
}
