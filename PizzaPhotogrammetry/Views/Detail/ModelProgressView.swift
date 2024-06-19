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
            ProcesssingView(status: item.progress)
        case .waiting:
            Text("Waiting")
        }
    }
}
