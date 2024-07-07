import Foundation

class PizzaScenesCache {
    
    var scenes: [URL: PizzaScenes] = [:]
    
    func scenes(for folder: PhotogrammetryFolder) -> PizzaScenes {
        let url = folder.sourceFolder
        if let cached = scenes[url] {
            return cached
        } else {
            let newScenes = PizzaScenes(folder: folder)
            scenes[url] = newScenes
            return newScenes
        }
    }
}

struct PizzaScenes {
    private(set) var preview: PizzaScene
    private(set) var previewAligned: PizzaScene
    private(set) var result: PizzaScene
    
    init(folder: PhotogrammetryFolder) {
        self.preview = PizzaScene(url: folder.previewDestination)
        self.previewAligned = PizzaScene(url: folder.previewAlignedDestination)
        self.result = PizzaScene(url: folder.resultDestination)
    }
}


extension PizzaScenesCache: RenderQueueDelegate {
    func didFinishItem(item: PhotogrammetryFolder, mode: Photogrammetry.Mode) {
        scenes[item.sourceFolder] = nil
    }
}

