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
