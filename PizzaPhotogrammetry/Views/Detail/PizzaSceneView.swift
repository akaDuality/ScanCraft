import SwiftUI
import SceneKit

struct PizzaSceneView: View {
    
    @Binding var boundingBox: BoundingBox
    @Binding var transform: Item.Transform
    @State private var scene: PizzaScene

    
    var url: URL
    let cameraMode: CameraMode
    init(url: URL,
         cameraMode: CameraMode,
         boundingBox: Binding<BoundingBox>,
         transform: Binding<Item.Transform>
         ) {
        self.url = url
        self._boundingBox = boundingBox
        self._transform = transform
        self.cameraMode = cameraMode
        self.scene = PizzaScene(url: url, cameraMode: cameraMode)
        
        transformPizzaNode()
    }
    
    func transformPizzaNode() {
        scene.transformPizzaNode(by: $transform.wrappedValue)
    }
    
    func updateBox() {
        scene.addBox(to: scene.pizzaNode, boundingBox: boundingBox)
    }
    
    var body: some View {
        ZStack(alignment: .bottomTrailing) {
            SceneView(
                scene: scene,
                pointOfView: nil,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled,
                ]
            )
            .onChange(of: url) { oldValue, newValue in
                self.scene = PizzaScene(url: url, cameraMode: cameraMode)
            }.onAppear {
                updateBox()
            }.onChange(of: boundingBox) { oldValue, newValue in
                updateBox()
            }.onChange(of: transform) { oldValue, newValue in
                transformPizzaNode()
            }
           
            Button("Export") {
                let url = self.url
                    .deletingLastPathComponent()
                    .appending(path: "Export.usdz")
                
                // TODO: Potential bug: https://forums.developer.apple.com/forums/thread/704590
                
                scene.removeBox()
                scene.removeZeroPlane(from: scene.rootNode)
                let isSuccess = scene.write(to: url, delegate: nil)
                
                updateBox()
                scene.addZeroPlane(to: scene.rootNode)
                
                print("Did finish export. Success? \(isSuccess)")
            }
            .padding(.trailing, 16)
            .padding(.bottom, 16)
        }
    }
}
