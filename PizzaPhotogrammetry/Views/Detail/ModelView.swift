import SwiftUI

struct ModelView: View {
    let url: URL
    @Binding var boundingBox: BoundingBox
    @Binding var transform: Item.Transform
    
    var renderAction: () -> Void
    
    var body: some View {
        HStack {
            // TODO: Keep camera position on change
            VStack {
                HStack {
                    PizzaSceneView(url: url, cameraMode: .x, boundingBox: $boundingBox, transform: $transform)
                    PizzaSceneView(url: url, cameraMode: .y, boundingBox: $boundingBox, transform: $transform)
                }
                HStack {
                    PizzaSceneView(url: url, cameraMode: .z, boundingBox: $boundingBox, transform: $transform)
                    PizzaSceneView(url: url, cameraMode: .free, boundingBox: $boundingBox, transform: $transform)
                }
            }.frame(minWidth: 800, minHeight: 500)
                .padding(.bottom, 20)
            
            ConfigurationView(boundingBox: $boundingBox, transform: $transform, renderAction: renderAction)
                .padding()
        }
    }
}

struct ConfigurationView: View {
    
    @Binding var boundingBox: BoundingBox
    @Binding var transform: Item.Transform
        
    var renderAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            Text("Box")
                .font(.headline)
            SizeChangeView(boundingBox: $boundingBox)
            
            //                Text("Minimum")
            //                InputView(title: "Min X", value: $boundingBox.min.x)
            //                InputView(title: "Min Y", value: $boundingBox.min.y)
            //                InputView(title: "Min Z", value: $boundingBox.min.z)
            //                    .padding(.bottom, 20)
            //
            //                Text("Maximum")
            //                InputView(title: "Max X", value: $boundingBox.max.x)
            //                InputView(title: "Max Y", value: $boundingBox.max.y)
            //                InputView(title: "Max Z", value: $boundingBox.max.z)
            
            
            // TODO: Add Tranform
            Text("Translation")
                .font(.headline)
            InputView(title: "X", value: $transform.translation.x)
            InputView(title: "Y", value: $transform.translation.y)
            InputView(title: "Z", value: $transform.translation.z)
            
            Text("Rotation")
                .font(.headline)
            InputView(title: "X", value: $transform.rotation.x)
            InputView(title: "Y", value: $transform.rotation.y)
            InputView(title: "Z", value: $transform.rotation.z)
            
            Button("Render") {
                renderAction()
            }
            
        }
    }
}

struct SizeChangeView: View {
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
    ModelView(
        url: Bundle.main.url(forResource: "Model", withExtension: "usdz")!,
        boundingBox: .constant(BoundingBox(
            min: Coord(x: -0.117, y: 0.11, z: -0.12),
            max: Coord(x: 0.117, y: 0.13, z: 0.12)
        )), transform: .constant(.zero), renderAction: {})
}
