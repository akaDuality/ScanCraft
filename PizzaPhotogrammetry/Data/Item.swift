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
final class Item {
    
    let id: UUID
    
    let sourceFolder: URL
    
    @Attribute(.ephemeral)
    var progress: Processing
    
    var boundingBox: BoundingBox = BoundingBox.zero
    var transform: Transform = Transform.zero
    
    var resultTransform: Transform = Transform.zero
    
    var mode: Photogrammetry.Mode
    
    var status: Status
    
    init(
        sourceFolder: URL
    ) {
        self.id = UUID()
        self.sourceFolder = sourceFolder
        self.status = .waiting
        self.progress = .empty
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
//        var startDate: Date?
//        var endDate: Date?
        
        mutating func reset() {
            estimatedRemainingTime = 0
            fractionCompleted = 0
            stage = .preProcessing
        }
        
        static var empty: Self {
            Processing(stage: .preProcessing, fractionCompleted: 0, estimatedRemainingTime: 0)
        }
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
    
    var tempDirectory: URL {
        sourceFolder
            .deletingLastPathComponent() // Add near incoming folder, not inside the folder
            .appending(path: "Temp") // TODO: Generate names
    }
    
    func url(for mode: Photogrammetry.Mode) -> URL {
        mode == .result ? resultDestination: previewDestination
    }
    
    var currentDestination: URL {
        mode == .result ? resultDestination: previewDestination 
    }
}

