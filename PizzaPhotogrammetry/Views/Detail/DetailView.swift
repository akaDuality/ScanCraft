import SwiftUI

struct DetailView: View {
    @Binding var item: Item
    
    var renderAction: () -> Void
    
    @State var mode: Photogrammetry.Mode {
        didSet {
            url = item.url(for: mode)
        }
    }
    
    @State private var url: URL
    @State private var preview: PizzaScene
    @State private var result: PizzaScene
    
    init(item: Binding<Item>, renderAction: @escaping () -> Void) {
        self._item = item
        
        let mode = item.wrappedValue.mode
        self.mode = mode
        self.url = item.wrappedValue.url(for: mode)
        self.renderAction = renderAction
        
        self.preview = PizzaScene(url: item.wrappedValue.previewDestination)
        self.result = PizzaScene(url: item.wrappedValue.resultDestination)
    }
    
    var body: some View {
        HStack {
            if mode == .result {
                HStack {
                    PizzaSceneView(scene: result, cameraMode: .free, boundingBox: .constant(.zero), transform: $item.resultTransform)
                    TransformSetupView(transform: $item.resultTransform)
                }
            } else {
                PizzaSceneGrid(scene: preview, item: $item)
                    .frame(minWidth: 800, minHeight: 500)
                    .padding(.bottom, 20)
                
                ConfigurationView(boundingBox: $item.boundingBox,
                                  transform: $item.transform,
                                  renderAction: renderAction)
                .padding()
            }
        }.toolbar {
            ToolbarItem(placement: .principal) {
                Picker("Preview mode", selection: $mode) {
                    ForEach(Photogrammetry.Mode.allCases, id: \.self) { mode in
                        Text(mode.name)
                    }
                }
                .pickerStyle(.segmented)
                .onChange(of: mode) { oldValue, newValue in
                    url = $item.wrappedValue.url(for: mode)
                }

            }
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
            BoundingBoxSetupView(boundingBox: $boundingBox)
            TransformSetupView(transform: $transform)
            
            Button("Render") {
                renderAction()
            }
            .controlSize(.large)
            .buttonStyle(.borderedProminent)
        }
    }
}

struct TransformSetupView: View {
    @Binding var transform: Item.Transform
    var body: some View {
        VStack(alignment: .leading) {
            Text("Translation")
                .font(.headline)
            InputView(title: "X", value: $transform.translation.x)
            InputView(title: "Y", value: $transform.translation.y)
            InputView(title: "Z", value: $transform.translation.z)
            
            Text("Rotation")
                .font(.headline)
                .padding(.top, 20)
            InputView(title: "Y", value: $transform.rotation.y)
            InputView(title: "X", value: $transform.rotation.x)
            InputView(title: "Z", value: $transform.rotation.z)
        }
    }
}

struct BoundingBoxSetupView: View {
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

//#Preview {
//    DetaliView(
//        url: Bundle.main.url(forResource: "Model", withExtension: "usdz")!,
//        boundingBox: .constant(BoundingBox(
//            min: Coord(x: -0.117, y: 0.11, z: -0.12),
//            max: Coord(x: 0.117, y: 0.13, z: 0.12)
//        )), transform: .constant(.zero), renderAction: {})
//}
