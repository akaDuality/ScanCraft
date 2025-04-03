import SceneKit

class Box: SCNNode {
    let box: SCNBox = SCNBox()
    
    override init() {
        super.init()
        
        self.geometry = box
        
        let material = box.firstMaterial
        material?.diffuse.contents = NSColor.systemGreen
        material?.transparency = 0.25
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func update(boundingBox: BoundingBox, orientation: Coord4) {
        box.width = boundingBox.width
        box.height = boundingBox.height
        box.length = boundingBox.length
        
        let verticalCenter = SCNVector3(0,
                                        boundingBox.min.y + boundingBox.height/2,
                                        0)
        self.position = verticalCenter
        self.orientation = orientation.quaternion
        
        //        addBoundingSpheres(to: boxNode, boundingBox: boundingBox)
    }
    
    // MARK: Bounding spheres
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
}
