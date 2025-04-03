import SwiftUI
import SceneKit

struct PizzaSceneView: View {
    
    @Binding var modelPosition: PhotogrammetryFolder.ModelPosition
    
    // Transform is set separately to allow apply different transform to result state
    @Binding var transform: PhotogrammetryFolder.Transform
    
    let scene: PizzaScene
    @State private var cameraNode: SCNNode
    
    init(scene: PizzaScene,
         cameraMode: CameraMode,
         modelPosition: Binding<PhotogrammetryFolder.ModelPosition>,
         transform: Binding<PhotogrammetryFolder.Transform>
    ) {
        self.scene = scene
        self._modelPosition = modelPosition
        self._transform = transform
        self.cameraNode = ProjectionCamera(mode: cameraMode)
        
        transformPizzaNode()
    }
    
    func transformPizzaNode() {
        scene.transformPizzaNode(by: $transform.wrappedValue)
    }
    
    func updateBox() {
        scene.box.update(
            boundingBox: modelPosition.boundingBox,
            orientation: modelPosition.boundingBoxOrientation)
    }
    
    var body: some View {
        SceneView(
            scene: scene,
            pointOfView: cameraNode,
            options: [
                .allowsCameraControl,
                .autoenablesDefaultLighting,
                .temporalAntialiasingEnabled,
            ]
        )
        .onAppear {
            updateBox()
            transformPizzaNode()
        }.onChange(of: modelPosition) { oldValue, newValue in
            updateBox()
            transformPizzaNode()
        }
    }
}
