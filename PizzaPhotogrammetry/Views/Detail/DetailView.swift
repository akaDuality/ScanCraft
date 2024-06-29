import SwiftUI

struct DetailView: View {
    @Binding var item: Item
    var progress: Processing?
    
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
         progress: Processing?,
         renderAction: @escaping () -> Void,
         previewAction: @escaping () -> Void) {
        self._item = item
        self.progress = progress
        
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
                if let progress {
                    ModelProgressView(item: item, progress: progress, retryAction: { _ in })
                } else {
                    EmptyView()
                }
                
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


enum CameraMode {
    case x, y, z, free
}

//#Preview {
//    DetaliView(
//        url: Bundle.main.url(forResource: "Model", withExtension: "usdz")!,
//        boundingBox: .constant(BoundingBox(
//            min: Coord(x: -0.117, y: 0.11, z: -0.12),
//            max: Coord(x: 0.117, y: 0.13, z: 0.12)
//        )), transform: .constant(.zero), renderAction: {})
//}
