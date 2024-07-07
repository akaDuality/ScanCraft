import Foundation

@Observable
@MainActor
final class Processing {
    init(url: URL) {
        self.url = url
        self.stage = .creatingSession
        self.fractionCompleted = 0
        self.estimatedRemainingTime = nil
    }
    
    var url: URL
    
    var metrics: [Metric] = []
    var stage: Stage? {
        didSet {
            if let stage = (stage ?? oldValue) { // Sometimes can send nil in the middle of the proccess
                if let oldMetric = metrics.first(where: { metric in
                    metric.stage == oldValue
                }) {
                    oldMetric.updateEndTime()
                } else {
                    let newMetric = Metric(stage: stage)
                    metrics.append(newMetric)
                }
            }
        }
    }
    
    var fractionCompleted: Double
    var estimatedRemainingTime: TimeInterval?
    
    func reset() {
        estimatedRemainingTime = 0
        fractionCompleted = 0
        stage = .preProcessing
    }

    /// Like PhotogrammetrySession.Output.ProcessingStage
    enum Stage: Codable {
        case creatingSession
        case preProcessing
        case imageAlignment
        case pointCloudGeneration
        case meshGeneration
        case textureMapping
        case optimization
        
        static let last: Self = .optimization
        
        var description: String {
            switch self {
            case .creatingSession: "Creating session"
            case .preProcessing: "Pre processing"
            case .imageAlignment: "Image alignment"
            case .pointCloudGeneration: "Point cloud generation"
            case .meshGeneration: "Mesh generation"
            case .textureMapping: "Texture mapping"
            case .optimization: "Optimization"
            }
        }
    }
}

enum Status: Codable {
    case waiting, processing, failed, finished
    
    var description: String {
        switch self {
        case .waiting:
            return "waiting"
        case .processing:
            return "processing"
        case .failed:
            return "failed"
        case .finished:
            return "finished"
        }
    }
}


import RealityKit
extension PhotogrammetryFolder.ModelPosition {
    var geometry: PhotogrammetrySession.Request.Geometry? {
        guard boundingBox != .zero else {
            return nil
        }
        
        return PhotogrammetrySession.Request.Geometry(
            orientedBounds: OrientedBoundingBox(
                orientation: boundingBoxOrientation.simd4,
                boundingBox: boundingBox.realityKit),
            transform: transform.realityKit
        )
    }
}

@Observable
class Metric: Identifiable {
    init(stage: Processing.Stage) {
        self.stage = stage
        self.startDate = Date()
    }
    
    func updateEndTime() {
        endDate = Date()
    }
    
    let id = UUID()
    
    let stage: Processing.Stage
    private let startDate: Date
    private var endDate: Date?
    
    var duration: TimeInterval? {
        guard let endDate else { return nil }
        
        return endDate.timeIntervalSince(startDate)
    }
}

extension [Metric] {
    func totalDuration() -> TimeInterval {
        reduce(0) { result, metric in
            return result + (metric.duration ?? 0)
        }
    }
}
