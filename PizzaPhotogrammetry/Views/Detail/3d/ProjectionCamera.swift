import SceneKit

class ProjectionCamera: SCNNode {
    let cameraOffset: CGFloat = 0.5
    
    init(mode: CameraMode) {
        super.init()
        
        let camera = SCNCamera()
        camera.automaticallyAdjustsZRange = true
        camera.usesOrthographicProjection = mode != .free
        camera.orthographicScale = 0.15
        
        self.camera = camera
        
        switch mode {
        case .x:
            worldPosition = SCNVector3(x: cameraOffset, y: 0, z: 0)
        case .y:
            worldPosition = SCNVector3(x: 0, y: -cameraOffset, z: 0)
        case .z:
            worldPosition = SCNVector3(x: 0, y: 0, z: cameraOffset)
        case .free:
            worldPosition = SCNVector3(x: cameraOffset/2, y: cameraOffset/2, z: cameraOffset/2)
        }
        
        // TODO: Pass object center
        look(at: SCNVector3(x: 0, y: 0, z: 0))
    }
    
    override init() {
        super.init()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
