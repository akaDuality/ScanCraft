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
                
                switch item.status {
                case .waiting:
                    Text("In queue")
                case .processing:
                    if let stage = item.progress.stage?.description {
                        Text("Stage: \(stage)")
                    }
                    
                    if let remainingTime = item.progress.estimatedRemainingTime, remainingTime > 0 {
                        HStack {
                            ProgressView(value: item.progress.fractionCompleted)
                                .progressViewStyle(.circular)
                                .controlSize(.small)
                                .padding(.horizontal, 8)
                            
                            Text(timeFormatter.localizedString(fromTimeInterval: remainingTime))
                        }
                    } else {
                        ProgressView() // Infinity indicator
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

#Preview {
    let url = URL(fileURLWithPath: "/Users/mikhail/Library/CloudStorage/GoogleDrive-m.rubanov@dodobrands.io/Shared drives/Photo Lab/2024/06-June/2024-06-13 — TR— 3D — Pesto/20/jpeg")
    let item = Item(sourceFolder: url)
    return NavigationCell(item: item, retryAction: { _ in }, renderAction: { _ in })
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
