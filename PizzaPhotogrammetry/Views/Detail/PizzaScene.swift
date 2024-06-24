//
//  PizzaScene.swift
//  PizzaPhotogrammetry
//
//  Created by Mikhail Rubanov on 23.06.2024.
//  Copyright © 2024 Apple. All rights reserved.
//

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
    
    var pizzaNode: SCNNode! {
        rootNode.childNode(withName: pizzaNodeName, recursively: true)
    }
    
    func makeScene(url: URL) {

        addZeroPlanes()
        
        let pizzaScene = try! SCNScene(url: url) // TODO: Remove !
        let pizzaNode = pizzaScene.rootNode
//        pizzaNode.castsShadow = true
        pizzaNode.name = pizzaNodeName
        
        rootNode.addChildNode(pizzaNode)
    }
    
    func transformPizzaNode(by transform: Item.Transform) {
        let translation = SCNMatrix4Translate(SCNMatrix4Identity,
                                              transform.translation.x,
                                              transform.translation.y,
                                              transform.translation.z)
        
        pizzaNode?.transform = translation
        
        pizzaNode.orientation = transform.rotation.quaternion
    }
    
    private let boundingBoxNodeName = "BoundingBox"
    func removeBox() {
        pizzaNode
            .childNode(withName: boundingBoxNodeName,
                       recursively: false)?
            .removeFromParentNode()
    }
    
    func addBox(to rootNode: SCNNode, boundingBox: BoundingBox, orientation: Coord4) {
        // Clear
        removeBox()
        
        // Create new
        
        let box = SCNBox(width:  boundingBox.width,
                         height: boundingBox.height,
                         length: boundingBox.length,
                         chamferRadius: 0)
        
        let verticalCenter = SCNVector3(0,
                                        boundingBox.min.y + boundingBox.height/2,
                                        0)
        
        let boxNode = SCNNode(geometry: box)
        boxNode.name = boundingBoxNodeName
        rootNode.addChildNode(boxNode)
        
        boxNode.position = verticalCenter
        boxNode.orientation = orientation.quaternion
        
        let material = boxNode.geometry?.firstMaterial
        material?.diffuse.contents = NSColor.green
        material?.transparency = 0.6
        
        addBoundingSpheres(to: boxNode, boundingBox: boundingBox)
    }
    
    // MARK: Zero Plane
    
    func addZeroPlanes() {
        let node = SCNNode()
        node.name = zeroPlaneName
        
        let plane1 = makeZeroPlane()
        plane1.eulerAngles.x = -.pi / 2
        node.addChildNode(plane1)
        
        let plane2 = makeZeroPlane()
        plane2.eulerAngles.y = -.pi / 2
        node.addChildNode(plane2)
        
        let plane3 = makeZeroPlane()
        plane3.eulerAngles.z = -.pi / 2
        node.addChildNode(plane3)
        
        rootNode.addChildNode(node)
    }
    
    private func makeZeroPlane() -> SCNNode {
        let box = SCNPlane(width: 0.5, height: 0.5)
        let planeNode = SCNNode(geometry: box)
        
        let material = planeNode.geometry!.firstMaterial!
        material.diffuse.contents = NSColor.purple
        material.transparency = 0.4
        material.isDoubleSided = true
        
        return planeNode
    }
    
    let zeroPlaneName = "ZeroPlane"
    func removeZeroPlanes() {
        rootNode
            .childNode(withName: zeroPlaneName, recursively: true)?
            .removeFromParentNode()
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
func createCamera(mode: CameraMode) -> SCNNode {
    let camera = SCNCamera()
    camera.automaticallyAdjustsZRange = true
    camera.usesOrthographicProjection = mode != .free
    camera.orthographicScale = 0.15
    
    let cameraNode = SCNNode()
    cameraNode.camera = camera
    
    switch mode {
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
    
    return cameraNode
}
