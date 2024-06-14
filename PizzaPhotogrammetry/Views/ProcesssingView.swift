import SwiftUI

struct ProcesssingView: View {
    
    @State var status: Item.Processing
    
    var body: some View {
        
        HStack {
            ProgressView(value: status.fractionCompleted)
                .progressViewStyle(.circular)
                .controlSize(.regular)
                .padding(.horizontal, 8)
            
            Text("Cooking pizza... \(Int(status.fractionCompleted * 100))%")
            
            // TODO: Add elapsed time
            // TODO: Summarize all spend time :D
        }
    }
}
