import SwiftUI
import SceneKit

struct PizzaSceneView: View {
    
    @Binding var boundingBox: BoundingBox
    @Binding var transform: Item.Transform
    @State private var scene: SCNScene
    
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
        
//        scene.rootNode.childNode(withName: "box", recursively: true)?.removeFromParentNode()
//        let newScene = try! SCNScene(url: url)
//        let model = newScene.rootNode.childNodes.first!
//        model.name = "box"
//        scene.rootNode.addChildNode(model)
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
            }
            .onAppear {
                addBox(to: scene)
            }.onChange(of: boundingBox) { oldValue, newValue in
                addBox(to: scene)
            }.onChange(of: transform) { oldValue, newValue in
                addBox(to: scene)
            }
        }
    }
    
    static func makeScene(url: URL, cameraMode: CameraMode) -> SCNScene {
        let scene = try! SCNScene(url: url)
//        scene.rootNode.position = .init()
        
        Self.addCameraMode(to: scene, cameraMode: cameraMode)
        
        return scene
    }
    
    static let cameraOffset: CGFloat = 0.5
    static func addCameraMode(to scene: SCNScene, cameraMode: CameraMode) {
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
    
    func addBox(to scene: SCNScene) {
        // Clear
        scene.rootNode.childNode(withName: "BoundingBox", recursively: false)?.removeFromParentNode()
        
        // Create new
        let box = SCNBox(width:  boundingBox.max.x - boundingBox.min.x,
                         height: boundingBox.max.y - boundingBox.min.y,
                         length: boundingBox.max.z - boundingBox.min.z,
                         chamferRadius: 0)
        let boxNode = SCNNode(geometry: box)
        boxNode.name = "BoundingBox"
        scene.rootNode.addChildNode(boxNode)
//        let verticalCenter = SCNVector3(0,
//                                        (boundingBox.max.y - boundingBox.min.y)/2,
//                                        0)
//        boxNode.position = verticalCenter
        let translation = SCNMatrix4Translate(SCNMatrix4Identity,
                                              transform.translation.x,
                                              transform.translation.y,
                                              transform.translation.z)
        let rotation = SCNMatrix4MakeRotation(Double.pi,
                                              transform.rotation.x,
                                              transform.rotation.y,
                                              transform.rotation.z)
        boxNode.transform = SCNMatrix4Mult(translation, rotation)
 
        boxNode.geometry?.firstMaterial?.diffuse.contents = NSColor.green
        boxNode.geometry?.firstMaterial?.transparency = 0.6
        
        
        func addSphere(_ position: SCNVector3, to rootNode: SCNNode) {
            let sphere = SCNSphere(radius: 0.005)
            let sphereNode = SCNNode(geometry: sphere)
            sphereNode.position = position
            //                        coneNode.transform = SCNMatrix4Translate(.init(), 0, -0.02, 0)
            //                        coneNode.look(at: SCNVector3(x: 0, y: 2, z: 0))
            sphereNode.geometry?.firstMaterial?.diffuse.contents = NSColor.red
            
            rootNode.addChildNode(sphereNode)
        }
        
        addSphere(SCNVector3((boundingBox.max.x - boundingBox.min.x)/2,
                             (boundingBox.max.y - boundingBox.min.y)/2,
                             0),
                  to: boxNode)
        addSphere(SCNVector3(0,
                             boundingBox.max.y - boundingBox.min.y,
                             0),
                  to: boxNode)
        addSphere(SCNVector3(0,
                             (boundingBox.max.y - boundingBox.min.y)/2,
                             (boundingBox.max.z - boundingBox.min.z)/2),
                  to: boxNode)
    }
}
