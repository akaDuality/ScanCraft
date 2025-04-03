import SceneKit

class PizzaScene: SCNScene {
    init(url: URL) {
        super.init()
        
        makeScene(url: url)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let pizzaNodeName = "Pizza"
    
    var pizza: SCNNode! {
        rootNode.childNode(withName: pizzaNodeName, recursively: true)
    }
    
    let box = Box()
    
    func makeScene(url: URL) {
        background.contents = NSColor.windowBackgroundColor
        if let pizzaScene = try? SCNScene(url: url) {
            // TODO: How to handle it? Show error?
            let pizzaNode = pizzaScene.rootNode
            //        pizzaNode.castsShadow = true
            pizzaNode.name = pizzaNodeName
            
            rootNode.addChildNode(pizzaNode)
            
            addZeroPlanes()
        }
        
        addBox()
    }
    
    func transformPizzaNode(by transform: PhotogrammetryFolder.Transform) {
        let translation = SCNMatrix4Translate(SCNMatrix4Identity,
                                              transform.translation.x,
                                              transform.translation.y,
                                              transform.translation.z)
        
        pizza.transform = translation
        pizza.scale = transform.scale.vector3
        pizza.orientation = transform.rotation.quaternion
    }
    
    // MARK: Zero Plane
    private let zeroPlane = ZeroPlanes()
    func addZeroPlanes() {
        rootNode.addChildNode(zeroPlane)
    }
    
    func hideBox() {
        box.removeFromParentNode()
    }
    
    func addBox() {
        pizza.addChildNode(box)
    }
    
    func removeZeroPlanes() {
        zeroPlane.removeFromParentNode()
    }

    let floor = Floor()
    func addFloor() {
        rootNode.addChildNode(floor)
    }
    
    func removeFloor() {
        floor.removeFromParentNode()
    }
}

extension PizzaScene {
    func export(to url: URL) {
        // TODO: Potential bug: https://forums.developer.apple.com/forums/thread/704590
        
        hideBox()
        removeZeroPlanes()
        removeFloor()
        let isSuccess = write(to: url, delegate: nil)
        
//        addBox()
        addZeroPlanes()
        addFloor()
        
        print("Did finish export. Success? \(isSuccess)")
    }
}
