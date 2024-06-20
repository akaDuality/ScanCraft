import SwiftUI

struct ModelProgressView: View {
    var item: Item
    
    var retryAction: (_ item: Item) -> Void
    
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
            ProgressDescription(progress: item.progress)
                .frame(width: 300)
        case .waiting:
            Text("Waiting")
        }
    }
}
