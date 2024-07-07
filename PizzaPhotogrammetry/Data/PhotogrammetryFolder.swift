//
//  Item.swift
//  PizzaPhotogrammetry
//
//  Created by Mikhail Rubanov on 11.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

import Foundation
import SwiftData
import RealityKit

@Model
final class PhotogrammetryFolder {
    
    let id: UUID
    let sourceFolder: URL
    var status: Status = Status.waiting
    var mode: Photogrammetry.Mode
    
    // TODO: Extract to config type
    
    struct ModelPosition: Codable, Equatable {
        var boundingBox: BoundingBox = BoundingBox.zero
        var boundingBoxOrientation: Coord4 = Coord4.default
        var transform: Transform = Transform.zero
        var resultTransform: Transform = Transform.zero
        
        static var zero: Self {
            Self(boundingBox: .zero, boundingBoxOrientation: .default, transform: .zero, resultTransform: .zero)
        }
    }
    
    var position: ModelPosition = ModelPosition.zero
    
    init(
        sourceFolder: URL
    ) {
        self.id = UUID()
        self.sourceFolder = sourceFolder
        self.mode = .default
        
        // TODO: Add info about bounding box
        if previewExists {
            self.status = .finished
            self.mode = .preview
        }
        
        if resultExists {
            self.status = .finished
            self.mode = .result
        }
    }
    
    var previewExists: Bool {
        FileManager.default.fileExists(atPath: previewDestination.path)
    }
    
    var resultExists: Bool {
        FileManager.default.fileExists(atPath: resultDestination.path)
    }

    var previewDestination: URL {
        sourceFolder
            .deletingLastPathComponent() // Add near incoming folder, not inside the folder
            .appending(path: "Preview.usdz") // TODO: Generate names
    
    }
    
    var previewAlignedDestination: URL {
        sourceFolder
            .deletingLastPathComponent() // Add near incoming folder, not inside the folder
            .appending(path: "Preview Aligned.usdz") // TODO: Generate names
        
    }
    
    var resultDestination: URL {
        sourceFolder
            .deletingLastPathComponent() // Add near incoming folder, not inside the folder
            .appending(path: "Result.usdz") // TODO: Generate names
    }
    
    var tempDirectory: URL {
        URL(fileURLWithPath: NSTemporaryDirectory(),
            isDirectory: true)
        .appendingPathComponent("PhotogrammetryProcessing")
    }
    
    func url(for mode: Photogrammetry.Mode) -> URL {
        switch mode {
        case .processing:
            previewDestination
        case .preview:
            previewDestination
        case .previewAligned:
            previewAlignedDestination
        case .result:
            resultDestination
        }
    }
    
    var currentDestination: URL {
        url(for: mode)
    }
    
    var possibleModes: [Photogrammetry.Mode] {
        var resultTransform = [Photogrammetry.Mode]()
        
        if previewExists {
            resultTransform.append(.preview)
        }
        
        if fileExists(for: .previewAligned) {
            resultTransform.append(.previewAligned)
        }
        
        if resultExists {
            resultTransform.append(.result)
        }
        
        if resultTransform.isEmpty {
            resultTransform.append(.processing)
        }
        
        return resultTransform
    }
    
    func fileExists(for mode: Photogrammetry.Mode) -> Bool {
        let url = url(for: mode)
        return FileManager.default.fileExists(atPath: url.path)
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
    
    var stage: Stage?
    var fractionCompleted: Double
    var estimatedRemainingTime: TimeInterval?
    //        var startDate: Date?
    //        var endDate: Date?
    

    
    func reset() {
        estimatedRemainingTime = 0
        fractionCompleted = 0
        stage = .preProcessing
    }
    
//    static var empty: Processing {
//        Processing(stage: .preProcessing,
//                   fractionCompleted: 0,
//                   estimatedRemainingTime: 0)
//    }
    
    /// Like PhotogrammetrySession.Output.ProcessingStage
    enum Stage: Codable {
        case creatingSession
        case preProcessing
        case imageAlignment
        case pointCloudGeneration
        case meshGeneration
        case textureMapping
        case optimization
        
        var description: String {
            switch self {
            case .creatingSession: "creating session"
            case .preProcessing: "pre processing"
            case .imageAlignment: "image alignment"
            case .pointCloudGeneration: "point cloud generation"
            case .meshGeneration: "mesh generation"
            case .textureMapping: "texture mapping"
            case .optimization: "optimization"
            }
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
