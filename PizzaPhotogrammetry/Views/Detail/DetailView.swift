import SwiftUI

struct DetailView: View {
    @Binding var item: PhotogrammetryFolder
    var progress: Processing?
    let scenes: PizzaScenes
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    @State var mode: Photogrammetry.Mode
    
    init(item: Binding<PhotogrammetryFolder>,
         progress: Processing?,
         scenes: PizzaScenes,
         renderAction: @escaping () -> Void,
         previewAction: @escaping () -> Void) {
        self._item = item
        self.progress = progress
        self.scenes = scenes
        
        let mode = item.wrappedValue.mode
        self.mode = mode
        self.renderAction = renderAction
        self.previewAction = previewAction
    }
    
    var body: some View {
        HStack {
            switch mode {
            case .processing:
                if let progress {
                    ModelProgressView(item: item, progress: progress, retryAction: { _ in })
                } else {
                    EmptyView()
                }
                
            case .preview:
                PizzaSceneGrid(
                    scene: scenes.preview,
                    item: $item,
                    renderAction: renderAction,
                    previewAction: previewAction)
                .frame(minWidth: 800, minHeight: 500)
                .padding(.bottom, 20)
                
//                ConfigurationView(position: $item.position,
//                                  renderAction: renderAction,
//                                  previewAction: previewAction)
//                .padding()

            case .previewAligned:
                PizzaSceneView(
                    scene: scenes.previewAligned,
                    cameraMode: .free,
                    modelPosition: $item.position, 
                    transform: $item.position.resultTransform)
                
            case .result:
                HStack {
                    PizzaSceneView(
                        scene: scenes.result,
                        cameraMode: .free,
                        modelPosition: $item.position,
                        transform: $item.position.resultTransform)
                    
                    TransformSetupView(
                        transform: $item.position.resultTransform,
                        exportAction: {
                            let url = self.item.sourceFolder
                                .deletingLastPathComponent()
                                .appending(path: "Export.usdz")
                            
                            // TODO: Potential bug: https://forums.developer.apple.com/forums/thread/704590
                            
                            let scene = scenes.result
                            scene.hideBox()
                            scene.removeZeroPlanes()
                            let isSuccess = scene.write(to: url, delegate: nil)
                            
                            scene.addBox()
                            scene.addZeroPlanes()
                            
                            print("Did finish export. Success? \(isSuccess)")
                        }
                    ).padding()
                }
            }
            
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Preview mode", selection: $mode) {
                    ForEach(Photogrammetry.Mode.allCases, id: \.self) { mode in
                        Text(mode.name)
                    }
                }
                .pickerStyle(.segmented)
            }
        
            ToolbarItem(placement: .confirmationAction) {
                Spacer()
            }
            
            ToolbarItem(placement: .confirmationAction) {
                ShareLink(item: item.currentDestination)
            }
        }
    }
}

enum CameraMode {
    case x, y, z, free
}

//#Preview {
//    DetaliView(
//        url: Bundle.main.url(forResource: "Model", withExtension: "usdz")!,
//        boundingBox: .constant(BoundingBox(
//            min: Coord(x: -0.117, y: 0.11, z: -0.12),
//            max: Coord(x: 0.117, y: 0.13, z: 0.12)
//        )), transform: .constant(.zero), renderAction: {})
//}
