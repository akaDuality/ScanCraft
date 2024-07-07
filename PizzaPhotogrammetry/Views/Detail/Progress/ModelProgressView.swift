import SwiftUI

struct ModelProgressView: View {
    var item: PhotogrammetryFolder
    var progress: Processing
    
    var retryAction: (_ item: PhotogrammetryFolder) -> Void
    
    var body: some View {
        switch item.status {
        case .failed:
            Text("Failed")
            Button("Retry") {
                retryAction(item)
            }
            
        case .processing, .finished:
            MetricsDescriptionView(progress: progress, retryAction: {
               retryAction(item) // TODO: no retain cycle?
            })
            .frame(width: 350)
        case .waiting:
            Text("Waiting")
        }
    }
}
