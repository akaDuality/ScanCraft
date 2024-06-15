import Foundation
import os
import RealityKit
import Metal

private let logger = Logger(subsystem: "com.apple.sample.photogrammetry",
                            category: "HelloPhotogrammetry")

/// Implements the main command structure, defines the command-line arguments,
/// and specifies the main run loop.
class Photogrammetry {
    
    private typealias Configuration = PhotogrammetrySession.Configuration
    private typealias Request = PhotogrammetrySession.Request
    
    private(set) var isProcessing = false
    
    private func config() -> PhotogrammetrySession.Configuration {
        var config = PhotogrammetrySession.Configuration()
        config.sampleOrdering = .sequential
    
        config.customDetailSpecification.maximumTextureDimension = .twoK
        config.customDetailSpecification.textureFormat = .jpeg(compressionQuality: 0.51)
        config.customDetailSpecification.maximumPolygonCount = 50_000
        config.customDetailSpecification.outputTextureMaps = .all//[.diffuseColor, .normal, .roughness]
        
        logger.log("Using configuration: \(String(describing: config))")
        
        return config
    }
    
    enum Mode: Codable {
        case processing, preview, result
        
        static var `default`: Self = .processing
    }
    
    func run(_ task: Item, mode: Mode) async throws {
        task.status = .processing
        isProcessing = true
        defer {
            isProcessing = false
        }
        
        guard PhotogrammetrySession.isSupported else {
            logger.error("Program terminated early because the hardware doesn't support Object Capture.")
            print("Object Capture is not available on this computer.")
            fatalError()
        }
        
        task.progress.stage = .creatingSession
        // Try to create the session, or else exit.
        var maybeSession: PhotogrammetrySession!
        do {
            maybeSession = try PhotogrammetrySession(input: task.sourceFolder,
                                                     configuration: config())
            logger.log("Successfully created session.")
        } catch {
            logger.error("Error creating session: \(String(describing: error))")
            throw error
        }
        guard let session = maybeSession else {
            Foundation.exit(1)
        }
        
        try await withCheckedThrowingContinuation { continuation in
            
            Task { @MainActor in
                task.progress.stage = .preProcessing
                
                do {
                    for try await output in session.outputs {
                        switch output {
                            
                        case .requestError(let request, let error):
                            logger.error("Request \(String(describing: request)) had an error: \(String(describing: error))")
//                            continuation.resume(throwing: error)
                            // TODO: Fail request
                        case .requestComplete(let request, let result):
                            if case .modelFile = request {
                                task.status = .finished
                                Photogrammetry.handleRequestComplete(request: request, result: result)
                                continuation.resume(returning: ())
                            } else if case .bounds = request, case .bounds(let box) = result {
                                task.boundingBox = .from(box)
                                
                                print("Bounds result: \(result)")
                            }
                            
                        case .requestProgress(let request, let fractionComplete):
                            task.progress.fractionCompleted = fractionComplete
                            
                            Photogrammetry.handleRequestProgress(request: request,
                                                                 fractionComplete: fractionComplete)
                            
                        case .requestProgressInfo(let request, let progress):
                            task.progress.stage = .from(progress.processingStage)
                            task.progress.estimatedRemainingTime = progress.estimatedRemainingTime
                            
                            logger.warning("Progress stage \(String(describing: progress.processingStage)), time: \(String(describing: progress.estimatedRemainingTime)).")
                            
                        case .processingComplete:
                            logger.log("Processing is complete!")
                            
                        case .inputComplete:  // data ingestion only!
                            logger.log("Data ingestion is complete.  Beginning processing...")
                        case .invalidSample(let id, let reason):
                            logger.warning("Invalid Sample! id=\(id)  reason=\"\(reason)\"")
                        case .skippedSample(let id):
                            logger.warning("Sample id=\(id) was skipped by processing.")
                        case .automaticDownsampling:
                            logger.warning("Automatic downsampling was applied!")
                        case .processingCancelled:
                            logger.warning("Processing was cancelled.")
                        case .stitchingIncomplete:
                            logger.warning("Stitching incomplete")
                        @unknown default:
                            logger.error("Output: unhandled message: \(output.localizedDescription)")
                        }
                    }
                } catch {
                    logger.error("Output: ERROR = \(String(describing: error))")
                    task.status = .failed
                    continuation.resume(throwing: error)
                }
            }
            
            let destinationURL = task.currentDestination
            // Run the main process call on the request, then enter the main run
            // loop until you get the published completion event or error.
            guard destinationURL.startAccessingSecurityScopedResource() else {
                fatalError() // TODO: throw an error
                //                continuation.resume(throwing: error) // TODO:
            }
            defer {
                destinationURL.stopAccessingSecurityScopedResource()
            }
            do {
                var geometry: PhotogrammetrySession.Request.Geometry? = nil
                if task.boundingBox != .zero {
                    geometry = PhotogrammetrySession.Request.Geometry(
                        bounds: task.boundingBox.realityKitBoundingBox,
                        transform: Transform(translation: SIMD3(x: 0,
                                                                y: -Float(task.boundingBox.min.y),
                                                                z: 0)))
                }
                
                let modelFileRequest = PhotogrammetrySession.Request.modelFile(
                    url: destinationURL,
                    detail: mode == .preview ? .preview : .custom,
                    geometry: geometry)
                    
                
                logger.log("Using request: \(String(describing: modelFileRequest))")
                try session.process(requests: [modelFileRequest, .bounds])
            } catch {
                logger.critical("Process got error: \(String(describing: error))")
                task.status = .failed
                continuation.resume(throwing: error)
            }
        }
    }
    
    /// Called when the the session sends a request completed message.
    private static func handleRequestComplete(request: PhotogrammetrySession.Request,
                                              result: PhotogrammetrySession.Result) {
        logger.log("Request complete: \(String(describing: request)) with result...")
        switch result {
        case .modelFile(let url):
            logger.log("\tmodelFile available at url=\(url)")
        default:
            logger.warning("\tUnexpected result: \(String(describing: result))")
        }
    }
    
    /// Called when the sessions sends a progress update message.
    private static func handleRequestProgress(request: PhotogrammetrySession.Request,
                                              fractionComplete: Double) {
        logger.log("Progress \(fractionComplete)")
    }
    
}

// MARK: - Helper Functions / Extensions

private func handleRequestProgress(request: PhotogrammetrySession.Request,
                                   fractionComplete: Double) {
    print("Progress \(fractionComplete)")
}

/// Error thrown when an illegal option is specified.
private enum IllegalOption: Swift.Error {
    case invalidDetail(String)
    case invalidSampleOverlap(String)
    case invalidSampleOrdering(String)
    case invalidFeatureSensitivity(String)
}

extension Item.ProcessingStage {
    static func from(_ processing: PhotogrammetrySession.Output.ProcessingStage?) -> Self? {
        switch processing {
        case .preProcessing: return .preProcessing
        case .imageAlignment: return .imageAlignment
        case .pointCloudGeneration: return .pointCloudGeneration
        case .meshGeneration: return .meshGeneration
        case .textureMapping: return .textureMapping
        case .optimization: return .textureMapping
        @unknown default:
            return nil
        }
    }
}
