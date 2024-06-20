import SwiftUI

struct DetaliView: View {
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
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
    }
}

struct SizeChangeView: View {
    @Binding var boundingBox: BoundingBox
    
    let step: CGFloat = 0.005
    
    var body: some View {
        HStack {
            Text("Width")
            Button("+") {
                boundingBox.min.x -= step
                boundingBox.max.x += step
            }
            
            Button("-") {
                boundingBox.min.x += step
                boundingBox.max.x -= step
            }
        }
        
        HStack {
            Text("Heigth")
            Button("+") {
                boundingBox.min.z -= step
                boundingBox.max.z += step
            }
            
            Button("-") {
                boundingBox.min.z += step
                boundingBox.max.z -= step
            }
        }
        
        HStack {
            Text("Top")
            Button("+") {
                boundingBox.max.y += step
            }
            
            Button("-") {
                boundingBox.max.y -= step
            }
        }
        
        HStack {
            Text("Bottom")
            Button("+") {
                boundingBox.min.y += step
            }
            
            Button("-") {
                boundingBox.min.y -= step
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
    DetaliView(
        url: Bundle.main.url(forResource: "Model", withExtension: "usdz")!,
        boundingBox: .constant(BoundingBox(
            min: Coord(x: -0.117, y: 0.11, z: -0.12),
            max: Coord(x: 0.117, y: 0.13, z: 0.12)
        )), transform: .constant(.zero), renderAction: {})
}
