import Foundation

protocol RenderQueueDelegate: AnyObject {
    func didFinishItem(item: PhotogrammetryFolder, mode: Photogrammetry.Mode)
}

@MainActor
class RenderQueue {
    
    var nextItem: (() -> PhotogrammetryFolder?)!
    weak var delegate: RenderQueueDelegate?
    
    @Published var progress: Processing?
    
    func render(item: PhotogrammetryFolder) {
        // TODO: Check that item not exists
        //        item.progress.reset()
        item.mode = .result
        item.status = .waiting
        processIfSessionIsNotBusy(item)
    }
    
    func makePreview(item: PhotogrammetryFolder) {
        //        item.progress.reset()
        try? FileManager.default.removeItem(at: item.url(for: .previewAligned))
        
        item.mode = .previewAligned
        item.status = .waiting
        processIfSessionIsNotBusy(item)
    }
    
    func failProcessingItem(items: [PhotogrammetryFolder]) {
        for item in items {
            if item.status == .processing {
                item.status = .failed
            }
            
            // TODO: Remove and rework detail view
            if item.status == .failed, item.mode == .result {
                item.mode = .preview
                item.status = .finished
            }
        }
    }
    
    func processNextItem() {
        guard let item = nextItem()
        else {
            print("Can't find next item")
            return
        }
        
        processIfSessionIsNotBusy(item)
    }
    
    @MainActor
    func processIfSessionIsNotBusy(_ item: PhotogrammetryFolder) {
        notificationCenter.requestPermission()
        
        guard !session.isProcessing else {
            print("Can't start processing because arleady processing another item")
            return
        }
        
        progress = Processing(url: item.sourceFolder)
        item.status = .processing
        Task {
            do {
                try await session.run(item, mode: item.mode, taskProgress: progress!)
                await MainActor.run {
                    item.status = .finished
                    notificationCenter.showCompletePush(item.sourceFolder)
                    delegate?.didFinishItem(item: item, mode: item.mode)
                }
                
                // TODO: Invalidate scene
            } catch {
                await MainActor.run {
                    item.status = .failed
                    notificationCenter.showFailurePush(item.sourceFolder)
                }
            }
            
            processNextItem()
        }
    }
    
    var session = Photogrammetry()
    
    let notificationCenter = NotificationCenter()
}
