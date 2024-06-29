import SwiftUI

struct ModelProgressView: View {
    var item: PhotogrammetryFolder
    var progress: Processing
    
    var retryAction: (_ item: PhotogrammetryFolder) -> Void
    
    var body: some View {
        switch item.status {
        case .finished:
            Text("Here is should be 3d view :D")
            
        case .failed:
            Text("Failed")
            Button("Retry") {
                retryAction(item)
            }
            
        case .processing:
            ProgressDescription(progress: progress)
                .frame(width: 350)
        case .waiting:
            Text("Waiting")
        }
    }
}
