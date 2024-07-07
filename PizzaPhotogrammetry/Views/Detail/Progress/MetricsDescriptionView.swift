import SwiftUI

struct MetricsDescriptionView: View {
    var progress: Processing?
    
    private let timeFormatter = RelativeDateTimeFormatter()
    
    var retryAction: () -> Void
    
    var body: some View {
        if let progress {
            VStack {
                Spacer()
                LazyVStack(alignment: .leading, spacing: 8, content: {
                    ForEach(progress.metrics) { metric in
                        HStack {
                            Text("\(metric.stage.description)")
                            
                            if let duration = metric.duration {
                                Text("\(timeFormatter.localizedString(fromTimeInterval: duration))")
                            }
                            
                            if progress.metrics.last === metric, metric.stage != .last {
                                ProgressView()
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                                    .padding(4)
                            }
                        }      
                    }
                    
                    if let remainingTime = progress.estimatedRemainingTime {
                        Text("\(timeFormatter.localizedString(fromTimeInterval: progress.metrics.totalDuration())) from \(timeFormatter.localizedString(fromTimeInterval: remainingTime))")
                            .bold()
                            .padding(.top, 24)
                    } else {
                        Text(timeFormatter.localizedString(fromTimeInterval: progress.metrics.totalDuration()))
                            .bold()
                            .padding(.top, 24)
                    }
                })
     
                Spacer()
            }
        } else {
            Button("Retry") {
                retryAction()
            }
        }
    }
}
