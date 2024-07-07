import SwiftUI

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
                HStack() {
                    PathView(url: item.sourceFolder)
                    Spacer()
                    
                    // Show that we need action
                    if item.mode != .result // non final
                        && progress?.url != item.sourceFolder // not current
                    {
                        Text(item.mode.name)
                    }
                }
                
                switch item.status {
                case .waiting:
                    Text("In queue")
                        .font(.footnote)
                        .foregroundStyle(.yellow)
                case .processing:
                    ProgressDescription(progress: progress)
                        .font(.footnote)
                        .foregroundStyle(.green)
                case .failed, .finished:
                    EmptyView()
                }
            }
            
            if item.status == .failed {
                Button("Retry", systemImage: "exclamationmark.triangle") {
                    retryAction(item)
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
                .font(.footnote)
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
