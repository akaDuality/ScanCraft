import SceneKit

class Floor: SCNNode {
    override init() {
        super.init()
        
        let worldGroundPlaneGeometry = SCNFloor()
        let worldGroundMaterial = SCNMaterial()
        worldGroundMaterial.lightingModel = .blinn
        worldGroundMaterial.writesToDepthBuffer = true
        worldGroundMaterial.colorBufferWriteMask = []
        worldGroundMaterial.isDoubleSided = true
        worldGroundPlaneGeometry.materials = [worldGroundMaterial]
        geometry = worldGroundPlaneGeometry
        
//        let ringGeometry = SCNTorus(ringRadius: 30 - 1, pipeRadius: 30 + 1)
//        ringGeometry.materials.first!.diffuse.contents = NSColor.red
//        let ringEntity = SCNNode(geometry: ringGeometry)
//        addChildNode(ringEntity)
//        
        // Create a ambient light
        let ambient = SCNLight()
        ambient.intensity = 100
        ambient.shadowMode = .deferred
        ambient.color = NSColor.white
        ambient.type = SCNLight.LightType.ambient
        
        let ambientLight = SCNNode()
        ambientLight.light = ambient
        ambientLight.position = SCNVector3(x: 0, y: 5, z: 0)
        addChildNode(ambientLight)
        
        // Create a directional light node with shadow
        let directLight = SCNLight()
        directLight.intensity = 1000
        directLight.type = SCNLight.LightType.directional
        directLight.color = NSColor.white
        directLight.castsShadow = true
        directLight.automaticallyAdjustsShadowProjection = true
        directLight.shadowSampleCount = 100
        directLight.shadowRadius = 8
        directLight.shadowMode = .deferred
        directLight.shadowMapSize = CGSize(width: 2048, height: 2048)
        directLight.shadowColor = NSColor.black.withAlphaComponent(0.75)
        
        let directionalNode = SCNNode()
        directionalNode.light = directLight
        directionalNode.position = SCNVector3(x: 0, y: 10, z: 0)
        directionalNode.eulerAngles = SCNVector3(-Float.pi / 2, 0, 0)
        addChildNode(directionalNode)
        
        addWorldAxis()
        addSizeRings()
    }
    
    func addWorldAxis() {
        let axis = SCNNode()
        let colors: [NSColor] = [.systemRed, .systemGreen, .systemBlue]
        
        for index in 0...2 {
            
            let box = SCNBox(width: 0.200, height: 0.001,
                             length: 0.001, chamferRadius: 0.001)
            
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.diffuse.contents = colors[index]
            box.materials[0] = material
            
            let node = SCNNode(geometry: box)
            
            switch index {
            case 0:
                node.position.x += 0.1
            case 1:
                node.eulerAngles = SCNVector3(0, 0, Float.pi/2)
                node.position.y += 0.1
            case 2:
                node.eulerAngles = SCNVector3(0, -Float.pi/2, 0)
                node.position.z += 0.1
            default: break
            }
            axis.addChildNode(node)
            axis.scale = SCNVector3(1.5, 1.5, 1.5)
            addChildNode(axis)
        }
    }
    
    func addSizeRings() {
        for diameter in [0.25, 0.30, 0.35] {
            let material = SCNMaterial()
            material.lightingModel = .constant
            material.diffuse.contents = NSColor.red
            
            let ringMesh = SCNTorus(ringRadius: diameter/2, pipeRadius: 0.001)
            ringMesh.materials = [material]
            
            let ring = SCNNode(geometry: ringMesh)
            addChildNode(ring)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
