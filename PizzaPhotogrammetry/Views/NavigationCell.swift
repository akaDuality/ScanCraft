import SwiftUI

struct ProgressDescription: View {
    
    var progress: Processing?
    
    private let timeFormatter = RelativeDateTimeFormatter()
    
    var body: some View {
        HStack {
            if let stage = progress?.stage?.description {
                Text("Stage: \(stage)")
                Spacer()
            }
            
            if let progress, let remainingTime = progress.estimatedRemainingTime, remainingTime > 0 {
                Text(timeFormatter.localizedString(fromTimeInterval: remainingTime))
                
                ProgressView(value: progress.fractionCompleted)
                    .progressViewStyle(.circular)
                    .controlSize(.small)
                    .padding(.horizontal, 8)
            } else {
                ProgressView() // Infinity indicator
                    .controlSize(.small)
            }
        }
    }
}

struct NavigationCell: View {
    @State var item: PhotogrammetryFolder
    var progress: Processing?
    var retryAction: (_ item: PhotogrammetryFolder) -> Void
    var renderAction: (_ item: PhotogrammetryFolder) -> Void
    
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
                    ProgressDescription(progress: progress)
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
}

//#Preview {
//    let url = URL(fileURLWithPath: "/Users/mikhail/Library/CloudStorage/GoogleDrive-m.rubanov@dodobrands.io/Shared drives/Photo Lab/2024/06-June/2024-06-13 — TR— 3D — Pesto/20/jpeg")
//    let item = Item(sourceFolder: url)
//    return NavigationCell(item: item, retryAction: { _ in }, renderAction: { _ in })
//}

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
