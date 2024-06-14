import SwiftUI
import SceneKit

struct ModelView: View {
    let url: URL
    @Binding var boundingBox: BoundingBox
    
    var body: some View {
        HStack {
            SceneView(
                scene: {
                    let scene = try! SCNScene(url: url)
                    scene.rootNode.position = .init()
                    if let pizzaNode = scene.rootNode.childNodes.first {
                        
                        pizzaNode.boundingBox = boundingBox.sceneKitBoundingBox
                        
                        highlightNode(pizzaNode)
                    }
                    
                    //                bounds(RealityKit.BoundingBox(
                    //            min: SIMD3<Float>(-0.24121478, -0.12618387, -0.2925045),
                    //            max: SIMD3<Float>(0.24121478, 0.26614827, 0.2925045)))
                    
                    //                let box = SCNBox(width: 0.48, height: 0.3, length: 0.6, chamferRadius: 0)
                    //                let boxNode = SCNNode(geometry: box)
                    //                boxNode.position = SCNVector3(0, 0.12, 0)
                    
                    //                boxNode.geometry?.firstMaterial?.transparency = 0.6
                    
                    //                scene.rootNode.addChildNode(boxNode)
                    return scene
                }(),
                pointOfView: nil,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                ]
            ).frame(minWidth: 500, minHeight: 300)
            
            VStack(alignment: .leading) {
                Text("Minimum")
                InputView(title: "Min X", value: $boundingBox.min.x)
                InputView(title: "Min Y", value: $boundingBox.min.y)
                InputView(title: "Min Z", value: $boundingBox.min.z)
                    .padding(.bottom, 20)
                
                Text("Maximum")
                InputView(title: "Max X", value: $boundingBox.max.x)
                InputView(title: "Max Y", value: $boundingBox.max.y)
                InputView(title: "Max Z", value: $boundingBox.max.z)
                
            }.padding()
            
            
        }
    }
}

struct InputView: View {
    let title: String
    @Binding var value: CGFloat
    
    let formatter: NumberFormatter = {
        let formatter = NumberFormatter()
        formatter.numberStyle = .decimal
        return formatter
    }()
    
    var body: some View {
        HStack() {
            TextField(title, value: $value, formatter: formatter)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .frame(width: 100)
            Button("+") {
                value += 0.01
            }
            Button("-") {
                value -= 0.01
            }
        }
    }
}

#Preview {
    ModelView(url: Bundle.main.url(forResource: "Model", withExtension: "usdz")!,
              boundingBox: .constant(BoundingBox(
                min: Coord(x: -0.117, y: 0.11, z: -0.12),
                max: Coord(x: 0.117, y: 0.13, z: 0.12)
              )))
}

func createLineNode(fromPos origin: SCNVector3, toPos destination: SCNVector3, color: NSColor) -> SCNNode {
    let line = lineFrom(vector: origin, toVector: destination)
    let lineNode = SCNNode(geometry: line)
    let planeMaterial = SCNMaterial()
    planeMaterial.diffuse.contents = color
    line.materials = [planeMaterial]
    
    return lineNode
}

func lineFrom(vector vector1: SCNVector3, toVector vector2: SCNVector3) -> SCNGeometry {
    let indices: [Int32] = [0, 1]
    
    let source = SCNGeometrySource(vertices: [vector1, vector2])
    let element = SCNGeometryElement(indices: indices, primitiveType: .line)
    
    return SCNGeometry(sources: [source], elements: [element])
}


let kHighlightingNode = "someName"
func highlightNode(_ node: SCNNode) {
    let (min, max) = node.boundingBox
    print(node.boundingBox)
    let zCoord = node.position.z
    let topLeft = SCNVector3Make(min.x, max.y, zCoord)
    let bottomLeft = SCNVector3Make(min.x, min.y, zCoord)
    let topRight = SCNVector3Make(max.x, max.y, zCoord)
    let bottomRight = SCNVector3Make(max.x, min.y, zCoord)
    
    
    let bottomSide = createLineNode(fromPos: bottomLeft, toPos: bottomRight, color: .yellow)
    let leftSide = createLineNode(fromPos: bottomLeft, toPos: topLeft, color: .yellow)
    let rightSide = createLineNode(fromPos: bottomRight, toPos: topRight, color: .yellow)
    let topSide = createLineNode(fromPos: topLeft, toPos: topRight, color: .yellow)
    
    [bottomSide, leftSide, rightSide, topSide].forEach {
        $0.name = kHighlightingNode // Whatever name you want so you can unhighlight later if needed
        node.addChildNode($0)
    }
}
