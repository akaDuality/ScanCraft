import SwiftUI
import SceneKit

struct PizzaSceneView: View {
    
    @Binding var modelPosition: PhotogrammetryFolder.ModelPosition
    
    let scene: PizzaScene
    @State private var cameraNode: SCNNode
    
    init(scene: PizzaScene,
         cameraMode: CameraMode,
         modelPosition: Binding<PhotogrammetryFolder.ModelPosition>
    ) {
        self.scene = scene
        self._modelPosition = modelPosition
        self.cameraNode = createCamera(mode: cameraMode)
        
        transformPizzaNode()
    }
    
    func transformPizzaNode() {
        scene.transformPizzaNode(by: $modelPosition.transform.wrappedValue)
    }
    
    func updateBox() {
        scene.updateBox(
            boundingBox: modelPosition.boundingBox,
            orientation: modelPosition.boundingBoxOrientation)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SceneView(
                scene: scene,
                pointOfView: cameraNode,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled,
                ]
            ).onAppear {
                updateBox()
                transformPizzaNode()
            }.onChange(of: modelPosition) { oldValue, newValue in
                updateBox()
                transformPizzaNode()
            }
            
            //            Button("Export") {
            //                let url = self.url
            //                    .deletingLastPathComponent()
            //                    .appending(path: "Export.usdz")
            //
            //                // TODO: Potential bug: https://forums.developer.apple.com/forums/thread/704590
            //
            //                scene.removeBox()
            //                scene.removeZeroPlane(from: scene.rootNode)
            //                let isSuccess = scene.write(to: url, delegate: nil)
            //
            //                updateBox()
            //                scene.addZeroPlane(to: scene.rootNode)
            //
            //                print("Did finish export. Success? \(isSuccess)")
            //            }
            //            .padding(.trailing, 16)
            //            .padding(.bottom, 16)
        }
    }
}
