import SwiftUI
import SceneKit

struct PizzaSceneView: View {
    
    @Binding var boundingBox: BoundingBox
    @Binding var transform: Item.Transform
    @State private var scene: SCNScene
    var pizzaNode: SCNNode! {
        scene.rootNode.childNode(withName: "Pizza", recursively: true)
    }
    
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
        self.scene = Self.makeScene(url: url, cameraMode: cameraMode)
        
        transformPizzaNode()
    }
    
    var body: some View {
        HStack {
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
                self.scene = Self.makeScene(url: url, cameraMode: cameraMode)
            }.onAppear {
                addBox(to: pizzaNode)
            }.onChange(of: boundingBox) { oldValue, newValue in
                addBox(to: pizzaNode)
            }.onChange(of: transform) { oldValue, newValue in
                transformPizzaNode()
            }
        }
    }
    
    func transformPizzaNode() {
        let translation = SCNMatrix4Translate(SCNMatrix4Identity,
                                              transform.translation.x,
                                              transform.translation.y,
                                              transform.translation.z)
        
        pizzaNode?.transform = translation
        
        pizzaNode.orientation = transform.rotation.quaternion
    }
    
    static func makeScene(url: URL, cameraMode: CameraMode) -> SCNScene {
        let rootScene = SCNScene()
        
        addCameraMode(to: rootScene, cameraMode: cameraMode)
        addZeroPlane(to: rootScene.rootNode)
        
        let pizzaScene = try! SCNScene(url: url) // TODO: Remove !
        let pizzaNode = pizzaScene.rootNode
        pizzaNode.name = "Pizza"
        
        rootScene.rootNode.addChildNode(pizzaNode)
        
        return rootScene
    }
    
    func addBox(to rootNode: SCNNode) {
        // Clear
        rootNode.childNode(withName: "BoundingBox", recursively: false)?.removeFromParentNode()
        
        // Create new
        
        let box = SCNBox(width:  boundingBox.width,
                         height: boundingBox.height,
                         length: boundingBox.length,
                         chamferRadius: 0)

        let verticalCenter = SCNVector3(0,
                                        boundingBox.min.y + boundingBox.height/2,
                                        0)
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "BoundingBox"
        rootNode.addChildNode(boxNode)
        
        boxNode.position = verticalCenter
        boxNode.geometry?.firstMaterial?.diffuse.contents = NSColor.green
        boxNode.geometry?.firstMaterial?.transparency = 0.6
        
        addBoundingSpheres(to: boxNode, boundingBox: boundingBox)
    }
}

func addBoundingSpheres(to box: SCNNode, boundingBox: BoundingBox) {
    let spheres: [SCNVector3] = [
        SCNVector3(boundingBox.width/2,
                   boundingBox.height/2,
                   0),
        SCNVector3(boundingBox.max.x,
                   0,
                   boundingBox.max.z),
        SCNVector3(0,
                   boundingBox.height/2,
                   boundingBox.length/2),
        
        // Center on top
        //            SCNVector3(boundingBox.width / 2,
        //                       boundingBox.height,
        //                       boundingBox.length / 2)
    ]
    
    spheres.forEach { coord in
        addSphere(coord, to: box, color: .red)
    }
}

func addSphere(_ position: SCNVector3, to rootNode: SCNNode, color: NSColor) {
    let sphere = SCNSphere(radius: 0.005)
    let sphereNode = SCNNode(geometry: sphere)
    sphereNode.position = position
    //                        coneNode.transform = SCNMatrix4Translate(.init(), 0, -0.02, 0)
    //                        coneNode.look(at: SCNVector3(x: 0, y: 2, z: 0))
    sphereNode.geometry?.firstMaterial?.diffuse.contents = color
    
    rootNode.addChildNode(sphereNode)
}

let cameraOffset: CGFloat = 0.5
func addCameraMode(to scene: SCNScene, cameraMode: CameraMode) {
    let camera = SCNCamera()
    camera.automaticallyAdjustsZRange = true
    camera.usesOrthographicProjection = cameraMode != .free
    camera.orthographicScale = 0.15
    
    let cameraNode = SCNNode()
    cameraNode.camera = camera
    scene.rootNode.addChildNode(cameraNode)
    //                    scene.pointOfView = cameraNode
    
    switch cameraMode {
    case .x:
        cameraNode.worldPosition = SCNVector3(x: cameraOffset, y: 0, z: 0)
    case .y:
        cameraNode.worldPosition = SCNVector3(x: 0, y: cameraOffset, z: 0)
    case .z:
        cameraNode.worldPosition = SCNVector3(x: 0, y: 0, z: cameraOffset)
    case .free:
        cameraNode.worldPosition = SCNVector3(x: cameraOffset/2, y: cameraOffset/2, z: cameraOffset/2)
    }
    
    // TODO: Pass object center
    cameraNode.look(at: SCNVector3(x: 0, y: 0, z: 0))
}

func addZeroPlane(to roodNode: SCNNode) {
    let box = SCNPlane(width: 1, height: 1)
    let planeNode = SCNNode(geometry: box)
    planeNode.eulerAngles.x = -.pi / 2
    planeNode.geometry?.firstMaterial?.diffuse.contents = NSColor.purple
    planeNode.geometry?.firstMaterial?.transparency = 0.4
    
    roodNode.addChildNode(planeNode)
}
