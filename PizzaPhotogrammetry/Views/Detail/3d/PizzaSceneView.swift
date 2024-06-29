import SwiftUI
import SceneKit

struct PizzaSceneGrid: View {
    
    let scene: PizzaScene
    @Binding var item: Item
        
    var body: some View {
        VStack {
            HStack {
                PizzaSceneView(scene: scene, cameraMode: .x, boundingBox: $item.boundingBox, boundingBoxOrientation: $item.boundingBoxOrientation, transform: $item.transform)
                PizzaSceneView(scene: scene, cameraMode: .y, boundingBox: $item.boundingBox, boundingBoxOrientation: $item.boundingBoxOrientation,transform: $item.transform)
            }
            HStack {
                PizzaSceneView(scene: scene, cameraMode: .z, boundingBox: $item.boundingBox, boundingBoxOrientation: $item.boundingBoxOrientation,transform: $item.transform)
                PizzaSceneView(scene: scene, cameraMode: .free, boundingBox: $item.boundingBox, boundingBoxOrientation: $item.boundingBoxOrientation,transform: $item.transform)
            }
        }
    }
}


struct PizzaSceneView: View {
    
    @Binding var boundingBox: BoundingBox
    @Binding var boundingBoxOrientation: Coord4
    @Binding var transform: Item.Transform
    
    let scene: PizzaScene
    @State private var cameraNode: SCNNode
    
    init(scene: PizzaScene,
         cameraMode: CameraMode,
         boundingBox: Binding<BoundingBox>,
         boundingBoxOrientation: Binding<Coord4>,
         transform: Binding<Item.Transform>
         ) {
        self.scene = scene
        self._boundingBox = boundingBox
        self._transform = transform
        self._boundingBoxOrientation = boundingBoxOrientation
        self.cameraNode = createCamera(mode: cameraMode)
        
        transformPizzaNode()
    }
    
    func transformPizzaNode() {
        scene.transformPizzaNode(by: $transform.wrappedValue)
    }
    
    func updateBox() {
        scene.updateBox(boundingBox: boundingBox, orientation: boundingBoxOrientation)
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
            }.onChange(of: boundingBox) { oldValue, newValue in
                updateBox()
            }.onChange(of: boundingBoxOrientation) { oldValue, newValue in
                updateBox()
            }.onChange(of: transform) { oldValue, newValue in
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
