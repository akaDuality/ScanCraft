import SwiftUI
import SceneKit

struct PizzaSceneGrid: View {
    
    let scene: PizzaScene
    @Binding var item: PhotogrammetryFolder
        
    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .topLeading) {
                    PizzaSceneView(
                        scene: scene,
                        cameraMode: .x,
                        modelPosition: $item.position)
                    
                    HStack {
                        Button("Left") {
                            
                        }
                        
                        Button("Right") {
                            
                        }
                    }.offset(x: 16, y: 16)
                }
                
                PizzaSceneView(
                    scene: scene,
                    cameraMode: .y,
                    modelPosition: $item.position)
            }
            HStack {
                PizzaSceneView(
                    scene: scene,
                    cameraMode: .z,
                    modelPosition: $item.position)
                
                PizzaSceneView(
                    scene: scene,
                    cameraMode: .free,
                    modelPosition: $item.position)
            }
        }
    }
}

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
