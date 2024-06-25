import SwiftUI

struct DetailView: View {
    @Binding var item: Item
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    @State var mode: Photogrammetry.Mode {
        didSet {
            url = item.url(for: mode)
        }
    }
    
    @State private var url: URL
    @State private var preview: PizzaScene
    @State private var previewAligned: PizzaScene
    @State private var result: PizzaScene
    
    init(item: Binding<Item>,
         renderAction: @escaping () -> Void,
         previewAction: @escaping () -> Void) {
        self._item = item
        
        let mode = item.wrappedValue.mode
        self.mode = mode
        self.url = item.wrappedValue.url(for: mode)
        self.renderAction = renderAction
        self.previewAction = previewAction
        
        self.preview = PizzaScene(url: item.wrappedValue.previewDestination)
        self.previewAligned = PizzaScene(url: item.wrappedValue.previewAlignedDestination)
        self.result = PizzaScene(url: item.wrappedValue.resultDestination)
    }
    
    var body: some View {
        HStack {
            switch mode {
            case .processing:
                ModelProgressView(item: item, retryAction: { _ in })
                
            case .preview:
                PizzaSceneGrid(scene: preview, item: $item)
                    .frame(minWidth: 800, minHeight: 500)
                    .padding(.bottom, 20)
                
                ConfigurationView(boundingBox: $item.boundingBox,
                                  transform: $item.transform,
                                  boundingBoxOrientation: $item.boundingBoxOrientation,
                                  renderAction: renderAction,
                                  previewAction: previewAction)
                .padding()
                
            case .previewAligned:
                PizzaSceneView(scene: previewAligned, cameraMode: .free, boundingBox: .constant(.zero), boundingBoxOrientation: .constant(.default), transform: $item.resultTransform)
                
            case .result:
                HStack {
                    PizzaSceneView(scene: result, cameraMode: .free, boundingBox: .constant(.zero), boundingBoxOrientation: .constant(.default), transform: $item.resultTransform)
                    
                    TransformSetupView(transform: $item.resultTransform)
                        .padding()
                }
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
    @Binding var boundingBoxOrientation: Coord4
    
    var renderAction: () -> Void
    var previewAction: () -> Void
    
    var body: some View {
        VStack(alignment: .leading) {
            BoundingBoxSetupView(
                boundingBox: $boundingBox,
                boundingBoxOrientation: $boundingBoxOrientation)
            
            TransformSetupView(transform: $transform)
                .padding(.bottom, 40)
            
            Button(action: previewAction) {
                Text("Preview")
                    .frame(width: 160)
            }
            .controlSize(.extraLarge)
            .buttonStyle(.borderedProminent)
            
            Button(action: renderAction) {
                Text("Render")
                    .frame(width: 160)
            }
            .controlSize(.extraLarge)
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
            
            SingleValueView(title: "X", value: $transform.translation.x)
            SingleValueView(title: "Y", value: $transform.translation.y)
            SingleValueView(title: "Z", value: $transform.translation.z)
            
            Text("Rotation")
                .font(.headline)
                .padding(.top, 20)
            SingleValueView(title: "X", value: $transform.rotation.x)
            SingleValueView(title: "Y", value: $transform.rotation.y)
            SingleValueView(title: "Z", value: $transform.rotation.z)
        }
    }
}

struct BoundingBoxSetupView: View {
    @Binding var boundingBox: BoundingBox
    @Binding var boundingBoxOrientation: Coord4
    
    let step: CGFloat = 0.005
    
    var body: some View {
        Text("Box")
            .font(.headline)
        
        VStack(alignment: .trailing) {
            InputView(
                title: "Top",
                value: $boundingBox.max.y,
                increaseValue: {
                    boundingBox.max.y += step
                }, decreaseValue: {
                    boundingBox.max.y -= step
                })
            
            InputView(
                title: "Bottom",
                value: $boundingBox.min.y,
                increaseValue: {
                    boundingBox.min.y += step
                }, decreaseValue: {
                    boundingBox.min.y -= step
                })
            
            InputView(
                title: "Width",
                value: .constant(boundingBox.width),
                increaseValue: {
                    boundingBox.min.x -= step
                    boundingBox.max.x += step
                }, decreaseValue: {
                    boundingBox.min.x += step
                    boundingBox.max.x -= step
                })
            
            InputView(
                title: "Length",
                value: .constant(boundingBox.length),
                increaseValue: {
                    boundingBox.min.z -= step
                    boundingBox.max.z += step
                }, decreaseValue: {
                    boundingBox.min.z += step
                    boundingBox.max.z -= step
                })
            
            Text("Rotation")
                .font(.headline)
                .padding(.top, 20)
            SingleValueView(title: "X", value: $boundingBoxOrientation.x)
            SingleValueView(title: "Y", value: $boundingBoxOrientation.y)
            SingleValueView(title: "Z", value: $boundingBoxOrientation.z)
            
        }.padding(.bottom, 40)
    }
}

enum CameraMode {
    case x, y, z, free
}

struct SingleValueView: View {
    let title: String
    @Binding var value: CGFloat
    
    var body: some View {
        InputView(
            title: title,
            value: $value,
            increaseValue: {
                value += 0.01
            }, decreaseValue: {
                value -= 0.01
            })
    }
}

struct InputView: View {
    let title: String
    @Binding var value: CGFloat
    
    var increaseValue: () -> Void
    var decreaseValue: () -> Void
    
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
                increaseValue()
            }
            Button("-") {
                decreaseValue()
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
