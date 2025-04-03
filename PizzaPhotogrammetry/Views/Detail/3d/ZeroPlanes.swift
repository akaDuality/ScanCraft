import SceneKit

class ZeroPlanes: SCNNode {
    let zeroPlaneName = "ZeroPlane"
    
    override init() {
        super.init()
        
        name = zeroPlaneName
        
        let width: CGFloat = 0.30
        let height: CGFloat = 0.1
        let plane1 = makeZeroPlane(width: width, height: width)
        plane1.eulerAngles.x = -.pi / 2
        //        node.addChildNode(plane1)
        
        let plane2 = makeZeroPlane(width: width, height: height)
        plane2.eulerAngles.y = -.pi / 2
        addChildNode(plane2)
        
        let plane3 = makeZeroPlane(width: height, height: width)
        plane3.eulerAngles.z = -.pi / 2
        addChildNode(plane3)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func makeZeroPlane(width: CGFloat, height: CGFloat) -> SCNNode {
        let box = SCNPlane(width: width, height: height)
        let planeNode = SCNNode(geometry: box)
        
        let material = planeNode.geometry!.firstMaterial!
        material.diffuse.contents = NSColor.systemPurple
        material.transparency = 0.4
        material.isDoubleSided = true
        
        return planeNode
    }
}
