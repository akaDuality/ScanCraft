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
    
    var id: UUID
    var sourceFolder: URL
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
    
    @MainActor 
    func possibleModes(processing: Processing?) -> [Photogrammetry.Mode] {
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
        
        // Add name of last 
        if let processing, processing.url == sourceFolder {
            resultTransform.append(.processing)
        }
        
        return resultTransform
    }
    
    func fileExists(for mode: Photogrammetry.Mode) -> Bool {
        let url = url(for: mode)
        return FileManager.default.fileExists(atPath: url.path)
    }
}
