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
final class Item: ObservableObject {
    
    let id: UUID
    
    let sourceFolder: URL
    
    @Attribute(.ephemeral)
    var progress: Processing
    
    var boundingBox: BoundingBox = BoundingBox.zero
    var transform: Transform = Transform.zero
    
    var mode: Photogrammetry.Mode
    var status: Status
    
    init(
        sourceFolder: URL
    ) {
        self.id = UUID()
        self.sourceFolder = sourceFolder
        self.status = .waiting
        self.progress = Processing(stage: .preProcessing, fractionCompleted: 0, estimatedRemainingTime: 0)
        self.mode = .default
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
    
    /// Like PhotogrammetrySession.Output.ProcessingStage
    enum ProcessingStage: Codable {
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
    
    struct Processing: Codable {
        var stage: ProcessingStage?
        var fractionCompleted: Double
        var estimatedRemainingTime: TimeInterval?
    }
    
    var previewDestination: URL {
        sourceFolder
            .deletingLastPathComponent() // Add near incoming folder, not inside the folder
            .appending(path: "Preview.usdz") // TODO: Generate names
    
    }
    
    var resultDestination: URL {
        sourceFolder
            .deletingLastPathComponent() // Add near incoming folder, not inside the folder
            .appending(path: "Result.usdz") // TODO: Generate names
        
    }
    
    var currentDestination: URL {
        mode == .preview ? previewDestination : resultDestination
    }
}

