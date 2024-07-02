import SwiftUI

struct PizzaSceneGrid: View {
    
    let scene: PizzaScene
    @Binding var item: PhotogrammetryFolder
        
    private let offset: CGFloat = 2
    private var step: CGFloat {
        if NSEvent.modifierFlags.contains(.command) {
            return 0.001
        } else {
            return 0.005
        }
    }
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    PizzaSceneView(
                        scene: scene,
                        cameraMode: .x,
                        modelPosition: $item.position)
                    
                    HStack(spacing: 24) {
                        HStack {
                            Button(action: {
                                item.position.transform.rotation.x += step
                                item.position.boundingBoxOrientation.x -= step
                            }, label: {
                                Image(systemName: "arrow.counterclockwise")
                            }).buttonStyle(.borderedProminent)
                            
                            Button(action: {
                                item.position.transform.rotation.x -= step
                                item.position.boundingBoxOrientation.x += step
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            }).buttonStyle(.borderedProminent)
                            
                        }
                    }
                    .padding(12)
                    .background(.windowBackground)
                    .cornerRadius(8)
                    .offset(x: -offset, y: -offset)
                }
                
                ZStack(alignment: .bottomTrailing) {
                    PizzaSceneView(
                        scene: scene,
                        cameraMode: .y,
                        modelPosition: $item.position)
                    
                    HStack {
                        Text("Bottom")
                        
                        Button("Upper") {
                            item.position.boundingBox.min.y -= step
                            item.position.transform.translation.y = -item.position.boundingBox.min.y
                        }.buttonStyle(.borderedProminent)
                        
                        Button("Lower") {
                            item.position.boundingBox.min.y += step
                            item.position.transform.translation.y = -item.position.boundingBox.min.y
                        }.buttonStyle(.borderedProminent)
                    }
                    .padding(12)
                    .background(.windowBackground)
                    .cornerRadius(8)
                    .offset(y: -offset)
                }
            }
            HStack {
                ZStack(alignment: .bottomTrailing) {
                    PizzaSceneView(
                        scene: scene,
                        cameraMode: .z,
                        modelPosition: $item.position)
                    
                    HStack(spacing: 24) {
                        HStack {
                            Button(action: {
                                item.position.transform.rotation.z += step
                                item.position.boundingBoxOrientation.z -= step
                            }, label: {
                                Image(systemName: "arrow.counterclockwise")
                            }).buttonStyle(.borderedProminent)
                            
                            Button(action: {
                                item.position.transform.rotation.z -= step
                                item.position.boundingBoxOrientation.z += step
                            }, label: {
                                Image(systemName: "arrow.clockwise")
                            }).buttonStyle(.borderedProminent)
                        }
                    }
                    .padding(12)
                    .background(.windowBackground)
                    .cornerRadius(8)
                    .offset(x: -offset, y: -offset)
                }
                
                ZStack(alignment: .bottomTrailing) {
                    PizzaSceneView(
                        scene: scene,
                        cameraMode: .free,
                        modelPosition: $item.position)
                    
                    HStack {
                        Button(action: {
                            previewAction()
                        }, label: {
                            Image(systemName: "circle.dotted.and.circle")
                        })
                        .controlSize(.extraLarge)
                        .buttonStyle(.bordered)
                        
                        Button("Render") {
                            renderAction()
                        }
                        .controlSize(.extraLarge)
                        .buttonStyle(.borderedProminent)
                    }
                    .padding(12)
                    .background(.windowBackground)
                    .cornerRadius(8)
                    .offset(x: -offset, y: -offset)
                }
            }
        }
    }
}
