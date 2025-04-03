import SwiftUI

struct DetailView: View {
    @Binding var item: PhotogrammetryFolder
    var progress: Processing?
    let scenes: PizzaScenes
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    init(item: Binding<PhotogrammetryFolder>,
         progress: Processing?,
         scenes: PizzaScenes,
         renderAction: @escaping () -> Void,
         previewAction: @escaping () -> Void) {
        self._item = item
        self.progress = progress
        self.scenes = scenes
        
        let mode = item.wrappedValue.mode
        self.renderAction = renderAction
        self.previewAction = previewAction
    }
    
    var body: some View {
        HStack {
            switch item.mode {
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
                            
                            scenes.result.export(to: url)
                            
                        }, convertToGlbAction: {
                            BlenderToGlbConverter().convertToGlb(url: item.sourceFolder.deletingLastPathComponent())
                        }
                    ).padding()
                }
            }
            
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Preview mode", selection: $item.mode) {
                    ForEach(item.possibleModes(processing: progress), id: \.self) { mode in
                        HStack(spacing: 8) {
                            Text(mode.name)
                            if item.mode == mode, let percent = progress?.fractionCompleted {
                                ProgressView(value: percent)
                                    .progressViewStyle(.circular)
                                    .controlSize(.small)
                            }
                        }
                        
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
