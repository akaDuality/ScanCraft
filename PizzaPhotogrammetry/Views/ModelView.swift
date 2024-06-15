import SwiftUI
import SceneKit

struct ModelView: View {
    let url: URL
    @Binding var boundingBox: BoundingBox
    
    var body: some View {
        HStack {
            // TODO: Keep camera position on change
            VStack {
                HStack {
                    View3d(url: url, boundingBox: $boundingBox, cameraMode: .x)
                    View3d(url: url, boundingBox: $boundingBox, cameraMode: .y)
                }
                HStack {
                    View3d(url: url, boundingBox: $boundingBox, cameraMode: .z)
                    View3d(url: url, boundingBox: $boundingBox, cameraMode: .free)
                }
            }.frame(minWidth: 800, minHeight: 500)
            
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
                
                CoordChange(boundingBox: $boundingBox)
                
                // TODO: Add Tranform
//                Text("Translation")
//                InputView(title: "X", value: $boundingBox.max.x)
//                InputView(title: "Y", value: $boundingBox.max.y)
//                InputView(title: "Z", value: $boundingBox.max.z)
                
            }.padding()
        }
    }
}

struct CoordChange: View {
    @Binding var boundingBox: BoundingBox
    
    var body: some View {
        HStack {
            Text("Width")
            Button("+") {
                boundingBox.min.x -= 0.01
                boundingBox.max.x += 0.01
            }
            
            Button("-") {
                boundingBox.min.x += 0.01
                boundingBox.max.x -= 0.01
            }
        }
        
        HStack {
            Text("Heigth")
            Button("+") {
                boundingBox.min.z -= 0.01
                boundingBox.max.z += 0.01
            }
            
            Button("-") {
                boundingBox.min.z += 0.01
                boundingBox.max.z -= 0.01
            }
        }
        
        HStack {
            Text("Top")
            Button("+") {
                boundingBox.max.y += 0.01
            }
            
            Button("-") {
                boundingBox.max.y -= 0.01
            }
        }
        
        HStack {
            Text("Bottom")
            Button("+") {
                boundingBox.min.y += 0.01
            }
            
            Button("-") {
                boundingBox.min.y -= 0.01
            }
        }
    }
}

enum CameraMode {
    case x, y, z, free
}

struct View3d: View {
    let url: URL
    @Binding var boundingBox: BoundingBox
    let cameraMode: CameraMode
    
    let cameraOffset: CGFloat = 0.3
    var body: some View {
        HStack {
            // TODO: Keep camera position on change
            SceneView(
                scene: {
                    let scene = try! SCNScene(url: url)
                    scene.rootNode.position = .init()
                    
                    let camera = SCNCamera()
                    camera.automaticallyAdjustsZRange = true
                    
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
                    
                    let box = SCNBox(width:  boundingBox.max.x - boundingBox.min.x,
                                     height: boundingBox.max.y - boundingBox.min.y,
                                     length: boundingBox.max.z - boundingBox.min.z,
                                     chamferRadius: 0)
                    let boxNode = SCNNode(geometry: box)
                    
                    let verticalCenter = SCNVector3(0,
                                                  (boundingBox.max.y - boundingBox.min.y)/2,
                                                  0)
                    boxNode.position = verticalCenter
                    
                    boxNode.geometry?.firstMaterial?.diffuse.contents = NSColor.green
                    boxNode.geometry?.firstMaterial?.transparency = 0.6
                    scene.rootNode.addChildNode(boxNode)
                    
                    func addSphere(_ position: SCNVector3) {
                        let sphere = SCNSphere(radius: 0.005)
                        let sphereNode = SCNNode(geometry: sphere)
                        sphereNode.position = position
                        //                        coneNode.transform = SCNMatrix4Translate(.init(), 0, -0.02, 0)
                        //                        coneNode.look(at: SCNVector3(x: 0, y: 2, z: 0))
                        sphereNode.geometry?.firstMaterial?.diffuse.contents = NSColor.red
                        
                        scene.rootNode.addChildNode(sphereNode)
                    }
                    
                    addSphere(SCNVector3((boundingBox.max.x - boundingBox.min.x)/2,
                                         (boundingBox.max.y - boundingBox.min.y)/2,
                                         0))
                    addSphere(SCNVector3(0,
                                         boundingBox.max.y - boundingBox.min.y,
                                         0))
                    addSphere(SCNVector3(0,
                                         (boundingBox.max.y - boundingBox.min.y)/2,
                                         (boundingBox.max.z - boundingBox.min.z)/2))
                   
                    
                    return scene
                }(),
                pointOfView: nil,
                options: [
                    .allowsCameraControl,
                    .autoenablesDefaultLighting,
                    .temporalAntialiasingEnabled
                ]
            )
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
            Text(title)
            
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
